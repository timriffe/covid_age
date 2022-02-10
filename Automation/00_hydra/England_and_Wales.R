library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))


ctr          <- "England_and_Wales" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# load packages
# library(tidyverse)
# library(here)
# library(readxl)
# library(lubridate)
# library(googlesheets4)
# 
# sort_input_data <- function(X){
#   X %>% 
#     mutate(Date2 = dmy(Date)) %>% 
#     arrange(Country,
#             Region,
#             Date2,
#             Code,
#             Sex, 
#             Measure,
#             Metric,
#             suppressWarnings(as.integer(Age))) %>% 
#     dplyr::select(-Date2)
# }

# check here for new url:
# https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales

deaths_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2021/publishedweek292021.xlsx"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths",today(), ".csv")

download.file(deaths_url, data_source, mode = "wb")


X     <- read_xlsx(data_source, 
                   sheet = "Covid-19 - Weekly occurrences", 
                   skip = 5)
X     <- X[6:25,3:(ncol(X)-1)]

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
colnames(X) <- dates

X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
colnames(X)

Deaths_b <- X %>% 
  pivot_longer(-Age,
               names_to = "dates",
               values_to = "Value") %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(AgeInt = case_when(
    Age == 0 ~ 1,
    Age == 1 ~ 4,
    Age == 5 ~ 5,
    Age == 10 ~ 5,
    Age == 15 ~ 5,
    Age == 20 ~ 5,
    Age == 25 ~ 5,
    Age == 30 ~ 5,
    Age == 35 ~ 5,
    Age == 40 ~ 5,
    Age == 45 ~ 5,
    Age == 50 ~ 5,
    Age == 55 ~ 5,
    Age == 60 ~ 5,
    Age == 65 ~ 5,
    Age == 70 ~ 5,
    Age == 75 ~ 5,
    Age == 80 ~ 5,
    Age == 85 ~ 5,
    Age == 90 ~ 15),
    Date = paste(
      sprintf("%02d", day(dates)),
      sprintf("%02d", month(dates)),
      year(dates),
      sep="."),
    Sex = "b",
    Country = "England and Wales",
    Code = paste0("GB-EAW"),
    Measure = "Deaths",
    Metric = "Count",
    Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
         Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


##########################
# Males

X     <- read_xlsx(data_source, 
                   sheet = "Covid-19 - Weekly occurrences", 
                   skip = 5)
X     <- X[28:47,3:(ncol(X)-1)]

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
colnames(X) <- dates


X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
colnames(X)

Deaths_m <- X %>% 
  pivot_longer(-Age,
               names_to = "dates",
               values_to = "Value") %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(AgeInt = case_when(
    Age == 0 ~ 1,
    Age == 1 ~ 4,
    Age == 5 ~ 5,
    Age == 10 ~ 5,
    Age == 15 ~ 5,
    Age == 20 ~ 5,
    Age == 25 ~ 5,
    Age == 30 ~ 5,
    Age == 35 ~ 5,
    Age == 40 ~ 5,
    Age == 45 ~ 5,
    Age == 50 ~ 5,
    Age == 55 ~ 5,
    Age == 60 ~ 5,
    Age == 65 ~ 5,
    Age == 70 ~ 5,
    Age == 75 ~ 5,
    Age == 80 ~ 5,
    Age == 85 ~ 5,
    Age == 90 ~ 15
  ),
  Date = paste(
    sprintf("%02d", day(dates)),
    sprintf("%02d", month(dates)),
    year(dates),
    sep="."),
  Sex = "m",
  Country = "England and Wales",
  Code = paste0("GB-EAW"),
  Measure = "Deaths",
  Metric = "Count",
  Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

##########################
# Females

X     <- read_xlsx(data_source, 
                   sheet = "Covid-19 - Weekly occurrences", 
                   skip = 5)
X     <- X[50:69,3:(ncol(X)-1)]

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
colnames(X) <- dates

X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
colnames(X)

Deaths_f <- X %>% 
  pivot_longer(-Age,
               names_to = "dates",
               values_to = "Value") %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(AgeInt = case_when(
    Age == 0 ~ 1,
    Age == 1 ~ 4,
    Age == 5 ~ 5,
    Age == 10 ~ 5,
    Age == 15 ~ 5,
    Age == 20 ~ 5,
    Age == 25 ~ 5,
    Age == 30 ~ 5,
    Age == 35 ~ 5,
    Age == 40 ~ 5,
    Age == 45 ~ 5,
    Age == 50 ~ 5,
    Age == 55 ~ 5,
    Age == 60 ~ 5,
    Age == 65 ~ 5,
    Age == 70 ~ 5,
    Age == 75 ~ 5,
    Age == 80 ~ 5,
    Age == 85 ~ 5,
    Age == 90 ~ 15
  ),
  Date = paste(
    sprintf("%02d", day(dates)),
    sprintf("%02d", month(dates)),
    year(dates),
    sep="."),
  Sex = "f",
  Country = "England and Wales",
  Code = paste0("GB-EAW"),
  Measure = "Deaths",
  Metric = "Count",
  Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()



# Combining dfs
Deaths <- rbind(Deaths_b, Deaths_m, Deaths_f)

write_rds(Deaths, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Deaths))
