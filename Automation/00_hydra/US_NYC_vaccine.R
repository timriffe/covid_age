#New york vaccine 

library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
library(dplyr)
library(tidyverse)
library(readxl)
library(googledrive)
library(purrr)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "US_NYC_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#read previous data 

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))

# Once-off fix:
# DataArchive <-
#   DataArchive %>% 
#   mutate(AgeInt = as.integer(AgeInt))

#automated process from github

In <- read.csv("https://raw.githubusercontent.com/nychealth/covid-vaccine-data/main/people/coverage-by-demo-allages.csv")

#age data both sexes

out_vaccine_age <-
  In %>% 
  dplyr::filter(SUBGROUP %in% c( "0-17","18-24","25-34","35-44","45-54","55-64","65-74","75-84","85+")) %>%
  select(Age = SUBGROUP,
         Date = DATE,
         Vaccination2 = COUNT_FULLY_CUMULATIVE, 
         Vaccination1 = COUNT_1PLUS_CUMULATIVE)%>%
  pivot_longer(!Date & !Age, names_to= "Measure", values_to= "Value")%>%
  mutate(Age=recode(Age, 
                    `0-17`="0",
                    `18-24`="18",
                    `25-34`="25",
                    `35-44`="35",
                    `45-54`="45",
                    `55-64`="55",
                    `65-74`="65",
                    `75-84`="75",
                    `85+`="85")) %>% 
  mutate(
    AgeInt = case_when(
               Age == "0" ~ 18L,
               Age== "18" ~ 7L,
               Age == "85" ~ 20L,
               TRUE ~ 10L),
    AgeInt = as.character(AgeInt),
    Sex = "b",
    Metric = "Count",
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = paste0("US-NYC+"),
    Country = "USA",
    Region = "New York City",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)



#totals by sex 


Sex_out_vaccine <-
  In %>%
  subset(SUBGROUP %in% c("Female","Male")) %>%
  select(Sex = SUBGROUP, 
         Date = DATE, 
         Vaccination2 = COUNT_FULLY_CUMULATIVE, 
         Vaccination1 = COUNT_1PLUS_CUMULATIVE)%>%
  pivot_longer(!Date & !Sex, names_to = "Measure", values_to = "Value")%>%
  mutate(Sex = recode(Sex, 
                    `Female`="f",
                    `Male`="m"),
    AgeInt = NA_integer_,
    AgeInt = as.character(AgeInt),
    Metric = "Count",
    Age = "TOT",
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "US-NYC+",
    Country = "USA",
    Region = "New York City",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)



#put together and append prev data
out <-
  bind_rows(DataArchive,
            out_vaccine_age, 
            Sex_out_vaccine) %>% 
  distinct() %>% 
  sort_input_data()
#out= rbind(manual_data, out_vaccine_age, Sex_out_vaccine)

#save output 

write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

#archive data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(In,data_source)


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



#process manually saved data from website, before git hub page existed 
#Read in Age data 

#xlsx_dir <- "U:/COVerAgeDB/Datenquellen/Vaccination/New York_Vaccine"

#all_paths <-
#list.files(path = xlsx_dir,
# pattern = "Vaccine.xlsx",
#full.names = TRUE)

#all_content <-
# all_paths %>%
# lapply(read_xlsx)

#all_filenames <- all_paths %>%
# basename() %>%
#as.list()

#include filename to get date from filename 
#all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

#Age_in <- rbindlist(all_lists, fill = T)


#colnames(Age_in)[2] <- "Age" 
#Age_out= Age_in %>%
#subset(Age== "<18" | Age== "18-24" | Age== "25-34" |Age== "35-44" |Age== "45-54" |Age== "55-64" |Age== "65-74" |
#      # Age== "75-84" |Age== "85+")%>%
#select(Age, V1, Vaccination2= `Fully Vaccinated`, Vaccination1= `At Least 1 Dose`)%>%
#pivot_longer(!V1 & !Age, names_to= "Measure", values_to= "Value")%>%
#mutate(Age=recode(Age, 
#`<18`="0",
#`18-24`="18",
#`25-34`="25",
#`35-44`="35",
# `45-54`="45",
# `55-64`="55",
#`65-74`="65",
#`75-84`="75",
#`85+`="85"))%>% 
#mutate(AgeInt = case_when(
#Age == "0" ~ 18L,
# Age== "18" ~ 7L,
# Age == "85" ~ 20L,
# TRUE ~ 10L))%>%
#separate(V1, c("1","2","Date","3"), "_")%>% 
# mutate(
# Sex = "b",
#Metric = "Count") %>% 
#mutate(
#Date = dmy(Date),
#Date = paste(sprintf("%02d",day(Date)),    
# sprintf("%02d",month(Date)),  
# year(Date),sep="."),
#Code = paste0("US_NY",Date),
# Country = "USA",
# Region = "New York",)%>% 
#select(Country, Region, Code, Date, Sex, 
#Age, AgeInt, Metric, Measure, Value)

#data by sex 

#Sex_out= Age_in %>%
#rename(Sex= Age)%>%
#subset(Sex== "Female" | Sex== "Male")%>%
#select(Sex, V1, Vaccination2= `Fully Vaccinated`, Vaccination1= `At Least 1 Dose`)%>%
#pivot_longer(!V1 & !Sex, names_to= "Measure", values_to= "Value")%>%
#mutate(Sex=recode(Sex, 
# `Female`="f",
# `Male`="m"))%>% 
# separate(V1, c("1","2","Date","3"), "_")%>% 
# mutate(
# AgeInt = "",
# Metric = "Count",
# Age= "TOT") %>% 
#mutate(
# Date = dmy(Date),
#Date = paste(sprintf("%02d",day(Date)),    
#  sprintf("%02d",month(Date)),  
#  year(Date),sep="."),
# Code = paste0("US_NY",Date),
# Country = "USA",
# Region = "New York",)%>% 
#select(Country, Region, Code, Date, Sex, 
# Age, AgeInt, Metric, Measure, Value)

#Read in totals 

#xlsx_dir <- "U:/COVerAgeDB/Datenquellen/Vaccination/New York_Vaccine"

#all_paths <-
#list.files(path = xlsx_dir,
# pattern = "Vaccine_Total.xlsx",
#full.names = TRUE)

#all_content <-
#all_paths %>%
#lapply(read_xlsx)

#all_filenames <- all_paths %>%
# basename() %>%
# as.list()

#include filename to get date from filename 
#all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

#total_in <- rbindlist(all_lists, fill = T)


#colnames(total_in)[1] <- "Age" 
#total_out= total_in%>%
#select(Age, Vaccination2= `Fully Vaccinated (count)`, Vaccination1= `At Least 1 Dose (count)`, V1)%>%
#subset(Age== "NYC")%>% #age data refers to NCY citisenz 
#pivot_longer(!V1 & !Age, names_to= "Measure", values_to= "Value")%>% 
# separate(V1, c("1","2","Date","3", "4"), "_")%>%
#mutate(Age=recode(Age, 
# `Total`="TOT"))%>%
# mutate(
#AgeInt = "",
# Metric = "Count",
#Sex= "b") %>% 
# mutate(
#Date = dmy(Date),
#Date = paste(sprintf("%02d",day(Date)),    
# sprintf("%02d",month(Date)),  
# year(Date),sep="."),
#Code = paste0("US_NY",Date),
#Country = "USA",
#Region = "New York",)%>% 
#select(Country, Region, Code, Date, Sex, 
# Age, AgeInt, Metric, Measure, Value)


#put together
#manual_data= rbind(Sex_out,Age_out,total_out)

##############################################################################################






