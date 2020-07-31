rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

# reading data from Montreal and last date entered 
db_drive <- read_sheet("https://docs.google.com/spreadsheets/d/1S7juDEgKOg57KcXDhTBF7fzTgV7LlA0hfTJCPOKxC7M/edit#gid=0",
                       sheet = "database")
db_drive2 <- db_drive %>% 
  mutate(date_f = dmy(Date))

last_date_drive <- max(db_drive2$date_f)


# reading data from the website 

temp <- tempfile()

download.file("https://info.gesundheitsministerium.at/data/data.zip", temp)
db_c_age <- read_csv2(unz(temp, "Altersverteilung.csv"))
db_c_sex <- read_csv2(unz(temp, "Geschlechtsverteilung.csv"))

db_d_age <- read_csv2(unz(temp, "AltersverteilungTodesfaelle.csv"))
db_d_sex <- read_csv2(unz(temp, "VerstorbenGeschlechtsverteilung.csv"))

db_tests <- read_csv2(unz(temp, "AllgemeinDaten.csv"))

unlink(temp)

date_f <- db_c_age$Timestamp[1] %>% 
  str_sub(1,10) %>% 
  ymd()

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")




if (date_f > last_date_drive){
  
  db_c_age2 <- db_c_age %>% 
    separate(Altersgruppe, c("Age", "trash"), sep = "-") %>% 
    mutate(Age = case_when(Age == "<5" ~ "0",
                           Age == ">84" ~ "85",
                           TRUE ~ Age),
           Metric = "Count",
           Sex = "b") %>% 
    rename(Value = Anzahl) %>% 
    select(Sex, Age, Metric, Value)
  
  db_c_sex2 <- db_c_sex %>% 
    rename(Value = "Anzahl in %") %>% 
    mutate(Sex = case_when(Geschlecht == "weiblich" ~ "f",
                           Geschlecht == "männlich" ~ "m",
                           TRUE ~ "UNK"),
           Metric = "Fraction",
           Value = Value / 100,
           Age = "TOT") %>% 
    select(Sex, Age, Metric, Value)
  
  db_cases <- bind_rows(db_c_age2, db_c_sex2) %>% 
    mutate(Measure = "Cases")
  
  
  db_d_age2 <- db_d_age %>% 
    separate(Altersgruppe, c("Age", "trash"), sep = "-") %>% 
    mutate(Age = case_when(Age == "<5" ~ "0",
                           Age == ">84" ~ "85",
                           TRUE ~ Age),
           Metric = "Count",
           Sex = "b") %>% 
    rename(Value = Anzahl) %>% 
    select(Sex, Age, Metric, Value)
  
  db_d_sex2 <- db_d_sex %>% 
    rename(Value = "Anzahl in %") %>% 
    mutate(Sex = case_when(Geschlecht == "weiblich" ~ "f",
                           Geschlecht == "männlich" ~ "m",
                           TRUE ~ "UNK"),
           Metric = "Fraction",
           Value = Value / 100,
           Age = "TOT") %>% 
    select(Sex, Age, Metric, Value)
  
  db_deaths <- bind_rows(db_d_age2, db_d_sex2) %>% 
    mutate(Measure = "Deaths")
  
  db_tests2 <- db_tests %>% 
    select(GesTestungen) %>% 
    rename(Value = GesTestungen) %>% 
    mutate(Sex = "b",
           Metric = "Count",
           Age = "TOT",
           Measure = "Tests")
    
  db_all <- bind_rows(db_deaths, db_cases, db_tests2) %>% 
    mutate(Country = "Austria",
           Region = "All",
           Code = paste0("AT", d),
           Date = d,
           AgeInt = case_when(Age == "0" ~ "5",
                              Age == "85" ~ "20",
                              Age == "TOT" ~ "",
                              TRUE ~ "10")) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = "https://docs.google.com/spreadsheets/d/1S7juDEgKOg57KcXDhTBF7fzTgV7LlA0hfTJCPOKxC7M/edit#gid=0",
               sheet = "database")
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("AT", d, "cases&deaths")
  
  meta <- drive_create(sheet_name, 
               path = "https://drive.google.com/drive/folders/1_Sh1868yjlu1yxIIOt3TAyEegAszX6kK?usp=sharing", 
               type = "spreadsheet",
               overwrite = T)
  
  write_sheet(db_c_age, 
              ss = meta$id,
              sheet = "cases_age")
  
  write_sheet(db_c_sex, 
              ss = meta$id,
              sheet = "cases_sex")
  
  write_sheet(db_d_age, 
              ss = meta$id,
              sheet = "deaths_age")
  
  Sys.sleep(105)
  
  write_sheet(db_d_sex, 
              ss = meta$id,
              sheet = "deaths_sex")
  
  write_sheet(db_tests, 
              ss = meta$id,
              sheet = "tests")
  
  sheet_delete(meta$id, "Sheet1")
  
} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}
  
  
