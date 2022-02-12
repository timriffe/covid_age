# Totals
rm(list=ls())
# set working dir
#setwd("/Users/franciscorowe/Dropbox/Francisco/Research/publications/2021/coverage-db/data")
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
# https://coronavirus.data.gov.uk/details/download

vac_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=vaccinationsAgeDemographics&format=csv"

download.file(vac_url, destfile = "../data/ENvaccines.csv")

X     <- read_csv("../data/ENvaccines.csv")

X <- X %>% mutate(date2 = as.character(as.Date(date, "%Y-%m-%d"),"%d.%m.%Y"))


Vaccine_b <- X %>% 
  mutate(
    Country = "England",
    Region = "All",
    Code = paste0("GB-EN", date2),
    Date = date2,
    Sex = "b",
    Age = "TOT",
    AgeInt = "TOT",
    Metric = "Count",
    Measure = "Vaccinations",
    Value = newPeopleVaccinatedCompleteByVaccinationDate
  ) %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) 

###########################
# First dose

vac1_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=newPeopleVaccinatedFirstDoseByPublishDate&format=csv"

download.file(vac1_url, destfile = "../data/UKvaccines1.csv")

X     <- read_csv("../data/UKvaccines1.csv")

X <- X %>% mutate(date2 = as.character(as.Date(date, "%Y-%m-%d"),"%d.%m.%Y"))


Vaccine_1 <- X %>% 
  mutate(
    Country = "United Kingdom",
    Region = "All",
    Code = paste0("GB", date2),
    Date = date2,
    Sex = "b",
    Age = "TOT",
    AgeInt = "TOT",
    Metric = "Count",
    Measure = "Vaccination1",
    Value = newPeopleVaccinatedFirstDoseByPublishDate
  ) %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) 

###########################
# Second dose

vac2_url <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=overview&metric=newPeopleVaccinatedSecondDoseByPublishDate&format=csv"

download.file(vac2_url, destfile = "../data/UKvaccines2.csv")

X     <- read_csv("../data/UKvaccines2.csv")

X <- X %>% mutate(date2 = as.character(as.Date(date, "%Y-%m-%d"),"%d.%m.%Y"))


Vaccine_2 <- X %>% 
  mutate(
    Country = "United Kingdom",
    Region = "All",
    Code = paste0("GB", date2),
    Date = date2,
    Sex = "b",
    Age = "TOT",
    AgeInt = "TOT",
    Metric = "Count",
    Measure = "Vaccination2",
    Value = newPeopleVaccinatedSecondDoseByPublishDate
  ) %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) 


# Combining dfs
vaccines <- rbind(Vaccine_b, Vaccine_1, Vaccine_2)

# push output to Drive:  
ss <- "https://docs.google.com/spreadsheets/d/1vsTtHTJiFn32sXFEJC__UR_knX6nrMiVTSxu_BAAE8Q/edit#gid=0"

# This is aggressive. It overwrites the tab. That works for deaths-only so far, but it may need to 
# be more nuanced when cases are added to, if they are retrieved in some other way.

write_sheet(vaccines, ss, sheet = "database")

# checker: https://mpidr.shinyapps.io/cleaning_tracker/


  