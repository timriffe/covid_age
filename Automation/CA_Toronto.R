# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(lubridate)
library(rvest)
library(zip)

drive_auth(email = email)
gs4_auth(email = email)

rubric <- get_input_rubric()
CA_MTL_rubric <- get_input_rubric() %>% filter(Short == "CA_TRT")
ss_i  <- CA_MTL_rubric %>% dplyr::pull(Sheet)
ss_db <-  CA_MTL_rubric %>% dplyr::pull(Source)

db <- read_csv("https://ckan0.cf.opendata.inter.prod-toronto.ca/download_resource/e5bf35bc-e681-43da-b2ce-0242d00922ad?format=csv")
