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
if (grepl("Git04", auto_update_wd)){
  auto_update_email <- "jessica_d.1994@yahoo.de"
}
if (grepl("gits", auto_update_wd)){
  auto_update_email <- "maxi.s.kniffka@gmail.com"
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
tasks <- 
  taskscheduler_ls() %>% 
  filter(str_sub(TaskName, 1, 8) == "coverage")
# ~~~~~~~~~~~~~~~~
# Scheduling tasks 
# ~~~~~~~~~~~~~~~~

# list of all available scripts to schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scripts <- c('US_Virginia', 'Netherlands', 'Estonia', 
             'Czechia', 'US_Michigan', 'Venezuela', 'US_Texas', 
             'USA_deaths_states', 'Sweden', 'Peru', 'Germany', 
             'US_Massachusetts', 'Colombia', 'US_NYC', 'Austria', 'Philippines', 
             'Scotland', 'Norway', 'US_California', 'Afghanistan', 'Finland', 
             'US_Wisconsin', 'Bulgaria', 'Denmark', 'Belgium', 'New_Zealand', 
             'Mexico', 'Thailand', 'Spain', 'US_Oregon', 'Slovakia', 'Cambodia', 
             'Hungary', 'Vietnam', 'Italy', 'Croatia',  
             'CA_Manitoba_Saskatchewan', 'CA_Ontario', 'CA_British_Columbia', 
             'Ukraine', 'Spain_vaccine', 'Chile_vaccine', 'Portugal_Vaccine', 
             'CA_Alberta', 'Canada_vaccine', 'US_Texas_Vaccine', 
             'Hong_Kong_Vaccine','Argentina','Slovenia', 'US_Maine','US_NYC_vaccine',
             'US_Vermont_Vaccine', 'US_Indiana','Lithuania_vaccine','US_Michigan_vaccine',
             'US_Minnesota_vaccine', 'Slovenia_vaccine', 'US_Oregon_Vaccine', 
             'Latvia_vaccine', 'Island_of_Jersey', 'Estonia_vaccine', 'Uruguay_vaccine', 
             'Chile','Finland_vaccine', 'ECDC_vaccine', 'Slovakia_vaccine', 
             'Germany_vaccine', 'US_Pennsylvania_vaccine', 'USA_vaccine',
             'Australia_vaccine', 'US_Idaho', 'New_Zealand', 
             'Maldives', 'Japan', 'Romania', 'Puerto_Rico', 'Scotland_Vaccine', 
             'Switzerland_Vaccine', 'Norway_Vaccine', 'France_Vaccine',
             'England_Vaccine', 'England', 'England_and_Wales', 'Togo', 
             'Netherlands_Vaccine', 'Costa_Rica_Vaccine', 
             'USA_cases_all', 'USA_cases_states', 'USA_deaths_all', 'USA_deaths_states', 'Somalia', 'Ireland')

# scripts <- c('USA_cases_all', 'USA_cases_states', 'USA_deaths_all', 'USA_deaths_states')
# scripts <- c('USA_cases_all', 'USA_deaths_all')
scripts %>% sort
# Scheduling all scripts at once
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# starting time for first schedule in hour and minutes
h_ini <- 08
m_ini <- 00
# delay between scripts in minutes
delay_time <- 5

i <- 0
for(c in scripts){
  # time schedule in decimal 
  hrs_mns <- h_ini + (m_ini + i * delay_time) / 60
  # extract hour
  if(hrs_mns>= 24)hrs_mns= hrs_mns-24
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

sched("Ireland", tm = "05:00", email = auto_update_email, wd = auto_update_wd)
sched('SouthKorea', tm = "18:23", email = auto_update_email, wd = auto_update_wd)
sched('USA_deaths_all', tm = "17:01", email = auto_update_email, wd = auto_update_wd)
sched('USA_cases_all', tm = "17:02", email = auto_update_email, wd = auto_update_wd)

#sch = "WEEKLY"

# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Deleting scheduled tasks 
# ~~~~~~~~~~~~~~~~~~~~~~~~~

# for deleting single task schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# taskscheduler_delete("COVerAGE-DB-automatic-daily-build")
# taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates")

delete_sched("USA_cases_all")



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# danger zone!!!! deleting all scheduled tasks
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scripts <- c('USA_all', 'USA_all_deaths')

for(c in scripts){
  delete_sched(c)
}


### scripts working outside hydra because of VPN:
#################################################
# sched("CA_Montreal", tm = "16:44",email = auto_update_email, wd = auto_update_wd)
# sched("Mexico", tm = "16:44",email = auto_update_email, wd = auto_update_wd)

