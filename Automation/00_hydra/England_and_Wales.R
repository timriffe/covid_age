library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)
source(here::here("Automation/00_Functions_automation.R"))


if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
  email <- "mumanal.k@gmail.com"
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

ctr          <- "England_and_Wales" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


## MK, 10.11.2022: since the data are published weekly in separate excel files, so I here scrape all the xls files and download and merge.
## these data are only on Deaths in England and Wales. 

# check here for new url:
# https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales


main_link <- "https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales"


excel_links <- scraplinks(main_link) %>% 
  filter(str_detect(link, "xls")) %>% 
  mutate(year = str_extract(url, "\\d+"),
         year = as.integer(year)) %>% 
 # filter(year >= 2020) %>% 
  filter(year >= 2022) %>% # to get the weekly updates ## 
  mutate(url = paste0("https://www.ons.gov.uk", url),
         destinations = paste0(dir_n, "Data_sources/", ctr, "/COVID-WeeklyData-", year, ".xlsx"))  
  
  
excel_links %>% 
  {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


deaths.list <-list.files(
  path= paste0(dir_n, "Data_sources/", ctr),
  pattern = ".xlsx",
  full.names = TRUE)


## Function to extract the sheet and process the data -hopefully!-

## it turns out that 2021 file has the Weekly new deaths data for 2020 & 2021 

read_process <- function(year_select, sheet_name, col_remove){
  
  raw_deaths <- data.frame(file_name = deaths.list) %>% 
    dplyr::mutate(year = str_extract(file_name, "\\d+")) %>% 
    dplyr::filter(year == year_select) %>% #sheets are different 
    dplyr::pull(file_name) %>% 
    purrr::set_names() %>% 
    purrr::map_dfr(~read_excel(., sheet = sheet_name, skip = 5), .id = "file_name") 
  
  raw_deaths %>% 
    dplyr::select(-c("file_name", "Week ended")) %>% 
    dplyr::rename(info = "...2") %>% 
    dplyr::mutate(Sex = case_when(str_detect(info, "Females") ~ "f",
                                  str_detect(info, "Males") ~ "m",
                                  TRUE ~ NA_character_)) %>% 
    tidyr::fill(Sex, .direction = "down") %>% 
    dplyr::mutate(Sex = replace_na(Sex, "b")) %>% 
    dplyr::filter(across(.cols = -c("Sex"), 
                         ~!is.na(.))) %>% 
    tidyr::separate(col = "info", into = c("info", "nothing"), sep = "[+-]") %>% 
    dplyr::mutate(info = case_when(info == "<1" ~ 0L,
                                   TRUE ~ as.integer(info))) %>% 
    dplyr::filter(!is.na(info)) %>% 
    dplyr::mutate(Age = as.character(info)) %>% 
    dplyr::select(-c("info", "nothing", col_remove)) %>% 
    tidyr::pivot_longer(-c("Age", "Sex"),
                        names_to = "date_prep",
                        values_to = "Value") %>%
    dplyr::mutate(date_prep = as.Date(as.numeric(date_prep), origin = "1899-12-30")) 

}


#Out_2020 <- read_process("2020", "Covid-19 - Weekly occurrences", `1 to 53`)

process_2021 <- read_process("2021", "Covid-19 - Weekly occurrences", "...108")

## ===========


## 2022 

raw_deaths_2022 <- data.frame(file_name = deaths.list) %>% 
  dplyr::mutate(year = str_extract(file_name, "\\d+")) %>% 
  dplyr::filter(year == "2022") %>% #sheets are different 
  dplyr::pull(file_name) %>% 
  purrr::set_names() %>% 
  ## we select deaths occurrences, then here I select occurrences 2022, and filter out 2021 data 
  purrr::map_dfr(~read_excel(., sheet = "5", skip = 6), .id = "file_name") 

processed_data2022 <- raw_deaths_2022 %>% 
  dplyr::select(-c("file_name", "All ages")) %>% 
  dplyr::rename(info = "Week number",
                date_prep = "Week ending") %>% 
  dplyr::mutate(Sex = case_when(str_detect(info, "females") ~ "f",
                                str_detect(info, "males") ~ "m",
                                TRUE ~ NA_character_)) %>% 
  tidyr::fill(Sex, .direction = "down") %>% 
  dplyr::mutate(Sex = replace_na(Sex, "b"),
                date_prep = as.Date(as.numeric(date_prep), origin = "1899-12-30"),
                info = as.integer(info)) %>% 
  dplyr::filter(!is.na(info)) %>% 
  dplyr::select(-c("info")) %>% 
  tidyr::pivot_longer(-c("date_prep", "Sex"),
                      names_to = "Age",
                      values_to = "Value") %>%
  tidyr::separate(col = "Age", into = c("Age", "nothing"), sep = "[+-]") %>% 
  dplyr::mutate(Age = case_when(Age == "<1" ~ "0",
                                Age == "01" ~ "1",
                                Age == "05" ~ "5",
                                TRUE ~ Age),
                Value = as.numeric(Value)) %>% 
  dplyr::select(-c("nothing")) %>% 
  dplyr::filter(date_prep > "2021-12-31")



process_all <- dplyr::bind_rows(process_2021, processed_data2022) %>% 
  dplyr::group_by(Sex, Age) %>% 
  dplyr::arrange(date_prep) %>% 
  dplyr::mutate(Value = cumsum(Value)) %>% 
  dplyr::ungroup()


Out <- process_all %>% 
  dplyr::mutate(AgeInt = case_when(Age == "0" ~ 1L,
                                   Age == "1" ~ 4L,
                                   Age == "90" ~ 15L,
                                   TRUE ~ 5L),
                Date = ddmmyyyy(date_prep),
                Country = "England and Wales",
                Code = paste0("GB-EAW"),
                Measure = "Deaths",
                Metric = "Count",
                Region = "All") %>% 
  dplyr::select(Country, Region, Code, Date, 
                Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

 
write_rds(Out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Out))

## END ## 


## HISTORICAL CODE ====================================


# 
# 
# deaths_url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2021/publishedweek292021.xlsx"
# 
# data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths",today(), ".csv")
# 
# download.file(deaths_url, data_source, mode = "wb")
# 
# 
# X     <- read_xlsx(data_source, 
#                    sheet = "Covid-19 - Weekly occurrences", 
#                    skip = 5)
# X     <- X[6:25,3:(ncol(X)-1)]
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
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
#     Age == 0 ~ 1,
#     Age == 1 ~ 4,
#     Age == 5 ~ 5,
#     Age == 10 ~ 5,
#     Age == 15 ~ 5,
#     Age == 20 ~ 5,
#     Age == 25 ~ 5,
#     Age == 30 ~ 5,
#     Age == 35 ~ 5,
#     Age == 40 ~ 5,
#     Age == 45 ~ 5,
#     Age == 50 ~ 5,
#     Age == 55 ~ 5,
#     Age == 60 ~ 5,
#     Age == 65 ~ 5,
#     Age == 70 ~ 5,
#     Age == 75 ~ 5,
#     Age == 80 ~ 5,
#     Age == 85 ~ 5,
#     Age == 90 ~ 15),
#     Date = paste(
#       sprintf("%02d", day(dates)),
#       sprintf("%02d", month(dates)),
#       year(dates),
#       sep="."),
#     Sex = "b",
#     Country = "England and Wales",
#     Code = paste0("GB-EAW"),
#     Measure = "Deaths",
#     Metric = "Count",
#     Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#          Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 
# 
# ##########################
# # Males
# 
# X     <- read_xlsx(data_source, 
#                    sheet = "Covid-19 - Weekly occurrences", 
#                    skip = 5)
# X     <- X[28:47,3:(ncol(X)-1)]
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# 
# X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
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
#     Age == 1 ~ 4,
#     Age == 5 ~ 5,
#     Age == 10 ~ 5,
#     Age == 15 ~ 5,
#     Age == 20 ~ 5,
#     Age == 25 ~ 5,
#     Age == 30 ~ 5,
#     Age == 35 ~ 5,
#     Age == 40 ~ 5,
#     Age == 45 ~ 5,
#     Age == 50 ~ 5,
#     Age == 55 ~ 5,
#     Age == 60 ~ 5,
#     Age == 65 ~ 5,
#     Age == 70 ~ 5,
#     Age == 75 ~ 5,
#     Age == 80 ~ 5,
#     Age == 85 ~ 5,
#     Age == 90 ~ 15
#   ),
#   Date = paste(
#     sprintf("%02d", day(dates)),
#     sprintf("%02d", month(dates)),
#     year(dates),
#     sep="."),
#   Sex = "m",
#   Country = "England and Wales",
#   Code = paste0("GB-EAW"),
#   Measure = "Deaths",
#   Metric = "Count",
#   Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#                 Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 
# ##########################
# # Females
# 
# X     <- read_xlsx(data_source, 
#                    sheet = "Covid-19 - Weekly occurrences", 
#                    skip = 5)
# X     <- X[50:69,3:(ncol(X)-1)]
# 
# nweeks <- ncol(X)*7-1
# 
# dates <- as.character(seq(dmy("03.01.2020"), (dmy("03.01.2020") + nweeks), by="weeks"))
# colnames(X) <- dates
# 
# X$Age <- c(0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
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
#     Age == 1 ~ 4,
#     Age == 5 ~ 5,
#     Age == 10 ~ 5,
#     Age == 15 ~ 5,
#     Age == 20 ~ 5,
#     Age == 25 ~ 5,
#     Age == 30 ~ 5,
#     Age == 35 ~ 5,
#     Age == 40 ~ 5,
#     Age == 45 ~ 5,
#     Age == 50 ~ 5,
#     Age == 55 ~ 5,
#     Age == 60 ~ 5,
#     Age == 65 ~ 5,
#     Age == 70 ~ 5,
#     Age == 75 ~ 5,
#     Age == 80 ~ 5,
#     Age == 85 ~ 5,
#     Age == 90 ~ 15
#   ),
#   Date = paste(
#     sprintf("%02d", day(dates)),
#     sprintf("%02d", month(dates)),
#     year(dates),
#     sep="."),
#   Sex = "f",
#   Country = "England and Wales",
#   Code = paste0("GB-EAW"),
#   Measure = "Deaths",
#   Metric = "Count",
#   Region = "All") %>% 
#   dplyr::select(Country, Region, Code, Date, 
#                 Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()
# 

# 
# # Combining dfs
# Deaths <- rbind(Deaths_b, Deaths_m, Deaths_f)


