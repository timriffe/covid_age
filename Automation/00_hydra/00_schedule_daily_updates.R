Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL","English")
library("taskscheduleR")
library(here)
source(here("Automation/00_Functions_automation.R"))

# commands in the git terminal to update each fork:
# first coinfigure the upstream (only once):
# git remote add upstream https://github.com/timriffe/covid_age.git
# then, each time for updates: 
# git pull upstream master

# taskscheduler_ls() %>% view()

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
if (grepl("Git04", auto_update_wd)){
  auto_update_email <- "jessica_d.1994@yahoo.de"
}

# sched() is a funtion that generates and schedules a trigger script 
# for each collection script. The trigger script has two purposes. 
# First, it includes the information of the local path of the project and 
# the Drive user credentials. Second, it calls the collection script ensuring
# that it is executed using the proper encoding format (UTF-8). 
# When scheduling the trigger script on hydra, the sched() function also 
# deletes tasks that were scheduled in the past with same name. 
# See "Automation/00_Functions_automation.R" for more details

# pending to assign time baseline to after schedule faster 
# ~~~~~~~~~~~~~~~~~~~~~~~
# time_base <- time("08:03") 



# current scripts working on hydra by participant
#################################################
sched("Slovenia", tm = "08:03", email = auto_update_email, wd = auto_update_wd)
sched("US_Virginia", tm = "08:06",email = auto_update_email, wd = auto_update_wd)
sched("USA_all_deaths", tm = "08:10",email = auto_update_email, wd = auto_update_wd)
sched("Netherlands", tm = "08:10",email = auto_update_email, wd = auto_update_wd)
sched("Estonia", tm = "08:18",email = auto_update_email, wd = auto_update_wd)
sched("Czechia", tm = "08:22",email = auto_update_email, wd = auto_update_wd)
sched("US_Michigan", tm = "08:26",email = auto_update_email, wd = auto_update_wd)
sched("Venezuela", tm = "09:54",email = auto_update_email, wd = auto_update_wd)
sched("US_Texas", tm = "08:32",email = auto_update_email, wd = auto_update_wd)
sched("USA_deaths_states", tm = "10:25",email = auto_update_email, wd = auto_update_wd)
sched("Sweden", tm = "10:01",email = auto_update_email, wd = auto_update_wd)
sched("Peru", tm = "08:40",email = auto_update_email, wd = auto_update_wd)
sched("Germany", tm = "08:51",email = auto_update_email, wd = auto_update_wd)
sched("US_Massachusetts", tm = "10:18",email = auto_update_email, wd = auto_update_wd)
sched("Colombia",  tm = "10:00",email = auto_update_email, wd = auto_update_wd)
sched("US_NYC", tm = "08:24",email = auto_update_email, wd = auto_update_wd)
sched("Austria", tm = "08:21",email = auto_update_email, wd = auto_update_wd)
sched("Philippines", tm = "09:10",email = auto_update_email, wd = auto_update_wd)
sched("Scotland", tm = "09:25",email = auto_update_email, wd = auto_update_wd)
sched("Norway", tm = "08:28",email = auto_update_email, wd = auto_update_wd)
sched("US_California", tm = "08:35",email = auto_update_email, wd = auto_update_wd)
sched("Afghanistan", tm = "09:40",email = auto_update_email, wd = auto_update_wd)
sched("Finland", tm = "09:50",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
sched("US_Wisconsin", tm = "10:02",email = auto_update_email, wd = auto_update_wd)
sched("Bulgaria", tm = "10:46",email = auto_update_email, wd = auto_update_wd)
sched("Denmark", tm = "07:00",email = auto_update_email, wd = auto_update_wd)
sched("Belgium", tm = "10:20",email = auto_update_email, wd = auto_update_wd)
sched("New_Zealand", "09:30",email = auto_update_email, wd = auto_update_wd)
sched("Mexico", "10:40",email = auto_update_email, wd = auto_update_wd)
sched("Thailand", "10:00",email = auto_update_email, wd = auto_update_wd)
sched("Spain", "09:01",email = auto_update_email, wd = auto_update_wd)
sched("US_Oregon", "10:18",email = auto_update_email, wd = auto_update_wd)
sched("Slovakia", "18:48",email = auto_update_email, wd = auto_update_wd)
sched("Cambodia", "10:32",email = auto_update_email, wd = auto_update_wd)
sched("Hungary", "07:26",email = auto_update_email, wd = auto_update_wd)
sched("Vietnam", "06:05",email = auto_update_email, wd = auto_update_wd)
sched("Italy", "06:00",email = auto_update_email, wd = auto_update_wd)
sched("Croatia", "09:32",email = auto_update_email, wd = auto_update_wd)
sched("CA_Quebec", "08:00",email = auto_update_email, wd = auto_update_wd)
sched("CA_Manitoba_Saskatchewan", "08:05",email = auto_update_email, wd = auto_update_wd)
sched("CA_Ontario", "08:08",email = auto_update_email, wd = auto_update_wd)
sched("CA_British_Columbia", "08:10",email = auto_update_email, wd = auto_update_wd)
sched("Ukraine", "08:40",email = auto_update_email, wd = auto_update_wd)
sched("Spain_vaccine", "12:20",email = auto_update_email, wd = auto_update_wd)
sched("Chile", "17:08",email = auto_update_email, wd = auto_update_wd)
sched("Portugal_Vaccine", "17:17",email = auto_update_email, wd = auto_update_wd)
sched("CA_Alberta", "12:30",email = auto_update_email, wd = auto_update_wd)
sched("Canada_vaccine", "13:00",email = auto_update_email, wd = auto_update_wd)
sched("US_Texas_Vaccine", "13:10",email = auto_update_email, wd = auto_update_wd)
sched("Hong_Kong_Vaccine", "05:00",email = auto_update_email, wd = auto_update_wd)
# sched("ES_Basque_Country", tm = "08:00",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
# sched("ECDC", tm = "09:45",email = auto_update_email, wd = auto_update_wd, sch = "WEEKLY")
# sched("Chile_vacc", "06:11",email = auto_update_email, wd = auto_update_wd)
# sched("US_Iowa"??, tm = "09:40",email = auto_update_email, wd = auto_update_wd)



# sched("GB_NIR", "19:02",email = auto_update_email, wd = auto_update_wd)
# sched("Brazil", "12:29",email = auto_update_email, wd = auto_update_wd)
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
delete_sched("ECDC")
# delete_sched("Slovakia")
delete_sched("Chile_vacc")
delete_sched("Slovenia")



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
taskscheduler_ls() %>% view()
