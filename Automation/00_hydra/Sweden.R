
# 1. Preamble ---------------

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "Sweden"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# data from drive 
# rubric_i <- get_input_rubric() %>% filter(Short == "SE")
# ss_i     <- rubric_i %>% dplyr::pull(Sheet)
# ss_db    <- rubric_i %>% dplyr::pull(Source)
# 
# print(paste0("Starting data retrieval for Sweden..."))
# 
# # ~~~~~~~~~~~~~~~~~~~
# When using it daily
# ~~~~~~~~~~~~~~~~~~~

# 2. Is there new cases/deaths data? =================

data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&deaths_",today(), ".xlsx")

url <- "https://www.arcgis.com/sharing/rest/content/items/b5e7488e117749c19881cce45db13f7e/data"
httr::GET(url, write_disk(data_source, overwrite = T))

# date from the data directly, last reported date in the sheet 'Antal per dag region'

date_f <- read_xlsx(data_source, sheet = 1) %>% 
  dplyr::pull(Statistikdatum) %>% 
  max() %>% 
  ymd()

# reading data from Drive and last date entered 
db_drive <-  read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Code = "SE")

last_date_drive <- db_drive %>% 
  filter(Measure %in% c("Cases","Deaths")) %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

# 3. Process data ---------- 
# process data and upload it only if the reported date is more recent than the date in Drive

