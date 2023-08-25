
### Clean up & functions ############################################
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

# TR 13 July 2023, copied from 01_update_inputDB.R
Measures <- c("Cases","Deaths","Tests","ASCFR","Vaccinations",
              "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4", 
              "Vaccination5", "Vaccination6", "VaccinationBooster")


logfile <- here::here("buildlog.md")
# n.cores <- round(6 + (detectCores() - 8)/4)
# n.cores  <- 3

# no longer used to determine core usage
freesz  <- memuse::Sys.meminfo()$freeram@size
# n.cores <- min(round(freesz / 16),20)
# if (Sys.info()["nodename"] == "HYDRA11"){
#   n.cores <- 50
# }
n.cores <- 4
### Load data #######################################################
#oo <- data.table::fread("N://COVerAGE-DB/Data/Output_5_internal.csv") 

# TR 26 July 2023 as of now, no longer need this reshape step!
# previous age harmonization run:
OutputCounts_old <- data.table::fread("N://COVerAGE-DB/Data/Output_5_internal.csv") %>% 
  filter(!is.na(Value))
#|>
  # TR 13 July 2023 switch to negative selection in order
  # tidyfast::dt_pivot_longer(-c( Country, Region, Code, Date, Sex, Age, AgeInt), 
  #                           names_to = "Measure", 
  #                           values_to = "Value", 
  #                           values_drop_na = TRUE)
  

subsets_keep <- data.table::fread("N://COVerAGE-DB/Data/subsets_keep_harmonizations.csv")

# these can be r-binded back to outputCounts_5_1e5 that were calculated only on the changeset
# Note, if something was deprecated from the inputDB, then it doesn't make it to the outputCounts
# dataset, in which case, its harmonization results are not preserved.
OutputCounts_keep <-
  subsets_keep |>
  left_join(OutputCounts_old, by = c("Code","Date","Sex","Measure")) |>
  select(-keep) 


# which of those old results shall we preserve rather than recalculate?
subset_changes <-
  data.table::fread("N://COVerAGE-DB/Data/subsets_to_harmonize.csv",
                    encoding = "UTF-8")

# Count data

# This used to point to a user copy, but now we presume the most recent inputCounts build is on N!
inputCounts <- data.table::fread("N://COVerAGE-DB/Data/inputCounts.csv",
                                 encoding = "UTF-8") %>% 
  collapse::fsubset(Measure %in% Measures) %>% 
  collapse::fselect(-Metric)


# Use left_join as implicit filter;
# reduced to just those subsets that are new or altered
inputCounts_changes <-
  subset_changes |>
  left_join(inputCounts, by = c("Code","Date","Sex","Measure")) %>% 
  arrange(Country, Region, Date, Measure, Sex, Age) %>% 
  collapse::fgroup_by(Code, Sex, Measure, Date) %>% 
  collapse::fmutate(id = cur_group_id(),
                    core_id = sample(1:n.cores,
                                     size = 1,
                                     replace = TRUE),
                    toss = any(is.na(Value))) %>% 
  ungroup() %>% 
  arrange(core_id,id, Age) %>% 
  collapse::fsubset(!toss) %>% 
  collapse::fselect(-toss)
# inputCounts <- tfile

# Offsets
# TR: are these updated for wpp2022?
Offsets     <- readRDS(here::here("Data","Offsets.rds"))
# print(object.size(Offsets),units = "Mb")
# 2.1 Mb
# Sort count data, add group ids.


# nr rows per core
# inputCounts$core_id %>% table()

# keep these to determine failures
ids_in <- inputCounts_changes$id %>% unique() %>% sort()

# Number of subsets per core
# tapply(inputCounts$id,inputCounts$core_id,function(x){x %>% unique() %>% length()})
# Split counts into big chunks
iL <- split(inputCounts_changes,
            inputCounts_changes$core_id,
            drop = TRUE)

### Age harmonization: 5-year age groups ############################

# Log
# log_section("Age harmonization", 
#             append = TRUE, 
#             logfile = logfile)


#print(object.size(iL),units = "Mb")
# 5 feb 2021 800 Mb
# length(iL)
 tic()
 # Apply PCLM to split into 5-year age groups
 iLout1e5 <- parallelsugar::mclapply(
                      iL, 
                      harmonize_age_p_bigchunks,
                      Offsets = Offsets, # 2.1 Mb data.frame passed to each process
                      N = 5,
                      OAnew = 100,
                      lambda = 1e5,
                      mc.cores = n.cores)
 toc()

# install.packages("doParallel")
# cl <- makeCluster(n.cores)
# clusterEvalQ(cl,
#              {source("R/00_Functions.R");
# Offsets = readRDS("Data/Offsets.rds");N=5;lambda = 1e-5; OAnew = 100})
# #clusterEvalQ(cl,ls())
# iLout1e5 <-parLapply(cl, 
#           iL, 
#           harmonize_age_p_bigchunks, 
#           Offsets = Offsets, 
#           N = 5, 
#           lambda = 1e-5, 
#           OAnew = 100)
# stopCluster(cl)

# saveRDS(iLout1e5, file = here::here("Data","iLout1e5.rds"))
 
out5 <- 
  rbindlist(iLout1e5) 
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

# Edit results
# outputCounts_5_1e5 <- out5 %>%  
#                       # Replace NaNs 
#                       mutate(Value = ifelse(is.nan(Value),0,Value)) %>% 
#                       # Rescale sexes
#                       group_by(Code, Measure) %>% 
#                       do(rescale_sexes_post(chunk = .data)) %>% 
#                       ungroup() %>%
#                       # Reshape to wide
#                       pivot_wider(names_from = Measure,
#                                   values_from = Value) %>% 
#                       # Get date into correct format
#                       mutate(date = dmy(Date)) %>% 
#                       # Sort
#                       arrange(Country, Region, date, Sex, Age) %>% 
#                       select(-date) %>% 
#                       # ensure columns in standard order:
#                       select(Country, Region, Code, Date, Sex, Age, AgeInt, Cases, Deaths, Tests)
# head(out5)

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




# Save binary
# saveRDS(outputCounts_5_1e5, here::here("Data","Output_5.rds"))
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
  mutate(Age = Age - Age %% 10) %>% 
  # Sum 
  group_by(Country, Region, Code, Date, Sex, Measure, Age) %>% 
  summarize(Value = sum(Value),
            .groups= "drop") %>% 
  # Replace age interval values
  mutate(AgeInt = ifelse(Age == 100, 5, 10))

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

# TR: deprecated: G now cut out of processing due to space issues 24 Aug 2023
# also copy rds files to N://COVerAGE-DB/Data
# cdb_files <- c(
#                "Output_5.csv","Output_5_internal.csv",
#                "Output_10.csv","Output_10_internal.csv",
#                "HarmonizationFailures.csv")
# files_from <- file.path("Data",cdb_files)
# 
# file.copy(from = files_from, 
#           to = "N:/COVerAGE-DB/Data", 
#           overwrite = TRUE)

# end


# outputCounts_10 %>% fgroup_by(Code,Date,Sex,Measure,Age) %>% fmutate()