
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

ctr          <- "AU_New_South_Wales" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# Source: https://data.nsw.gov.au/data/dataset/nsw-covid-19-cases-by-age-range

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

#save output 

write_rds(nsw_cases_age, paste0(dir_n, ctr, ".rds"))

##'MK: No data since 19-10-2023, so deprecated. 

#log_update(pp = ctr, N = nrow(nsw_cases_age))


#Archive 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(nsw_cases_age, data_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)




