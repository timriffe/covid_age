
library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.de"
}


# info country and N drive address

ctr          <- "Australia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



nsw_cases_age <- read.csv("https://data.nsw.gov.au/data/dataset/3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf/resource/4b03bc25-ab4b-46c0-bb3e-0c839c9915c5/download/confirmed_cases_table2_age_group_agg.csv") %>% 
  select(Date = notification_date, Age = age_group, Value = confirmed_cases_count) %>% 
  group_by(Date, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Age), fill=list(Value=0)) %>% 
  arrange(Date, Age) %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b",
         Country = "Australia",
         Region = "New South Wales",
         Measure = "Cases",
         Metric = "Count",
         Code = "AU-NSW",
         Age = case_when(
           Age == "AgeGroup_0-19" ~ "0",
           Age == "AgeGroup_20-24" ~ "20",
           Age == "AgeGroup_25-29" ~ "25",
           Age == "AgeGroup_30-34" ~ "30",
           Age == "AgeGroup_35-39" ~ "35",
           Age == "AgeGroup_40-44" ~ "40",
           Age == "AgeGroup_45-49" ~ "45",
           Age == "AgeGroup_50-54" ~ "50",
           Age == "AgeGroup_55-59" ~ "55",
           Age == "AgeGroup_60-64" ~ "60",
           Age == "AgeGroup_65-69" ~ "65",
           Age == "AgeGroup_70+" ~ "70",
           Age == "AgeGroup_None" ~ "UNK" ),
         AgeInt = case_when(
         Age == "0" ~ 20L,
         Age == "70" ~ 35L,
         Age == "UNK" ~ NA_integer_,
         TRUE ~ 5L),
         Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep=".")) %>% 
  sort_input_data()







##victoria
#vic_cases_age <- read.csv("https://data.nsw.gov.au/data/dataset/f9fe3aba-8b79-4e7a-a165-e4c53e22cf0d/resource/0325e760-26a5-4b9b-9681-42ef723ce6be/download/covid-19-tests-by-date-and-age-range.csv")


