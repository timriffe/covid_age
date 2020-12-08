
source("Automation/00_Functions_automation.R")
library(lubridate)
library(RCurl)
library(readr)
library(tidyverse)

if (! "email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr    <- "Norway"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
NO_dir <- paste0(dir_n, "Data_sources/", ctr, "/")

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# drive urls
rubric <- get_input_rubric() %>% 
  filter(Country == "Norway")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)
ss_db <- rubric %>% 
  dplyr::pull(Source)

###########################################################
# Read in current Norway data
###########################################################
NOin <- get_country_inputDB("NO") %>% 
  select(-Short)

###########################################################
# Detect files to capture
###########################################################

# Cases and Tests only from recent days, because these contain
# longer time series.
check_dates <- seq(today()-7,today(),by="days")

case_urls <- paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_msis_by_time_sex_age_",as.character(check_dates),".csv")

case_data_urls <- rep(FALSE, length(case_urls))
for (i in 1:length(case_urls)){
  case_data_urls[i] <- url.exists(case_urls[i])
  cat(i,"\n")
}

test_urls <- paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_lab_by_time_",as.character(check_dates),".csv")

test_data_urls <- rep(FALSE, length(test_urls))
for (i in 1:length(test_urls)){
  test_data_urls[i] <- url.exists(test_urls[i])
  cat(i,"\n")
}

# Deaths need to be grabbed on a per day basis, 
# so we need to check lots of dates
check_dates_deaths <- seq(ymd("2020-01-01"),today(),by="days")

deaths_urls <- paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_demographics_",as.character(check_dates_deaths),".csv")
death_data_urls <- rep(FALSE, length(deaths_urls))
for (i in 1:length(deaths_urls)){
  death_data_urls[i] <- url.exists(deaths_urls[i])
  cat(i,"\n")
}

###########################################################
# Read in detected files
###########################################################

# Cases and Tests are a single time series
Cases_in  <- read_csv(rev(case_urls[case_data_urls])[1])
Tests_in  <- read_csv(rev(test_urls[test_data_urls])[1])

# Deaths need to be read in in a loop, because they 
# don't contain proper dates
DL <- list()
j <- 1
for (i in 1:length(deaths_urls)){
  if (death_data_urls[i]){
    DL[[j]] <- read_csv(deaths_urls[i]) %>% 
      mutate(Date = check_dates_deaths[i])
    j <- j + 1
  }
}
Deaths_in <- bind_rows(DL)

# Deaths_in <- vroom(deaths_urls[death_data_urls])

###########################################################
# do some preliminary formatting
###########################################################
Cases <-
  Cases_in %>% 
  mutate(Age = recode(age,
      "0-9" = "0",
      "10-19" = "10",
      "20-29" = "20",
      "30-39" = "30",
      "40-49" = "40",
      "50-59" = "50",
      "60-69" = "60",
      "70-79" = "70",
      "80-89" = "80",
      "90+" = "90"),
      Sex = ifelse(sex == "male","m","f")) %>% 
  arrange(Sex, Age, date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(Date = date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Cases",
         AgeInt = ifelse(Age == "90", 15, 10))

# Total Tests
Tests <-
  Tests_in %>% 
  mutate(Age = "TOT",
         Sex = "TOT",
         n = n_pos + n_neg) %>% 
  arrange(date) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(Date = date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Tests",
         AgeInt = NA_real_)
  
# Deaths_in %>% 
#   group_by(Date, sex) %>% 
#   mutate(TOT = sum(n[age != "total"])) %>% 
#   filter(age == "total") %>% 
#   select(Date, sex, n, TOT) %>% 
#   View()

get_zero <- function(chunk){
  if (!"0" %in% chunk$age){
    chunk <- chunk %>% 
    slice(1) %>% 
    mutate(age = "0",
           n=0) %>% 
    bind_rows(chunk)
  }
  chunk
}

Deaths <-
  Deaths_in %>% 
  mutate(Age = recode(age,
                      "0-39" = "0",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80-89" = "80",
                      "90+" = "90",
                      "total" = "TOT"),
         Sex = recode(sex,
                      "male" = "m",
                      "female" = "f",
                      "total" = "b")) %>% 
  group_by(Sex, Date) %>% 
  do(get_zero(chunk = .data)) %>% 
  ungroup() %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(Date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Deaths",
         AgeInt = case_when(Age == "0" ~ 40L,
                            Age == "90" ~15L,
                            Age == "TOT" ~ NA_integer_,
                            TRUE ~ 10L)) %>% 
  filter(Age != "TOT")

###########################################################
# Merge files, create more columns
###########################################################

captured <- 
  Deaths %>% 
  bind_rows(Cases) %>% 
  bind_rows(Tests) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("NO",Date)) 

###########################################################
# bind data, only keeping Deaths prior to just-captured deaths
# treat cases and tests as completely refreshing
###########################################################

minD <- 
  Deaths %>% 
  dplyr::pull(Date) %>% 
  min()

NOout <- 
  NOin %>% 
  filter(Measure == "Deaths",
         dmy(Date) < minD) %>% 
  bind_rows(captured) %>% 
  sort_input_data()

###########################################################
# Push to Drive
###########################################################

write_sheet(NOout,
            ss_i,
            sheet = "database")

N <- nrow(captured)
log_update(pp = "Norway", N = N)


###########################################################
# log source files
###########################################################

write_csv(Deaths_in,"Data/NO_deaths.csv")
write_csv(Cases_in,"Data/NO_cases.csv")
write_csv(Tests_in,"Data/NO_tests.csv")

files <- c("Data/NO_deaths.csv","Data/NO_cases.csv","Data/NO_tests.csv")
#ex_files <- c(paste0(PH_dir, files))

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname,
          files = files, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(files)




