rm(list=ls())
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(lubridate)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

setwd("U:/nextcloud/Projects/COVID_19/COVerAge-DB/automated_COVerAge-DB/US_New_Jersey_data")
filename <- paste0("US_NJ_", d, "_Cases&Deaths.pdf")

url <- "https://www.nj.gov/health/cd/documents/topics/NCOV/COVID_Confirmed_Case_Summary.pdf"
download.file(url, filename, mode = "wb")

drive_upload(
  filename,
  path = "https://drive.google.com/drive/u/0/folders/1ZlLmWE5I8hAbfcrAPThsO2XNSmcSA6vg",
  name = filename,
  overwrite = T)

