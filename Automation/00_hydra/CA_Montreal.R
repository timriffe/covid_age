rm(list=ls())
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(rvest)
library(lubridate)

# Authorizing authentification or Drive (edit these lines with the user's email)
drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

# reading data from Montreal and last date entered 
db_drive <- read_sheet("https://docs.google.com/spreadsheets/d/1EQTK1lbqzOvMK3o6FJ3Qtc6EMpreZn8qp8mzwt2k0r0/edit?usp=drive_web&ouid=114992678969098684781",
                    sheet = "database")
db_drive2 <- db_drive %>% 
  mutate(date_f = dmy(Date))
last_date_drive <- max(db_drive2$date_f)

# Date of last update on the website
# https://santemontreal.qc.ca/en/public/coronavirus-covid-19/situation-of-the-coronavirus-covid-19-in-montreal/#c41383
m_url <- "https://santemontreal.qc.ca/en/public/coronavirus-covid-19/situation-of-the-coronavirus-covid-19-in-montreal/"
html <- read_html(m_url)
date_text <- html_nodes(html, xpath = '//*[@id="c43669"]/p/b') %>% 
  html_text()
loc_date1 <- str_locate(date_text, "as of ")[2] + 1
loc_date2 <- str_locate(date_text, ",")[1] - 1
date1 <- paste0(str_sub(date_text, loc_date1, loc_date2), " 2020")
date_f <- mdy(date1)

if (date_f > last_date_drive){

  d <- paste(sprintf("%02d", day(date_f)),
             sprintf("%02d", month(date_f)),
             year(date_f), sep = ".")

  db_a <- read_csv2("https://santemontreal.qc.ca/fileadmin/fichiers/Campagnes/coronavirus/situation-montreal/grage.csv")
  db_s <- read_csv2("https://santemontreal.qc.ca/fileadmin/fichiers/Campagnes/coronavirus/situation-montreal/sexe.csv")
  
  db_s2 <- db_s %>% 
    rename(Sex = 1,
           Cases = 2,
           Deaths = 5)
  
  db_s3 <- db_s2 %>% 
    select(Sex, Cases, Deaths) %>% 
    mutate(Sex = case_when(str_sub(Sex, 1, 1) == "M" ~ "m",
                           str_sub(Sex, 1, 1) == "F" ~ "f",
                           str_sub(Sex, 1, 1) == "I" ~ "UNK",
                           str_sub(Sex, 1, 1) == "T" ~ "b"),
           Cases = str_replace(Cases, ",", ""),
           Cases = as.numeric(str_replace(Cases, "< 5", "2")),
           Deaths = str_replace(Deaths, ",", ""), 
           Deaths = str_replace(Deaths, "-", "0"), 
           Deaths = as.numeric(str_replace(Deaths, "< 5", "2")),
           Age = "TOT") %>% 
    filter(Sex != "UNK")
    
  db_a2 <- db_a  %>% 
    rename(Age = 1,
           Cases = 2,
           Deaths = 5)
  
  db_a3 <- db_a2 %>% 
    mutate(Age = str_sub(Age, 1, 2),
           Age = case_when(Age == "0-" ~ "0",
                           Age == "5-" ~ "5",
                           Age == "Ma" ~ "UNK",
                           Age == "To" ~ "TOT",
                           TRUE ~ Age),
           Cases = str_replace(Cases, ",", ""),
           Cases = as.numeric(str_replace(Cases, "< 5", "2")),
           Deaths = str_replace(Deaths, ",", ""), 
           Deaths = str_replace(Deaths, "-", "0"), 
           Deaths = as.numeric(str_replace(Deaths, "< 5", "2")),
           Sex = "b") %>% 
    select(Sex, Age, Cases, Deaths) %>% 
    filter(Age != "TOT",
           Age != "UNK")
  
  db <- bind_rows(db_a3, db_s3) %>%
    mutate(AgeInt = case_when(Age == "0" ~ "5",
                              Age == "5" ~ "5",
                              Age == "80" ~ "25",
                              Age == "TOT" | Age == "UNK"  ~ "",
                              TRUE ~ "10"),
           Metric = "Count",
           Country = "Canada",
           Region = "Montreal",
           Code = paste0("CA_MTL", d),
           Date = d) %>% 
    gather(Cases, Deaths, key = "Measure", val = "Value") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(db,
               ss = "https://docs.google.com/spreadsheets/d/1EQTK1lbqzOvMK3o6FJ3Qtc6EMpreZn8qp8mzwt2k0r0/edit#gid=601949320",
               sheet = "database")
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("CA_MTL", d, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = "https://drive.google.com/drive/folders/1K3Px57wr-MFR7Wjff0K6VamFdYmhZo_q?usp=sharing", 
                       type = "spreadsheet",
                       overwrite = T)
  
  write_sheet(db_a, 
              ss = meta$id,
              sheet = "cases&deaths_age")
  
  write_sheet(db_s, 
              ss = meta$id,
              sheet = "cases&deaths_sex")
  
  sheet_delete(meta$id, "Sheet1")
  
} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}
