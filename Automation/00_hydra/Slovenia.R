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
library(readxl)
library(googlesheets4)
library(googledrive)
library(rio)
library(lubridate)
library(rvest)
library(httr)

drive_auth(email = email)
gs4_auth(email = email)


SI_rubric <- get_input_rubric() %>% filter(Short == "SI")
ss_i  <- SI_rubric %>% dplyr::pull(Sheet)
ss_db <-  SI_rubric %>% dplyr::pull(Source)
# reading data from Montreal and last date ent

#### Previous database in COVerAGE-DB ####
db_drive <- get_country_inputDB("SI")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

### reading data from the website 
m_url <- "https://www.nijz.si/sl/dnevno-spremljanje-okuzb-s-sars-cov-2-covid-19"
html <- read_html(m_url)

# locating the links for Excel files
url <- html_nodes(html, xpath = '//*[@id="node-5056"]/div[5]/ul/li/a') %>%
  html_attr("href")

db_cases <- rio::import(url, 
                        sheet = "Po starostnih skupinah ", 
                        range = cell_cols("A:L")) %>% 
  as_tibble()

date_f <- db_cases %>%
  rename(date = "Starostna skupina") %>%
  mutate(date = as.numeric(date),
         date_f = as.Date(date, origin = "1899-12-30")) %>% 
  drop_na(date_f) %>% 
  dplyr::pull(date_f) %>% 
  max()


if (date_f > last_date_drive){
  
  db_c <- rio::import(url, 
                      sheet = 3, 
                      range = "O1:R12") %>% 
    as_tibble()
  
  db_d <- rio::import(url, 
                      sheet = 4) %>% 
    as_tibble()
  
  
  ###############################
  ### daily collection automation
  ###############################
  
  ### Cases
  ##############
  
  db_c2 <- db_c %>%
    rename(age_g = 1,
           m = 2,
           f = 3,
           b = 4) %>%
    gather(-age_g, key = Sex, value = Value) %>%
    separate(age_g, c("Age","age2"), "-") %>%
    mutate(Age = case_when(Age == "Skupaj" ~ "TOT",
                           Age == "85+" ~ "85",
                           TRUE ~ Age),
           date_f = date_f,
           Measure = "Cases") %>%
    select(Sex, Age, date_f, Measure, Value)
  
  ### deaths
  ##############
  
  id_d <- grep("Starostne", colnames(db_d))
  
  db_d2 <- db_d %>% 
    select(id_d, id_d + 1, id_d + 2, id_d + 3) %>% 
    rename(age_g = 1,
           m = 2,
           f = 3,
           b = 4) %>%
    drop_na() %>% 
    bind_rows(tibble(age_g = "0", m = 0, f = 0, b = 0)) %>% 
    gather(-age_g, key = Sex, value = Value) %>% 
    separate(age_g, c("Age","age2"), "-") %>% 
    mutate(Age = case_when(Age == "Skupaj" ~ "TOT",
                           Age == "85+" ~ "85",
                           TRUE ~ Age),
           Measure = "Deaths",
           date_f = date_f,
           Measure = "Deaths") %>%
    select(Sex, Age, date_f, Measure, Value) 
  
  db_all <- bind_rows(db_c2, db_d2) %>% 
    mutate(Date = paste(sprintf("%02d", day(date_f)),
                        sprintf("%02d", month(date_f)),
                        year(date_f), sep = "."),
           Country = "Slovenia",
           Code = paste0("SI", Date),
           Region = "All",
           AgeInt = case_when(Age == "0" & Measure == "Deaths" ~ "45", 
                              Age == "0" & Measure == "Cases" ~ "5", 
                              Age == "85" ~ "20",
                              Age == "TOT" ~ "",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = ss_i,
               sheet = "database")
  log_update(pp = "Slovenia", N = nrow(db_all))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  d <- paste(sprintf("%02d", day(date_f)),
             sprintf("%02d", month(date_f)),
             year(date_f), sep = ".")
  
  meta <- drive_create(paste0("SI", d, "_cases&deaths"),
                       path = ss_db, 
                       type = "spreadsheet",
                       overwrite = T)
  
  write_sheet(db_cases, 
              ss = meta$id,
              sheet = "cases_age")
  
  write_sheet(db_c, 
              ss = meta$id,
              sheet = "cases_age_sex")
  
  write_sheet(db_d, 
              ss = meta$id,
              sheet = "deaths_age_sex")
  
  sheet_delete(meta$id, "Sheet1")
  
} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}




