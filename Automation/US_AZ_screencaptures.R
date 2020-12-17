


# Not working: page doesn't fully load



library(lubridate)
library(reticulate)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

py_run_file("C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.py")
#py_run_file("Automation/US_AZ_screencaptures.py")

if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)

log_update("US_Arizona",N = "captured")


schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-US_AZ_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-US_AZ_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



