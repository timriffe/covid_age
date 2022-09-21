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
  auto_update_email <- "kikepaila@gmail.com"
}
if (grepl("gits", auto_update_wd)){
  auto_update_email <- "maxi.s.kniffka@gmail.com"
}

## Sys.setenv(email = "mumanal.k@gmail.com")

if (grepl("gits", auto_update_wd)){
  auto_update_email <- "mumanal.k@gmail.com"
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
#taskscheduler_ls() %>% view()
tasks <- 
  taskscheduler_ls() %>% 
  filter(str_sub(TaskName, 1, 8) == "coverage")
# ~~~~~~~~~~~~~~~~
# Scheduling tasks 
# ~~~~~~~~~~~~~~~~

# list of all available scripts to schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scripts <- c('Peru', 'PeruVaccine' , 'Afghanistan', 
             'Argentina', 'AU_New_South_Wales',
             'AustraliaEpi', 'Australia_vaccine', 'Austria', 
             'Bulgaria',  'Belgium', 'CanadaPDFs',
             'Czechia', 'Colombia', 'Cambodia', 'Croatia', 
             'CA_Manitoba_Saskatchewan', 'CA_Ontario', 'CA_British_Columbia', 
             'CA_Alberta', 'Chile', 'CA_Manitoba', 
             'Chile_vaccine', 'Canada_vaccine', 'Costa_Rica_Vaccine', 
             'Denmark',
             'Estonia', 'England', 'England_and_Wales',
             'Estonia_vaccine', 'ECDC_vaccine', 'England_Vaccine', 
             'Finland', 'Finland_vaccine', 'FranceEpi', 'France_Vaccine',
             'GeorgiaVaccine',
             'Germany', 'Germany_vaccine', 'GreecePDFs', 'Guatemala',
             'Haiti', 'Hungary', 'Hong_Kong_Vaccine',
             'IndiaVax',
             'Italy', 'Ireland', 'Italy_reg', 'Island_of_Jersey', 'Israel',
             'Japan',
             'Lithuania_vaccine', 'Latvia_vaccine',
             'Mexico', 'Maldives', 'Malaysia', 'Mozambique',
             'Nepal', 'Nigeria',
             'Norway',  'Netherlands', 'New_Zealand',  
             'Norway_Vaccine', 'Netherlands_Vaccine', 
             'Philippines', 'Puerto_Rico', 
             'Portugal_Vaccine', # does not work
             'Romania', 
             'Spain', 'Spain_vaccine',
             'Scotland', 'Scotland_Vaccine', 
             'Slovakia',  'Slovenia', 
             'Slovenia_vaccine', 'Slovakia_vaccine', 
             'Somalia', 'SouthAfrica', 'SouthKorea', 'SriLankaPDFs',
             'Sweden', 
             'Switzerland_Vaccine',
             'Togo', 'Taiwan', 
             'Thailand', # does not work
             'Uruguay_vaccine', 'Ukraine', 
             'US_Indiana', 'US_Maine', 'US_Massachusetts',  'US_NYC',
             'US_California', 'US_Wisconsin', 'US_Oregon', 'US_Michigan', 
             'US_Virginia', 'US_Idaho', 'US_Texas', 
             'US_Michigan_vaccine','US_Minnesota_vaccine', 'US_Oregon_Vaccine',
             'US_Pennsylvania_vaccine', 'US_Maine_Vaccine',
             'US_NYC_vaccine', 'US_Vermont_Cases', 
             'US_Vermont_Vaccine', 'US_Texas_Vaccine',
             'USA_cases_all', 
             'USA_deaths_all', 'USA_deaths_states',
             'USA_vaccine', 'USA_vaccine_states',
             'Vietnam', # does not work
             'Venezuela')

# scripts <- c('USA_cases_all', 'USA_cases_states', 'USA_deaths_all', 'USA_deaths_states')
# scripts <- c('USA_cases_all', 'USA_deaths_all')
scripts %>% sort
# Scheduling all scripts at once
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# starting time for first schedule in hour and minutes
h_ini <- 06
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

sched("Israel", tm = "14:57", email = auto_update_email, wd = auto_update_wd)
sched("Italy", tm = "15:55", email = auto_update_email, wd = auto_update_wd)
sched('Germany_vaccine', tm = "14:45", email = auto_update_email, wd = auto_update_wd)
sched('Peru', tm = "15:47", email = auto_update_email, wd = auto_update_wd)
sched("USA_deaths_states", tm = "15:32", email = auto_update_email, wd = auto_update_wd)
sched("US_Wisconsin", tm = "14:55", email = auto_update_email, wd = auto_update_wd)
sched('Italy', tm = "14:57", email = auto_update_email, wd = auto_update_wd)
sched('Canada_vaccine', tm = "15:00", email = auto_update_email, wd = auto_update_wd)
sched("Lithuania_vaccine", tm = "15:03", email = auto_update_email, wd = auto_update_wd)
sched("Latvia_vaccine", tm = "15:05", email = auto_update_email, wd = auto_update_wd)
sched('USA_vaccine', tm = "15:07", email = auto_update_email, wd = auto_update_wd)
sched('Japan', tm = "15:09", email = auto_update_email, wd = auto_update_wd)
sched("Puerto_Rico", tm = "15:10", email = auto_update_email, wd = auto_update_wd)
sched("England_Vaccine", tm = "15:12", email = auto_update_email, wd = auto_update_wd)
sched('England', tm = "15:15", email = auto_update_email, wd = auto_update_wd)
sched('Ireland', tm = "15:17", email = auto_update_email, wd = auto_update_wd)
sched("Togo", tm = "15:20", email = auto_update_email, wd = auto_update_wd)

#sch = "WEEKLY"

# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Deleting scheduled tasks 
# ~~~~~~~~~~~~~~~~~~~~~~~~~

# for deleting single task schedule
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# taskscheduler_delete("COVerAGE-DB-automatic-daily-build")
# taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates")

delete_sched("US_Massachusets")



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

