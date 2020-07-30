rm(list=ls())
library(taskscheduleR)

local_path <- "U:/nextcloud/Projects/COVID_19/COVerAGE-DB/covid_age/Automation/00_hydra/"

sched <- function(pp = "CA_montreal", tm = "06:00"){
  script <- paste0(local_path, pp, ".R")  
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
# delete_sched("CA_montreal")


sched("US_New_Jersey", "13:50")
sched("Slovenia", "13:55")
sched("Colombia", "14:00")
sched("Germany", "14:20")
sched("US_Massachusetts", "14:45")
sched("Austria", "15:00")
sched("US_Virginia", "15:20")
sched("US_NYC", "15:25")
sched("USA_all_deaths", "15:30")
sched("CA_Montreal", "15:35")
sched("US_Texas", "15:40")
sched("US_Wisconsin", "15:45")
sched("US_Michigan", "15:50")
sched("Sweden", "15:55")
sched("Netherlands", "16:00")
sched("Venezuela", "16:05")
sched("New_Zeland", "16:10")
sched("Estonia", "16:15")

taskscheduler_ls()

scripts <- c(
  "US_New_Jersey",
  "Slovenia",
  "Colombia",
  "Germany",
  "US_Massachusetts",
  "Austria",
  "US_Virginia",
  "US_NYC",
  "USA_all_deaths",
  "CA_Montreal",
  "US_Texas",
  "US_Wisconsin",
  "US_Michigan",
  "Sweden",
  "Netherlands",
  "Venezuela",
  "New_Zeland",
  "Estonia"
)


# ## Delete all
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
