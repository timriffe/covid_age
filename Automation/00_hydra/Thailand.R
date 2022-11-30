## Thailand 
## Written by: Tim Riffe

source(here::here("Automation/00_Functions_automation.R"))
library(tidyverse)
library(lubridate)
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
# info country and N drive address
ctr   <- "Thailand"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# TR: pull urls from rubric instead 

at_rubric <- get_input_rubric() %>% filter(Short == "TH")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)


cases_url <- "https://data.go.th/dataset/8a956917-436d-4afd-a2d4-59e4dd8e906e/resource/be19a8ad-ab48-4081-b04a-8035b5b2b8d6/download/confirmed-cases.csv"

## CHANGE SYS.LOCALE to THAI so that sex can be recoded ##
Sys.setlocale(locale = "Thai")
TH <- read_csv(cases_url)


Ages <- as.character(0:100,"UNK")

Cases_rawpre12082021 <-
  TH %>% 
  select(Date = announce_date,
         Age = age,
         Sex = sex) %>% 
  mutate(Date = dmy(Date),
         Age = ifelse(sign(Age) == -1, -Age,Age), # one case of -34 must mean 34, right?
         Age = if_else(Age >= 105, 105, Age),
         Age = as.integer(Age),
         Age = ifelse(is.na(Age),"UNK",as.character(Age)),
         Sex = ifelse(is.na(Sex),"UNK",as.character(Sex)),
         Sex = case_when(
           Sex %in% c("ชาย", "นาย") ~ "m",
           Sex %in% c("หญิง") ~ "f",
           TRUE ~ Sex))%>% 
  group_by(Date, Sex, Age) %>% 
  summarize(Value = n(), .groups="drop") %>% 
  tidyr::complete(Date, Sex, Age = Ages, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  ## here, filter out 12.08.2021 as the second file starts with this date data. 
  dplyr::filter(Date != "2021-08-12")


data_source <- paste0(dir_n, "Data_sources/", ctr, "/Downloads/")


all_links <- scraplinks("https://data.go.th/dataset/covid-19-daily") %>% 
  dplyr::filter(str_detect(url, ".xls")) %>%
  dplyr::filter(!str_detect(url, "-daily_data_dictionary.xlsx")) %>%
  dplyr::mutate(base = data_source,
                file_name = str_extract(url, "\\d+.xls"),
                file_name = str_replace(file_name, ".xls", ".xlsx"),
                destinations = paste0(base, file_name)) %>%
  dplyr::filter(!is.na(file_name))

Sys.setlocale(locale = "Thai")

all_links %>%
  {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


data.list <-list.files(
  path= data_source,
  pattern = ".xlsx",
  full.names = TRUE)


all_data <- data.list %>% 
  set_names() %>% 
  map_dfr(~read_excel(.),
          .id = "file_name") 

raw_data12082021 <- all_data %>% 
  select(Date = announce_date,
         Age = age,
         Sex = sex) %>% 
  mutate(Date = ymd(Date),
         Age = ifelse(sign(Age) == -1, -Age,Age), # one case of -34 must mean 34, right?
         Age = if_else(Age >= 105, 105, Age),
         Age = as.integer(Age),
         Age = ifelse(is.na(Age),"UNK",as.character(Age)),
         Sex = ifelse(is.na(Sex),"UNK",as.character(Sex)),
         Sex = case_when(
           #  Sex %in% c("  หญิง", "หญิง", "") ~ "f",
           Sex %in% c("นาย", "ชาย") ~ "m",
           Sex %in% c("หห", "ร.ต.ท.", "ญ", "ช")~ "UNK", 
           TRUE ~ "f"))%>% 
  group_by(Date, Sex, Age) %>% 
  summarize(Value = n(), .groups="drop") %>% 
  tidyr::complete(Date, Sex, Age = Ages, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) 


Cases_raw_all <- bind_rows(Cases_rawpre12082021, raw_data12082021)


processed_data <- Cases_raw_all %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  mutate(Country = "Thailand",
         Region = "All",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Metric = "Count",
         Measure = "Cases",
         AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                            Age == "100" ~ 5L,
                            TRUE ~ 1L),
         Code = "TH") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  filter(!(Sex == "UNK" & Value == 0),
         !(Age == "UNK" & Value == 0)) %>% 
  sort_input_data() 

## CHANGE SYS.LOCALE BACK TO all ##
Sys.setlocale("LC_ALL","English")

# Save and log
write_rds(processed_data, paste0(dir_n, ctr, ".rds"))
log_update("Thailand", N = nrow(processed_data))

# Archive inputs
#data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
#write_csv(TH, data_source)
# zipname <- paste0(dir_n, 
#                   "Data_sources/", 
#                   ctr,
#                   "/", 
#                   ctr,
#                   "_data_",
#                   today(), 
#                   ".zip")
# zip::zipr(zipname, 
#           data_source, 
#           recurse = TRUE, 
#           compression_level = 9,
#           include_directories = TRUE)
# 
# file.remove(data_source)
# end


## FOR REFERENCE CODE ## =====================

## MK: 22.11.2022 

## DOWNLOAD THE FILES PUBLISHED IN THE WEBPAGE 

# Source website: https://data.go.th/dataset/covid-19-daily

## The data are published in multiple files till 01.05.2022 


# rvest::read_html("https://data.go.th/dataset/covid-19-daily") %>% 
#   rvest::html_nodes("a ") %>% 
#   rvest::html_attr('href')
# 
# 
# data_source <- paste0(dir_n, "Data_sources/", ctr, "/Downloads/")
# 
# all_links <- scraplinks("https://data.go.th/dataset/covid-19-daily") %>% 
#   dplyr::filter(str_detect(url, ".xls")) %>% 
#   dplyr::filter(!str_detect(url, "-daily_data_dictionary.xlsx")) %>% 
#   dplyr::mutate(base = data_source,
#                 file_name = str_extract(url, "\\d+.xls"),
#                 file_name = str_replace(file_name, ".xls", ".xlsx"),
#                 destinations = paste0(base, file_name)) %>% 
#   dplyr::filter(!is.na(file_name))
# 
# Sys.setlocale(locale = "Thai")
# 
# all_links %>% 
#   {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}
