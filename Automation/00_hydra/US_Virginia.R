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

drive_auth(email = email)
gs4_auth(email = email)

# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_VA")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# reading data from Drive and last date entered 
db_drive <- get_country_inputDB("US_VA")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  drop_na(date_f) %>% 
  dplyr::pull(date_f) 

max(last_date_drive)

# reading data from the website
url_age <- "https://data.virginia.gov/api/views/uktn-mwig/rows.csv?accessType=DOWNLOAD"
db_age <- read_csv(url_age)

date_f <- mdy(max(db_age$`Report Date`))

if (!(date_f %in% last_date_drive)){

  url_sex   <- "https://data.virginia.gov/api/views/tdt3-q47w/rows.csv?accessType=DOWNLOAD"
  url_tests <- "https://data.virginia.gov/api/views/3u5k-c2gr/rows.csv?accessType=DOWNLOAD"
  db_sex    <- read_csv(url_sex)
  db_tests  <- read_csv(url_tests)
  
  d <- paste(sprintf("%02d", day(date_f)),
             sprintf("%02d", month(date_f)),
             year(date_f), sep = ".")

  date_f_tests <- db_tests %>% 
    rename(date_f = "Lab Report Date") %>% 
    mutate(date_f = mdy(date_f)) %>%
    drop_na(date_f) %>% 
    dplyr::pull(date_f) %>% 
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
    summarise(Value = sum(new)) %>% 
    ungroup() %>% 
    mutate(Sex = "b")
    # ungroup() %>% 
    # group_by(Age, Measure) %>% 
    # mutate(Value = cumsum(new),
    #        Sex = "b") %>% 
    
    
    
  
  
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
    pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
    group_by(date_f, Sex, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT")
    # group_by(Sex, Measure) %>% 
    # mutate(Value = cumsum(new),
    #        Age = "TOT") %>% 
    # ungroup()
    
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
              ss = ss_i,
              sheet = "database")
  log_update(pp = "US_Virginia", N = nrow(db_all))
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("US_VA", d, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = ss_db, 
                       type = "spreadsheet",
                       overwrite = TRUE)
  
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

} else if (date_f %in% last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = "US_Virginia", N = 0)
}
