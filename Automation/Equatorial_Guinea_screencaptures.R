

library(lubridate)
library(rvest)
library(httr)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")




cases_url  <- "https://guineasalud.org/estadisticas/"

cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Equatorial_Guinea/GQ_cases_age_sex",today(),".png")
cases_png <- "test.png"


image_url <-
  read_html(cases_url) %>% 
  html_nodes(css = "body > div.wrapper > div > div > div > div.full_width > div > div:nth-child(1) > div > div > div > div > div:nth-child(6) > div > div > div:nth-child(2) > div > div > div.wpb_single_image.wpb_content_element.vc_align_left > div > div > img") %>% 
  html_attr("src")

download.file(image_url, cases_png)


if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

gs4_auth(email = email)
drive_auth(email = email)

ss_db <- get_input_rubric() %>% 
  filter(Country == "Equatorial Guinea") %>% 
  dplyr::pull(Source)

drive_put(cases_png,
          path = as_id(ss_db))

log_update("Equatorial_Guinea",N = "captured")

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Equatorial_Guinea_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Equatorial_Guinea_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/Equatorial_Guinea_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}
