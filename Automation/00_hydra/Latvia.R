# Latvia Epi-data 
## MK: Latvia data is collected manually in google drive sheet, deaths by age and cases by sex and age,
## the below link has the cases by age, and deaths, tests and cases as totals. 
## since these data are collected manually, i will keep this script just in case we moved to automated collection. 

library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# info country and N drive address

ctr          <- "Latvia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# main source: https://data.gov.lv/dati/lv/group/veseliba
epi_data <- read_csv2("https://data.gov.lv/dati/dataset/f01ada0a-2e77-4a82-8ba2-09cf0cf90db3/resource/d499d2f0-b1ea-4ba2-9600-2c701b03bd4a/download/covid_19_izmeklejumi_rezultati.csv")

epi_data %>% 
  select(Date = 'Datums',
         contains("Gadi"),
         Tests = 'TestuSkaits',
         Cases = 'ApstiprinataCOVID19InfekcijaSkaits',
         Deaths = "MirusoPersonuSkaits") %>% 
  mutate(Date = ymd(Date)) %>% 
  View()




















