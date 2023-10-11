### Clean up & functions ############################################
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

## For some reason we weren't able to source from Tim's GitHub, so Tim copied all the functions
## in Functions.R file, and we use it here instead. 
source(here::here("R/00_Functions.R"))
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

# TR 13 July 2023, copied from 01_update_inputDB.R
Measures <- c("Cases","Deaths","Tests","Vaccinations",
              "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4", 
              "Vaccination5", "Vaccination6", "VaccinationBooster")


inputCounts_raw <- data.table::fread("N://COVerAGE-DB/Data/inputCounts.csv",
                                     encoding = "UTF-8")

## split the raw data by Measure and save each inputCounts_Measure into csv file
dfxl <- inputCounts_raw |> 
  group_split(Measure)


for(i in dfxl){
  name_measure <- unique(i[['Measure']])
  data.table::fwrite(i, file = paste0("N://COVerAGE-DB/Data/inputCounts_Measure/", 
                                      name_measure, ".csv"))
}

## END

