source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(reticulate)

# conda_create("coveragedb")
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email,
         scopes = c("https://www.googleapis.com/auth/spreadsheets",
                    "https://www.googleapis.com/auth/drive"))
drive_auth(email = email,
           scopes = c("https://www.googleapis.com/auth/spreadsheets",
                      "https://www.googleapis.com/auth/drive"))
ss_db <- get_input_rubric() %>% 
  filter(Country == "Indonesia") %>% 
  dplyr::pull(Source)

# use_python("C://Users//riffe//AppData//Local//R-MINI~1//envs//coveragedb//python.exe")
#  # conda_create("coveragedb")
#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "G:/riffe/covid_age/Automation/Indonesia_screencaptures.py"
# py_file <- "Automation/Indonesia_screencaptures.py"
source_python(file=py_file)
#py_run_file("C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.py")
#py_run_file("Automation/US_AZ_screencaptures.py")

file_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Indonesia/Indonesia_demo_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Indonesia/Indonesia_demo.png",
            file_out)

drive_put(media = file_out,
          path = googledrive::as_id(ss_db))


log_update("Indonesia",N = "captured")


schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Indonesia_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Indonesia_screencaptures", 
                       rscript = "Automation/Indonesia_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



