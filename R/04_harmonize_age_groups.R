
### Clean up & functions ############################################

source(here("R","00_Functions.R"))
logfile <- here("buildlog.md")
n.cores <- round(6 + (detectCores() - 8)/8)


### Load data #######################################################

# Count data
inputCounts <- readRDS(here("Data","inputCounts.rds"))
inputCounts$Metric <- NULL

codes_in <- with(inputCounts, paste(Country,Region,Measure,Short)) %>% unique()

# Offsets
Offsets     <- readRDS(here("Data","Offsets.rds"))

# Sort count data
inputCounts <- 
  inputCounts %>% 
  arrange(Country, Region, Measure, Sex, Age)

# Split counts into chunks
iL <- split(inputCounts,
              list(inputCounts$Code,
                   inputCounts$Sex,
                   inputCounts$Measure),
              drop =TRUE)

# rmelements <-
# iL %>% lapply(function(X){
#   any(X$Measure == "Count")
# }) %>% unlist()
# iL <- iL[!rmelements]
### Age harmonization: 5-year age groups ############################

# Log
log_section("Age harmonization", 
            append = TRUE, 
            logfile = logfile)
 
# Apply PCLM to split into 5-year age groups
iLout1e5 <- mclapply(iL, 
                      FUN = try_step,
                      process_function = harmonize_age_p,
                      byvars = c("Code","Sex","Measure"),
                      Offsets = Offsets,
                      N = 5,
                      OAnew = 100,
                      lambda = 1e5,
                      logfile = logfile,
                      mc.cores = n.cores)
# rmelements <-
#   iLout1e5 %>% lapply(function(X){
#     any(X$Measure == "Count")
#   }) %>% unlist()
# iLout1e5 <- iLout1e5[!rmelements]
# Edit results
outputCounts_5_1e5 <- iLout1e5 %>% 
                      # Get into one data set
                      rbindlist() %>% 
                      # Replace NaNs 
                      mutate(Value = ifelse(is.nan(Value),0,Value)) %>% 
                      # Rescale sexes
                      group_by(Code, Measure) %>% 
                      do(rescale_sexes_post(chunk = .data)) %>% 
                      ungroup() %>%
                      # Reshape to wide
                      pivot_wider(names_from = Measure,
                                  values_from = Value) %>% 
                      # Get date into correct format
                      mutate(date = dmy(Date)) %>% 
                      # Sort
                      arrange(Country, Region, date, Sex, Age) %>% 
                      select(-date) 

# Save binary

if (hours < Inf){
  outputCounts_5_1e5_hold <- readRDS(here("Data","Output_5.rds"))
  outputCounts_5_1e5_out <-
    outputCounts_5_1e5_hold %>% 
    pivot_longer(cols = Cases:Tests,
                 names_to = "Measure",
                 values_to = "Value") %>% 
    filter(!is.na(Value)) %>% 
    mutate(Short = add_Short(Code,Date),
           checkid = paste(Country,Region,Measure,Short)) %>% 
    # remove anything we had before that we just re-processed.
    # unfortunately also throws out anything that didn't throw an
    # error previous time but did so this time.
    filter(!checkid %in% codes_in) %>% 
    pivot_wider(names_from = Measure,
                values_from = Value) %>% 
    # append the stuff we just processed
    bind_rows(outputCounts_5_1e5) %>% 
    # Get date into correct format
    mutate(date = dmy(Date)) %>% 
    # Sort
    arrange(Country, Region, date, Sex, Age) %>% 
    select(-date, -Short, -checkid)
  
  saveRDS(outputCounts_5_1e5_out, here("Data","Output_5.rds"))
  
  outputCounts_5_1e5 <- outputCounts_5_1e5_out
  
} else {
  saveRDS(outputCounts_5_1e5, here("Data","Output_5.rds"))
}




# Round to full integers
outputCounts_5_1e5_rounded <- 
  outputCounts_5_1e5 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1),
         Tests = round(Tests,1))

# Save csv
header_msg <- paste("Counts of Cases, Deaths, and Tests in harmonized 5-year age groups\nBuilt:",timestamp(prefix="",suffix=""),"\nReproducible with: ",paste0("https://github.com/timriffe/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))
write_lines(header_msg, file = here("Data","Output_5.csv"))
write_csv(outputCounts_5_1e5_rounded, file = here("Data","Output_5.csv"), append = TRUE, col_names = TRUE)





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
header_msg <- paste("Counts of Cases, Deaths, and Tests in harmonized 10-year age groups\nBuilt:",timestamp(prefix="",suffix=""),"\nReproducible with: ",paste0("https://github.com/timriffe/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))
write_lines(header_msg, file = here("Data","Output_10.csv"))
write_csv(outputCounts_10_rounded, file = here("Data","Output_10.csv"), append = TRUE, col_names = TRUE)

# Save binary

saveRDS(outputCounts_10, here("Data","Output_10.rds"))



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
    filter(!is.na(ASCFR),
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