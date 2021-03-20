
library(here)
change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
}
wd_sched_detect <- function(){
  if (!interactive()){
    initial.options <- commandArgs(trailingOnly = FALSE)
    file.arg.name   <- "--file="
    script.name     <- sub(file.arg.name,"",initial.options[grep(file.arg.name,initial.options)]) 
    
    wd <- script.name 
  }else {
    wd <- getwd()
  }
  for (i in 1:3){
    bname <- basename(wd)
    if (bname == "covid_age"){
      break
    }
    wd <- dirname(wd)
  }
  wd
}

change_here(wd_sched_detect())
startup::startup()
setwd(here())

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
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-daily-build")
  taskscheduleR::taskscheduler_create(
                       taskname = "COVerAGE-DB-automatic-daily-build", 
                       rscript =  paste0(Sys.getenv("path_repo"), "/R/build_pre.R"), 
                       schedule = "DAILY", 
                       starttime = "01:00",
                       startdate = format(Sys.Date()+1 , "%d/%m/%Y"))
}

#
test_schedule_build <- FALSE
if (test_schedule_build){
  library(taskscheduleR)
  taskscheduler_create(taskname = "COVerAGE-DB-automatic-build-test", 
                       rscript =  paste0(Sys.getenv("path_repo"), "/R/build_pre.R"), 
                       schedule = "ONCE", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



#taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")





