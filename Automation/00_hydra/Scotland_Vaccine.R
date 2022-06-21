source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(here)
library(readxl)
library(lubridate)
library(dplyr)
library(tidyverse)
library(tidyr)


# info country and N drive address

ctr          <- "Scotland_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


###get vaccine data for scotland

vacc <- read.csv("https://www.opendata.nhs.scot/dataset/6dbdd466-45e3-4348-9ee3-1eac72b5a592/resource/9b99e278-b8d8-47df-8d7a-a8cf98519ac1/download/daily_vacc_age_sex_20211103.csv")
vacc2 <- vacc %>% 
  select(Date = Date, Sex = Sex, Age = AgeGroup, Measure = Dose, Value = CumulativeNumberVaccinated) %>% 
  mutate(Sex = case_when(
    Sex == "Female" ~ "f",
    Sex == "Male" ~ "m",
    Sex == "Total" ~ "b"),
    Age = case_when(
      Age == "12 to 15" ~ "12",          
      Age == "16 to 17" ~ "16",   
      Age == "18 to 29" ~ "18",  
      Age == "30 to 39" ~ "30",   
      Age == "40 to 49" ~ "40",   
      Age == "50 to 54" ~ "50",            
      Age == "55 to 59" ~ "55",            
      Age == "60 to 64" ~ "60",            
      Age == "65 to 69" ~ "65",   
      Age == "70 to 74" ~ "70",            
      Age == "75 to 79" ~ "75",   
      Age == "80 years and over" ~ "80",   
            Age == "All vaccinations" ~ "TOT"   
    ),
    Measure = case_when(
      Measure == "Dose 1" ~ "Vaccination1",
      Measure == "Dose 2" ~ "Vaccination2",
      Measure == "Dose 3" ~ "Vaccination3",
      Measure == "Dose 4" ~ "Vaccination4",
      Measure == "Dose 5" ~ "Vaccination5"
    ),
    Date = as.Date(ymd(Date)
    ),
    AgeInt = case_when(
      Age == "12" ~ 4,
      Age == "16" ~ 2,
      Age == "18" ~ 12,
      Age == "30" ~ 10,
      Age == "40" ~ 10,
      Age == "80" ~ 25,
      Age == "TOT" ~ NA_real_,
      TRUE ~ 5 
    )
    ) %>% 
  filter(Age != "40 years and over",
         Age != "18 years and over",
         Age != "16 years and over") %>% 
  arrange(Date, Sex, Measure, Age) %>% 
  mutate(Date = ddmmyyyy(Date)) %>% 
  mutate(Country = "Scotland",
         Region = "All",
         Metric = "Count",
         Code = paste0("GB-SCT")) %>% 
  sort_input_data()

small_ages <- vacc2 %>% 
  filter(Age == "12") %>% 
  mutate(Age = 0,
         AgeInt = 12L,
         Value = 0)

vacc2 <- rbind(vacc2, small_ages) %>% 
  sort_input_data()
#save output data

write_rds(vacc2, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc2)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(vacc, data_source)


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
