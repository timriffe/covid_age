# TODO: make error trapping wrappers for parallelization of each step.

### Functions & settings ############################################

source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

logfile <- here("buildlog.md")

### Get data ########################################################


inputDB <- data.table::fread(here("Data","inputDBresolved.csv"),
                             encoding = "UTF-8")


# this script transforms the inputDB as required, and produces standardized measures and metrics

icolsIN <- colnames(inputDB)
icols   <- icolsIN[icolsIN != "AgeInt"]

### Remove unnecessary rows #########################################

Z <-
  inputDB %>% 
  # TR: This removes sex-totals that are fractions.
  filter(!(Age == "TOT" & Metric == "Fraction"),
         !(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Value == 0),
         !is.na(Value)) %>% 
  as.data.table() %>% 
  mutate(AgeInt = as.integer(AgeInt))


### Covert UNK Sex, UNK Age to both-sex TOT entries ################

# Log
log_section("prep (resolve_UNKUNK)", logfile = logfile)

AA <- Z[ , try_step(
  process_function = resolve_UNKUNK,
  chunk = .SD,
  byvars = c("Code","Date","Measure"),
  logfile = logfile,
  write_log = FALSE),
  by = list(Code, Date, Measure),
  .SDcols = icols][,..icols]


### Convert fractions ###############################################

# Log 
log_section("A (convert_fractions_sexes)", logfile = logfile)

# Convert sex-specific fractions to counts
A <- AA[ , try_step(process_function = convert_fractions_sexes,
                   chunk = .SD,
                   byvars = c("Code","Date","Measure"),
                   logfile = logfile,
                   write_log = FALSE),
        by = list(Code, Date, Measure), 
        .SDcols = icols][,..icols]

# Convert fractions within sexes to counts
A <- A[ , try_step(process_function = convert_fractions_within_sex,
                   chunk = .SD,
                   byvars = c("Code","Date", "Sex", "Measure"),
                   logfile = logfile,
                   write_log = FALSE),
        by=list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

### Distribute counts with unknown age ##############################

# Log
log_section("B (redistribute_unknown_age)", logfile = logfile)

B <- A[ , try_step(process_function = redistribute_unknown_age,
                   chunk = .SD,
                   byvars = c("Code","Date","Sex","Measure"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

### Scale to totals (within sex) ####################################

# Log
log_section("C (rescale_to_total)", logfile = logfile)

C <- B[ , try_step(process_function = rescale_to_total,
                   chunk = .SD,
                   byvars = c("Code","Date","Sex","Measure"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

### Derive counts from deaths and CFRs ##############################

# Log
log_section("D (infer_cases_from_deaths_and_ascfr)", logfile = logfile)

D <- C[ , try_step(process_function = infer_cases_from_deaths_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code","Date", "Sex"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Sex), 
        .SDcols = icols][,..icols]

# Infer deaths from cases and CFRs ##################################

# Log
log_section("E (infer_deaths_from_cases_and_ascfr)", logfile = logfile)

E <- D[ , try_step(process_function = infer_deaths_from_cases_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code","Date", "Sex"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Sex), 
        .SDcols = icols][,..icols]

# Drop ratio (just to be sure, above call probably did that)
E <- E[Metric != "Ratio"]

### Distribute cases with unkown sex ################################

log_section("G (redistribute_unknown_sex)", logfile = logfile)

G <- E[ , try_step(process_function = redistribute_unknown_sex,
                   chunk = .SD,
                   byvars = c("Code","Date", "Age", "Measure"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Age, Measure), 
        .SDcols = icols][,..icols]

### Scale sex-specific data to match combined sex data ##############

# Log
log_section("H (rescale_sexes)", logfile = logfile)

H <- G[ , try_step(process_function = rescale_sexes,
                   chunk = .SD,
                   byvars = c("Code","Date", "Measure"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Measure), 
        .SDcols = icols][,..icols]

# Remove sex totals
H <- H[Age != "TOT"]

### Both sexes combined calculated from sex-specifc #################

# Log
log_section("I (infer_both_sex)", logfile = logfile)

I <- H[ , try_step(process_function = infer_both_sex,
                   chunk = .SD,
                   byvars = c("Code","Date", "Measure"),
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Measure), 
        .SDcols = icols][,..icols]

# saveRDS(I, file = "Data/step_I_testing_maybe_lower_closeout.rds")  
### Adjust closeout age #############################################

# Log
log_section("J (maybe_lower_closeout)", logfile = logfile)

J <- I[ , Age := as.integer(Age), ][, ..icols]

# Adjust
J <- J[ , try_step(process_function = maybe_lower_closeout,
                   chunk = .SD, 
                   byvars = c("Code","Date", "Sex", "Measure"),
                   OAnew_min = 85,
                   Amax = 104,
                   logfile = logfile,
                   write_log = FALSE), 
        by = list(Code, Date, Sex, Measure),
        .SDcols = icols][,..icols]

### Adjusting starting age

K <- J %>% 
  group_by(Date, Code, Sex, Measure) %>% 
  slice(which.min(Age)) %>% 
  filter(Age != 0) %>% 
  mutate(Age = 0,
         Value = 0) 
K <- rbind(J, K) %>% 
  sort_input_data()


### Saving ##########################################################

# Formatting 
# TR: add_AgeInt might not be working!!
inputCounts <- K[ , AgeInt := add_AgeInt(Age, omega = 105),
                  by = list(Country, Region, Date, Sex, Measure)][, ..icolsIN] %>% 
  arrange(Country, Region, Sex, Measure, Age) %>% 
  as.data.frame()

# Save
# saveRDS(inputCounts, file = here("Data","inputCounts.rds"))
data.table::fwrite(inputCounts, file = here::here("Data","inputCounts.csv"))
data.table::fwrite(inputCounts, file = here::here("Data", "inputCounts-SnapShots", 
                                                  paste0("inputCounts_", lubridate::today(), ".csv")))

rm(inputDB,Z,AA,A,B,C,D,E,G,H,I,J);gc()

# create failures object:

# TR: tricky in infer after these steps because of Metric / Measure conversions.
# namely, missing ASFCR Measure, or missing Fraction, or Ratio Metrics are artifacts.
# ASCFR could results in Cases OR Deaths, as well. Code, Date, Sex?



