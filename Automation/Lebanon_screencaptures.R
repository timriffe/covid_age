
  #install.packages("webshot")
  library(webshot)
library(lubridate)
#install_phantomjs()

  source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
  



cases_url  <- "https://corona.ministryinfo.gov.lb/"

cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Lebanon/Lebanon_cases_",today(),".png")


webshot::webshot(url = cases_url,
        file = cases_png,
        vwidth = 500,
        vheight = 2500, 
        delay = 20)

if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)

log_update("Lebanon",N = "captured")

drive_auth(email = email)
ss_db <- get_input_rubric() %>% 
  filter(Country == "Lebanon") %>% 
  dplyr::pull(Source)

drive_put(media = cases_png,
          path = as_id(ss_db))

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Lebanon_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Lebanon_screencaptures", 
                       rscript = "G:/riffe/covid_age/Automation/Lebanon_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}

