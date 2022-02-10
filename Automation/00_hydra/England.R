library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))


ctr          <- "England" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



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

write_rds(Deaths, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Deaths))


