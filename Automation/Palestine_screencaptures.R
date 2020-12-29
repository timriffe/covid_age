


# Not working: page doesn't fully load


#install.packages("webshot")
library(webshot)
library(lubridate)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# makes empty capture
ps_demo_url <- "https://corona.ps/details"


ps_demo_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Palestine/Palestine_",today(),".png")

webshot(url= ps_demo_url,
        file = ps_demo_png,
        delay = 10)


if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)

log_update("Palestine",N = "captured")

ss_db <- ss_db <- get_input_rubric() %>% 
  filter(Country == "Palestine") %>% 
  dplyr::pull(Source)
drive_put(ps_demo_png,
          path = as_id(ss_db))

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Palestine_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Palestine_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/Palestine_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



