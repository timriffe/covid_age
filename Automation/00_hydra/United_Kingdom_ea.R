library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))


ctr          <- "United_Kingdom" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# check here for new url:
# https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales

#2020 and 2021 data
# to be updated
deaths_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2021/publishedweek522021.xlsx"
data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths2021",today(), ".xlsx")
download.file(deaths_url, data_source, mode = "wb")

uk20_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2020/publishedweek532020.xlsx"
uk21_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2021/publishedweek522021.xlsx"
data_source_20 <- paste0(dir_n, "Data_sources/", ctr, "/deaths2020",today(), ".xlsx")
data_source_21 <- paste0(dir_n, "Data_sources/", ctr, "/deaths2021",today(), ".xlsx")
download.file(uk20_url, data_source_20, mode = "wb")
download.file(uk21_url, data_source_21, mode = "wb")

# England and Wales 2020 and 2021 ====
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dts <- 
  read_xlsx(data_source_21, 
            sheet = "Covid-19 - Weekly occurrences", 
            skip = 5)

ages <- c('<1', '1-4', '5-9', '10-14', '15-19', '20-24', '25-29', '30-34', 
          '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', 
          '70-74', '75-79', '80-84', '85-89', '90+')

dts2 <- 
  dts %>% 
  select(-1) %>% 
  rename(Age = 1) %>% 
  filter(Age %in% ages) %>% 
  add_column(Sex = c(rep("b", 20), rep("m", 20), rep("f", 20))) %>% 
  select(Age, Sex, everything()) %>% 
  gather(-Age, -Sex, key = Date, value = new_deaths) %>% 
  mutate(Date = as.Date(as.double(Date), origin = "1899-12-30")) %>% 
  drop_na() %>% 
  group_by(Age, Sex) %>% 
  mutate(Value = cumsum(new_deaths)) %>% 
  ungroup() %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = recode(Age,
                      "<1" = "0",
                      "1-" = "1",
                      "5-" = "5")) %>% 
  group_by(Date, Sex) %>% 
  mutate(AgeInt = ifelse(Age == "90", 15, as.numeric(lead(Age)) - as.numeric(Age))) %>% 
  ungroup() %>% 
  mutate(Country = "England and Wales",
         Date = ddmmyyyy(Date),
         Code = "GB-EAW",
         Measure = "Deaths",
         Metric = "Count",
         Region = "All") %>% 
  sort_input_data()


# United Kingdom 2020-2021 ====
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

uk20 <- 
  read_xlsx(data_source_20, 
            sheet = "UK - Covid-19 - Weekly reg", 
            skip = 4)

uk21 <- 
  read_xlsx(data_source_21, 
            sheet = "UK - Covid-19 - Weekly reg", 
            skip = 4)

ages_uk <- c("Under 1 year", "01-14", "15-44", "45-64", "65-74", "75-84", "85+")

uk20_2 <- 
  uk20 %>% 
  select(-1) %>% 
  rename(Age = 1) %>% 
  filter(Age %in% ages_uk) %>% 
  add_column(Sex = c(rep("b", 7), rep("m", 7), rep("f", 7))) %>% 
  select(Age, Sex, everything()) %>% 
  gather(-Age, -Sex, key = Date, value = new_deaths) %>% 
  mutate(Date = as.Date(as.double(Date), origin = "1899-12-30"))

uk21_2 <- 
  uk21 %>% 
  select(-1) %>% 
  rename(Age = 1) %>% 
  filter(Age %in% ages_uk) %>% 
  add_column(Sex = c(rep("b", 7), rep("m", 7), rep("f", 7))) %>% 
  select(Age, Sex, everything()) %>% 
  gather(-Age, -Sex, key = Date, value = new_deaths) %>% 
  mutate(Date = as.Date(as.double(Date), origin = "1899-12-30")) 

uk2021 <- 
  bind_rows(uk20_2, uk21_2) %>% 
  drop_na() %>% 
  group_by(Age, Sex) %>% 
  mutate(Value = cumsum(new_deaths)) %>% 
  ungroup() %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = recode(Age,
                      "Un" = "0",
                      "01" = "1")) %>% 
  group_by(Date, Sex) %>% 
  mutate(AgeInt = ifelse(Age == "85", 20, as.numeric(lead(Age)) - as.numeric(Age))) %>% 
  ungroup() %>% 
  mutate(Country = "United Kingdom",
         Date = ddmmyyyy(Date),
         Code = "GB",
         Measure = "Deaths",
         Metric = "Count",
         Region = "All") %>% 
  sort_input_data()



write_rds(uk2021, paste0(dir_n, "United_Kingdom_ea", ".rds"))

