
print("")
print("")
print("")
print("--------------------------------------------------------------------------------")
print("--------------------------------------------------------------------------------")
print("--------------------------------------------------------------------------------")
print(paste0(Sys.time(), ", Start of harmonization process"))

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

# source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
library(here)
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()
getwd()

source("R/00_Functions.R")

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
                       starttime = "11:31",
                       startdate = format(Sys.Date(), "%m/%d/%Y"))
}

#
test_schedule_build <- FALSE
if (test_schedule_build){
  library(taskscheduleR)
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")
  taskscheduler_create(taskname = "COVerAGE-DB-automatic-build-test", 
                       rscript =  paste0(Sys.getenv("path_repo"), "/R/build_pre.R"), 
                       schedule = "ONCE", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



#taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-build-test")





