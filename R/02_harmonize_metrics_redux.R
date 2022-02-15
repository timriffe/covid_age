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
icols   <- c(icolsIN[icolsIN != "AgeInt"],"keep_","reason")

### Remove unnecessary rows #########################################

Z <-
  inputDB %>% 
  # TR: This removes sex-totals that are fractions.
  # does this need to be recosidered?
  # For example an age-sex fraction dist with Sex = "b" total?
  
  filter(!(Age == "TOT" & Metric == "Fraction"),
         !(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Value == 0),
         !is.na(Value)) %>% 
  as.data.table() %>% 
  mutate(AgeInt = as.integer(AgeInt),
         keep_ = TRUE,
         reason = NA_character_)


### Covert UNK Sex, UNK Age to both-sex TOT entries ################

# Log
log_section("prep (resolve_UNKUNK)", logfile = logfile)

Z <- Z[ , try_step(
  process_function = resolve_UNKUNK,
  chunk = .SD,
  process_function_name = "resolve_UNKUNK"),
  by = list(Code, Date, Measure),
  .SDcols = icols][,..icols]

A_failures  <- Z[keep_ == FALSE]
Z           <- Z[keep_ == TRUE]

### Convert fractions ###############################################

# Log 
log_section("convert_fractions_sexes", logfile = logfile)

# Convert sex-specific fractions to counts
Z <- Z[ , try_step(process_function = convert_fractions_sexes,
                    chunk = .SD,
                    process_function_name = "convert_fractions_sexes"),
         by = list(Code, Date, Measure), 
         .SDcols = icols][,..icols]

B_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
# Log 
log_section("convert_fractions_within_sex", logfile = logfile)
# Convert fractions within sexes to counts
Z <- Z[ , try_step(process_function = convert_fractions_within_sex,
                   chunk = .SD,
                   process_function_name = "convert_fractions_within_sex"),
        by=list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

C_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]

### Distribute counts with unknown age ##############################

# Log
log_section("redistribute_unknown_age", logfile = logfile)

Z <- Z[ , try_step(process_function = redistribute_unknown_age,
                   chunk = .SD,
                   process_function_name = "redistribute_unknown_age"), 
        by = list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

C_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
### Scale to totals (within sex) ####################################

# Log
log_section("rescale_to_total", logfile = logfile)

Z <- Z[ , try_step(process_function = rescale_to_total,
                   chunk = .SD,
                   process_function_name = "rescale_to_total"), 
        by = list(Code, Date, Sex, Measure), 
        .SDcols = icols][,..icols]

D_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
### Derive counts from deaths and CFRs ##############################

# Log
log_section("infer_cases_from_deaths_and_ascfr", logfile = logfile)

Z <- Z[ , try_step(process_function = infer_cases_from_deaths_and_ascfr,
                   chunk = .SD,
                   process_function_name = "infer_cases_from_deaths_and_ascfr"), 
        by = list(Code, Date, Sex), 
        .SDcols = icols][,..icols]

E_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
# Infer deaths from cases and CFRs ##################################

# Log
log_section("infer_deaths_from_cases_and_ascfr", logfile = logfile)

Z <- Z[ , try_step(process_function = infer_deaths_from_cases_and_ascfr,
                   chunk = .SD,
                   process_function_name = "infer_deaths_from_cases_and_ascfr"), 
        by = list(Code, Date, Sex), 
        .SDcols = icols][,..icols]

F_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
# Drop ratio (just to be sure, above call probably did that)
G_failures <- Z[Metric == "Ratio"] %>% 
  mutate(reason = "why are there still Ratio metrics?")
Z <- Z[Metric != "Ratio"]

### Distribute cases with unkown sex ################################

log_section("redistribute_unknown_sex", logfile = logfile)

Z <- Z[ , try_step(process_function = redistribute_unknown_sex,
                   chunk = .SD,
                   process_function_name = "redistribute_unknown_sex"), 
        by = list(Code, Date, Age, Measure), 
        .SDcols = icols][,..icols]
H_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
### Scale sex-specific data to match combined sex data ##############

# Log
log_section("rescale_sexes", logfile = logfile)

Z <- Z[ , try_step(process_function = rescale_sexes,
                   chunk = .SD,
                   process_function_name = "rescale_sexes"), 
        by = list(Code, Date, Measure), 
        .SDcols = icols][,..icols]

I_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
# Remove sex totals
Z <- Z[Age != "TOT"]

### Both sexes combined calculated from sex-specifc #################

# Log
log_section("infer_both_sex", logfile = logfile)

Z <- Z[ , try_step(process_function = infer_both_sex,
                   chunk = .SD,
                   process_function_name = "infer_both_sex"), 
        by = list(Code, Date, Measure), 
        .SDcols = icols][,..icols]

J_failures <- Z[keep_ == FALSE]
Z          <- Z[keep_ == TRUE]
# saveRDS(I, file = "Data/step_I_testing_maybe_lower_closeout.rds")  
### Adjust closeout age #############################################

# Log
log_section("maybe_lower_closeout", logfile = logfile)

Z <- Z[ , Age := as.integer(Age), ][, ..icols]

# Adjust
Z <- Z[ , try_step(process_function = maybe_lower_closeout,
                   chunk = .SD, 
                   process_function_name = "maybe_lower_closeout"), 
        by = list(Code, Date, Sex, Measure),
        .SDcols = icols][,..icols]

K_failures <- Z[keep_ == FALSE] 
K_failures <- K_failures[ , Age := as.character(Age), ][, ..icols]
Z          <- Z[keep_ == TRUE]

### Saving ##########################################################

# Formatting 

inputCounts <- Z[ , AgeInt := add_AgeInt(Age, omega = 105),
                  by = list(Country, Region, Date, Sex, Measure)][, ..icolsIN] %>% 
  arrange(Country, Region, Sex, Measure, Age) %>% 
  as.data.frame()

inputCounts_failures <- bind_rows(
  A_failures,
  B_failures,
  C_failures,
  D_failures,
  E_failures,
  F_failures,
  G_failures,
  H_failures,
  I_failures,
  J_failures,
  K_failures
) %>% 
  select(-keep_)

# Save
# saveRDS(inputCounts, file = here("Data","inputCounts.rds"))
data.table::fwrite(inputCounts, file = here::here("Data","inputCounts.csv"))
data.table::fwrite(inputCounts_failures, file = here::here("Data","inputCounts_failures.csv"))




