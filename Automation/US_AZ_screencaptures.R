source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(reticulate)


if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)
ss_db <- get_input_rubric() %>% 
  filter(Region == "Arizona") %>% 
  dplyr::pull(Source)

# use_python("C://Users//riffe//AppData//Local//R-MINI~1//envs//coveragedb//python.exe")
#  # conda_create("coveragedb")
#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.py"

source_python(file=py_file)
#py_run_file("C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.py")
#py_run_file("Automation/US_AZ_screencaptures.py")

cases_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_cases_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_cases.png",
            cases_out)
deaths_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_deaths_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_deaths.png",
            deaths_out)
tests_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_tests_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Arizona/US_AZ_tests.png",
            tests_out)


drive_put(media = cases_out,
          path = googledrive::as_id(ss_db))
drive_put(media = deaths_out,
          path = googledrive::as_id(ss_db))
drive_put(media = tests_out,
          path = googledrive::as_id(ss_db))


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



