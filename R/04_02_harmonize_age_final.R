## This script is a subscript of '04_harmonize_age_groups_changes.R' 
## aims to start the harmonization using inputCounts.csv.
## Outputs: 5/10_internal.csv files.

### Clean up & functions ############################################
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

## For some reason we weren't able to source from Tim's GitHub, so Tim copied all the functions
## in Functions.R file, and we use it here instead. 
source(here::here("R/00_Functions.R"))
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

logfile <- here::here("buildlog.md")
#n.cores <- round(6 + (detectCores() - 8)/4)
# n.cores  <- 3
# no longer used to determine core usage
# freesz  <- memuse::Sys.meminfo()$freeram@size

Offsets <- readRDS("N://COVerAGE-DB/Data/Offsets.rds")

# inputCounts_raw <- data.table::fread("N://COVerAGE-DB/Data/inputCounts.csv",
#                                  encoding = "UTF-8")

# TR 13 July 2023, copied from 01_update_inputDB.R
# Measures <- c("Cases","Deaths",
#               "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4", 
#               "Vaccination5", "Vaccination6", "VaccinationBooster",
#               "Tests","Vaccinations")


measure_name <- "Vaccination5"

inputCounts_raw <- data.table::fread(paste0("N://COVerAGE-DB/Data/inputCounts_Measure/", 
                                            measure_name, ".csv"),
                                     encoding = "UTF-8")

pre_inputCounts <-
  inputCounts_raw %>% 
 # collapse::fsubset(Measure %in% Measures) %>% 
  collapse::fselect(-Metric) %>% 
  ## filter out the after 31-03-2023
  collapse::fsubset(dmy(Date) <= ymd("2023-03-31")) %>% 
  collapse::roworder(Country, Region, Date, Sex, Age) %>% 
  collapse::fgroup_by(Code, Sex, Date) 

## Here is to create ID vector to use to split the data --
id_inputCounts <- GRPid(pre_inputCounts) 
max(id_inputCounts)

inputCounts <- pre_inputCounts %>% 
  collapse::fmutate(
    id = id_inputCounts,
    toss = any(is.na(Value))) %>% 
  collapse::fungroup() %>% 
  collapse::roworder(id, Age) %>% 
  collapse::fsubset(!toss) %>% 
  collapse::fselect(-toss)# %>% 
 # collapse::fsubset(id %in% sample(id, size = 500, replace = FALSE))


iL <- split(inputCounts, list(inputCounts$id)) 

rm(inputCounts); rm(inputCounts_raw); rm(pre_inputCounts)

## so we run here the harmonization function for all the splitted data 

harmonizedL <- suppressMessages(lapply(iL,
                      harmonize_age_p_del,
                      Offsets = Offsets,
                      OAnew = 100,
                      N = 5,
                      lambda = 1e5))

## Bind the outputs into one data frame 

out5 <- rbindlist(harmonizedL)

## write/ save the output files

data.table::fwrite(out5, 
                   file = paste0("N://COVerAGE-DB/Data/outputCounts_Measure/", 
                                 measure_name, ".csv"))

## END =====================================================================================
# ## A rough estimation of the duration that the harmonization process would take ~ 5 days.
# 
# iL_test <- sample(1:max(id_inputCounts),1000, replace = FALSE)
# iL_guage <- iL[iL_test]
# tic()
# harmonizedL_guage <- suppressMessages(lapply(iL_guage,
#                       harmonize_age_p_del,
#                       Offsets = Offsets,
#                       OAnew = 100,
#                       N = 5,
#                       lambda = 1e5))
# time_stop <- toc()
# days_to_run <- ((time_stop$toc - time_stop$tic) * length(iL) / 1000) / 60 / 60 / 24