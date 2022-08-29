##norway vaccines
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here::here("Automation/00_Functions_automation.R"))
if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Norway_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Norway/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## MK: 11.07.2022

# load packages 
library(tidyverse)
library(RSelenium)
library(netstat)
library(jsonlite)
library(rvest)
library(xml2)

## SCRAPPE THE DOWNLOAD LINK ##

## This is not working on Hydra, so I just keep the code for reference.

# driver <- rsDriver(
#   browser = "firefox",
#   # in case broswer = "chrome", get the chrome://version/ in the browser
#   #then binman::list_versions("chromedriver") in the console
#  # chromever = "103.0.5060.53",
#   verbose = FALSE,
#   port = free_port()
# )
# 
# remDr <- driver$client
# #remDr$open()
#  
# path <- "https://statistikk.fhi.no/sysvak/antall-vaksinerte?etter=diagnose&fordeltPaa=alder&diagnose=COVID_19&dose=01,02,03,04&kjonn=K,M"
# remDr$navigate(path)
# Sys.sleep(5)
# remDr$findElement(using = "class", "fhi-btn-fa-and-text__text")$clickElement()
# 
# last_ned <- remDr$findElement(using = "class", "fhi-btn-fa-and-text__text")
# remDr$mouseMoveToLocation(webElement = last_ned)
# remDr$findElement(using = "class", 
#                   value = "dropdown-item fhi-dropdown-last-ned__option")$clickElement()
# 
# 
# 
# remDr$quit()


## This is not working on Hydra, so I just keep the code for reference. 
## will add the date as of today()
# 
# find_date <- remDr$findElement(using = 'xpath',
#                                value = '//span[@class="highcharts-caption"]')
# date_extract <- find_date$getElementText()[[1]] 
# 
# date_number <- date %>% parse_number()
# 
# date_update <- date %>% 
#   str_extract_all("[0-9]+") %>% 
#   unlist()
# 
# date <- date_update[1:3] %>% paste(collapse = '.')

## THESE DATA ARE CUMLATIVE ## 

api <- "https://statistikk.fhi.no/api/sysvak/v0/vaccinations?columns=diagnose&rows=alder&diagnosisList=COVID_19&sexesList=K,M&dosesList=01,02,03,04"

data_today <- jsonlite::fromJSON(api)[['groupings']] %>%
  tidyr::unnest_wider(column) %>%
  select('Measure' = 2,
         'Sex' = 3,
         "Age" = 4,
         "Value" = 5) 
  
vacc_today <- data_today %>% 
  dplyr::mutate(
    Value = as.integer(Value),
    Value = replace_na(Value, 0),
    Date = today(),
    Date = ymd(Date),
    Sex = case_when(Sex == "Kvinne" ~ "f",
                    Sex == "Mann" ~ "m"),
    Measure = case_when(Measure == "Dose 1" ~ "Vaccination1",
                        Measure == "Dose 2" ~ "Vaccination2",
                        Measure == "Dose 3" ~ "Vaccination3",
                        Measure == "Dose 4" ~ "Vaccination4"),
    Age = str_extract(Age, pattern = "\\d+"),
    AgeInt=case_when(
      Age == "12" ~ 4L,
      Age == "16" ~ 2L,
      Age == "18" ~ 7L,
      Age == "25" ~ 15L,
      Age == "40" ~ 5L,
      Age == "45" ~ 10L,
      Age == "55" ~ 10L,
      Age == "65" ~ 10L,
      Age == "75" ~ 5L,
      Age == "80" ~ 5L,
      Age == "85" ~ 20L),
    Metric = "Count",
    Code = paste0("NO"),
    Country = "Norway",
    Region = "All") %>% 
  select(Country, Region, Code, 
         Date, Age, AgeInt, Sex, Measure, Metric, Value)


## IN CASE NEEDED: HISTORIC DATA reading; cleaning and merging;
## from 13.03.2021 till 11.07.2022
## these historical data is by day, so we have to cumsum. 

