# print("\n")
# print("")
# print("")
# print("--------------------------------------------------------------------------------")
# print("--------------------------------------------------------------------------------")
# print("--------------------------------------------------------------------------------")
print(paste0("\n", "\n", "\n", "\n", "\n", Sys.time(), ", Fresh start of process"))
# print("--------------------------------------------------------------------------------")
# print("--------------------------------------------------------------------------------")
# print("--------------------------------------------------------------------------------")

source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
# source("https://raw.githubusercontent.com/kikeacosta/covid_age/master/R/00_Functions.R")
library(here)
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()
getwd()

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/pandoc")
repo <- git2r::repository(here())
# creds <- structure(list(username = Sys.getenv("GITHUB_USER"), 
#                         password = Sys.getenv("GITHUB_PASS")), 
#                    class = "cred_user_pass")
#init()
git2r::pull(repo,credentials = cred_token())

source(here("R","build.R"))

schedule_this <- FALSE
if (schedule_this){
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-weekly-build")
  # taskscheduleR::taskscheduler_create(
  #   taskname = "COVerAGE-DB-automatic-daily-build", 
  #   rscript =  paste0(Sys.getenv("path_repo"), "/R/build_pre.R"), 
  #   schedule = "WEEKLY",
  #   days = "FRI",
  #   starttime = "09:32",
  #   startdate = format(Sys.Date(), "%m/%d/%Y"))
  taskscheduleR::taskscheduler_create(
    taskname = "COVerAGE-DB-automatic-weekly-build", 
    rscript = here("R","build_pre.R"), 
    schedule = "WEEKLY",
    days = "FRI",
    starttime = "16:20",
    startdate = "12-07-2021")
}

#
test_schedule_build <- FALSE
if (test_schedule_build){
  library(taskscheduleR)
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")
  taskscheduler_create(taskname = "COVerAGE-DB-automatic-build-test", 
                       rscript =  here::here("R/build_pre.R"), 
                       schedule = "ONCE", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



#taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")





