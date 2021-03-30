
### Clean up & functions ############################################
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")


logfile <- here::here("buildlog.md")
# n.cores <- round(6 + (detectCores() - 8)/4)
# n.cores  <- 3

freesz  <- memuse::Sys.meminfo()$freeram@size
n.cores <- min(round(freesz / 16),20)

### Load data #######################################################

# Count data
inputCounts <- readRDS(here::here("Data","inputCounts.rds"))
inputCounts$Metric <- NULL
 
# Offsets
Offsets     <- readRDS(here::here("Data","Offsets.rds"))
# print(object.size(Offsets),units = "Mb")
# 2.1 Mb
# Sort count data, add group ids.

inputCounts <- 
  inputCounts %>% 
  arrange(Country, Region, Date, Measure, Sex, Age) %>% 
  group_by(Code, Sex, Measure, Date) %>% 
  mutate(id = cur_group_id(),
         core_id = sample(1:n.cores,size=1,replace = TRUE)) %>% 
  ungroup() 

# nr rows per core
# inputCounts$core_id %>% table()

ids_in <- inputCounts$id %>% unique() %>% sort()

# Number of subsets per core
# tapply(inputCounts$id,inputCounts$core_id,function(x){x %>% unique() %>% length()})
# Split counts into big chunks
iL <- split(inputCounts,
            inputCounts$core_id,
            drop = TRUE)

### Age harmonization: 5-year age groups ############################

# Log
log_section("Age harmonization", 
            append = TRUE, 
            logfile = logfile)


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

saveRDS(iLout1e5, file = here::here("Data","iLout1e5.rds"))
 
out5 <- 
  rbindlist(iLout1e5) 
  # Get into one data set
saveRDS(out5, file = here::here("Data","Output_5_before_sex_scaling_etc.rds"))
 rm(iL);rm(iLout1e5)

ids_out  <- out5$id %>% unique() %>% sort()
failures <- ids_in[!ids_in %in% ids_out]

HarmonizationFailures <-
  inputCounts %>% 
  filter(id %in% failures)

saveRDS(HarmonizationFailures, file = here::here("Data","HarmonizationFailures.rds"))

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
outputCounts_5_1e5 <-
  out5 %>% 
  as.data.table() %>% 
  .[, Value := nafill(Value, nan = NA, fill = 1)] %>% 
  .[, rescale_sexes_post(chunk = .SD), keyby = .(Country, Region, Code, Date, Measure, AgeInt)] %>% 
  as_tibble() %>% 
  pivot_wider(names_from = "Measure", values_from = "Value") %>% 
  dplyr::select(Country, Region, Code, Date, Sex, Age, AgeInt, Cases, Deaths, Tests) %>% 
  arrange(Country, Region, dmy(Date), Sex, Age) 
# Save binary

# if (hours < Inf){
#   outputCounts_5_1e5_hold <- readRDS(here("Data","Output_5.rds"))
#   outputCounts_5_1e5_out <-
#     outputCounts_5_1e5_hold %>% 
#     pivot_longer(cols = Cases:Tests,
#                  names_to = "Measure",
#                  values_to = "Value") %>% 
#     filter(!is.na(Value)) %>% 
#     mutate(Short = add_Short(Code,Date),
#            checkid = paste(Country,Region,Measure,Short)) %>% 
#     # remove anything we had before that we just re-processed.
#     # unfortunately also throws out anything that didn't throw an
#     # error previous time but did so this time.
#     filter(!checkid %in% codes_in) %>% 
#     pivot_wider(names_from = Measure,
#                 values_from = Value) %>% 
#     # append the stuff we just processed
#     bind_rows(outputCounts_5_1e5) %>% 
#     # Get date into correct format
#     mutate(date = dmy(Date)) %>% 
#     # Sort
#     arrange(Country, Region, date, Sex, Age) %>% 
#     select(-date, -Short, -checkid)
#   
#   saveRDS(outputCounts_5_1e5_out, here("Data","Output_5.rds"))
#   
#   outputCounts_5_1e5 <- outputCounts_5_1e5_out
#   
# } else {
  saveRDS(outputCounts_5_1e5, here::here("Data","Output_5.rds"))
