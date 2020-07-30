rm(list=ls())
library(httr)
library(jsonlite)
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(lubridate)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")


# reading data from Montreal and last date entered 
db_drive <- read_sheet("https://docs.google.com/spreadsheets/d/1UB9lOnSZiPD4LeedYBaAkpFL3r1DB51BI7F1GKJw-Bw/edit#gid=0",
                       sheet = "database")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  pull(date_f) %>% 
  max()

# reading data from the website 
r <- GET("https://covid19.patria.org.ve/api/v1/summary")
a <- content(r, "text", encoding = "ISO-8859-1")
b <- fromJSON(a)

r2 <- GET("https://covid19.patria.org.ve/api/v1/timeline")
a2 <- content(r2, "text", encoding = "ISO-8859-1")
b2 <- fromJSON(a2)

date_f <- b2 %>% 
  pull(Date) %>% 
  max()

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

if (date_f > last_date_drive){

  db <- b$Confirmed$ByAgeRange %>% 
    bind_cols %>% 
    gather(key = age_g, value = Value) %>% 
    separate(age_g, c("Age", "res")) %>% 
    select(-res) %>% 
    bind_rows(tibble(Age = "TOT", 
                     Value = b$Confirmed$Count)) %>% 
    mutate(Sex = "b") %>% 
    bind_rows(tibble(Age = "TOT", 
                     Sex = c("f", "m"), 
                     Value = c(b$Confirmed$ByGender$female, b$Confirmed$ByGender$male))) %>% 
    mutate(Measure = "Cases") %>% 
    bind_rows(tibble(Age = "TOT", 
                     Sex = c("b"), 
                     Measure = "Deaths",
                     Value = b$Deaths$Count)) %>%
    mutate(Region = "All",
           Date = d,
           Country = "Venezuela",
           Code = paste0("VE", Date),
           AgeInt = case_when(Age == "TOT" ~ "", 
                              Age == "90" ~ "15",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 
  
  db
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(db,
               ss = "https://docs.google.com/spreadsheets/d/1UB9lOnSZiPD4LeedYBaAkpFL3r1DB51BI7F1GKJw-Bw/edit#gid=0",
               sheet = "database")
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  temp <- tempfile(fileext = ".txt")
  writeLines(a, temp)
  drive_upload(
    temp,
    path = "https://drive.google.com/drive/folders/1khiU26stWXubrwM7wNd_tndfzd9QVpeJ?usp=sharing",
    name = paste0("VE", d, "_cases.txt"),
    overwrite = T)
  unlink(temp)

} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}


