
setwd(Sys.getenv("path_repo"))

source("~/.Rprofile")
source(file.path("R","00_Functions.R"))

library(usethis)
library(git2r)

# declare
repo <- git2r::repository(Sys.getenv("path_repo"))
#init()
git2r::pull(repo,credentials = cred_token()) # possibly creds not making it this far?

# TR: this one easier in command line, at least I don't see a way to 
# specify a custom remote using git2r::pull
system("git pull kike master")

a <- git2r::status()
if (length(a$unstaged) > 0){
  commit(repo, 
         message = "auto sync with kike", 
         all = TRUE)
}



git2r::push(repo,credentials = cred_token())


schedule_this <- FALSE
if (schedule_this){
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-daily-sync")
  taskscheduleR::taskscheduler_create(
    taskname = "COVerAGE-DB-automatic-daily-sync", 
    rscript = file.path(Sys.getenv("path_repo"),"R","a_sync.R"), 
    schedule = "DAILY", 
    starttime = "06:00",
    startdate = format(Sys.Date() , "%d/%m/%Y"))
}

schedule_test <- FALSE
if (schedule_test){
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-automatic-daily-sync-test")
  taskscheduleR::taskscheduler_create(
    taskname = "COVerAGE-DB-automatic-daily-sync-test", 
    rscript = file.path(Sys.getenv("path_repo"),"R","a_sync.R"), 
    schedule = "ONCE", 
    starttime = "08:05")
}

