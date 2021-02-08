
#install.packages("webshot")
library(webshot)
library(lubridate)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

#install_phantomjs()
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)

deaths_url <- "https://public.tableau.com/profile/idaho.division.of.public.health#!/vizhome/DPHIdahoCOVID-19Dashboard/DeathDemographics"
cases_url  <- "https://public.tableau.com/profile/idaho.division.of.public.health#!/vizhome/DPHIdahoCOVID-19Dashboard/Demographics"


deaths_png <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Idaho/US_ID_deaths_",today(),".png")
cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Idaho/US_ID_cases_",today(),".png")

webshot::webshot(url = deaths_url,
        file = deaths_png,
        vwidth = 800,
        vheight = 800, 
        delay = 10)


webshot::webshot(url = cases_url,
        file = cases_png,
        vwidth = 500,
        vheight = 800, 
        delay = 15)


log_update(pp = "US_Idaho", N = "captured")

drive_auth(email = email)
ss_db <- get_input_rubric() %>% 
  filter(Region == "Idaho") %>% 
  dplyr::pull(Source)

drive_put(media = deaths_png,
          path = as_id(ss_db))

drive_put(media = cases_png,
          path = as_id(ss_db))

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-US_ID_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-US_ID_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/US_ID_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}

