rm(list=ls())# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "tim.riffe@gmail.com"
setwd("C:/Users/riffe/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_WI")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)
# reading directly from the web
# https://data.dhsgis.wi.gov/datasets/covid-19-historical-data-table/data
db0 <- read_csv("https://opendata.arcgis.com/datasets/b913e9591eae4912b33dc5b4e88646c5_10.csv",
                col_types = cols(.default = "d"))

db <- db0 %>% 
  filter(GEOID == 55)

spec(db)

# impossible to parse the original date, which starts at 15.03.2020
date1 <- as_date("2020-03-15")
date_end <- as_date("2020-03-15") + as.numeric(count(db)-1)

# selecting variables and reshaping to long format
db2 <- db %>% 
  mutate(date_f = seq(ymd(date1),ymd(date_end), by = '1 day'),
         Tests = POSITIVE + NEGATIVE) %>% 
  select(date_f, POSITIVE, POS_FEM, POS_MALE, POS_0_9, POS_10_19, POS_20_29, 
         POS_30_39, POS_40_49, POS_50_59, POS_60_69, POS_70_79, 
         POS_80_89, POS_90, DEATHS, DTHS_FEM, DTHS_MALE, DTHS_0_9,
         DTHS_10_19, DTHS_20_29, DTHS_30_39, DTHS_40_49, DTHS_50_59, 
         DTHS_60_69, DTHS_70_79, DTHS_80_89, DTHS_90, Tests) %>% 
  gather(-date_f, key = var, value = Value) %>% 
  arrange(date_f) %>% 
  replace_na(list(Value = 0))

# filling age, sex, etc. (no data by age before the 29th of March)
db3 <- db2 %>% 
  mutate(Measure = case_when(str_sub(var, 1, 1) == "P" ~ "Cases", 
                             str_sub(var, 1, 1) == "D" ~ "Deaths", 
                             str_sub(var, 1, 1) == "T" ~ "Tests"),
         age1 = case_when(Measure == "Cases" ~ str_sub(var, 5, 6),
                         Measure == "Deaths" ~ str_sub(var, 6, 7),
                         TRUE ~ "TOT"),
         Age = case_when(age1 == "TI" | age1 == "FE" | age1 == "MA" | age1 == "S" | age1 == "TOT" ~ "TOT",
                         age1 == "0_" ~ "0",
                         TRUE ~ age1),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            Age == "90" ~ 15,
                            TRUE ~ 10),
         Sex = case_when(age1 == "FE" ~ "f",
                         age1 == "MA" ~ "m",
                         TRUE ~ "b"),
         Country = "USA", 
         Region = "Wisconsin",
         Metric = "Count",
         Date = paste0(sprintf("%02d", day(date_f)), ".", sprintf("%02d", month(date_f)), ".2020"),
         Code = paste0("US_WI_", Date)) %>% 
  filter(date_f >= as_date("2020-03-29")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db3, 
            ss = ss_i,
            sheet = "database")
log_update(pp = "US_Wisconsin", N = nrow(db3))
############################################
#### uploading metadata to Google Drive ####
############################################

date_end_f <- paste(sprintf("%02d", day(date_end)),
                    sprintf("%02d", month(date_end)),
                    year(date_end), sep = ".")

sheet_name <- paste0("US_WI", date_end_f, "cases&deaths")

meta <- drive_create(sheet_name, 
             path = ss_db, 
             type = "spreadsheet",
             overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "cases&deaths")

sheet_delete(meta$id, "Sheet1")

