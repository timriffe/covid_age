#demographics for victoria https://www.covid19data.com.au/demographics

library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.de"
}


# info country and N drive address

ctr          <- "Australia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

##cases for new south wales australia
nsw_regional_cases <- read.csv("https://data.nsw.gov.au/data/dataset/aefcde60-3b0c-4bc0-9af1-6fe652944ec2/resource/5d63b527-e2b8-4c42-ad6f-677f14433520/download/confirmed_cases_table1_location_agg.csv")
nsw_regional_cases_out <- nsw_regional_cases %>% 
  select(Date = notification_date, Postcode = postcode, Region = lhd_2010_name, Subregion = lga_name19, Test = confirmed_by_pcr, Value = confirmed_cases_count) %>% 
  
  




nsw_cases_age <- read.csv("https://data.nsw.gov.au/data/dataset/3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf/resource/4b03bc25-ab4b-46c0-bb3e-0c839c9915c5/download/confirmed_cases_table2_age_group_agg.csv")





































##victoria
vic_cases_age <- read.csv("https://data.nsw.gov.au/data/dataset/f9fe3aba-8b79-4e7a-a165-e4c53e22cf0d/resource/0325e760-26a5-4b9b-9681-42ef723ce6be/download/covid-19-tests-by-date-and-age-range.csv")

##try again to download the local data
https://www.coronavirus.vic.gov.au/victorian-coronavirus-covid-19-data
https://www.dhhs.vic.gov.au/sites/default/files/documents/202202/NCOV_COVID_Cases_by_Age_Group_20220224.csv
https://www.dhhs.vic.gov.au/sites/default/files/documents/202202/NCOV_COVID_Cases_by_Age_Group_20220224.csv
##no data for act
##no data for northern teretories
##no data on queensland (only daily table, scrapable)
##no data on south australia (only daily table, scrapable)
##no data for tasmania
##western australia (dashboard)
