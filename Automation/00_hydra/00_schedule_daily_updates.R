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



# Steps for new automated sources 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1) create folders in N: drive (there is a way to include it in the auto script, already done in Argentina's!)
# 2) adjust input rubric to specify the source of the formatted data (N:  or Google Drive)
# 3) add the country/script to the Hydra dashboard 
# 4) schedule the country script on hydra (in this script)
# 5) add the script name to the list of scripts below


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Jessica, once finished the scheduling of all countries on your side, 
# let's try with the new script of Argentina!!
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# To see the list of scheduled tasks
taskscheduler_ls() %>% view()

# ~~~~~~~~~~~~~~~~
# Scheduling tasks 
# ~~~~~~~~~~~~~~~~

# list of all available scripts to schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scripts <- c('US_Virginia', 'USA_all_deaths', 'Netherlands', 'Estonia', 
             'Czechia', 'US_Michigan', 'Venezuela', 'US_Texas', 
             'USA_deaths_states', 'Sweden', 'Peru', 'Germany', 
             'US_Massachusetts', 'Colombia', 'US_NYC', 'Austria', 'Philippines', 
             'Scotland', 'Norway', 'US_California', 'Afghanistan', 'Finland', 
             'US_Wisconsin', 'Bulgaria', 'Denmark', 'Belgium', 'New_Zealand', 
             'Mexico', 'Thailand', 'Spain', 'US_Oregon', 'Slovakia', 'Cambodia', 
             'Hungary', 'Vietnam', 'Italy', 'Croatia', 'CA_Quebec', 
             'CA_Manitoba_Saskatchewan', 'CA_Ontario', 'CA_British_Columbia', 
             'Ukraine', 'Spain_vaccine', 'Chile', 'Portugal_Vaccine', 
             'CA_Alberta', 'Canada_vaccine', 'US_Texas_Vaccine', 
             'Hong_Kong_Vaccine')

scripts <- c("Slovenia", "US_Virginia")


# Scheduling all scripts at once
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# starting time for first schedule in hour and minutes
h_ini <- 6
m_ini <- 30
# delay between scripts in minutes
delay_time <- 15

i <- 0
for(c in scripts){
  # time schedule in decimal 
  hrs_mns <- h_ini + (m_ini + i * delay_time) / 60
  # extract hour
  hrs <- floor(hrs_mns)
  # extract minutes
  mns <- round((hrs_mns - floor(hrs_mns)) * 60, 1)
  # build time
  time <- paste0(sprintf("%02d", hrs), ":", sprintf("%02d", mns))
  # print country and time of scheduling
  cat(c, " scheduling at ", time, "\n")
  # schedule it
  sched(c, tm = time, email = auto_update_email, wd = auto_update_wd)
  # increase the counter in 1
  i <- i + 1
}


# for individual scheduling
# ~~~~~~~~~~~~~~~~~~~~~~~~~
sched("Slovenia", tm = "08:03", email = auto_update_email, wd = auto_update_wd)



# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Deleting scheduled tasks
# ~~~~~~~~~~~~~~~~~~~~~~~~~

# for deleting single task schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
delete_sched("CA_Alberta")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# danger zone!!!! deleting all schedules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(c in scripts){
  delete_sched(c)
}




# previous long non-smart version
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

### scripts working outside hydra because of VPN:
#################################################
# sched("CA_Montreal", tm = "16:44",email = auto_update_email, wd = auto_update_wd)
# sched("Mexico", tm = "16:44",email = auto_update_email, wd = auto_update_wd)

