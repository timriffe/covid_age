
# 1. Preamble ---------------

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "SwedenVax"
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

# 3.2. Vaccines ================

## Source Epi website <- "https://www.folkhalsomyndigheten.se/smittskydd-beredskap/utbrott/aktuella-utbrott/covid-19/statistik-och-analyser/bekraftade-fall-i-sverige/"

## Vax website <- "https://www.folkhalsomyndigheten.se/folkhalsorapportering-statistik/statistikdatabaser-och-visualisering/vaccinationsstatistik/statistik-for-vaccination-mot-covid-19/"  

# First, see if there is new vaccine data
  
data_source_vac <- paste0(dir_n, "Data_sources/", ctr, "/vaccination_",today(), ".xlsx")
  
# url_vac <- "https://fohm.maps.arcgis.com/sharing/rest/content/items/fc749115877443d29c2a49ea9eca77e9/data"
# httr::GET(url_vac, write_disk(data_source_vac, overwrite = T))
  
url_vax <- "https://www.folkhalsomyndigheten.se/folkhalsorapportering-statistik/statistikdatabaser-och-visualisering/vaccinationsstatistik/statistik-for-vaccination-mot-covid-19/"

excel_link <- scraplinks(url_vax) |> 
  filter(str_detect(url, ".xlsx")) |> 
  mutate(url = paste0("https://www.folkhalsomyndigheten.se", url)) |> 
  dplyr::pull(url)
  

httr::GET(excel_link, write_disk(data_source_vac, overwrite = T))

