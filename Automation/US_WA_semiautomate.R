### WASHINGTON STATE CASES AND DEATHS ###

# Libraries ---------------------------------------------------------------

library(readxl)
library(tidyverse)
library(lubridate)
library(here)
library(googlesheets4)

# Load data ---------------------------------------------------------------

ws_cases <- read_excel(path = here("Data","PUBLIC-CDC-Event-Date-SARS.xlsx"), sheet = 1)
ws_deaths <- read_excel(path = here("Data","PUBLIC-CDC-Event-Date-SARS.xlsx"), sheet = 2)

# Manage cases ------------------------------------------------------------

#long format
ws_cases_long <- 
  ws_cases %>% 
  mutate(Day2 = ymd(WeekStartDate)) %>% 
  group_by(County,Day2) %>% 
  pivot_longer(cols = c(NewPos_All,
                        `Age 0-19`,
                        `Age 20-39`,
                        `Age 40-59`,
                        `Age 60-79`,
                        `Age 80+`,
                        `Positive UnkAge`),
               names_to = "age_class",
               values_to = "cases") %>% 
  mutate(age_class = as.factor(age_class)) %>% 
  arrange(age_class,Day2) %>% 
  select(-dtm_updated) %>% 
  ungroup()

#calculate new cases by age_group per day
ws_cases_final <- 
  ws_cases_long %>% 
  group_by(Day2,WeekStartDate,age_class) %>% 
  mutate(cases_cum = cumsum(cases)) %>% 
  summarise(cases_new = max(cases_cum)) %>% 
  ungroup()

#calculate total cases by age_group
ws_cases_final <- 
  ws_cases_final %>% 
  group_by(age_class) %>% 
  arrange(age_class,Day2) %>% 
  mutate(cases_new_cum = cumsum(cases_new)) %>% 
  arrange(Day2,age_class) %>% 
  ungroup()

#formatting as it is in the spreadsheet
ws_cases_spreadsheet <- 
  ws_cases_final %>%
  separate(WeekStartDate, into = c("Y","M","D"), sep = "-") %>% 
  mutate(Country = "USA",
         Region = "Washington",
         Date = paste(D, ".", M, ".", Y, sep = ""),
         Code = paste("US_WA", Date, sep = ""),
         Sex = "b",
         Age = as.factor(case_when(age_class == "NewPos_All" ~ "TOT",
                                   age_class == "Age 0-19" ~ "0",
                                   age_class == "Age 20-39" ~ "20",
                                   age_class == "Age 40-59" ~ "40",
                                   age_class == "Age 60-79" ~ "60",
                                   age_class == "Age 80+" ~ "80",
                                   age_class == "Positive UnkAge" ~ "UNK")),
         AgeInt = as.factor(case_when(Age %in% c("TOT","UNK") ~ "NA",
                                      Age %in% c("0",
                                                 "20",
                                                 "40",
                                                 "60") ~ "20",
                                      Age == "80" ~ "25")),
         Metric = "Count",
         Measure = "Cases",
         Value = cases_new_cum) %>% 
  select(Country, Region, Date, Code, Sex, Age, AgeInt, Metric, Measure, Value, Day2)

# Manage deaths -----------------------------------------------------------

#long format
ws_deaths_long <- 
  ws_deaths %>% 
  mutate(Day2 = ymd(WeekStartDate)) %>% 
  group_by(County,Day2) %>% 
  pivot_longer(cols = c(Deaths,
                        `Age 0-19`,
                        `Age 20-39`,
                        `Age 40-59`,
                        `Age 60-79`,
                        `Age 80+`,
                        `Positive UnkAge`),
               names_to = "age_class",
               values_to = "deaths") %>% 
  mutate(age_class = as.factor(age_class)) %>% 
  arrange(age_class,Day2) %>% 
  select(-dtm_updated) %>% 
  ungroup()

#calculate new deaths by age_group per day
ws_deaths_final <- 
  ws_deaths_long %>% 
  group_by(Day2,WeekStartDate,age_class) %>% 
  mutate(deaths_cum = cumsum(deaths)) %>% 
  summarise(deaths_new = max(deaths_cum)) %>% 
  ungroup()

#calculate total deaths by age_group
ws_deaths_final <- 
  ws_deaths_final %>% 
  group_by(age_class) %>% 
  arrange(age_class,Day2) %>% 
  mutate(deaths_new_cum = cumsum(deaths_new)) %>% 
  arrange(Day2,age_class) %>% 
  ungroup()

#formatting as it is in the spreadsheet
ws_deaths_spreadsheet <- 
  ws_deaths_final %>%
  separate(WeekStartDate, into = c("Y","M","D"), sep = "-") %>% 
  mutate(Country = "USA",
         Region = "Washington",
         Date = paste(D, ".", M, ".", Y, sep = ""),
         Code = paste("US_WA", Date, sep = ""),
         Sex = "b",
         Age = as.factor(case_when(age_class == "Deaths" ~ "TOT",
                                   age_class == "Age 0-19" ~ "0",
                                   age_class == "Age 20-39" ~ "20",
                                   age_class == "Age 40-59" ~ "40",
                                   age_class == "Age 60-79" ~ "60",
                                   age_class == "Age 80+" ~ "80",
                                   age_class == "Positive UnkAge" ~ "UNK")),
         AgeInt = as.factor(case_when(Age %in% c("TOT","UNK") ~ "NA",
                                      Age %in% c("0",
                                                 "20",
                                                 "40",
                                                 "60") ~ "20",
                                      Age == "80" ~ "25")),
         Metric = "Count",
         Measure = "Deaths",
         Value = deaths_new_cum) %>% 
  select(Country, Region, Date, Code, Sex, Age, AgeInt, Metric, Measure, Value, Day2)

# Preparing to push -------------------------------------------------------

ws_spreadsheet <- 
  rbind(ws_cases_spreadsheet, ws_deaths_spreadsheet) %>% 
  mutate(Age = factor(Age, levels(Age)[c(1,2,3,4,5,7,6)])) %>%
  arrange(Day2, Measure, Age) %>% 
  select(-Day2) #it was useful to arrange the dataset


# Push dataframe ----------------------------------------------------------

sheet_write(ws_spreadsheet, 
             ss = "https://docs.google.com/spreadsheets/blablalba_huge_ugly_link_goes_here", 
             sheet = "database")
