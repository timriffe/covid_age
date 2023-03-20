#Uruguay vaccine 

library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
library(dplyr)
library(tidyverse)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Uruguay_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#read in data 

## Source: https://github.com/3dgiordano/covid-19-uy-vacc-data/

In= read.csv("https://raw.githubusercontent.com/3dgiordano/covid-19-uy-vacc-data/main/data/Age.csv")

#process

Out_vaccine1= In %>%
  select(Date= date, total_12_17, total_18_24, 
         total_25_34, total_35_44, total_45_54,
         total_55_64, total_65_74, total_75_115)%>%
  pivot_longer(!Date, names_to= "Des", values_to= "Value")%>%
  separate(Des, c("A", "Age", "B"), "_")%>%
  select(Date, Age, Value)%>%
  mutate(AgeInt = case_when(
    Age == "12" ~ 6L,
    Age == "18" ~ 7L,
    Age == "75" ~ 30L,
    TRUE ~ 10L)) %>% 
  mutate(
    Measure = "Vaccination1",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("UY"),
    Country = "Uruguay",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
filter(!is.na(Value))#some of the most recent values have no entry



Out_vaccine2= In%>%
select(Date= date,total_fully_12_17,total_fully_18_24, 
       total_fully_25_34, total_fully_35_44, 
       total_fully_45_54, total_fully_55_64,
       total_fully_65_74, total_fully_75_115)%>%
  pivot_longer(!Date, names_to= "Des", values_to= "Value")%>%
  separate(Des, c("A", "B","Age", "C"), "_")%>%
  select(Date, Age, Value)%>%
  mutate(AgeInt = case_when(
    Age == "12" ~ 6L,
    Age == "18" ~ 7L,
    Age == "75" ~ 30L,
    TRUE ~ 10L)) %>% 
  mutate(
    Measure = "Vaccination2",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("UY"),
    Country = "Uruguay",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  filter(!is.na(Value))#some of the most recent values have no entry


#put together 

Out= rbind(Out_vaccine1, Out_vaccine2) %>% 
  sort_input_data()


#save output data

write_rds(Out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(Out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

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






