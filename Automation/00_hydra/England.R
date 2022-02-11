library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))


ctr          <- "England" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


###deaths total country

deaths_url <- "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/01/COVID-19-total-announced-deaths-28-January-2022.xlsx"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths",today(), ".csv")

download.file(deaths_url, data_source, mode = "wb")


# download.file(deaths_url, destfile = ("../data/ENdeaths.xlsx"))

X     <- read_xlsx(data_source, 
               sheet = "Tab3 Deaths by age", 
               skip = 15)
X     <- X[3:7,-c(1,2,3)]

right <- is.na(X) %>%
  colSums() %>%
  '=='(5) %>%
  which() %>%
  '['(1)
X     <- X[,2:(right-1)]

ndays <- ncol(X)

dates <- as.character(seq(dmy("02.03.2020"), (dmy("02.03.2020") + ndays), by="days"))
colnames(X) <- dates

X$Age <- c(0,20,40,60,80)
colnames(X)

Deaths <- X %>% 
  pivot_longer(-Age,
               names_to = "dates",
               values_to = "Value") %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(AgeInt = ifelse(Age == 80, 25, 20),
         Date = ymd(dates),
         Sex = "b",
         Country = "England",
         Date = paste(
           sprintf("%02d", day(dates)),
           sprintf("%02d", month(dates)),
           year(dates),
           sep="."),
         Code = paste0("GB-EN"),
         Measure = "Deaths",
         Metric = "Count",
         Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
         Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()
#########################
##cases total country####
#########################

cases_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newCasesBySpecimenDateAgeDemographics&format=csv"

data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/cases",today(), ".csv")

download.file(cases_url, data_source2, mode = "wb")


# download.file(deaths_url, destfile = ("../data/ENdeaths.xlsx"))

X     <- read_csv(data_source2)

Cases <- X %>% 
  select(Country =areaName, Date = date, Age = age, Value = rollingSum) %>% 
  filter(Age != "00_59",
         Age != "60+") %>% 
  mutate(Region = "All",
         Code = "UK-EN",
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
           sep="."))
  
  
out <- rbind(Deaths, Cases) %>% 
  sort_input_data()


##saving


write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))


