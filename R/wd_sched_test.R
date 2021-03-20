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

cat(wd_sched_detect())

schedule_test <- FALSE
if (schedule_test){
  taskscheduleR::taskscheduler_delete("wd_sched_test")
  taskscheduleR::taskscheduler_create(
    taskname = "wd_sched_test", 
    rscript = file.path(Sys.getenv("path_repo"),"R","wd_sched_test.R"), 
    schedule = "ONCE", 
    starttime = "10:05")
}