if (date_f > last_date_drive){
  
  date <- paste(sprintf("%02d", day(date_f)),
                sprintf("%02d", month(date_f)),
                year(date_f), sep = ".")
  
  # 3.1. Cases and deaths ==========
  
  db_sex <- read_xlsx(data_source, sheet = 5)
  db_age <- read_xlsx(data_source, sheet = 6)
  
  # Get data by sex
  
  db_s2 <- db_sex %>% 
    # rename(Sex = K?n,
    rename(
      Sex = starts_with("K"),
      Cases = Totalt_antal_fall,
      Deaths = Totalt_antal_avlidna
    ) %>% 
    mutate(
      Sex = case_when(Sex == "Man" ~ "m",
                      Sex == "Kvinna" ~ "f",
                      Sex == "Uppgift saknas" ~ "UNK"),
      Age = "TOT"
    ) %>% 
    select(Sex, Age, Cases, Deaths)
  
  # Get data by age
  
  db_a2 <- db_age %>% 
    rename(
      Cases = Totalt_antal_fall,
      Deaths = Totalt_antal_avlidna
      , Age = ends_with("ldersgrupp")
    ) %>% 
    # mutate(Age = str_sub(?ldersgrupp, 7, 8),
    mutate(
      Age = str_sub(Age, 7, 8),
      Age = case_when(Age == "0_" ~ "0",
                      Age == "t " ~ "UNK",
                      TRUE ~ Age),
      Sex = "b"
    ) %>% 
    select(Sex, Age, Cases, Deaths)
  
  out_cases <- 
    bind_rows(db_s2, db_a2) %>% 
    gather(Cases, Deaths, key = Measure, value = Value) %>% 
    mutate(Country = "Sweden",
           Region = "All",
           Code = paste0("SE"),
           Date = date,
           AgeInt = case_when(
             Age == "TOT" | Age == "UNK" ~ ""
             , Age == "90" ~ "15"
             , TRUE ~ "10"
           ), Metric = "Count"
    ) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  data_source_zip <-  data_source
  
  # 3.2. Vaccines ================
  
  # First, see if there is new vaccine data
  
  data_source_vac <- paste0(dir_n, "Data_sources/", ctr, "/vaccination_",today(), ".xlsx")
  
  url_vac <- "https://fohm.maps.arcgis.com/sharing/rest/content/items/fc749115877443d29c2a49ea9eca77e9/data"
  httr::GET(url_vac, write_disk(data_source_vac, overwrite = T))
  
  
  # date_f_vac <- read_xlsx(data_source_vac, sheet = 1) %>% 
  #   dplyr::pull(Statistikdatum) %>% 
  #   max() %>% 
  #   ymd()
  
  # In vaccine file, the date is not actually stored in 
  # any of the sheets, but, at the time pf writing (20210209)
  # it is only stored in the sheet name
  
  date_f_vac_temp <- excel_sheets(data_source_vac)
  date_f_vac_temp <- date_f_vac_temp[grepl("[0-9]{4}$", date_f_vac_temp)]
  date_f_vac_temp <- trimws(gsub("FOHM", "", date_f_vac_temp))
  
  date_f_vac_temp_split <- unlist(strsplit(tolower(date_f_vac_temp), " "))
  
  # Update 20210520
  # They changed they way that dates are recorded, now the month is in Swedish
  
  
  # lookup_swe <- 1:12
  # names(lookup_swe) <- 
  #   c("januari", "februari", "mars", "april", "maj", "juni", "juli", "augusti"
  #     , "september", "oktober", "november", "december")
  
  # Update 20210609
  # Apparently, the swedish month name is abbreviated to three-letters. 
  # This is my guess of what the future months will be:
  
  lookup_swe <- 1:12
  names(lookup_swe) <- 
    c("jan", "feb", "mar", "apr", "maj", "jun", "jul", "aug"
      , "sep", "okt", "nov", "dec")
    
  date_f_vac_temp_split[2] <- lookup_swe[date_f_vac_temp_split[2]]
  date_f_vac_temp2 <- paste(date_f_vac_temp_split, collapse = "/")
  date_f_vac <- dmy(date_f_vac_temp2)
  
  last_date_drive_vac <- db_drive %>% 
    filter(Measure %in% "Vaccination1") %>% 
    mutate(date_f = dmy(Date)) %>% 
    dplyr::pull(date_f) %>% 
    max()
  
  update_vaccines <- date_f_vac > last_date_drive_vac
  
  if (update_vaccines){
  print("New vaccination data available - updating..")  
    
    vac_sex <- read_xlsx(data_source_vac, sheet = 7)
    vac_age <- read_xlsx(data_source_vac, sheet = 4)
    vacc3_age <- read_xlsx(data_source_vac, sheet = 5)
    vacc4_age <- read_xlsx(data_source_vac, sheet = 6)
    
    # Get data by sex
    
    vac_s2 <-
      vac_sex %>% 
      select(
        Sex = starts_with("K")
        , Value = `Antal vaccinerade`
        # Changed on 20210423 by Diego after codes changed
        # , Measure = Dosnummer
        , Measure = Vaccinationsstatus
      ) %>% 
      # filter(!grepl("^t", Sex, ignore.case = T)) %>% 
      mutate(
        Sex = case_when(
          grepl("^m", Sex, ignore.case = T) ~ "m",
          grepl("^k", Sex, ignore.case = T) ~ "f"
          # grepl("^t", Sex, ignore.case = T) ~ "UNK"
        ) 
        , Measure = case_when(
          # Changed on 20210423 by Diego after codes changed
          grepl("Minst 1 dos", Measure, ignore.case = T) ~ "Vaccination1"
          , grepl("Minst 2 doser", Measure, ignore.case = T) ~ "Vaccination2"
          # grepl("1", Measure, ignore.case = T) ~ "Vaccination1"
          # , grepl("2", Measure, ignore.case = T) ~ "Vaccination2"
        )
        , Age = "TOT"
        , AgeInt = ""
        # Add empty row for UNK
        , Sex = ifelse(is.na(Sex), "UNK", Sex)
        , AgeInt = ifelse(Sex == "UNK", "", AgeInt)
        , Value = ifelse(Sex == "UNK", 0, Value)
      ) %>% 
      select(Sex, Age, AgeInt, Measure, Value) %>% 
      arrange(Sex)
    
    # Get data by age
    
    vac_a2 <-
      vac_age %>% 
      filter(grepl("Sverige", Region)) %>% 
      select(
        Value = contains("antal")
        # , Measure = Dosnummer
        , Measure = Vaccinationsstatus
        , Age = ends_with("ldersgrupp")
      ) %>% 
      # filter(!grepl("^Total", Age)) %>% 
      mutate(
        Measure = case_when(
          # grepl("1", Measure, ignore.case = T) ~ "Vaccination1"
          # , grepl("2", Measure, ignore.case = T) ~ "Vaccination2"
          grepl("Minst 1 dos", Measure, ignore.case = T) ~ "Vaccination1"
          , grepl("Minst 2 doser", Measure, ignore.case = T) ~ "Vaccination2"
        )
        , Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
        , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
        , Age = as.character(Age_low)
        , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
        , Sex = "b"
        # Add empty row for UNK
        , Age = ifelse(is.na(Age), "UNK", Age)
        , AgeInt = ifelse(Age == "UNK", "", AgeInt)
        , Value = ifelse(Age == "UNK", 0, Value)
      ) %>%  
      select(Sex, Age, AgeInt, Measure, Value)
    
    
    small_ages <- vac_a2 %>% 
         filter(Age == "12") %>% 
         mutate(Age = "0",
                AgeInt = 12L,
                Value = 0)
    vac_a2 <- rbind(vac_a2, small_ages)
    
    
    #data by age for third vaccination
    
    vac_a3 <-
      vacc3_age %>% 
      filter(grepl("Sverige", Region)) %>% 
      select(
        Value = contains("antal")
        # , Measure = Dosnummer
        , Measure = Vaccinationsstatus
        , Age = ends_with("ldersgrupp")
      ) %>% 
      # filter(!grepl("^Total", Age)) %>% 
      mutate(
        Measure = "Vaccination3", 
        Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
        , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
        , Age = as.character(Age_low)
        , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
        , Sex = "b"
        # Add empty row for UNK
        , Age = ifelse(is.na(Age), "UNK", Age)
        , AgeInt = ifelse(Age == "UNK", "", AgeInt)
        , Value = ifelse(Age == "UNK", 0, Value)
      ) %>%  
      select(Sex, Age, AgeInt, Measure, Value)
    
    small_ages <- vac_a3 %>% 
      filter(Age == "18") %>% 
      mutate(Age = "0",
             AgeInt = 18L,
             Value = 0)
    vac_a3 <- rbind(vac_a3, small_ages)
    
    
    #data by age for fourth vaccination
    
    vac_a4 <-
      vacc4_age %>% 
      filter(grepl("Sverige", Region)) %>% 
      select(
        Value = contains("antal")
        # , Measure = Dosnummer
        , Measure = Vaccinationsstatus
        , Age = ends_with("ldersgrupp")
      ) %>% 
      # filter(!grepl("^Total", Age)) %>% 
      mutate(
        Measure = "Vaccination4", 
        Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
        , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
        , Age = as.character(Age_low)
        , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
        , Sex = "b"
        # Add empty row for UNK
        , Age = ifelse(is.na(Age), "UNK", Age)
        , AgeInt = ifelse(Age == "UNK", "", AgeInt)
        , Value = ifelse(Age == "UNK", 0, Value)
      ) %>%  
      select(Sex, Age, AgeInt, Measure, Value)
    
    small_ages <- vac_a4 %>% 
      filter(Age == "80") %>% 
      mutate(Age = "0",
             AgeInt = 80L,
             Value = 0)
    vac_a4 <- rbind(vac_a4, small_ages)
    
    
    
    out_vac <-
      bind_rows(vac_s2, vac_a2, vac_a3, vac_a4) %>% 
      mutate(Country = "Sweden",
             Region = "All",
             Code = paste0("SE"),
             Date = date,
             Metric = "Count"
      ) %>% 
      select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
      arrange(Measure)
  
    out <- bind_rows(out_cases, out_vac)  
    
    data_source_zip <-  c(data_source_zip, data_source_vac)
    
  } else if(!update_vaccines){
    out <- out_cases
  }
  

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # uploading database to Google Drive 
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  write_rds(db_drive, paste0(dir_n, ctr, ".rds"))
  
  log_update(pp = "Sweden", N = nrow(out))
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Uploading metadata to N Drive  =====
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  zipname <- paste0(dir_n, 
                    "Data_sources/", 
                    ctr,
                    "/", 
                    ctr,
                    "_data_",
                    today(), 
                    ".zip")
  
  zipr(zipname, 
       data_source_zip, 
       recurse = TRUE, 
       compression_level = 9,
       include_directories = TRUE)
  
  # clean up file chaff
  file.remove(data_source_zip)
  # file.remove(data_source_vac)
  
} else if (date_f == last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = "Sweden", N = 0)
}




