rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

email <- "kikepaila@gmail.com"

drive_auth(email = email)
gs4_auth(email = email)

# data from deaths and tests
deaths <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/10XayKoMKOOOJrZBPcUbd_SIZgBIC5eNt9ei4oVVw-SY/edit#gid=0",
                     sheet = "database_deaths_tests")

deaths2 <- deaths %>% 
  mutate(date_f = dmy(Date)) %>% 
  drop_na(Value)

# open connexion for the link
# https://www.mspbs.gov.py/reporte-covid19.html
# https://public.tableau.com/vizql/w/COVID19PY-Registros/v/Descargardatos/viewData/sessions/36CDE8AFF81E4696ADBD0D871C447BBD-0:0/views/7713620505763405234_2641841674343653269?maxrows=200&viz=%7B%22worksheet%22%3A%22Descargar%20datos%22%7D
# db <- read_csv("https://public.tableau.com/vizql/w/COVID19PY-Registros/v/Descargardatos/vudcsv/sessions/B52B2EB92B9B4377B31BBD48969655F0-0:0/views/7713620505763405234_2641841674343653269?summary=true")

unique(db$Edad) %>% sort()

db2 <- db %>% 
  rename(date_f = "Fecha Confirmacion",
         Sex = Sexo) %>% 
  select(date_f, Sex, Edad) %>% 
  mutate(date_f = mdy(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = case_when(Edad <= 100 ~ as.character(floor(Edad/5)*5), 
                         Edad > 100 & Edad < 120 ~ "100",
                         Edad >= 120 ~"UNK")) %>% 
  group_by(date_f, Sex, Age) %>% 
  summarise(new = sum(n())) %>% 
  ungroup() 

sexes <- unique(db2$Sex)
dates_f <- unique(db2$date_f)
ages <- unique(db2$Age) %>% sort()

db3 <- db2 %>% 
  complete(Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  arrange(suppressWarnings(as.integer(Age)), Sex, date_f) %>% 
  group_by(Age, Sex) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup()

db_full <- db3 %>%
  mutate(Region = "All",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Paraguay",
         Code = paste0("PY_", Date),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            TRUE ~ 5),
         Metric = "Count",
         Measure = "Cases") %>% 
  bind_rows(deaths2) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

# total cummulative values
date_end <- max(dates_f)

date_end_format <- paste(sprintf("%02d", day(date_end)),
                         sprintf("%02d", month(date_end)),
                         year(date_end), sep = ".")

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db_full, 
            ss = "https://docs.google.com/spreadsheets/d/10XayKoMKOOOJrZBPcUbd_SIZgBIC5eNt9ei4oVVw-SY/edit#gid=0",
            sheet = "database")

############################################
#### uploading metadata to Google Drive ####
############################################

sheet_name <- paste0("PY", date_end_format, "cases")

meta <- drive_create(sheet_name,
                     path = "https://drive.google.com/drive/folders/1tHjyFAPp7YdaS3O7QF2QJFzL1cg0nrkI?usp=sharing", 
                     type = "spreadsheet")

write_sheet(db, 
            ss = meta$id,
            sheet = "cases")

sheet_delete(meta$id, "Sheet1")