# 
#  path_csv <- paste0(dir_n_source, "csvSources/")
# 
# 
#  file_1 <- read.csv(paste0(path_csv, "2022-07-12.antall-vaksinasjoner-etter-sykdom-fordelt-på-dag-13.03.2021-01.07.2021.csv"))
#  file_2 <- read.csv(paste0(path_csv, "2022-07-12.antall-vaksinasjoner-etter-sykdom-fordelt-på-dag-02.07.2021-01.01.2022.csv"))
#  file_3 <- read.csv(paste0(path_csv, "2022-07-12.antall-vaksinasjoner-etter-sykdom-fordelt-på-dag-01.01.2022-11.07.2022.csv"))
# 
# 
# # FUNCTION TO clean data
# # since variables names are not consistent;
# # I prefer to read each separately first then bind rows when data manipulation is done ##
#  data_prep <- function(file_name){
# 
#    str_split_fixed(string = file_name$ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI,
#                    pattern = ";",
#                    n = 100) %>%
#      as.data.frame() %>%
#      dplyr::mutate(V1 = case_when(V1 == "" ~ "Date",
#                                   TRUE ~ V1)) %>%
#      janitor::row_to_names(row_number = 1) %>%
#      dplyr::select(contains("Date") | contains("Covid-19")) %>%
#      tidyr::pivot_longer(cols = -Date,
#                          names_to = c("Disease", "Measure", "Sex", "Age"),
#                          names_sep = (", "),
#                          values_to = "Value") %>%
#      dplyr::mutate(
#        Value = as.integer(Value),
#        Value = replace_na(Value, 0),
#        Date = as.Date(Date, format = "%d.%m.%Y"),
#        Date = ymd(Date),
#        Sex = case_when(Sex == "Kvinne" ~ "f",
#                        Sex == "Mann" ~ "m"),
#        Measure = case_when(Measure == "Dose 1" ~ "Vaccination1",
#                            Measure == "Dose 2" ~ "Vaccination2",
#                            Measure == "Dose 3" ~ "Vaccination3",
#                            Measure == "Dose 4" ~ "Vaccination4"),
#        Age = str_extract(Age, pattern = "\\d+")) %>%
#      select(Date, Age, Sex, Measure, Value)
#  }
#  file_1_vacc <- data_prep(file_1)
# 
#  file_2_vacc <- data_prep(file_2) %>%
#    filter(Date != "2022-01-01") # as 01.01.2022 is already included in file3
# 
#  file_3_vacc <- data_prep(file_3)
# 
# 
#  vacc_out <- bind_rows(file_1_vacc, file_2_vacc,
#            file_3_vacc)
# 
#  ## FILL IN THE DATE GAPS
#  
#  
#  dates_f <- seq(min(vacc_out$Date), 
#                 max(vacc_out$Date), by = "day")
#  
#  vacc_out_cum <- vacc_out %>% 
#    tidyr::complete(Sex, Age, Measure, Date=dates_f, fill=list(Value=0)) %>% 
#    dplyr::group_by(Age, Sex, Measure, .drop = TRUE) %>% 
#    dplyr::mutate(Value = cumsum(Value),
#                  AgeInt=case_when(
#                    Age == "12" ~ 3L,
#                    Age == "16" ~ 1L,
#                    Age == "18" ~ 6L,
#                    Age == "25" ~ 15L,
#                    Age == "40" ~ 5L,
#                    Age == "45" ~ 10L,
#                    Age == "55" ~ 10L,
#                    Age == "65" ~ 10L,
#                    Age == "75" ~ 5L,
#                    Age == "80" ~ 5L,
#                    Age == "85" ~ 20L),
#                  Metric = "Count") %>% 
#   dplyr::select(Date, Age, AgeInt, Sex, Measure, Metric, Value) 
#    
#  
# 
#  write_rds(vacc_out_cum, paste0(dir_n, ctr, ".rds"))
#

## HERE SHOULD START THE DAILY PROCESSES ## 

## read historical saved data 

vacc_historical <- readRDS(paste0(dir_n, "Norway_Vaccine.rds")) %>% 
  mutate(Date = dmy(Date))

vacc_out <- rbind(vacc_today, vacc_historical) %>% 
  mutate(
     Date = ymd(Date),
     Date = paste(sprintf("%02d",day(Date)),    
                  sprintf("%02d",month(Date)),  
                  year(Date),sep="."))%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Value = as.character(Value)) %>% 
  sort_input_data() %>% 
  unique()

#upload 

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))


log_update("Norway_Vaccine", N = nrow(vacc_out))


## Keep a copy of today's data 

write_csv(vacc_today,
           file = paste0(dir_n_source, today(), ".csv"))


## ================== historical coding trials ##===============

# all_paths <-
#   list.files(path = dir_n_source,
#              pattern = ".csv",
#              #pattern = "alder-2020",
#              full.names = TRUE)


# 
# all_content <-
#   all_paths %>%
#   lapply(read_csv)

