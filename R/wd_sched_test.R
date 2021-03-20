wd_sched_detect <- function(){
  initial.options <- commandArgs(trailingOnly = FALSE)
  file.arg.name   <- "--file="
  script.name     <- sub(file.arg.name,"",initial.options[grep(file.arg.name,initial.options)]) 
  dirname(script.name)
}

cat(wd_sched_detect())

schedule_test <- FALSE
if (schedule_test){
  taskscheduleR::taskscheduler_delete("wd_sched_test")
  taskscheduleR::taskscheduler_create(
    taskname = "wd_sched_test", 
    rscript = file.path(Sys.getenv("path_repo"),"R","wd_sched_test.R"), 
    schedule = "ONCE", 
    starttime = "08:29")
}