# }




# Round to full integers
outputCounts_5_1e5_rounded <- 
  outputCounts_5_1e5 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1),
         Tests = round(Tests,1))

# Save csv
header_msg1 <- "Counts of Cases, Deaths, and Tests in harmonized 5-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))

#write_lines(header_msg, path = here("Data","Output_5.csv"))
#write_csv(outputCounts_5_1e5_rounded, path = here("Data","Output_5.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1), 
                   file = here::here("Data","Output_5.csv"))
data.table::fwrite(as.list(header_msg2), 
                   file = here::here("Data","Output_5.csv"),
                   append = TRUE)
data.table::fwrite(as.list(header_msg3), 
                   file = here::here("Data","Output_5.csv"),
                   append = TRUE)
data.table::fwrite(outputCounts_5_1e5_rounded, 
                   file = here::here("Data","Output_5.csv"), 
                   append = TRUE, col.names = TRUE)




### Age harmonization: 10-year age groups ###########################

# Get 10-year groups from 5-year groups
outputCounts_10 <- 
  #  Take 5-year groups
  outputCounts_5_1e5 %>% 
  # Replace numbers ending in 5
  mutate(Age = Age - Age %% 10) %>% 
  # Sum 
  group_by(Country, Region, Code, Date, Sex, Age) %>% 
  summarize(Cases = sum(Cases),
            Deaths = sum(Deaths),
            Tests = sum(Tests)) %>% 
  ungroup() %>% 
  # Replace age interval values
  mutate(AgeInt = ifelse(Age == 100, 5, 10))

outputCounts_10 <- outputCounts_10[, colnames(outputCounts_5_1e5)]

# round output for csv
outputCounts_10_rounded <- 
  outputCounts_10 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1),
         Tests = round(Tests,1))

# Save CSV
header_msg1 <- "Counts of Cases, Deaths, and Tests in harmonized 10-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))


#write_lines(header_msg, path = here("Data","Output_10.csv"))
#write_csv(outputCounts_10_rounded, path = here("Data","Output_10.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1), 
                   file = here::here("Data","Output_10.csv"))
data.table::fwrite(as.list(header_msg2), 
                   file = here::here("Data","Output_10.csv"),
                   append = TRUE)
data.table::fwrite(as.list(header_msg3), 
                   file = here::here("Data","Output_10.csv"),
                   append = TRUE)

data.table::fwrite(outputCounts_10_rounded, 
                   file = here::here("Data","Output_10.csv"), 
                   append = TRUE, col.names = TRUE)

# Save binary

saveRDS(outputCounts_10, here::here("Data","Output_10.rds"))



### Checks ##########################################################

# Check?
spot_checks <- FALSE

if (spot_checks){
  
# Once-off diagnostic plot: Data preparation
ASCFR5 <- 
outputCounts_5_1e5 %>% 
    group_by(Country, Region, Code, Sex) %>% 
    mutate(D = sum(Deaths)) %>% 
    ungroup() %>% 
    mutate(ASCFR = Deaths / Cases,
           ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
    dplyr::filter(!is.na(ASCFR),
           Sex == "b",
           D >= 100) 

# Once-off diagnostic plot: Plot
ASCFR5 %>% 
  ggplot(aes(x=Age, y = ASCFR, group = interaction(Country, Region, Code))) + 
  geom_line(alpha=.05) + 
  scale_y_log10() + 
  xlim(20,100) + 
  geom_quantile(ASCFR5,
                mapping=aes(x=Age, y = ASCFR), 
                method = "rqss",
                quantiles=c(.025,.25,.5,.75,.975), 
                lambda = 2,
                inherit.aes = FALSE,
                color = "tomato",
                size = 1)

}