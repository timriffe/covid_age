
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

## Source Website <- "https://www.folkhalsomyndigheten.se/smittskydd-beredskap/utbrott/aktuella-utbrott/covid-19/statistik-och-analyser/bekraftade-fall-i-sverige/

## MK: 31 March 2023: Since 30 March 2023, data will be presented here: https://www.folkhalsomyndigheten.se/fall-covid-19/
## These data are weekly data since 2022, so it is different from what we have. 


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
  mutate(Code = "SE",
      #   Date = ddmmyyyy(Date),
         AgeInt = as.character(AgeInt)) %>% 
  filter(Measure %in% c("Cases","Deaths"))

last_date_drive <- db_drive %>% 
  filter(Measure %in% c("Cases","Deaths")) %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

# 3. Process data ---------- 
# process data and upload it only if the reported date is more recent than the date in Drive

if (date_f > last_date_drive){
  
  
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
           Date = ddmmyyyy(date_f),
           AgeInt = case_when(
             Age == "TOT" | Age == "UNK" ~ ""
             , Age == "90" ~ "15"
             , TRUE ~ "10"
           ), Metric = "Count"
    ) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  data_source_zip <-  data_source
  
 out <- bind_rows(db_drive, out_cases) %>% 
      sort_input_data()
 
 
 # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 # uploading database to Google Drive 
 # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 write_rds(out, paste0(dir_n, ctr, ".rds"))
 
 log_update(pp = "SwedenEpi", N = nrow(out))
    

} else if (date_f == last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = "SwedenEpi", N = 0)
}


  
  
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
  

# END#
