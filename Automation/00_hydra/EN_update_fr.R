# set working dir
#setwd("/Users/franciscorowe/Dropbox/Francisco/Research/publications/2021/coverage-db/data")
getwd()

# load packages
library(tidyverse)
library(here)
library(readxl)
library(lubridate)
library(googlesheets4)

sort_input_data <- function(X){
  X %>% 
    mutate(Date2 = dmy(Date)) %>% 
    arrange(Country,
            Region,
            Date2,
            Code,
            Sex, 
            Measure,
            Metric,
            suppressWarnings(as.integer(Age))) %>% 
    dplyr::select(-Date2)
}

# check here for new url:
# https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-daily-deaths/

deaths_url <- "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/01/COVID-19-total-announced-deaths-28-January-2022.xlsx"

download.file(deaths_url, destfile = ("../data/ENdeaths.xlsx"))

X     <- read_xlsx("../data/ENdeaths.xlsx", 
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
         Code = paste0("GB_EN", Date),
         Measure = "Deaths",
         Metric = "Count",
         Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
         Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

# push output to Drive:  
ss <- "https://docs.google.com/spreadsheets/d/1E7rXv46X_RcQBHNL3YeBC3-JmhhkG4PoJKMsdxQUtvM/edit#gid=0"

# This is aggressive. It overwrites the tab. That works for deaths-only so far, but it may need to 
# be more nuanced when cases are added to, if they are retrieved in some other way.
write_sheet(Deaths, ss, sheet = "database")



