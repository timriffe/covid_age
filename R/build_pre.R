
library(here)
change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
}

change_here("C:/Users/riffe/Documents/covid_age")
startup::startup()
repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = creds)

source(here("R","build.R"))


schedule_this <- FALSE
if (schedule_this){
  library(taskscheduleR)
  taskscheduler_create(taskname = "COVerAGE-DB-automatic-daily-build", 
                       rscript = "C:/Users/riffe/Documents/covid_age/R/build_pre.R", 
                       schedule = "DAILY", 
                       starttime = "02:00",
                       startdate = format(Sys.Date() + 1, "%d/%m/%Y"))
}

#taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-daily-build")
test_schedule_build <- FALSE
if (test_schedule_build){
  library(taskscheduleR)
  taskscheduler_create(taskname = "COVerAGE-DB-automatic-build-test", 
                       rscript = "C:/Users/riffe/Documents/covid_age/R/build_pre.R", 
                       schedule = "ONCE", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}

#taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")





