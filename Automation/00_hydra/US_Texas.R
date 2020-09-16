# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "tim.riffe@gmail.com"
setwd("C:/Users/riffe/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")

library(tidyverse)
library(readxl)
#library(rio)
library(googlesheets4)
library(googledrive)
library(lubridate)

drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_TX")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# reading data from Drive and last date entered 
db_drive <- get_country_inputDB("US_TX")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

# reading data from the website
url1 <- "https://dshs.texas.gov/coronavirus/TexasCOVID19CaseCountData.xlsx"

text_date <- rio::import(url1, 
                      sheet = "Cases by Age Group",
                      range = "A1:A1",
                      col_names = FALSE)[1,1]

loc_date <- str_locate(text_date, "/")[2]

d <- paste(sprintf("%02d", as.numeric(str_sub(text_date, loc_date + 1, loc_date + 2))), sprintf("%02d", as.numeric(str_sub(text_date, loc_date - 2, loc_date - 1))), "2020", sep = ".")
date_f <- dmy(d)

if (date_f > last_date_drive){

 
  db_c_age <- rio::import(url1, 
                          sheet = "Cases by Age Group",
                          skip = 1) %>% 
    as_tibble()
  
  db_c_sex <- rio::import(url1, 
                          sheet = "Cases by Gender",
                          skip = 1) %>% 
    as_tibble()
  
  db_d_age <- rio::import(url1, 
                          sheet = "Fatalities by Age Group",
                          skip = 1) %>% 
    as_tibble()
  
  db_d_sex <- rio::import(url1, 
                          sheet = "Fatalities by Gender",
                          skip = 1) %>% 
    as_tibble()
  
  # TR: this is an aggregate of all reported testing types.
   # We may wish to parse it down to a subset of these
   db_tests <- rio::import(url1, 
                           sheet = "Tests by Day",
                           skip = 2) %>% 
     as_tibble() %>% 
     select(6:7) %>% 
    # filter(Location == "Total Tests") %>% 
     rename(Value = `Test Results...7`,
            Date = `Specimen Collection Date`) %>% 
     mutate(Measure = "Tests",
            Age = "TOT",
            Sex = "b",
            Date = as_date(Date)) %>% 
     select(Sex, Age, Measure, Value) %>% 
     arrange(Date) %>% 
     mutate(Value = cumsum(Value))
  
   db_totals <- rio::import(url1, 
                            sheet = "Trends",
                            skip = 2) %>% 
     as_tibble() %>% 
     rename(Cases = 3,
            Deaths = 4) %>% 
     mutate(d_f = as_date(Date),
            Deaths = as.numeric(Deaths)) %>% 
     select(d_f, Cases, Deaths) %>% 
     drop_na(d_f) %>% 
     replace_na(list(Deaths = 0)) 

  # c_tot <- db_totals %>% 
  #   pull(Cases)
  # 
  # d_tot <- db_totals %>% 
  #   pull(Deaths)
  
  db_c_age2 <- db_c_age %>% 
    separate('Age\r\nGroupings', c("Age", "trash"), sep = "-") %>% 
    mutate(Age = case_when(Age == "<1 year" ~ "0",
                           Age == "80+ years" ~ "80",
                           Age == "Unknown" ~ "UNK",
                           Age == "Total" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b") %>% 
    rename(Value = Number) %>% 
    drop_na(Value) %>% 
    select(Sex, Age, Value) %>% 
    filter(Age != "TOT",
            Age != "UNK")# %>% 
    # bind_rows(tibble(Sex = "b", Age = "TOT", Value = c_tot))
  
  db_c_sex2 <- db_c_sex %>% 
    rename(Value = "Number") %>% 
    mutate(Sex = case_when(Gender == "Female" ~ "f",
                           Gender == "Male" ~ "m",
                           Gender == "Unknown" ~ "UNK",
                           Gender == "Total" ~ "b",
                           TRUE ~ "UNK"),
           Age = "TOT") %>% 
    filter(Sex != "b",
           Sex != "UNK") %>% 
    drop_na(Value) %>% 
    select(Sex, Age, Value)
  
  db_cases <- bind_rows(db_c_age2, db_c_sex2) %>% 
    mutate(Measure = "Cases")
  
  db_d_age2 <- db_d_age %>% 
    separate('Age\r\nGroupings', c("Age", "trash"), sep = "-") %>% 
    mutate(Age = case_when(Age == "<1 year" ~ "0",
                           Age == "80+ years" ~ "80",
                           Age == "Unknown" ~ "UNK",
                           Age == "Total" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b") %>% 
    rename(Value = Number) %>% 
    drop_na(Value) %>% 
    select(Sex, Age, Value) %>% 
    filter(Age != "TOT",
           Age != "UNK")
  # TR: this was what provoked github.com/timriffe/covid_age/issues/38
  #%>% 
    #bind_rows(tibble(Sex = "b", Age = "TOT", Value = c_tot)) # TR should have been d_tot
  
  db_d_sex2 <- db_d_sex %>% 
    rename(Value = "Number") %>% 
    mutate(Sex = case_when(Gender == "Female" ~ "f",
                           Gender == "Male" ~ "m",
                           Gender == "Unknown" ~ "UNK",
                           Gender == "Total" ~ "b",
                           TRUE ~ "UNK"),
           Age = "TOT") %>% 
    drop_na(Value) %>% 
    filter(Sex != "b",
           Sex != "UNK") %>% 
    select(Sex, Age, Value)
  
  
  
  db_deaths <- bind_rows(db_d_age2, db_d_sex2) %>% 
    mutate(Measure = "Deaths")
  
  db_all <- bind_rows(db_cases, db_deaths, db_tests) %>% 
    mutate(Country = "USA",
           Region = "Texas",
           Code = paste0("US_TX", d),
           Date = d,
           AgeInt = case_when(Age == "0" ~ "1",
                              Age == "1" ~ "9",
                              Age == "10" ~ "10",
                              Age == "20" ~ "10",
                              Age == "30" ~ "10",
                              Age == "40" ~ "10",
                              Age == "50" ~ "10",
                              Age == "80" ~ "25",
                              Age == "TOT" ~ "",
                              Age == "UNK" ~ "",
                              TRUE ~ "5"),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  # This command append new rows at the end of the sheet
  sheet_append(db_all,
               ss = ss_i,
               sheet = "database")
  log_update(pp = "US_Texas", N = nrow(db_all))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  # still to modify to Texas version!
  
  sheet_name <- paste0("US_TX", d, "cases&deaths")
  
  meta <- drive_create(sheet_name, 
               path = "https://drive.google.com/drive/folders/1OM6vpNTwT84lZkKe3Hy0uMEDWO8vKvzq?usp=sharing", 
               type = "spreadsheet")
  
  write_sheet(db_c_age, 
              ss = meta$id,
              sheet = "cases_age")
  
  write_sheet(db_c_sex, 
              ss = meta$id,
              sheet = "cases_sex")
  
  write_sheet(db_d_age, 
              ss = meta$id,
              sheet = "deaths_age")
  
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

# TR : now, no matter what, whenever we rerun this script, we can still swap out totals,
# and also do a re-sort. i.e. age stuff is always an append operation, but both-sex totals
# can be revised in retrospect, and should always be swapped.

# 1) re-read the full DB (wasteful)
db_drive <- get_country_inputDB("US_TX") %>% 
  select(-Short)

# 2) read and format totals:
db_totals <- rio::import(url1, 
                         sheet = "Trends",
                         skip = 2) %>% 
  as_tibble() %>% 
  rename(Cases = 3,
         Deaths = 4) %>% 
  mutate(d_f = as_date(Date),
         Deaths = as.numeric(Deaths)) %>% 
  select(d_f, Cases, Deaths) %>% 
  drop_na(d_f) %>% 
  replace_na(list(Deaths = 0)) %>% 
  pivot_longer(Cases:Deaths, 
               names_to = "Measure", 
               values_to = "Value") %>% 
  mutate(Sex = "b",
         Date = paste(
           sprintf("%02d",day(d_f)),
           sprintf("%02d",month(d_f)),
           sprintf("%02d",year(d_f)),
           sep = "."
         ),
         Code = paste0("US_TX",Date),
         Country = "USA",
         Region = "Texas",
         Metric = "Count",
         AgeInt = NA,
         Age = "TOT") %>% 
  select(all_of(colnames(db_drive))) %>% 
  filter(Value > 0) %>% 
  filter(Date %in% db_drive$Date)

# 3) remove both-sex totals from drive object
db_drive <- db_drive %>% 
  filter(!(Sex == "b" & Age == "TOT" & Measure %in% c("Cases","Deaths")))

# 4) bind and push:
db_out <- db_drive %>% 
  bind_rows(db_totals) %>% 
  sort_input_data()

write_sheet(db_out, ss = ss_i, sheet = "database")