#temporal
# db_drive <- get_country_inputDB("SE")
# 
# 
# small_ages1 <- db_drive %>% 
#   filter(Measure == "Vaccination1" |
#            Measure == "Vaccination2") %>% 
#   mutate(Date = dmy(Date)) %>% 
#   filter(Date >= "2021-10-20",
#          Age == "12") %>% 
#   mutate(Age = "0",
#          AgeInt = 12L,
#          Value = 0,
#          Date = ddmmyyyy(Date))
# 
# 
# small_ages2 <- db_drive %>% 
#   filter(Measure == "Vaccination1" |
#            Measure == "Vaccination2") %>% 
#   mutate(Date = dmy(Date)) %>% 
#   filter(Date <= "2021-10-19",
#          Date >= "2021-09-08",
#          Age == "16") %>% 
#   mutate(Age = "0",
#          AgeInt = 16L,
#          Value = 0,
#          Date = ddmmyyyy(Date))
# 
# 
# small_ages3 <- db_drive %>% 
#   filter(Measure == "Vaccination1" |
#            Measure == "Vaccination2") %>% 
#   mutate(Date = dmy(Date)) %>% 
#   filter(Date <= "2021-09-07",
#          Age == "18") %>% 
#   mutate(Age = "0",
#          AgeInt = 18L,
#          Value = 0,
#          Date = ddmmyyyy(Date))
# 
# db_drive <- rbind(db_drive, small_ages1, small_ages2, small_ages3) %>% 
#   sort_input_data()
# 

