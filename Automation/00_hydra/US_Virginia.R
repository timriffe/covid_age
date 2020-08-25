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

date_f <- mdy(max(db_age$`Report Date`))

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
    rename(date = "Report Date",
           Cases = "Number of Cases",
           Deaths = "Number of Deaths") %>% 
    separate("Age Group", c("Age", "trash"), sep = "-") %>% 
    replace_na(list(Cases = 0, Deaths = 0)) %>% 
    mutate(date_f =  mdy(date),
           Age = case_when(Age == "80+" ~ "80",
                           Age == "Missing" ~ "UNK",
                           TRUE ~ Age)) %>% 
    select(date_f, Age, Cases, Deaths) %>% 
    gather(Cases, Deaths, key = "Measure", value = "new") %>% 
    group_by(date_f, Age, Measure) %>% 
    summarise(new = sum(new)) %>% 
    ungroup() %>% 
    group_by(Age, Measure) %>% 
    mutate(Value = cumsum(new),
           Sex = "b") %>% 
    ungroup()
    
    
  
  
  db_sex2 <- db_sex %>% 
    rename(date = "Report Date",
           Cases = "Number of Cases",
           Deaths = "Number of Deaths") %>% 
    replace_na(list(Cases = 0, Deaths = 0)) %>% 
    mutate(date_f =  mdy(date)) %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           TRUE ~ "UNK")) %>% 
    select(date_f, Sex, Cases, Deaths) %>% 
    gather(Cases, Deaths, key = "Measure", value = "new") %>% 
    group_by(date_f, Sex, Measure) %>% 
    summarise(new = sum(new)) %>% 
    ungroup() %>% 
    group_by(Sex, Measure) %>% 
    mutate(Value = cumsum(new),
           Age = "TOT") %>% 
    ungroup()
    
  db_tests2 <- db_tests %>% 
    rename(tests = "Number of PCR Testing Encounters",
           date = "Lab Report Date") %>% 
    mutate(date_f =  mdy(date)) %>% 
    replace_na(list(tets = 0)) %>% 
    drop_na() %>% 
    group_by(date_f) %>% 
    summarise(new = sum(tests)) %>%
    ungroup() %>% 
    group_by() %>% 
    mutate(Value = cumsum(new),
           Sex = "b",
           Age = "TOT",
           Measure = "Tests") %>% 
    ungroup()
 
  db_all <- bind_rows(db_age2, db_sex2, db_tests2) %>% 
    mutate(Country = "USA",
           Region = "Virginia",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("US_VA", Date),
           AgeInt = case_when(Age == "TOT" ~ "",
                              Age == "UNK" ~ "",
                              Age == "80" ~ "25",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  write_sheet(db_all, 
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
