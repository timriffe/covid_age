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

# TR 13 July 2023, copied from 01_update_inputDB.R
Measures <- c("Cases","Deaths","Tests","ASCFR","Vaccinations",
              "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4", 
              "Vaccination5", "Vaccination6", "VaccinationBooster")


logfile <- here::here("buildlog.md")
#n.cores <- round(6 + (detectCores() - 8)/4)
# n.cores  <- 3
Offsets <- readRDS("N://COVerAGE-DB/Data/Offsets.rds")
# no longer used to determine core usage
freesz  <- memuse::Sys.meminfo()$freeram@size

inputCounts_raw <- data.table::fread("N://COVerAGE-DB/Data/inputCounts.csv",
                                 encoding = "UTF-8")
pre_inputCounts <-
  inputCounts_raw %>% 
  collapse::fsubset(Measure %in% Measures) %>% 
  collapse::fselect(-Metric) %>% 
  ## filter out the after 31-03-2023
  collapse::fsubset(dmy(Date) <= ymd("2023-03-31")) %>% 
  collapse::roworder(Country, Region, Date, Measure, Sex, Age) %>% 
  collapse::fgroup_by(Code, Sex, Measure, Date) 

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

## A rough estimation of the duration that the harmonization process would take ~ 5 days.

iL_test <- sample(1:max(id_inputCounts),1000, replace = FALSE)
iL_guage <- iL[iL_test]
tic()
harmonizedL_guage <- suppressMessages(lapply(iL_guage,
                      harmonize_age_p_del,
                      Offsets = Offsets,
                      OAnew = 100,
                      N = 5,
                      lambda = 1e5))
time_stop <- toc()
days_to_run <- ((time_stop$toc - time_stop$tic) * length(iL) / 1000) / 60 / 60 / 24

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

# Get into one data set
data.table::fwrite(out5, file = "N://COVerAGE-DB/Data/Output_5_before_sex_scaling_etc.csv")
rm(iL);rm(iLout1e5)

ids_out  <- out5$id %>% unique() %>% sort()
failures <- ids_in[!ids_in %in% ids_out]

HarmonizationFailures <-
  inputCounts %>% 
  filter(id %in% failures)

data.table::fwrite(HarmonizationFailures, file = "N://COVerAGE-DB/Data/HarmonizationFailures.csv")
# saveRDS(HarmonizationFailures, file = here::here("Data","HarmonizationFailures.rds"))

outputCounts_5_1e5 <-
  out5 %>% 
  as.data.table() %>% 
  .[, Value := nafill(Value, nan = NA, fill = 1)] %>% 
  .[, rescale_sexes_post(chunk = .SD), keyby = .(Country, Region, Code, Date, Measure, AgeInt)] %>% 
  as_tibble() %>% 
  # pivot_wider(names_from = "Measure", values_from = "Value") %>% 
  # dplyr::select(Country, Region, Code, Date, Sex, Age, AgeInt, Cases, Deaths, Tests) %>% 
  # arrange(Country, Region, dmy(Date), Sex, Age) |>
  # NEW, to avoid redundant harmonization
  bind_rows(OutputCounts_keep) |>
  arrange(Country, Region, Date, Measure, Sex, Age)

data.table::fwrite(outputCounts_5_1e5, file = "N://COVerAGE-DB/Data/Output_5_internal.csv")

# Round to full integers (update)
outputCounts_5_1e5_rounded <- 
  outputCounts_5_1e5 %>% 
  mutate(Value = round(Value,1))
#Deaths = round(Deaths,1),
#Tests = round(Tests,1))

# Save csv
header_msg1 <- "Counts of all measures in harmonized 5-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))

#write_lines(header_msg, path = here("Data","Output_5.csv"))
#write_csv(outputCounts_5_1e5_rounded, path = here("Data","Output_5.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1), 
                   file = "N://COVerAGE-DB/Data/Output_5.csv")
data.table::fwrite(as.list(header_msg2), 
                   file = "N://COVerAGE-DB/Data/Output_5.csv",
                   append = TRUE)
data.table::fwrite(as.list(header_msg3), 
                   file = "N://COVerAGE-DB/Data/Output_5.csv",
                   append = TRUE)
data.table::fwrite(outputCounts_5_1e5_rounded, 
                   file = "N://COVerAGE-DB/Data/Output_5.csv", 
                   append = TRUE, col.names = TRUE)




### Age harmonization: 10-year age groups ###########################

# Get 10-year groups from 5-year groups
outputCounts_10 <- 
  #  Take 5-year groups
  outputCounts_5_1e5 %>% 
  # Replace numbers ending in 5
  collapse::fmutate(Age = Age - Age %% 10) %>% 
  # Sum 
  collapse::fgroup_by(Country, Region, Code, Date, Sex, Measure, Age) %>% 
  collapse::fsummarize(Value = sum(Value),
            keep.group_vars = FALSE) %>% 
  # Replace age interval values
  collapse::fmutate(AgeInt = ifelse(Age == 100, 5, 10))

outputCounts_10 <- outputCounts_10[, colnames(outputCounts_5_1e5)]

# round output for csv
outputCounts_10_rounded <- 
  outputCounts_10 %>% 
  mutate(Value = round(Value,1))
# Deaths = round(Deaths,1),
# Tests = round(Tests,1))

# Save CSV
header_msg1 <- "Counts of all measures in harmonized 10-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))


#write_lines(header_msg, path = here("Data","Output_10.csv"))
#write_csv(outputCounts_10_rounded, path = here("Data","Output_10.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1), 
                   file = "N://COVerAGE-DB/Data/Output_10.csv")
data.table::fwrite(as.list(header_msg2), 
                   file = "N://COVerAGE-DB/Data/Output_10.csv",
                   append = TRUE)
data.table::fwrite(as.list(header_msg3), 
                   file = "N://COVerAGE-DB/Data/Output_10.csv",
                   append = TRUE)

data.table::fwrite(outputCounts_10_rounded, 
                   file = "N://COVerAGE-DB/Data/Output_10.csv", 
                   append = TRUE, col.names = TRUE)

# Save binary

# saveRDS(outputCounts_10, here::here("Data","Output_10.rds"))
data.table::fwrite(outputCounts_10, file = "N://COVerAGE-DB/Data/Output_10_internal.csv")




