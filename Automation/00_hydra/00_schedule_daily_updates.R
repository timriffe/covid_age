Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL","English")
library("taskscheduleR")
library(here)
source(here("Automation/00_Functions_automation.R"))

# TR: modifying this script to assume we're working inside the repository, and 
# are relative to it. This first part detects who is scheduling (diego, 
# emanuele, jorge, ugo, marilia, jessica, tim, enrique, etc.)
# When scheduling with these functions, first lines of scripts are going to be 
# modified with the Google Drive user and local path in hydra where the 
# covid_age project is located 

auto_update_wd <- here()

# for instance, enrique's path is "U:/gits/covid_age"
if (grepl("riffe", auto_update_wd)){
   auto_update_email <- "tim.riffe@gmail.com"   
}
if (grepl("gits", auto_update_wd)){
  auto_update_email <- "kikepaila@gmail.com"
}

# sched() is a funtion that generates and schedules a trigger script 
# for each collection script. The trigger script has two purposes. 
# First, it includes the information of the local path of the project and 
# the Drive user credentials. Second, it calls the collection script ensuring
# that it is executed using the proper encoding format (UTF-8). 
# When scheduling the trigger script on hydra, the sched() function also 
# deletes tasks that were scheduled in the past with same name. 
# See "Automation/00_Functions_automation.R" for more details

# current scripts working on hydra by participant
#################################################
sched("Slovenia", tm = "09:50",email = auto_update_email, wd = auto_update_wd)
sched("US_Virginia", tm = "09:55",email = auto_update_email, wd = auto_update_wd)
sched("USA_all_deaths", tm = "10:00",email = auto_update_email, wd = auto_update_wd)
sched("Netherlands", tm = "09:40",email = auto_update_email, wd = auto_update_wd)
sched("Estonia", tm = "09:45",email = auto_update_email, wd = auto_update_wd)
sched("Czechia", tm = "09:50",email = auto_update_email, wd = auto_update_wd)
sched("US_Michigan", tm = "02:40",email = auto_update_email, wd = auto_update_wd)
sched("Venezuela", tm = "09:31",email = auto_update_email, wd = auto_update_wd)
sched("US_Texas", tm = "09:32",email = auto_update_email, wd = auto_update_wd)
sched("USA_deaths_states", tm = "08:34",email = auto_update_email, wd = auto_update_wd)
sched("Sweden", tm = "12:00",email = auto_update_email, wd = auto_update_wd)
sched("Peru", tm = "09:40",email = auto_update_email, wd = auto_update_wd)
sched("Germany", tm = "09:35",email = auto_update_email, wd = auto_update_wd)
sched("US_Massachusetts", tm = "08:18",email = auto_update_email, wd = auto_update_wd)
sched("Colombia",  tm = "09:30",email = auto_update_email, wd = auto_update_wd)
sched("US_NYC", tm = "08:15",email = auto_update_email, wd = auto_update_wd)
sched("Austria", tm = "21:25",email = auto_update_email, wd = auto_update_wd)
sched("ES_Basque_Country", tm = "11:00",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
sched("Philippines", tm = "10:00",email = auto_update_email, wd = auto_update_wd)
sched("Scotland", tm = "12:10",email = auto_update_email, wd = auto_update_wd)
sched("Norway", tm = "16:11",email = auto_update_email, wd = auto_update_wd)
sched("US_California", tm = "07:50",email = auto_update_email, wd = auto_update_wd)
sched("Afghanistan", tm = "06:35",email = auto_update_email, wd = auto_update_wd)
sched("ECDC", tm = "08:37",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
sched("Finland", tm = "11:44",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
sched("US_Wisconsin", tm = "13:02",email = auto_update_email, wd = auto_update_wd)
sched("Bulgaria", tm = "08:24",email = auto_update_email, wd = auto_update_wd)
sched("Denmark", tm = "09:29",email = auto_update_email, wd = auto_update_wd)
# sched("US_Iowa", tm = "09:40",email = auto_update_email, wd = auto_update_wd)
sched("Belgium", tm = "14:30",email = auto_update_email, wd = auto_update_wd)
sched("New_Zealand", "10:03",email = auto_update_email, wd = auto_update_wd)
sched("Mexico", "17:23",email = auto_update_email, wd = auto_update_wd)
sched("Thailand", "17:15",email = auto_update_email, wd = auto_update_wd)
sched("Spain", "10:01",email = auto_update_email, wd = auto_update_wd)
sched("US_Oregon", "12:18",email = auto_update_email, wd = auto_update_wd)
## broken scripts:
##################
# sched("New_Zealand", tm = "02:10",email = auto_update_email, wd = auto_update_wd)

### scripts working outside hydra because of VPN:
#################################################
# sched("CA_Montreal", tm = "16:44",email = auto_update_email, wd = auto_update_wd)
# sched("Mexico", tm = "16:44",email = auto_update_email, wd = auto_update_wd)

### function to delete tasks
############################
# delete_sched("Austria")
# delete_sched("CA_Montreal")
# delete_sched("Colombia_sch")
# delete_sched("Estonia")
# delete_sched("German_sch")
# delete_sched("Mexico")
# delete_sched("Netherlands")
# delete_sched("New_Zealand")
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
# delete_sched("USA_deaths_all_states")
# delete_sched("Philippines")
# delete_sched("Scotland")
# delete_sched("Norway")
# delete_sched("US_Iowa")


### to list current tasks
#########################
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
