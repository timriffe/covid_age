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
  filter(Country == "Moldova") %>% 
  dplyr::pull(Source)

#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "G:/riffe/covid_age/Automation/Moldova_screencaptures.py"
source_python(file=py_file)


file_out_1 <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_both_sex_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_both_sex.png",
            file_out_1)
file_out_2 <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_by_sex_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Moldova/Moldova_by_sex.png",
            file_out_2)


drive_put(media = file_out_1,
          path = googledrive::as_id(ss_db))

drive_put(media = file_out_2,
          path = googledrive::as_id(ss_db))

log_update("Moldova",N = "captured")

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Moldova_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Moldova_screencaptures", 
                       rscript = "G:/riffe/covid_age/Automation/Moldova_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}