# all_filenames <- all_paths %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
# vacc_in$Date <- substr(vacc_in$V1,1, nchar(vacc_in$V1)-65)
# vacc_in <- vacc_in[,-2]
# vacc_in <- vacc_in %>%
#   separate(ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI,
#             c("Age","Dose1 male", "Dose1 female","Dose2 male","Dose2 female","Dose3 male","Dose3 female"),
#             sep = (";"))
# vacc_in <- melt(vacc_in, id= c("Age", "Date"))
# names(vacc_in)[4] <- "Value"
# 
# vacc_out_beforeJune22 <- vacc_in %>% 
#   mutate(AgeInt=case_when(
#     Age == "0-15 Ã¥r" ~ 16L,
#     Age == "12-15 Ã¥r" ~ 4L,
#     Age == "16-17 Ã¥r" ~ 2L,
#     Age == "16-44 Ã¥r" ~ 39L,
#     Age == "18-24 Ã¥r" ~ 7L,
#     Age == "25-39 Ã¥r" ~ 15L,
#     Age == "40-44 Ã¥r" ~ 5L,
#     Age == "45-54 Ã¥r" ~ 10L,
#     Age == "55-64 Ã¥r" ~ 10L,
#     Age == "65-74 Ã¥r" ~ 10L,
#     Age == "75-84 Ã¥r" ~ 10L,
#     Age == "85 og over" ~ 20L)) %>% 
#   mutate(Age=recode(Age, 
#                     `0-15 Ã¥r`="0",
#                     `12-15 Ã¥r`="12",
#                     `16-17 Ã¥r`="16",
#                     `16-44 Ã¥r`="16",
#                     `18-24 Ã¥r`="18",
#                     `25-39 Ã¥r`="25",
#                     `40-44 Ã¥r`="40",
#                     `45-54 Ã¥r`="45",
#                     `55-64 Ã¥r`="55",
#                     `65-74 Ã¥r`="65",
#                     `75-84 Ã¥r`="75",
#                     `85 og over`="85"))%>% 
#   mutate(
#     Measure = case_when(
#       variable == "Dose1 male" ~ "Vaccination1",
#       variable == "Dose1 female" ~ "Vaccination1",      
#       variable == "Dose2 male" ~ "Vaccination2",
#       variable == "Dose2 female" ~ "Vaccination2",
#       variable == "Dose3 female" ~ "Vaccination3",
#       variable == "Dose3 male" ~ "Vaccination3",
#       
#     ),
#     Metric = "Count",
#     Sex= case_when(
#       variable == "Dose1 male" ~ "m",
#       variable == "Dose1 female" ~ "f",
#       variable == "Dose2 male" ~ "m",
#       variable == "Dose2 female" ~ "f",         
#       variable == "Dose3 male" ~ "m",
#       variable == "Dose3 female" ~ "f"  
#     )) %>% 
#   filter(Date != "2021-12-07") %>% 
#   mutate(Date = ymd(Date)) %>% 
#   select(-variable)
# 

## MK: Norway changed their way of reporting vaccination in early June 2022 #
##Source for updates: https://github.com/folkehelseinstituttet/surveillance_data
## these data are downloaded manually & transformed as following ##


