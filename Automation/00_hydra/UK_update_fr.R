# Totals
# set working dir
setwd("/Users/franciscorowe/Dropbox/Francisco/Research/publications/2021/coverage-db/data")
#setwd("/Users/Franciscorowe 1/Dropbox/Francisco/Research/in_progress/coverage-db/data")
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
# https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales

#2020 data
deaths_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2020/publishedweek532020.xlsx"

download.file(deaths_url, destfile = "../data/UKdeaths.xlsx")

#2021 data
# to be updated
deaths_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2021/publishedweek292021.xlsx"

download.file(deaths_url, destfile = "../data/UKdeaths2.xlsx")

X     <- read_xlsx("../data/UKdeaths.xlsx", 
                   sheet = "UK - Covid-19 - Weekly reg", 
                   skip = 5)

X     <- X[9:15, 13:ncol(X)]

X2     <- read_xlsx("../data/UKdeaths2.xlsx", 
                   sheet = "UK - Covid-19 - Weekly reg", 
                   skip = 5)

X2     <- X2[10:16, 3:ncol(X2)]

X <- cbind(X, X2)

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
colnames(X) <- dates

X$Age <- c(0, 1, 15, 45, 65, 75, 85)
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
                         Age == 1 ~ 14,
                         Age == 15 ~ 30,
                         Age == 45 ~ 20,
                         Age == 65 ~ 10,
                         Age == 75 ~ 10,
                         Age == 85 ~ 20),
         Date = ymd(dates),
         Sex = "b",
         Country = "United Kingdom",
         Date = paste(
           sprintf("%02d", day(Date)),
           sprintf("%02d", month(Date)),
           year(Date),
           sep="."),
         Code = paste0("GB", Date),
         Measure = "Deaths",
         Metric = "Count",
         Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
         Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


###########################
# Males

X     <- read_xlsx("../data/UKdeaths.xlsx", 
                   sheet = "UK - Covid-19 - Weekly reg", 
                   skip = 5)

X     <- X[18:24, 13:ncol(X)]

X2     <- read_xlsx("../data/UKdeaths2.xlsx", 
                    sheet = "UK - Covid-19 - Weekly reg", 
                    skip = 5)

X2     <- X2[19:25, 3:ncol(X2)]

X <- cbind(X, X2)

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
colnames(X) <- dates

X$Age <- c(0, 1, 15, 45, 65, 75, 85)
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
    Age == 1 ~ 14,
    Age == 15 ~ 30,
    Age == 45 ~ 20,
    Age == 65 ~ 10,
    Age == 75 ~ 10,
    Age == 85 ~ 20),
    Date = ymd(dates),
    Sex = "m",
    Country = "United Kingdom",
    Date = paste(
      sprintf("%02d", day(Date)),
      sprintf("%02d", month(Date)),
      year(Date),
      sep="."),
    Code = paste0("GB",Date),
    Measure = "Deaths",
    Metric = "Count",
    Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
         Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

###########################
# Females

X     <- read_xlsx("../data/UKdeaths.xlsx", 
                   sheet = "UK - Covid-19 - Weekly reg", 
                   skip = 5)

X     <- X[27:33, 13:ncol(X)]

X2     <- read_xlsx("../data/UKdeaths2.xlsx", 
                    sheet = "UK - Covid-19 - Weekly reg", 
                    skip = 5)

X2     <- X2[31:37, 3:ncol(X2)]

X <- cbind(X, X2)

nweeks <- ncol(X)*7-1

dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
colnames(X) <- dates

X$Age <- c(0, 1, 15, 45, 65, 75, 85)
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
    Age == 1 ~ 14,
    Age == 15 ~ 30,
    Age == 45 ~ 20,
    Age == 65 ~ 10,
    Age == 75 ~ 10,
    Age == 85 ~ 20),
    Date = ymd(dates),
    Sex = "f",
    Country = "United Kingdom",
    Date = paste(
      sprintf("%02d", day(Date)),
      sprintf("%02d", month(Date)),
      year(Date),
      sep="."),
    Code = paste0("GB",Date),
    Measure = "Deaths",
    Metric = "Count",
    Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


# Combining dfs
Deaths <- rbind(Deaths_b, Deaths_m, Deaths_f)


# push output to Drive:  
ss <- "https://docs.google.com/spreadsheets/d/1Xv862F8FU5bZSLAKd2vxMnH4WeOe9VIphVdrTsvaBZU/edit#gid=0"

# This is aggressive. It overwrites the tab. That works for deaths-only so far, but it may need to 
# be more nuanced when cases are added to, if they are retrieved in some other way.

write_sheet(Deaths, ss, sheet = "database")

# checker: https://mpidr.shinyapps.io/cleaning_tracker/
