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
url <- html_nodes(html, xpath = '//*[@id="node-5056"]/div[4]/div/div/div/p[7]/a') %>%
  html_attr("href")

paste0("https://www.nijz.si", url)
# tb4 cases
# tb6 deaths


date_f <- rio::import(paste0("https://www.nijz.si", url), 
                        sheet = "tb4", 
                        range = cell_cols(1)) %>% 
  rename(date_f = 1) %>% 
  mutate(date_f = as.Date(as.integer(date_f), origin = "1899-12-30")) %>% 
  drop_na() %>% 
  dplyr::pull(date_f) %>% 
  max()
         




if (date_f > last_date_drive){
  
  ###############################
  ### daily collection automation
  ###############################
  
  ### Cases
  ##############

  db_c <- rio::import(paste0("https://www.nijz.si", url), 
                      sheet = "tb4", 
                      skip = 2) %>%
    as_tibble() 
  
  db_c2 <- db_c %>% 
    rename(date_f = 1,
           m_0 = 2,
           m_5 = 3,
           m_15 = 4,
           m_25 = 5,
           m_35 = 6,
           m_45 = 7,
           m_55 = 8,
           m_65 = 9,
           m_75 = 10,
           m_85 = 11,
           m_TOT = 12,
           f_0 = 13,
           f_5 = 14,
           f_15 = 15,
           f_25 = 16,
           f_35 = 17,
           f_45 = 18,
           f_55 = 19,
           f_65 = 20,
           f_75 = 21,
           f_85 = 22,
           f_TOT = 23,
           b_0 = 24,
           b_5 = 25,
           b_15 = 26,
           b_25 = 27,
           b_35 = 28,
           b_45 = 29,
           b_55 = 30,
           b_65 = 31,
           b_75 = 32,
           b_85 = 33,
           b_TOT = 34) %>% 
    gather(-date_f, key = Age, value = new) %>% 
    separate(Age, c("Sex", "Age"), sep = "_") %>% 
    mutate(date_f = as.Date(as.integer(date_f), origin = "1899-12-30")) %>% 
    replace_na(list(new = 0)) %>% 
    drop_na()
  
  # # test  
  # db_cases %>% 
  #   filter(Age != "TOT") %>% 
  #   group_by(Sex) %>% 
  #   summarise(sum(Value))
  
  db_c3 <- db_c2 %>% 
    group_by(Sex, Age) %>% 
    mutate(Value = cumsum(new)) %>% 
    select(-new) %>% 
    ungroup() %>% 
    mutate(Measure = "Cases")
  
  ### deaths
  ##############
  db_d <- rio::import(paste0("https://www.nijz.si", url), 
                      sheet = "tb6", 
                      skip = 2)
    
  db_d2 <- db_d %>% 
    rename(date_f = 1,
           m_45 = 2,
           m_55 = 3,
           m_65 = 4,
           m_75 = 5,
           m_85 = 6,
           m_TOT = 7,
           f_45 = 8,
           f_55 = 9,
           f_65 = 10,
           f_75 = 11,
           f_85 = 12,
           f_TOT = 13,
           b_45 = 14,
           b_55 = 15,
           b_65 = 16,
           b_75 = 17,
           b_85 = 18,
           b_TOT = 19) %>% 
    gather(-date_f, key = Age, value = new) %>% 
    separate(Age, c("Sex", "Age"), sep = "_") %>% 
    mutate(date_f = as.Date(as.integer(date_f), origin = "1899-12-30")) %>% 
    replace_na(list(new = 0)) %>% 
    drop_na()

  # # test  
  # db_d %>% 
  #   filter(Age != "TOT") %>% 
  #   group_by(Sex) %>% 
  #   summarise(sum(Value))
  
  db_d3 <- db_d2 %>% 
    complete(date_f, 
             Sex, 
             Age = c("0", as.character(seq(45, 85, 10)), "TOT"), 
             fill = list(new = 0)) %>% 
    group_by(Sex, Age) %>% 
    mutate(Value = cumsum(new)) %>% 
    select(-new) %>% 
    ungroup() %>% 
    mutate(Measure = "Deaths")
  
  
  db_all <- bind_rows(db_c3, db_d3) %>% 
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
  write_sheet(db_all,
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