# vacc_in <- rbindlist(all_content, fill = T)
#  
# vacc_in <- vacc_in[- grep("Covid", vacc_in$ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI),]
# 
# vacc_out <- vacc_in %>%
#   tidyr::separate(ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI,
#             c("Date",
#               "Dose 1, Female, 12-15",
#               "Dose 1, Male, 12-15",
#               "Dose 1, Male, 16-17",
#               "Dose 1, Female, 16-17",
#               "Dose 1, Male, 18-24",
#               "Dose 1, Female, 18-24",
#               "Dose 1, Female, 25-39",
#               "Dose 1, Male, 25-39",
#               "Dose 1, Male, 40-44",
#               "Dose 1, Female, 40-44",
#               "Dose 1, Male, 45-54",
#               "Dose 1, Female, 45-54",
#               "Dose 1, Male, 55-64",
#               "Dose 1, Female, 55-64",
#               "Dose 1, Male, 65-74",
#               "Dose 1, Female, 65-74",
#               "Dose 1, Male, 75-79",
#               "Dose 1, Female, 80-84",
#               "Dose 1, Male, 80-84",
#               "Dose 1, Female, 85",
#               "Dose 1, Male, 85",
#               "Dose 2, Female, 12-15",
#               "Dose 2, Female, 16-17",
#               "Dose 2, Male, 16-17",
#               "Dose 2, Male, 18-24",
#               "Dose 2, Female, 18-24",
#               "Dose 2, Female, 25-39",
#               "Dose 2, Male, 25-39",
#               "Dose 2, Male, 40-44",
#               "Dose 2, Female, 40-44",
#               "Dose 2, Male, 45-54",
#               "Dose 2, Female, 45-54",
#               "Dose 2, Female, 55-64",
#               "Dose 2, Male, 55-64",
#               "Dose 2, Female, 65-74",
#               "Dose 2, Male, 65-74",
#               "Dose 2, Female, 75-79",
#               "Dose 2, Male, 75-79",
#               "Dose 2, Female, 80-84",
#               "Dose 2, Male, 80-84",
#               "Dose 2, Female, 85",
#               "Dose 2, Male, 85",
#               "Dose 3, Male, 12-15",
#               "Dose 3, Female, 12-15",
#               "Dose 3, Female, 16-17",
#               "Dose 3, Male, 16-17",
#               "Dose 3, Male, 18-24",
#               "Dose 3, Male, 25-39",
#               "Dose 3, Female, 40-44",
#               "Dose 3, Male, 40-44",
#               "Dose 3, Male, 45-54",
#               "Dose 3, Female, 45-54",
#               "Dose 3, Male, 55-64",
#               "Dose 3, Female, 55-64",
#               "Dose 3, Male, 65-74",
#               "Dose 3, Female, 65-74",
#               "Dose 3, Male, 75-79",
#               "Dose 3, Female, 75-79",
#               "Dose 3, Female, 80-84",
#               "Dose 3, Male, 80-84",
#               "Dose 3, Female, 85",
#               "Dose 3, Male, 85",
#               "Dose 4, Female, 12-15",
#               "Dose 4, Female, 18-24",
#               "Dose 4, Male, 18-24",
#               "Dose 4, Female, 25-39",
#               "Dose 4, Male, 25-39",
#               "Dose 4, Female, 40-44",
#               "Dose 4, Male, 40-44",
#               "Dose 4, Female, 45-54",
#               "Dose 4, Male, 45-54",
#               "Dose 4, Female, 55-64",
#               "Dose 4, Male, 55-64",
#               "Dose 4, Female, 65-74",
#               "Dose 4, Male, 65-74",
#               "Dose 4, Female, 75-79",
#               "Dose 4, Male, 75-79",
#               "Dose 4, Female, 85",
#               "Dose 4, Male, 85",
#               "Dose 2, Male, 12-15",
#               "Dose 3, Female, 18-24",
#               "Dose 3, Female, 25-39",
#               "Dose 4, Female, 80-84",
#               "Dose 4, Male, 80-84"
#             ),
#             sep = (";")) %>%
#   dplyr::slice(-1) %>%
#   tidyr::pivot_longer(cols = -Date,
#                       names_to = c("Measure", "Sex", "Age"),
#                       names_sep = (", "),
#                       values_to = "Value") %>%
#   dplyr::mutate(
#     Date = as.Date(Date, format = "%d.%m.%Y"),
#     Date = ymd(Date),
#     Sex = case_when(Sex == "Female" ~ "f",
#                     Sex == "Male" ~ "m"),
#     Measure = case_when(Measure == "Dose 1" ~ "Vaccination1",
#                         Measure == "Dose 2" ~ "Vaccination2",
#                         Measure == "Dose 3" ~ "Vaccination3",
#                         Measure == "Dose 4" ~ "Vaccination4"),
#     AgeInt=case_when(
#       Age == "0-15" ~ 16L,
#       Age == "12-15" ~ 4L,
#       Age == "16-17" ~ 2L,
#       Age == "16-44" ~ 39L,
#       Age == "18-24" ~ 7L,
#       Age == "25-39" ~ 15L,
#       Age == "40-44" ~ 5L,
#       Age == "45-54" ~ 10L,
#       Age == "55-64" ~ 10L,
#       Age == "65-74" ~ 10L,
#       Age == "75-79" ~ 10L,
#       Age == "80-84" ~ 10L,
#       Age == "85" ~ 20L),
#     Age=recode(Age,
#                `0-15`="0",
#                `12-15`="12",
#                `16-17`="16",
#                `16-44`="16",
#                `18-24`="18",
#                `25-39`="25",
#                `40-44`="40",
#                `45-54`="45",
#                `55-64`="55",
#                `65-74`="65",
#                ## MK: Since June 2022:
#                ## Age groups has changed to 75-79 and 80-84 (including the historical data) ##
#                `75-79` = "75",
#                `80-84`="80",
#                `85`="85"),
#     Metric = "Count")
# 
# 
# 
# ##adding 0 to 11 from 27.09.2021
# vacc_zero <- vacc_out %>% 
#   filter(Date >= "2021-09-28",
#          Age == 12) %>% 
#   mutate(Age = 0,
#          AgeInt = 12L,
#          Value = 0)

