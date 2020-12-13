
#install.packages("webshot")
library(webshot)
library(lubridate)
#install_phantomjs()


deaths_url <- "https://public.tableau.com/profile/oregon.health.authority.covid.19#!/vizhome/OregonCOVID-19CaseDemographicsandDiseaseSeverityStatewide-SummaryTable/DemographicDataSummaryTable"
cases_url  <- "https://public.tableau.com/profile/oregon.health.authority.covid.19#!/vizhome/OregonCOVID-19Update/CaseandTesting"


deaths_png <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Oregon/US_OR_deaths_",today(),".png")
cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Oregon/US_OR_cases_",today(),".png")

webshot(url = deaths_url,
        file = deaths_png,
        vwidth = 800,
        vheight = 3000, 
        delay = 10)


webshot(url = cases_url,
        file = cases_png,
        vwidth = 500,
        vheight = 2500, 
        delay = 10)




schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-US_OR_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-US_OR_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/US_OR_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}

