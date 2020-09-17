# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")


library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

print(paste0("Starting data retrieval for NYC..."))

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_NYC")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# reading data from Drive and last date entered 
db_drive <- get_country_inputDB("US_NYC")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()


# country <- "nyc"
# path_out <- paste0("U:/Projects/COVerAGE-DB/Data/",country,"/")

db_age <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/by-age.csv")
db_sex <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/by-sex.csv")
db_sum <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/summary.csv", col_names = F)
db_tests <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/tests.csv")
db_tested <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/tests-by-zcta.csv")

tests <- db_tests %>% 
  group_by() %>% 
  summarise(sum(TOTAL_TESTS))

tested <- db_tested %>% 
  group_by() %>% 
  summarise(sum(Total))

date_f <- db_sum %>% 
  filter(X1 == "DATE_UPDATED") %>% 
  separate(X2, c("m", "d")) %>% 
  mutate(date = ymd(paste("2020", m, d, sep = "/"))) %>% 
  dplyr::pull(date)

d <- paste(sprintf("%02d", day(date_f)),
              sprintf("%02d", month(date_f)),
              year(date_f), sep = ".")


if (date_f > last_date_drive){

  db_other <- tibble(Sex = "b",
                     Age = "TOT",
                     Measure = c("Probable deaths", "Tests", "Tested"),
                     Value = c(as.numeric(db_sum[4,2]), 
                               as.numeric(tests[1,1]),
                               as.numeric(tested[1,1])))
  
  db_a2 <- db_age %>% 
    mutate(Age = str_sub(AGE_GROUP, 1, 2),
           Age = case_when(Age == "0-" ~ "0",
                           Age == "Ci" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b") %>% 
    rename(Cases = CASE_COUNT,
           Deaths = DEATH_COUNT) %>% 
    select(Sex, Age, Cases, Deaths)
  
  db_s2 <- db_sex %>% 
    rename(Sex = SEX_GROUP,
           Cases = CASE_COUNT,
           Deaths = DEATH_COUNT) %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           TRUE ~ "b"),
           Age = "TOT") %>% 
    select(Sex, Age, Cases, Deaths) %>% 
    filter(Sex != "b")
  
  db_all <- bind_rows(db_a2, db_s2) %>% 
    gather(Cases, Deaths, key = Measure, value = Value) %>% 
    bind_rows(db_other) %>%
    mutate(Country = "USA",
           Region = "NYC",
           Code = paste0("US_NYC", d),
           Date = d,
           AgeInt = case_when(Age == "0" ~ "18",
                              Age == "18" ~ "27",
                              Age == "45" ~ "20",
                              Age == "65" ~ "10",
                              Age == "75" ~ "30",
                              TRUE ~ ""),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = ss_i,
               sheet = "database")
  log_update(pp = "US_NYC", N = nrow(db_all))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  # setwd("C:/Users/kikep/Dropbox/covid_age/automated_COVerAge-DB/NYC_data")
  
  sheet_name <- paste0("US_NYC", d, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = ss_db, 
                       type = "spreadsheet",
                       overwrite = T)
  
  write_sheet(db_age, 
              ss = meta$id,
              sheet = "cases_deaths_age")
  
  write_sheet(db_sex, 
              ss = meta$id,
              sheet = "cases_deaths_sex")
  
  write_sheet(db_tests, 
              ss = meta$id,
              sheet = "tests")
  
  write_sheet(db_tested, 
              ss = meta$id,
              sheet = "tested")
  
  sheet_delete(meta$id, "Sheet1")
  
  print(paste("NC data saved!", Sys.Date()))
  
} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}
