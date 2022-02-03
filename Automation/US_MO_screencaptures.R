source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(reticulate)

# conda_create("coveragedb")
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)
ss_db <- get_input_rubric() %>% 
  filter(Region == "Missouri") %>% 
  dplyr::pull(Source)


#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "C:/Users/riffe/Documents/covid_age/Automation/US_MO_screencaptures.py"
source_python(file=py_file)


file_out1 <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_demo_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_demo.png",
            file_out1)
file_out2 <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_totals_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/US_Missouri/US_MO_totals.png",
            file_out2)


drive_put(media = file_out1,
          path = googledrive::as_id(ss_db))
drive_put(media = file_out2,
          path = googledrive::as_id(ss_db))

log_update("US_Missouri",N = "captured")


schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-US_MO_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-US_MO_screencaptures", 
                       rscript = "Automation/US_MO_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



