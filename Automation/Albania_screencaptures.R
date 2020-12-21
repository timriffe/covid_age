

library(webshot)
library(lubridate)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# makes empty capture
al_demo_url <- "https://coronavirus.al/statistika/"
al_demo_pdf  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Albania/Albania_",today(),".pdf")


library(webshot)
webshot(al_demo_url,
        al_demo_pdf,
        delay= 10)

if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)

log_update("Albania",N = "captured")


schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Albania_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Albania_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/Albania_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}
