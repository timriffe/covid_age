rm(list=ls())# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")
library(tidyverse)
library(tidyverse)
library(readxl)
library(googlesheets4)
library(googledrive)
library(rio)
library(lubridate)
library(rvest)

drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_MI")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

# what's current most recent date?
db_drive <- get_country_inputDB("US_MI")
db_drive2 <- db_drive %>% 
  mutate(date_f = dmy(Date))

last_date_drive <- max(db_drive2$date_f)

# reading data from the website 
### source
### https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html

m_url <- "https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html"
root <- "https://www.michigan.gov"
html <- read_html(m_url)

### when using links from the wayback machine
# m_url <- "https://web.archive.org/web/20200627034205/https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html"
# root <- "https://web.archive.org"

# locating the links for Excel files
url1 <- html_nodes(html, xpath = '//*[@id="comp_115341"]/ul/li/span/span/span[2]/p[2]/a') %>%
  html_attr("href")

url2 <- html_nodes(html, xpath = '//*[@id="comp_115341"]/ul/li/span/span/span[2]/p[4]/a') %>%
  html_attr("href")

url3 <- html_nodes(html, xpath = '//*[@id="comp_115341"]/ul/li/span/span/span[2]/p[5]/a') %>%
  html_attr("href")

# importing data from the Excel files
db_tot <- rio::import(paste0(root, url1)) %>% 
  as_tibble()

db_demo <- rio::import(paste0(root, url2)) %>% 
  as_tibble()

db_tests <- rio::import(paste0(root, url3)) %>% 
  as_tibble()

date_f <- as.Date(max(db_tot$Updated))

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

d

if (date_f > last_date_drive){

  ###################
  # Formatting data #
  ###################
  db2 <- db_demo %>% 
    mutate(Cases = ifelse(Cases == "Suppressed", "1", Cases),
           Deaths = ifelse(Deaths == "Suppressed", "1", Deaths),
           Cases = as.numeric(Cases),
           Deaths = as.numeric(Deaths),
           Age = str_sub(AgeCat, 1, 2),
           Age = ifelse(Age == "0-", "0", Age),
           Sex = case_when(SEX == "Female" ~ "f",
                           SEX == "Male" ~ "m",
                           SEX == "Unknown" ~ "u")) %>% 
    filter(CASE_STATUS == "Confirmed") %>% 
    group_by(Age, Sex) %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    ungroup()
  
  db_sex_t <- db2 %>% 
    filter(Sex != "u") %>% 
    group_by(Sex) %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    mutate(Age = "TOT") %>% 
    ungroup()
  
  db_b <- db2 %>% 
    filter(Age != "Un") %>% 
    group_by(Age) %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    mutate(Sex = "b") %>% 
    ungroup()
  
  db_t <- db_tot %>% 
    filter(CASE_STATUS == "Confirmed") %>% 
    group_by() %>% 
    summarise(Cases = sum(Cases),
              Deaths = sum(Deaths)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT",
           Sex = "b")
  
  db_tests2 <- db_tests %>% 
    filter(TestType == "Diagnostic") %>% 
    group_by() %>% 
    summarise(Value = sum(Count)) %>% 
    mutate(Age = "TOT",
           Sex = "b",
           Measure = "Tests")
  
  db_all <- db2 %>% 
    filter(Sex != "u", Age != "Un") %>% 
    bind_rows(db_b, db_sex_t, db_t) %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
    bind_rows(db_tests2) %>% 
    mutate(AgeInt = case_when(Age == "0" ~ "20",
                              Age == "80" ~ "25",
                              Age == "TOT" ~ "",
                              TRUE ~ "10"),
           Country = "USA",
           Region = "Michigan",
           Date = d,
           Code = paste0("US_MI", d),
           Metric = "Count") %>% 
    arrange(Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = ss_i,
               sheet = "database")
  log_update(pp = "US_Michigan", N = nrow(db_all))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("US_MI", d, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = ss_db, 
                       type = "spreadsheet",
                       overwrite = T)
  
    write_sheet(db_demo, 
              ss = meta$id,
              sheet = "cases&deaths_age_sex")
  
  write_sheet(db_tot, 
              ss = meta$id,
              sheet = "cases&deaths_county")
  
  write_sheet(db_tests, 
              ss = meta$id,
              sheet = "tests_county")
  
  sheet_delete(meta$id, "Sheet1")

} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}
