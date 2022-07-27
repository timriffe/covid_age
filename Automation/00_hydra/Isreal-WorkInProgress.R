## ISRAEL data
## created by: Manal Kamal


source(here::here("Automation/00_Functions_automation.R"))
library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Israel" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/data_", today(), ".csv")

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## SOURCE of the datasets: https://data.gov.il/dataset/covid-19

## dataset for epi-and vaccination data
## scrappping the link did not work with me

data_url <- "https://data.gov.il/dataset/covid-19/resource/89f61e3a-4866-4bbf-bcc1-9734e5fee58e"

csv_url <- "http://data.gov.il/dataset/covid-19/resource/89f61e3a-4866-4bbf-bcc1-9734e5fee58e/download/corona_age_and_gender_ver_00346.csv"

raw_data <- download.file(url = csv_url, 
                          destfile = data_source,
                          mode = "wb")



## SCRAPPE THE DOWNLOAD LINK ##

## This is not working on Hydra, so I just keep the code for reference.

# load packages 
library(tidyverse)
library(RSelenium)
library(netstat)
library(jsonlite)
library(rvest)
library(xml2)

## SCRAPPE THE DOWNLOAD LINK ##

## This is not working on Hydra, so I just keep the code for reference.

 driver <- rsDriver(
   browser = "firefox",
   # in case broswer = "chrome", get the chrome://version/ in the browser
   #then binman::list_versions("chromedriver") in the console
  # chromever = "103.0.5060.53",
   verbose = FALSE,
   port = free_port()
 )
 
 remDr <- driver$client
 #remDr$open()
  
 path <- data_url
 remDr$navigate(path)
 Sys.sleep(5)
 remDr$findElement(using = "class", "a.resource-url-analytics resource-type-None")$clickElement()
 
 last_ned <- remDr$findElement(using = "class", "a.resource-url-analytics resource-type-None")
 remDr$mouseMoveToLocation(webElement = last_ned)
 remDr$findElement(using = "class", 
                   value = "dropdown-item fhi-dropdown-last-ned__option")$clickElement()
 
 
 
 remDr$quit()
# This is not working on Hydra, so I just keep the code for reference. 
# will add the date as of today()
 
 find_date <- remDr$findElement(using = 'xpath',
                                value = '//span[@class="highcharts-caption"]')
 date_extract <- find_date$getElementText()[[1]] 
 
 date_number <- date %>% parse_number()
 
 date_update <- date %>% 
   str_extract_all("[0-9]+") %>% 
   unlist()
 
date <- date_update[1:3] %>% paste(collapse = '.')























## API 

requ <- GET(url = "https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e",
            add_headers())
weboutput <- content(requ)























