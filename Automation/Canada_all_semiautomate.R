# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
# setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# "https://www150.statcan.gc.ca/n1/en/pub/13-26-0003/2020001/COVID19-eng.zip?st=CbM6myWY"

# TR New: you must be in the repo environment 
source("R/00_Functions.R")

library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)
library(readxl)

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "CA")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db <- read_csv("U:/nextcloud/Projects/COVID_19/COVerAge-DB/canada/201019_13100781-eng/13100781.csv",
               col_types = cols(.default = "c"))

# from long to wide format
db2 <- db %>% 
  rename(id = 'Case identifier number',
         variable = 'Case information',
         Value = VALUE) %>% 
  filter(variable %in% c('Region', 'Episode week', 'Gender', 'Age group', 'Death')) %>% 
  mutate(variable = case_when(variable == 'Episode week' ~ 'week',
                              variable == 'Gender' ~ 'Sex',
                              variable == 'Age group' ~ 'Age',
                              TRUE ~ variable)) %>% 
  select(id, variable, Value) %>% 
  spread(variable, Value) %>% 
  arrange(suppressWarnings(as.integer(id)))

test <- db2 %>% 
  filter(week == "99")

unique(db2$week) %>% as.numeric() %>% sort()
table(db2$week)

# all weeks in data but "99"
weeks <- as.numeric(unique(db2$week)[!unique(db2$week) %in% "99"]) %>% sort()

# imputing cases with no date of event to the last two weeks 
week_imp <- weeks[length(weeks)-1] %>% as.character()

# replacing the values
db3 <- db2 %>% 
  mutate(Region = case_when(Region == "1" ~ "Atlantic",
                            Region == "2" ~ "Quebec",
                            Region == "3" ~ "Ontario and Nunavut",
                            Region == "4" ~ "Prairies",
                            Region == "5" ~ "British Columbia and Yukon",
                            TRUE ~ "Other"),
         Sex = case_when(Sex == '1' ~ "m",
                         Sex == '2' ~ "f",
                         Sex == '9' ~ "u"),
         Age = case_when(Age == '1' ~ "0",
                         Age == '2' ~ "20",
                         Age == '3' ~ "30",
                         Age == '4' ~ "40",
                         Age == '5' ~ "50",
                         Age == '6' ~ "60",
                         Age == '7' ~ "70",
                         Age == '8' ~ "80",
                         Age == '99' ~ "UNK"),
         Death = case_when(Death == "1" ~ "y",
                           Death == "2" ~ "n",
                           Death == "9" ~ "u"),
         week = ifelse(week == "99", week_imp, week),
         date_f = as.Date(paste(2020, week, 1, sep="-"), "%Y-%U-%u") - 1)

unique(db3$Age)

# all dates to be collected
dates <- as.Date(paste(2020, min(weeks):max(weeks), 1, sep="-"), "%Y-%U-%u") - 1
ages <- unique(db3$Age) %>% sort() %>% suppressWarnings(as.integer())

cases <- db3 %>% 
  select(date_f, Region, Sex, Age) %>% 
  mutate(new = 1) %>% 
  group_by(date_f, Region, Sex, Age) %>% 
  summarise(new = sum(new)) %>% 
  ungroup() %>% 
  complete(date_f = dates, Region, Sex, Age = ages, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases")

#################
# Because there is no date of death, currently we are assigning the same date as the 
# episode date, which normally corresponds to the confirmation date.
# We should impute this date by adding an age-specific average time from infection to death, 
# which could be estimated from other data, such as the Dutch or the German, for example.   

deaths <- db3 %>% 
  filter(Death == 'y') %>% 
  select(date_f, Region, Sex, Age) %>% 
  mutate(new = 1) %>% 
  group_by(date_f, Region, Sex, Age) %>% 
  summarise(new = sum(new)) %>% 
  ungroup() %>% 
  complete(date_f = dates, Region, Sex, Age = ages, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths")

cd <- bind_rows(cases, deaths) %>% 
  select(-new) 
  
cd_all_ages <- cd %>% 
  group_by(date_f, Region, Measure, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Age = "TOT")

cd_all_sexes <- cd %>% 
  group_by(date_f, Region, Measure, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b")

cd_all_ages_sexes <- cd %>% 
  group_by(date_f, Region, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b",
         Age = "TOT")

regions <- cd %>% 
  bind_rows(cd_all_ages,
            cd_all_sexes,
            cd_all_ages_sexes) %>% 
  filter(Age != "UNK",
         Sex != "u") %>% 
  arrange(date_f, Region, Measure, Sex, Age)

canada <- regions %>% 
  group_by(date_f, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All")

db_all <- bind_rows(canada, regions) %>% 
  mutate(Country = "Canada",
         AgeInt = case_when(Age == "0" ~ "20",
                            Age == "80" ~ "25",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         short = case_when(
           Region == "Atlantic" ~ "CA_SC_ATL",
           Region == "Quebec" ~ "CA_SC_QC",
           Region == "Ontario and Nunavut" ~ "CA_SC_ON_NU",
           Region == "Prairies" ~ "CA_SC_PRS",
           Region == "British Columbia and Yukon" ~ "CA_SC_BC_YT",
           Region == "All" ~ "CA_SC"),
         Code = paste0(short, Date),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################
# This command append new rows at the end of the sheet
write_sheet(db_all,
             ss = ss_i,
             sheet = "database")
log_update(pp = "Canada", N = nrow(db_all))

############################################
#### uploading metadata to Google Drive ####
############################################
d <- paste(sprintf("%02d",day(today())),
           sprintf("%02d",month(today())),
           year(today()),
           sep=".")

sheet_name <- paste0("CA", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = ss_db, 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db2, 
            ss = meta$id,
            sheet = "cases&deaths")

sheet_delete(meta$id, "Sheet1")


