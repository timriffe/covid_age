
# TR: modifying this script to assume we're working inside the repository, and are relative to it.
# should detect if it's tim, enrique, or diego.
rm(list=ls())
library(taskscheduleR)
library(tidyverse)
library(here)
auto_update_email <- '"tim.riffe@gmail.com"'
auto_update_wd    <- here()
# we assume this tasks are scheduled in a here()-aware fashion
sched <- function(
  pp = "CA_montreal", 
  tm = "06:00", 
  email = "tim.riffe@gmail.com",
  wd = here()){
  script <- here("Automation/00_hydra/", paste0(pp, ".R")  )
  
  # modify the script to know who scehduled it and where it is
  A        <- readLines(script)
  ind      <- (A == "# ##  ###") %>% which() %>% '['(1)
  A[ind+1] <- paste("email <-",email)
  A[ind+2] <- paste0('setwd("',wd,'")')
  writeLines(A,script)
  # -------------------
  
  tskname <- paste0("coverage_db_", pp, "_daily")
  
  try(taskscheduler_delete(taskname = tskname))
  
  taskscheduler_create(taskname = tskname, 
                       rscript = script,
                       schedule = "DAILY", 
                       starttime = tm, 
                       startdate = "30/06/2020")
}

delete_sched <- function(pp = "CA_montreal"){
  tskname <- paste0("coverage_db_", pp, "_daily")
  taskscheduler_delete(taskname = tskname)
}

# sched("Netherlands", "15:12")
# delete_sched("US_New_Jersey")

sched("CA_Montreal", tm = "12:08",email = auto_update_email, wd = auto_update_wd)
sched("Colombia",  tm = "12:30",email = auto_update_email, wd = auto_update_wd)
sched("Venezuela", tm = "13:48",email = auto_update_email, wd = auto_update_wd)


sched("Slovenia", tm = "15:48",email = auto_update_email, wd = auto_update_wd)
sched("Germany", tm = "16:12",email = auto_update_email, wd = auto_update_wd)
sched("US_Massachusetts", tm = "16:50",email = auto_update_email, wd = auto_update_wd)

sched("Austria", tm = "18:50",email = auto_update_email, wd = auto_update_wd)
sched("US_Virginia", tm = "19:50",email = auto_update_email, wd = auto_update_wd)
sched("Mexico", tm = "20:50",email = auto_update_email, wd = auto_update_wd)

sched("US_NYC", tm = "22:38",email = auto_update_email, wd = auto_update_wd)
sched("USA_all_deaths", tm = "01:00",email = auto_update_email, wd = auto_update_wd)

# not yet scheduled:
sched("US_Texas", tm = "01:30",email = auto_update_email, wd = auto_update_wd)

sched("US_Wisconsin", tm = "02:10",email = auto_update_email, wd = auto_update_wd)
sched("US_Michigan", "16:00")
sched("Sweden", "17:00")
sched("Netherlands", "18:00")

sched("New_Zeland", "18:20")
sched("Estonia", "21:00")
sched("Peru", "22:00")

# delete_sched("Austria")
# delete_sched("CA_Montreal")
# delete_sched("Colombia")
# delete_sched("Estonia")
# delete_sched("Germany")
# delete_sched("Mexico")
# delete_sched("Netherlands")
# delete_sched("New_Zeland")
# delete_sched("Peru")
# delete_sched("Slovenia")
# delete_sched("Sweden")
# delete_sched("US_Massachusetts")
# delete_sched("US_Michigan")
# delete_sched("US_New_Jersey")
# delete_sched("US_NYC")
# delete_sched("US_Texas")
# delete_sched("US_Virginia")
# delete_sched("US_Wisconsin")
# delete_sched("USA_all_deaths")
# delete_sched("Venezuela")

# 
# taskscheduler_ls()
# 
# scripts <- c(
#   "Colombia",
#   "Germany",
#   "US_Massachusetts",
#   "Austria",
#   "US_Virginia",
#   "US_NYC",
#   "USA_all_deaths",
#   "CA_Montreal",
#   "US_Texas", 
#   "US_Wisconsin",
#   "US_Michigan",
#   "Sweden",
#   "Netherlands",
#   "Venezuela",
#   "New_Zeland"
# )
# 
### Delete all 
# for (sc in scripts){
#   print(sc)
#   delete_sched(sc)
# }
# 
# i <- 0
# for (sc in scripts){
#   print(sc)
#   t <- paste0("15:2", as.character(i))
#   sched(sc, t)
#   i <- i + 5
# }

# taskscheduler_delete(taskname = "usa_daily")
# myscript <- "U:/Projects/COVerAge-BD/automate_codes/US_wisconsin.R"
# taskscheduler_create(taskname = "wisconsin_daily", rscript = myscript,
#                      schedule = "DAILY", starttime = "12:16", startdate = "30/06/2020")
taskscheduler_ls()
