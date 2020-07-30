rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

# info by state
# hm <- read_csv("https://data.cdc.gov/api/views/9bhg-hcku/rows.csv?accessType=DOWNLOAD")
db <- read_csv("https://data.cdc.gov/api/views/vsak-wrfu/rows.csv?accessType=DOWNLOAD")
to <- read_csv("https://data.cdc.gov/api/views/r8kw-7aab/rows.csv?accessType=DOWNLOAD")

db2 <- db %>% 
  select("Age Group", "Sex", "Week ending Date", "COVID-19 Deaths") %>% 
  rename(Age = "Age Group",
         date_f = "Week ending Date",
         Value = "COVID-19 Deaths") %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "Un" ~ "0",
                         Age == "1-" ~ "1",
                         Age == "5-" ~ "5",
                         TRUE ~ as.character(Age)),
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex == "All Sex" ~ "b"),
         AgeInt = case_when(Age == "0" ~ "1",
                            Age == "1" ~ "4",
                            Age == "5" ~ "10",
                            Age == "85" ~ "20",
                            TRUE ~ "10"),
         date_f = make_date(d = str_sub(date_f, 4, 5), m = str_sub(date_f, 1, 2), y = 2020)) %>% 
  select(date_f, Sex, Age, AgeInt, Value)

to2 <- to %>% 
  filter(State == "United States") %>% 
  select("End Week", "COVID-19 Deaths") %>% 
  rename(date_f = "End Week",
         Value = "COVID-19 Deaths") %>% 
  mutate(date_f = make_date(d = str_sub(date_f, 4, 5), m = str_sub(date_f, 1, 2), y = 2020),
         Age = "TOT",
         AgeInt = "",
         Sex = "b") %>% 
  select(date_f, Sex, Age, AgeInt, Value)

db3 <- db2 %>% 
  bind_rows(to2)

dts <- unique(db3$date_f)

dts2 <- NULL
db_cum <- NULL

for (i in 1:length(dts)) {
  dts2 <- c(dts2, dts[i])

  db_temp <- db3 %>% 
    filter(date_f %in% dts2) %>% 
    group_by(Sex, Age, AgeInt) %>% 
    summarise(Value= sum(Value)) %>% 
    mutate(date_f = dts[i])
  
  db_cum <- bind_rows(db_cum,
                      db_temp)
}

db_all <- db_cum %>% 
  filter(date_f > "2020-02-29") %>% 
  mutate(Country = "USA",
         Region = "All",
         Metric = "Count",
         Measure = "Deaths",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("US", Date)) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db_all, 
            ss = "https://docs.google.com/spreadsheets/d/146lWGd4Vwmq98FDxLEvEJlUC0MvJUR7XlROyE98AEiM/edit#gid=1300689471",
            sheet = "database")

############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("US_All_", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1wZFatpaBA-zI6Bduli-ycQG450oSOzIQ?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "deaths_age")

write_sheet(to,
            ss = meta$id,
            sheet = "deaths_all")

sheet_delete(meta$id, "Sheet1")


# uploading data for INED

meta2 <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1t2_JQaVJEPWEZxAqhe8TxEDkIrYeMLCF?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta2$id,
            sheet = "deaths_age")

write_sheet(to,
            ss = meta2$id,
            sheet = "deaths_all")

sheet_delete(meta2$id, "Sheet1")


