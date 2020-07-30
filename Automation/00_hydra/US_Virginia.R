rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

# reading data from Drive and last date entered 
db_drive <- read_sheet("https://docs.google.com/spreadsheets/d/1b8vpZhKDPKWm8QeSFFy01u3rGbEhxUf_nkyjtkPLQlc/edit#gid=0",
                       sheet = "database")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  drop_na(date_f) %>% 
  pull(date_f) 

max(last_date_drive)

# reading data from the website
url_age <- "https://data.virginia.gov/api/views/uktn-mwig/rows.csv?accessType=DOWNLOAD"
db_age <- read_csv(url_age)

date_f <- mdy(db_age[1,1])

if (!(date_f %in% last_date_drive)){

  url_sex <- "https://data.virginia.gov/api/views/tdt3-q47w/rows.csv?accessType=DOWNLOAD"
  url_tests <- "https://data.virginia.gov/api/views/3u5k-c2gr/rows.csv?accessType=DOWNLOAD"
  db_sex <- read_csv(url_sex)
  db_tests <- read_csv(url_tests)
  
  d <- paste(sprintf("%02d", day(date_f)),
             sprintf("%02d", month(date_f)),
             year(date_f), sep = ".")

  date_f_tests <- db_tests %>% 
    rename(date_f = "Lab Report Date") %>% 
    mutate(date_f = mdy(date_f)) %>%
    drop_na(date_f) %>% 
    pull(date_f) %>% 
    max()
  
  d_tests <- paste(sprintf("%02d", day(date_f_tests)),
             sprintf("%02d", month(date_f_tests)),
             year(date_f_tests), sep = ".")
  
  db_age2 <- db_age %>% 
    rename(Cases = "Number of Cases",
           Deaths = "Number of Deaths") %>% 
    separate("Age Group", c("Age", "trash"), sep = "-") %>% 
    group_by(Age) %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    ungroup() %>% 
    mutate(Age = case_when(Age == "80+" ~ "80",
                           Age == "Missing" ~ "UNK",
                           TRUE ~ Age),
           Sex = "b") %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value") 
  
  
  db_sex2 <- db_sex %>% 
    rename(Cases = "Number of Cases",
           Deaths = "Number of Deaths") %>% 
    group_by(Sex) %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    ungroup() %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           TRUE ~ "UNK"),
           Age = "TOT") %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value")
  
  db_tests2 <- db_tests %>% 
    rename(tests = "Number of PCR Testing Encounters") %>% 
    group_by() %>% 
    summarise(Value = sum(tests)) %>% 
    mutate(Sex = "b",
           Age = "TOT",
           Measure = "Tests")
  
  db_all <- bind_rows(db_age2, db_sex2, db_tests2) %>% 
    mutate(Country = "USA",
           Region = "Virginia",
           Code = ifelse(Measure == "Tests", paste0("US_VA", d_tests), paste0("US_VA", d)),
           Date = ifelse(Measure == "Tests", d_tests, d),
           AgeInt = case_when(Age == "TOT" ~ "",
                              Age == "UNK" ~ "",
                              Age == "80" ~ "25",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = "https://docs.google.com/spreadsheets/d/1b8vpZhKDPKWm8QeSFFy01u3rGbEhxUf_nkyjtkPLQlc/edit#gid=0",
               sheet = "database")
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("US_VA", d, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = "https://drive.google.com/drive/folders/1lwjVpzT6QLzW-_PzhygMiosXcJd7jNk4?usp=sharing", 
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
  
  sheet_delete(meta$id, "Sheet1")

} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}