write_rds(dts2, paste0(dir_n, "England_Wales_ea", ".rds"))





# 
# 
# X     <- X[9:15, 13:ncol(X)]
# 
# X2     <- read_xlsx(data_source2, 
#                    sheet = "UK - Covid-19 - Weekly reg", 
#                    skip = 5)
# 
# X2     <- X2[10:16, 3:ncol(X2)]
# 
# X <- cbind(X, X2)
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# X$Age <- c(0, 1, 15, 45, 65, 75, 85)
# colnames(X)
# 
# Deaths_b <- X %>% 
#   pivot_longer(-Age,
#                names_to = "dates",
#                values_to = "Value") %>% 
#   group_by(Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#   mutate(AgeInt = case_when(
#                         Age == 0 ~ 1,
#                          Age == 1 ~ 14,
#                          Age == 15 ~ 30,
#                          Age == 45 ~ 20,
#                          Age == 65 ~ 10,
#                          Age == 75 ~ 10,
#                          Age == 85 ~ 20),
#          Date = ymd(dates),
#          Sex = "b",
#          Country = "United Kingdom",
#          Date = paste(
#            sprintf("%02d", day(Date)),
#            sprintf("%02d", month(Date)),
#            year(Date),
#            sep="."),
#          Code = paste0("GB"),
#          Measure = "Deaths",
#          Metric = "Count",
#          Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#          Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 
# 
# ###########################
# # Males
# 
# X     <- read_xlsx(data_source1, 
#                    sheet = "UK - Covid-19 - Weekly reg", 
#                    skip = 5)
# 
# X     <- X[18:24, 13:ncol(X)]
# 
# X2     <- read_xlsx(data_source2, 
#                     sheet = "UK - Covid-19 - Weekly reg", 
#                     skip = 5)
# 
# X2     <- X2[19:25, 3:ncol(X2)]
# 
# X <- cbind(X, X2)
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# X$Age <- c(0, 1, 15, 45, 65, 75, 85)
# colnames(X)
# 
# Deaths_m <- X %>% 
#   pivot_longer(-Age,
#                names_to = "dates",
#                values_to = "Value") %>% 
#   group_by(Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#   mutate(AgeInt = case_when(
#     Age == 0 ~ 1,
#     Age == 1 ~ 14,
#     Age == 15 ~ 30,
#     Age == 45 ~ 20,
#     Age == 65 ~ 10,
#     Age == 75 ~ 10,
#     Age == 85 ~ 20),
#     Date = ymd(dates),
#     Sex = "m",
#     Country = "United Kingdom",
#     Date = paste(
#       sprintf("%02d", day(Date)),
#       sprintf("%02d", month(Date)),
#       year(Date),
#       sep="."),
#     Code = paste0("GB"),
#     Measure = "Deaths",
#     Metric = "Count",
#     Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#          Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 
# ###########################
# # Females
# 
# X     <- read_xlsx(data_source1, 
#                    sheet = "UK - Covid-19 - Weekly reg", 
#                    skip = 5)
# 
# X     <- X[27:33, 13:ncol(X)]
# 
# X2     <- read_xlsx(data_source2, 
#                     sheet = "UK - Covid-19 - Weekly reg", 
#                     skip = 5)
# 
# X2     <- X2[31:37, 3:ncol(X2)]
# 
# X <- cbind(X, X2)
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("13.03.2020"), (dmy("13.03.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# X$Age <- c(0, 1, 15, 45, 65, 75, 85)
# colnames(X)
# 
# Deaths_f <- X %>% 
#   pivot_longer(-Age,
#                names_to = "dates",
#                values_to = "Value") %>% 
#   group_by(Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#   mutate(AgeInt = case_when(
#     Age == 0 ~ 1,
#     Age == 1 ~ 14,
#     Age == 15 ~ 30,
#     Age == 45 ~ 20,
#     Age == 65 ~ 10,
#     Age == 75 ~ 10,
#     Age == 85 ~ 20),
#     Date = ymd(dates),
#     Sex = "f",
#     Country = "United Kingdom",
#     Date = paste(
#       sprintf("%02d", day(Date)),
#       sprintf("%02d", month(Date)),
#       year(Date),
#       sep="."),
#     Code = paste0("GB"),
#     Measure = "Deaths",
#     Metric = "Count",
#     Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#                 Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 
# 
# # Combining dfs
# Deaths <- rbind(Deaths_b, Deaths_m, Deaths_f)


# write_rds(Deaths, paste0(dir_n, ctr, ".rds"))
# 
# # updating hydra dashboard
# log_update(pp = ctr, N = nrow(Deaths))

