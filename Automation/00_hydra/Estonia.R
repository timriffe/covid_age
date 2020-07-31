rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

db <- read_csv("https://opendata.digilugu.ee/opendata_covid19_test_results.csv")

db2 <- db %>% 
  rename(Sex = Gender) %>% 
  separate(AgeGroup, c("Age","age2"), "-") %>% 
  mutate(Test = 1,
         Case = ifelse(ResultValue == "P", 1, 0),
         date_f = as.Date(ResultTime),
         Sex = case_when(Sex == 'N' ~ 'f',
                         Sex == 'M' ~ 'm',
                         TRUE ~ 'UNK'),
         Age = ifelse(Age == "üle 85", "85", Age),
         Age = replace_na(Age, "UNK")) %>% 
  group_by(date_f, Age, Sex) %>% 
  summarise(Cases = sum(Case),
            Tests = sum(Test)) %>% 
  ungroup() %>% 
  gather('Cases', 'Tests', key = 'Measure', value = 'new')

db3 <- db2 %>% 
  tidyr::complete(date_f = unique(db2$date_f), Sex = unique(db2$Sex), Age = unique(db2$Age), Measure, fill = list(new = 0)) %>% 
  group_by(Sex, Age, Measure) %>% 
  mutate(Value = cumsum(new)) %>% 
  arrange(date_f, Sex, Measure, Age) %>% 
  ungroup() 

db4 <- db3 %>% 
  group_by(date_f, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Age = "TOT") %>%
  ungroup() 

db5 <- db4 %>% 
  group_by(date_f, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b", Age = "TOT") %>% 
  ungroup() 

db6 <- db3 %>% 
  group_by(date_f, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b") %>% 
  ungroup() 

db_all <- bind_rows(db3, db4, db5, db6) %>% 
  filter(Age != "UNK",
         Sex != "UNK") %>%
  mutate(Region = "All",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Estonia",
         Code = paste0("EE_", Date),
         AgeInt = case_when(Age == "TOT" | Age == "UNK" ~ NA_character_, 
                            Age == "85" ~ "20",
                            TRUE ~ "5"),
         Metric = "Count") %>% 
  arrange(date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################
# This command replace the whole sheet
write_sheet(db_all, 
            ss = "https://docs.google.com/spreadsheets/d/1Jp2ffKZBYzraR5qb0eDcaz9jx-90vRwZqZBHn8tp-ak/edit#gid=1548224005",
            sheet = "database")

#############################################
#### saving metadata in the Drive folder ####
#############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("EE", d, "_cases&tests")

meta <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1iH6a7i6_e7roA3-fvDOPPGFTONzl4xr_?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "cases&tests")

sheet_delete(meta$id, "Sheet1")
