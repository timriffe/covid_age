library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))

if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}
ctr          <- "England" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = email)
gs4_auth(email = email)

###deaths total country

deaths_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newDeaths28DaysByDeathDateAgeDemographics&format=csv"

data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/deaths",today(), ".csv")

download.file(deaths_url, data_source1, mode = "wb")


# download.file(deaths_url, destfile = ("../data/ENdeaths.xlsx"))

deaths_in     <- read_csv(data_source1)


Deaths <- deaths_in %>% 
  select(Country =areaName, Date = date, Age = age, Value = deaths) %>% 
  filter(Age != "00_59",
         Age != "60+") %>% 
  arrange(Date) %>% 
   group_by(Age) %>% 
   mutate(Value = cumsum(Value)) %>% 
  mutate(Region = "All",
         Code = "GB-ENG",
         Metric = "Count",
         Measure = "Deaths",
         Sex = "b",
         Age = case_when(
           Age == "00_04" ~ "0",
           Age == "05_09" ~ "5",
           Age == "10_14" ~ "10",
           Age == "15_19" ~ "15",
           Age == "20_24" ~ "20",
           Age == "25_29" ~ "25",
           Age == "30_34" ~ "30",
           Age == "35_39" ~ "35",
           Age == "40_44" ~ "40",
           Age == "45_49" ~ "45",
           Age == "50_54" ~ "50",
           Age == "55_59" ~ "55",
           Age == "60_64" ~ "60",
           Age == "65_69" ~ "65",
           Age == "70_74" ~ "70",
           Age == "75_79" ~ "75",
           Age == "80_84" ~ "80",
           Age == "85_89" ~ "85",
           Age == "90+" ~ "90",
           Age == "unassigned" ~ "UNK"   
         ),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 5L
         ),
         Date = paste(
           sprintf("%02d", day(Date)),
           sprintf("%02d", month(Date)),
           year(Date),
           sep=".")) %>% 
  sort_input_data()

#########################
##cases total country####
#########################

cases_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newCasesBySpecimenDateAgeDemographics&format=csv"

data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/cases",today(), ".csv")

download.file(cases_url, data_source2, mode = "wb")


# download.file(deaths_url, destfile = ("../data/ENdeaths.xlsx"))

cases_in     <- read_csv(data_source2)

Cases <- cases_in %>% 
  select(Country =areaName, Date = date, Age = age, Value = cases) %>% 
  filter(Age != "00_59",
         Age != "60+") %>% 
   arrange(Date) %>% 
   group_by(Age) %>% 
   mutate(Value = cumsum(Value)) %>% 
  mutate(Region = "All",
         Code = "GB-ENG",
         Metric = "Count",
         Measure = "Cases",
         Sex = "b",
         Age = case_when(
           Age == "00_04" ~ "0",
           Age == "05_09" ~ "5",
           Age == "10_14" ~ "10",
           Age == "15_19" ~ "15",
           Age == "20_24" ~ "20",
           Age == "25_29" ~ "25",
           Age == "30_34" ~ "30",
           Age == "35_39" ~ "35",
           Age == "40_44" ~ "40",
           Age == "45_49" ~ "45",
           Age == "50_54" ~ "50",
           Age == "55_59" ~ "55",
           Age == "60_64" ~ "60",
           Age == "65_69" ~ "65",
           Age == "70_74" ~ "70",
           Age == "75_79" ~ "75",
           Age == "80_84" ~ "80",
           Age == "85_89" ~ "85",
           Age == "90+" ~ "90",
           Age == "unassigned" ~ "UNK"   
         ),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 5L
         ),
         Date = paste(
           sprintf("%02d", day(Date)),
           sprintf("%02d", month(Date)),
           year(Date),
           sep=".")) %>% 
  sort_input_data()
  
  



##regional data
##cases
regional_cases_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=newCasesBySpecimenDateAgeDemographics&format=csv"

data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/regions_Cases",today(), ".csv")

download.file(regional_cases_url, data_source3, mode = "wb")


regional_cases_in     <- read_csv(data_source3)

