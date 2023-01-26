
## This script is to schedule the first three steps in the database build workflow  
## These scripts are:
## 01_update_inputDB.R
## 01.5_resolve_sources.R
## 02_harmonize_metrices.R

Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL","English")
library("taskscheduleR")
library(here)

## Sys.unsetenv("GITHUB_PAT")
## remotes::install_github("timriffe/DemoTools", dependencies = TRUE)

source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

#source(here::here("R", "00_Functions.R"))


setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

# always work with the most uptodate repository
repo <- git2r::repository(here::here())

email <- Sys.getenv("email")
gs4_auth(email = email, 
         scopes = c("https://www.googleapis.com/auth/spreadsheets",
                    "https://www.googleapis.com/auth/drive"))
drive_auth(email = email,
           scopes = c("https://www.googleapis.com/auth/spreadsheets",
                      "https://www.googleapis.com/auth/drive"))


## PART I. Source the files of interest ## =================

source(here::here("R", "01_update_inputDB.R"))
source(here::here("R", "01.5_resolve_sources.R"))
source(here::here("R", "02_harmonize_metrics.R"))



## PART II. Schedule the scripts ## ===============

#taskscheduleR::taskscheduler_ls() %>% view()

schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-thrice-weekly-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-thrice-weekly-inputDB-updates", 
                       rscript =  here::here("R","02.1_ScheduleThreeSteps.R"), 
                       schedule = "WEEKLY",
                       days = c("WED","THU"),
                       starttime = "12:30")
}