# date_f_vac <- read_xlsx(data_source_vac, sheet = 1) %>%
#     dplyr::pull(Statistikdatum) %>%
#     max() %>%
#     ymd()
  
  # In vaccine file, the date is not actually stored in 
  # any of the sheets, but, at the time pf writing (20210209)
  # it is only stored in the sheet name
  
  date_f_vac_temp <- excel_sheets(data_source_vac)
  date_f_vac_temp <- date_f_vac_temp[grepl("[0-9]{4}$", date_f_vac_temp)]
  date_f_vac_temp <- trimws(gsub("Information", "", date_f_vac_temp))
  
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
  
  db_drive <-  read_rds(paste0(dir_n, ctr, ".rds")) %>% 
    mutate(AgeInt = case_when(Measure %in% c("Vaccination4", "Vaccination5") & Age == "65" ~ "5",
                              TRUE ~ AgeInt),
           AgeInt = case_when(Measure %in% c("Vaccination4") & 
                                Age == "65" & Date %in% c("07.04.2022", "14.04.2022") ~ "15",
                              Age == "12" ~ "4",
                              Age == "16" ~ "2",
                              Age == "18" ~ "12",
                              TRUE ~ AgeInt))
  
  last_date_drive_vac <- db_drive %>% 
    mutate(date_f = dmy(Date)) %>% 
    dplyr::pull(date_f) %>% 
    max()
  
  update_vaccines <- date_f_vac > last_date_drive_vac
  
  if (update_vaccines){
  print("New vaccination data available - updating..")  
    # MK-Update: (27.06.2022)
    # Since 2022.06.23, Sweden updated their way of publishing vaccination data: ##
    # one sheet for 1:3 doses, 1 sheet for 4th dose #
    # so for the 3 doses sheet: vac_age, and for the fourth: vacc4_age #
    # MK-Update: (04.10.2022):
    # Sweden added sheet for 5th dose, 4th dose separately by age group. so I read all sheets first, 
    ## merge all ages-related tables in one df, then process. 
    
    ## MK: 03.04.2023: Sweden changed some definitons and the data published accordingly. 
    ## Vaccinated with at least 3 doses is for; those which last dose is after 01.03.2023, i am not sure this follows the same data as previous, 
    ## so I kept only first and second doses for now. 
    ## no data anymore on vaccination 4 & 5. 
    
   # vac_sex <- read_xlsx(data_source_vac, sheet = "Vaccinerade kön")
    vac_age <- read_xlsx(data_source_vac, sheet = "Åldersstatistik dos 1 o 2 LÅST")
    # vacc_3 <- read_xlsx(data_source_vac, sheet = "Åldersstatistik dos 3")
    # vacc_4 <- read_xlsx(data_source_vac, sheet = "Dos 4 per åldersgrupp")
    # vacc_5 <- read_xlsx(data_source_vac, sheet = "Dos 5 per åldersgrupp")
    # vac_age <- bind_rows(vacc_1_3, vacc_4, vacc_5)
    
   ## vac_age <- read_xlsx(data_source_vac, sheet = 5)
  ##  vacc3_age <- read_xlsx(data_source_vac, sheet = 5)
  ##  vacc4_age <- read_xlsx(data_source_vac, sheet = 6)
    
    # Get data by sex
    
    # vac_s2 <-
    #   vac_sex %>%
    #   select(
    #     Sex = starts_with("K")
    #     , Value = contains("antal")
    #     # Changed on 20210423 by Diego after codes changed
    #     # , Measure = Dosnummer
    #     , Measure = ends_with("status")
    #   ) %>%
    #   # filter(!grepl("^t", Sex, ignore.case = T)) %>%
    #   mutate(
    #     Sex = case_when(str_detect(Sex, "M") ~ "m",
    #                     str_detect(Sex, "Kv") ~ "f",
    #                     str_detect(Sex, "Tot") ~ "b"),
    #     Measure = case_when(Measure %in% c("1",
    #                                        "Dos 1",
    #                                        "Minst 1 dos") ~ "Vaccination1",
    #                         Measure %in% c("2", 
    #                                        "Minst 2 doser",
    #                                        "2 doser",
    #                                        "Dos 2",
    #                                        "Färdigvaccinerade") ~ "Vaccination2")
    #     , Age = "TOT"
    #     , AgeInt = ""
    #     # Add empty row for UNK
    #     # , Sex = ifelse(is.na(Sex), "UNK", Sex)
    #     # , AgeInt = ifelse(Sex == "UNK", "", AgeInt)
    #     # , Value = ifelse(Sex == "UNK", 0, Value)
    #   ) %>%
    #   select(Sex, Age, AgeInt, Measure, Value) %>%
    #   arrange(Sex)

    # Get data by age
    
    vac_a2 <-
      vac_age %>% 
      filter(Region == "| Sverige |") %>% 
    #  filter(grepl("| Sverige |", Region)) %>% 
      select(
        Value = contains("antal")
        # , Measure = Dosnummer
        , Measure = ends_with("status")
        , Age = ends_with("ldersgrupp")
      ) %>% 
      dplyr::filter(!str_detect(Age, "Totalt 18+")) %>% 
      dplyr::mutate(Measure = case_when(Measure %in% c("1",
                                                       "Dos 1",
                                                       "1 dos",
                                                       "Minst 1 dos") ~ "Vaccination1",
                                        Measure %in% c("2", 
                                                       "Minst 2 doser",
                                                       "2 doser",
                                                       "Dos 2",
                                                       "Färdigvaccinerade") ~ "Vaccination2",
                                        Measure %in% c("Minst 3 doser", "3 doser") ~ "Vaccination3",
                                        Measure %in% c("4 doser") ~ "Vaccination4",
                                        Measure %in% c("5 doser") ~ "Vaccination5"),
                    Age = case_when(Age == "Totalt" ~ "TOT",
                                    TRUE ~ str_extract(Age, "^[0-9]{2}")),
                    # Age_low = as.numeric(str_extract(Age, "^[0-9]{2}")),
                    # Age_high = as.numeric(str_extract(Age, "[0-9]{2}$")),
                    Age = as.character(Age),
                    #  Age = ifelse(is.na(Age), "UNK", Age),
                    AgeInt = case_when(Age == "12" ~ 4L,
                                       Age == "16" ~ 2L,
                                       Age == "18" ~ 12L,
                                       Age == "90" ~ 15L,
                                       #    Age == "UNK" ~ NA_integer_,
                                       TRUE ~ 10L),
                    Sex = "b",
                    AgeInt = as.character(AgeInt)
      )%>%  
      select(Sex, Age, AgeInt, Measure, Value)
    
    out_vac <-
    #  bind_rows(vac_s2, vac_a2) 
    vac_a2 %>% 
                #vac_a4) %>% 
      mutate(Country = "Sweden",
             Region = "All",
             Code = paste0("SE"),
             Date = ddmmyyyy(date_f_vac),
             Metric = "Count"
      ) %>% 
      select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
      arrange(Measure)
  
    out <- bind_rows(db_drive, out_vac) %>% 
      sort_input_data()
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # uploading database to Google Drive 
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    write_rds(out, paste0(dir_n, ctr, ".rds"))
    
   # log_update(pp = "SwedenVax", N = nrow(out))
    
    
  }  else if (date_f_vac == last_date_drive_vac) {
    cat(paste0("no new updates so far, last date: ", date_f_vac))
   # log_update(pp = "SwedenVax", N = 0)
  }
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Uploading metadata to N Drive  =====
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  data_source_zip <-  c(data_source_vac)
  
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
 
