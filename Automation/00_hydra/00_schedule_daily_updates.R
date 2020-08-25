rm(list=ls())
library(taskscheduleR)

sched <- function(pp = "CA_montreal", tm = "06:00"){
  script <- paste0("U:/nextcloud/Projects/COVID_19/COVerAge-DB/automated_COVerAge-DB/00_hydra/", pp, ".R")  
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

sched("Colombia", "00:00")
sched("Venezuela", "01:00")
sched("CA_Montreal", "02:00")
# sched("US_New_Jersey", "02:10")

sched("Slovenia", "04:00")
sched("Germany", "05:00")
sched("US_Massachusetts", "06:00")

sched("Austria", "07:00")
sched("US_Virginia", "09:00")
sched("Mexico", "10:00")

sched("US_NYC", "11:00")
sched("USA_all_deaths", "12:00")
sched("US_Texas", "13:00")

sched("US_Wisconsin", "15:00")
sched("US_Michigan", "16:00")
sched("Sweden", "17:00")
sched("Netherlands", "18:00")

sched("New_Zeland", "20:00")
sched("Estonia", "21:00")
sched("Peru", "22:00")



taskscheduler_ls()

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
