
## This script is to schedule the first three steps in the database build workflow  
## These scripts are:
## 01_update_inputDB.R
## 01.5_resolve_sources.R
## 02_harmonize_metrices.R


here::i_am("covid_age.Rproj")

source(here::here("R", "00_Functions.R"))

log_section("New build log", append = FALSE)

## PART I. Source the files of interest ## =================

source(here::here("R", "01_update_inputDB.R"))
source(here::here("R", "01.5_resolve_sources.R"))
source(here::here("R", "02_harmonize_metrices.R"))



## PART II. Schedule the scripts ## ===============


schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-thrice-weekly-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-thrice-weekly-inputDB-updates", 
                       rscript =  here::here("R","01_update_inputDB.R"), 
                       schedule = "WEEKLY",
                       days = c("MON","THU"),
                       starttime = "23:00")
}

#taskscheduleR::taskscheduler_ls() %>% view()

schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-inputDB-resolve-sources")
  taskscheduler_create(taskname = "COVerAGE-DB-inputDB-resolve-sources", 
                       rscript =  here::here("R", "01.5_resolve_sources.R"), 
                       schedule = "TUE", 
                       starttime = "23:00")
  
}



schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-inputDB-harmonize-matrices")
  taskscheduler_create(taskname = "COVerAGE-DB-harmonize_metrices.R", 
                       rscript =  here::here("R", "02_harmonize_metrices.R"), 
                       schedule = "WED", 
                       starttime = "20:00")
}