### Historical Code =======================

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
# small_ages <- vac_a2 %>% 
#      filter(Age == "12") %>% 
#      mutate(Age = "0",
#             AgeInt = 12L,
#             Value = 0)
#vac_a2 <- rbind(vac_a2, small_ages)


# #data by age for third vaccination
# 
# vac_a3 <-
#   vacc3_age %>% 
#   filter(grepl("| Sverige |", Region)) %>% 
#   select(
#     Value = contains("antal")
#     # , Measure = Dosnummer
#     , Measure = ends_with("status")
#     , Age = ends_with("ldersgrupp")
#   ) %>% 
#   # filter(!grepl("^Total", Age)) %>% 
#   mutate(
#     Measure = "Vaccination3", 
#     Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
#     , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
#     , Age = as.character(Age_low)
#     , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
#     , Sex = "b"
#     # Add empty row for UNK
#     , Age = ifelse(is.na(Age), "UNK", Age)
#     , AgeInt = ifelse(Age == "UNK", "", AgeInt)
#     , Value = ifelse(Age == "UNK", 0, Value)
#   ) %>%  
#   select(Sex, Age, AgeInt, Measure, Value)
# 
# small_ages <- vac_a3 %>% 
#   filter(Age == "18") %>% 
#   mutate(Age = "0",
#          AgeInt = 18L,
#          Value = 0)
# vac_a3 <- rbind(vac_a3, small_ages)
# 

#data by age for fourth vaccination

# vac_a4 <-
#   vacc4_age %>% 
#   filter(grepl("| Sverige |", Region)) %>% 
#   select(
#     Value = contains("antal")
#     # , Measure = Dosnummer
#     , Measure = ends_with("status")
#     , Age = ends_with("ldersgrupp")
#   ) %>% 
#   # filter(!grepl("^Total", Age)) %>% 
#   mutate(
#     Measure = case_when(Measure == "4 doser" ~ "Vaccination4"), 
#     Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
#     , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
#     , Age = as.character(Age_low)
#     , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
#     , Sex = "b"
#     # Add empty row for UNK
#     , Age = ifelse(is.na(Age), "UNK", Age)
#     , AgeInt = ifelse(Age == "UNK", "", AgeInt)
#     , Value = ifelse(Age == "UNK", 0, Value)
#   ) %>%  
#   select(Sex, Age, AgeInt, Measure, Value)
# 
# small_ages <- vac_a4 %>% 
#   filter(Age == "80") %>% 
#   mutate(Age = "0",
#          AgeInt = 80L,
#          Value = 0)
# vac_a4 <- rbind(vac_a4, small_ages)



