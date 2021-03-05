# Vermont Vaccine 
library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(dplyr)
library(stringr)
library(tidyverse)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "US_Vermont_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#input data 
In= read.csv("https://opendata.arcgis.com/datasets/998b24e2475b4d1999c8c9fd80513ea8_0.csv",  fileEncoding="UTF-8-BOM")


# Age data 

Out_age= In%>%
  select(- Dose_1_Male, -Dose_1_Female, -Dose_1_Sex_Unknown, -Dose_2_Male, -Dose_2_Female, -Dose_2_Sex_Unknown, -FID, Date=Dates) %>% 
  pivot_longer(!Date & !County, names_to= "Age", values_to= "Value")%>%
  mutate(Date= lubridate::mdy(stringr::str_extract(Date,"(?=-).*?$")))%>%
  # aggregate the county level data to state level 
  group_by(Date, Age) %>% 
  summarize(Value = sum(Value), .groups="drop")%>% 
  mutate(Value = case_when(is.na(Value)~ "0",
                           TRUE~ as.character(Value)))%>%
  separate(Age, c("Dose", "Measure", "Age"), "_")%>%
  mutate(Measure= recode(Measure, 
                         `1` = "Vaccination1",
                         `2`= "Vaccination2"))%>%
  mutate(AgeInt = case_when(
    Age == "16" ~ 2L,
    Age == "18" ~ 17L,
    Age == "50"~ 10L,
    Age == "75"~ 30L,
    TRUE~ 15L))%>% 
  mutate(
    Sex = "b",
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_VT",Date),
    Country = "USA",
    Region = "Vermont",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


# Totals by sex 

Out_sex= In %>%
  select(Dose_1_Male,Dose_1_Female,Dose_1_Sex_Unknown, Dose_2_Male, Dose_2_Female, Dose_2_Sex_Unknown, County, Date=Dates) %>% 
  pivot_longer(!Date & !County, names_to= "Sex", values_to= "Value")%>%
  mutate(Date= lubridate::mdy(stringr::str_extract(Date,"(?=-).*?$")))%>%
  # aggregate the county level data to state level 
  group_by(Date, Sex) %>% 
  summarize(Value = sum(Value), .groups="drop")%>% 
  mutate(Value = case_when(is.na(Value)~ "0",
                           TRUE~ as.character(Value)))%>%
  separate(Sex, c("Dose", "Measure", "Sex"), "_")%>%
  mutate(Measure= recode(Measure, 
                         `1` = "Vaccination1",
                         `2`= "Vaccination2"))%>%
  mutate(Sex= recode(Sex, 
                     `Male`= "m",
                     `Female`= "f",
                     `Sex`= "UNK"))%>%
  mutate(
  Metric = "Count",
  Age= "TOT", 
  AgeInt= "") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_VT",Date),
    Country = "USA",
    Region = "Vermont",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)



#########put dataframes together#####

out <- bind_rows(Out_age,
                 Out_sex)

#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_sex_",today(), ".csv")

write_csv(In, data_source)

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













  
 
  