Regional_Cases <- regional_cases_in %>% 
  select(Region =areaName, Date = date, Age = age, Value = cases) %>% 
  filter(Age != "00_59",
         Age != "60+") %>% 
  arrange(Date) %>% 
  group_by(Region, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  mutate(Country = "England",
         Code = case_when(
           Region == "East Midlands" ~ "GB-EEM+",
           Region == "East of England" ~ "GB-EEOE+",
           Region == "London" ~ "GB-EL+",
           Region == "North East" ~ "GB-ENE+",
           Region == "North West" ~ "GB-ENW+",
           Region == "South East" ~ "GB-ESE+",
           Region == "South West" ~ "GB-ESW+",
           Region == "West Midlands" ~ "GB-EWM+",
           Region == "Yorkshire and The Humber" ~ "GB-EYATH+"),
         Metric = "Count",
         Measure = "Cases",
         Sex = "b",
         Age = case_when(
           Age == "00_04" ~ "0",
           Age == "05_09" ~ "5",
           Age == "10_14" ~ "10",
           Age == "15_19" ~ "15",
           Age == "20_24" ~ "20",
           Age == "25_29" ~ "25",
           Age == "30_34" ~ "30",
           Age == "35_39" ~ "35",
           Age == "40_44" ~ "40",
           Age == "45_49" ~ "45",
           Age == "50_54" ~ "50",
           Age == "55_59" ~ "55",
           Age == "60_64" ~ "60",
           Age == "65_69" ~ "65",
           Age == "70_74" ~ "70",
           Age == "75_79" ~ "75",
           Age == "80_84" ~ "80",
           Age == "85_89" ~ "85",
           Age == "90+" ~ "90",
           Age == "unassigned" ~ "UNK"   
         ),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 5L
         ),
         Date = paste(
           sprintf("%02d", day(Date)),
           sprintf("%02d", month(Date)),
           year(Date),
           sep=".")) %>% 
  sort_input_data()


##subsubtrgional data
subregional_cases_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&metric=newCasesBySpecimenDateAgeDemographics&format=csv"
data_source3.2 <- paste0(dir_n, "Data_sources/", ctr, "/subregions_Cases",today(), ".csv")

download.file(subregional_cases_url, data_source3.2, mode = "wb")


subregional_cases_in     <- read_csv(data_source3.2)


##deaths
regional_death_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=newDeaths28DaysByDeathDateAgeDemographics&format=csv"


data_source4 <- paste0(dir_n, "Data_sources/", ctr, "/regions_Deaths",today(), ".csv")

download.file(regional_death_url, data_source4, mode = "wb")


regional_deaths_in     <- read_csv(data_source4)

Regional_Deaths <- regional_deaths_in %>% 
  select(Region =areaName, Date = date, Age = age, Value = deaths) %>% 
  filter(Age != "00_59",
         Age != "60+") %>% 
  arrange(Date) %>% 
  group_by(Region, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  mutate(Country = "England",
         Code = case_when(
           Region == "East Midlands" ~ "GB-EEM+",
           Region == "East of England" ~ "GB-EEOE+",
           Region == "London" ~ "GB-EL+",
           Region == "North East" ~ "GB-ENE+",
           Region == "North West" ~ "GB-ENW+",
           Region == "South East" ~ "GB-ESE+",
           Region == "South West" ~ "GB-ESW+",
           Region == "West Midlands" ~ "GB-EWM+",
           Region == "Yorkshire and The Humber" ~ "GB-EYATH+"),
         Metric = "Count",
         Measure = "Deaths",
         Sex = "b",
         Age = case_when(
           Age == "00_04" ~ "0",
           Age == "05_09" ~ "5",
           Age == "10_14" ~ "10",
           Age == "15_19" ~ "15",
           Age == "20_24" ~ "20",
           Age == "25_29" ~ "25",
           Age == "30_34" ~ "30",
           Age == "35_39" ~ "35",
           Age == "40_44" ~ "40",
           Age == "45_49" ~ "45",
           Age == "50_54" ~ "50",
           Age == "55_59" ~ "55",
           Age == "60_64" ~ "60",
           Age == "65_69" ~ "65",
           Age == "70_74" ~ "70",
           Age == "75_79" ~ "75",
           Age == "80_84" ~ "80",
           Age == "85_89" ~ "85",
           Age == "90+" ~ "90",
           Age == "unassigned" ~ "UNK"   
         ),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 5L
         ),
         Date = paste(
           sprintf("%02d", day(Date)),
           sprintf("%02d", month(Date)),
           year(Date),
           sep=".")) %>% 
  sort_input_data()


out <- rbind(Deaths, Cases, Regional_Cases, Regional_Deaths) %>% 
  sort_input_data()


##saving

write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))
