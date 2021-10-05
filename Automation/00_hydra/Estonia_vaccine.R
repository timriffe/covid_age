#Estonia vaccine 

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

ctr          <- "Estonia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
# rubric <- get_input_rubric() %>% filter(Short == "EE")
# 
# ss_i <- rubric %>% 
#   dplyr::pull(Sheet)
# 
# ss_db <- rubric %>% 
#   dplyr::pull(Source)
# 
# # reading data from Drive and last date entered 
# 
# In_drive <- get_country_inputDB("EE")%>% 
#   select(-Short)
# #Save entered case and test data  
# 
# drive_archive= In_drive%>%
#   filter(Measure== "Cases"| Measure== "Tests")


#read in vaccine data 

In_vaccine= read.csv("https://opendata.digilugu.ee/opendata_covid19_vaccination_county_agegroup_gender.csv")


#process 

In_vaccine[In_vaccine == ""] <- NA
In_vaccine[In_vaccine == " "] <- NA

Out_vaccine= In_vaccine%>%
  select(Date= ï..StatisticsDate, Age=AgeGroup, Sex= Gender, Value=TotalCount,Measure= VaccinationStatus, Region= CountyEHAK)%>%
  mutate(Sex = case_when(
    is.na(Sex)~ "UNK",
    Sex == "M" ~ "m",
    Sex == "N" ~ "f"))%>%
  mutate(Age = case_when(
    is.na(Age) ~ "UNK",
    TRUE~ as.character(Age)))%>%
  mutate(Region = case_when(
    is.na(Region) ~ "UNK",
    TRUE~ as.character(Region)))%>%
  mutate(Age=recode(Age, 
                    `0-17`="0",
                    `18-29`="18",
                    `30-39`="30",
                    `40-49`="40",
                    `50-59`="50",
                    `60-69`="60",
                    `70-79`="70",
                    `80+`="80",
                    `Unknown`="UNK"))%>% 
  mutate(Measure= recode(Measure,
                         `InProgress`="Vaccination1",
                         `Completed`="Vaccination2"))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "18" ~ 12L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("EE_",Region,Date),
    Country = "Estonia")%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

    
    
#put together with archived data 

# Out= rbind(drive_archive,Out_vaccine)
#     
# write_sheet(Out, 
#             ss = ss_i, 
#             sheet = "database")

write_rds(Out_vaccine, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(Out_vaccine))


# ------------------------------------------
# now archive

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(In_vaccine, data_source)

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

##############################################################################





















