

library(webshot)
library(lubridate)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# makes empty capture
al_demo_url <- "https://coronavirus.al/statistika/"

al_demo_pdf  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Albania/Albania_",today(),".pdf")


if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
  al_demo_pdf  <- paste0("Data/Albania_",today(),".pdf")
  
}
webshot::webshot(al_demo_url,
        al_demo_pdf,
        delay= 10)

gs4_auth(email = email)
drive_auth(email = email)

log_update("Albania",N = "captured")

ss_db <- get_input_rubric() %>% 
  filter(Country == "Albania") %>% 
  dplyr::pull("Source")

drive_put(media= al_demo_pdf,
          path = as_id(ss_db))

if (al_demo_pdf == paste0("Data/Albania_",today(),".pdf")){
  file.remove(al_demo_pdf)
}

schedule.this <- FALSE
if (schedule.this){
  # library(taskscheduleR)
  # taskscheduler_delete("COVerAGE-DB-Albania_screencaptures")
  # taskscheduler_create(taskname = "COVerAGE-DB-Albania_screencaptures", 
  #                      rscript = "C:/Users/riffe/Documents/covid_age/Automation/Albania_screencaptures.R", 
  #                      schedule = "DAILY", 
  #                      starttime = format(Sys.time() + 61, "%H:%M"))
  
  library(cronR)
  cmd <- cron_rscript("Automation/Albania_screencaptures.R")
  cron_add(cmd, 
           frequency = 'daily', 
           id = "COVerAGE-DB_Albania", 
           at = "15:03")
  cron_ls()
  cron_clear(ask=FALSE)
  
  
}


