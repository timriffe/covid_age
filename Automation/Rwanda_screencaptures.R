

#install.packages("webshot")
library(webshot)
library(lubridate)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")




cases_url  <- "https://gis.rbc.gov.rw/portal/apps/opsdashboard/index.html#/59872985985446bbaf8c394ad857c5cd"

cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Rwanda/Rwanda_cases_",today(),".png")



webshot(url= cases_url,
        file = cases_png,
        delay = 60)



if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)

log_update("Rwanda",N = "captured")

ss_db <- ss_db <- get_input_rubric() %>% 
  filter(Country == "Rwanda") %>% 
  dplyr::pull("Source")

drive_put(media = cases_png,
          path = as_id(ss_db))

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Rwanda_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Rwanda_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/Rwanda_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}
