#Australia vaccine 

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

ctr          <- "Australia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


#make folder on hydra
if (!dir.exists(paste0(dir_n, "Data_sources/", ctr))){
  dir.create(paste0(dir_n, "Data_sources/", ctr))
}




# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# read in data 


IN= read.csv("https://vaccinedata.covid19nearme.com.au/data/air.csv")


#process

Out= IN %>% 
  select(-VALIDATED, -URL, -AIR_AUS_70_PLUS_POPULATION, -AIR_95_PLUS_FEMALE_PCT, -AIR_95_PLUS_MALE_PCT, 
         -AIR_90_94_FEMALE_PCT, -AIR_90_94_MALE_PCT, -AIR_85_89_FEMALE_PCT, -AIR_85_89_MALE_PCT, 
         -AIR_80_84_FEMALE_PCT, -AIR_80_84_MALE_PCT, -AIR_75_79_FEMALE_PCT, -AIR_75_79_MALE_PCT,
         -AIR_70_74_FEMALE_PCT, -AIR_70_74_MALE_PCT,-AIR_65_69_FEMALE_PCT, -AIR_65_69_MALE_PCT,
         -AIR_60_64_FEMALE_PCT, -AIR_60_64_MALE_PCT, -AIR_55_59_FEMALE_PCT, -AIR_55_59_MALE_PCT, 
         -AIR_50_54_FEMALE_PCT, -AIR_50_54_MALE_PCT, -AIR_45_49_FEMALE_PCT, -AIR_45_49_MALE_PCT,
         -AIR_40_44_FEMALE_PCT, -AIR_40_44_MALE_PCT, -AIR_35_39_FEMALE_PCT,-AIR_35_39_MALE_PCT,
         -AIR_30_34_FEMALE_PCT,-AIR_30_34_MALE_PCT, -AIR_25_29_FEMALE_PCT, -AIR_25_29_MALE_PCT, 
         -AIR_20_24_FEMALE_PCT, -AIR_20_24_MALE_PCT , -AIR_16_19_FEMALE_PCT, -AIR_16_19_MALE_PCT)%>%
pivot_longer(!DATE_AS_AT, names_to= "Age", values_to= "Value")%>%
  separate(Age, c("1", "2", "3", "4", "5", "6", "7"), "_")%>%
  filter(`5`!= "POPULATION")%>%
  #remove percent data 
  filter(`6`!= "PCT")%>%
  filter(`2`!= "NSW")%>%
  filter(`2`!= "VIC")%>%
  filter(`2`!= "QLD")%>%
  filter(`2`!= "WA")%>%
  filter(`2`!= "TAS")%>%
  filter(`2`!= "SA")%>%
  filter(`2`!= "ACT")%>%
  filter(`2`!= "NT")%>%
  filter(`2`!= "AUS")%>%
  select(Date= DATE_AS_AT, Age= `2`, Measure= `4`, Value)%>%
  mutate(AgeInt = case_when(
    Age == "16" ~ 4L,
    Age == "95" ~ 10L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 5L))%>%
  mutate(Measure= recode(Measure, 
                         "FIRST"= "Vaccination1", 
                         "SECOND"= "Vaccination2"))%>%
  mutate(
    Sex = "b",
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("AU"),
    Country = "Australia",
    Region = "All")%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  
  

#save output 

write_rds(Out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(Out))
  
  
#Archive 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(IN, data_source)

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
  
  
  















