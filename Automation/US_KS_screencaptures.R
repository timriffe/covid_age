
library(webshot)
library(lubridate)


source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")



ks_cases_url <- "https://public.tableau.com/views/COVID-19TableauVersion2/CaseCharacteristics?:language=en&:embed=y&:embed_code_version=3&:loadOrderID=0&:display_count=y&publish=yes&:origin=viz_share_link"

ks_deaths_url <- "https://public.tableau.com/views/COVID-19TableauVersion2/DeathSummary?:language=en&:embed=y&:embed_code_version=3&:loadOrderID=0&:display_count=y&publish=yes&:origin=viz_share_link"

ks_cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Kansas/US_KS_cases_",today(),".png")

ks_deaths_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Kansas/US_KS_deaths_",today(),".png")



webshot::webshot(url = ks_cases_url,
        file=ks_cases_png,
        delay = 15,
        vwidth=1000,
        vheight=3000)
webshot::webshot(url = ks_deaths_url,
        file=ks_deaths_png,
        delay = 15,
        vwidth=1000,
        vheight=3000)



if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)

log_update("US_Kansas",N = "captured")


schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-US_KS_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-US_KS_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/US_KS_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}