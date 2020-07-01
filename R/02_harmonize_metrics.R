# TODO: make error trapping wrappers for parallelization of each step.

### Functions & settings ############################################

# Better safe than sorry
rm(list=ls());gc()
source("R/00_Functions.R")



### Get data ########################################################

# Load
inputDB <- readRDS(here("Data","inputDB.rds"))

# Any NAs in data?
inputDB %>% '$'(Age) %>% is.na() %>% any()
inputDB %>% '$'(Value) %>% is.na() %>% any()

# Column names
icols <- colnames(inputDB)



### Remove unnecessary rows #########################################

Z <-
  inputDB %>% 
  filter(!(Age == "TOT" & Metric == "Fraction"),
         !(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Sex == 0)) %>% 
  as.data.table()



### Convert fractions ###############################################

# Log entry
log_section("A")

# Convert sex-specific fractions to counts
A <- Z[ , try_step(process_function = convert_fractions_sexes,
                   chunk = .SD,
                   byvars = c("Code","Measure")),
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]

# Convert fractions within sexes to counts
A <- A[ , try_step(process_function = convert_fractions_within_sex,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")),
        by=list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]



### Distribute counts with unknown age ##############################

# Log
log_section("B")

# Distribute
B <- A[ , try_step(process_function = redistribute_unknown_age,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")), 
        by = list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]



### Scale to totals (within sex) ####################################

# Log
log_section("C")

# Scale
C <- B[ , try_step(process_function = rescale_to_total,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")), 
        by = list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]



### Derive counts from deaths and CFRs ##############################

# Log
log_section("D")

# Infer
D <- C[ , try_step(process_function = infer_cases_from_deaths_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code", "Sex")), 
        by = list(Code, Sex), 
        .SDcols = icols][,..icols]



# Infer deaths from cases and CFRs ##################################

# Log
log_section("E")

# Infer
E <- D[ , try_step(process_function = infer_deaths_from_cases_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code", "Sex")), 
        by = list(Code, Sex), 
        .SDcols = icols][,..icols]

# Drop ratio (just to be sure, above call probably did that)
E <- E[Metric != "Ratio"]



### Distribute cases with unkown sex ################################

# Log
log_section("G")

# Redistribute
G <- E[ , try_step(process_function = redistribute_unknown_sex,
                   chunk = .SD,
                   byvars = c("Code", "Age", "Measure")), 
        by = list(Code, Age, Measure), 
        .SDcols = icols][,..icols]



### Scale sex-specific data to match combined sex data ##############

# Log
log_section("H")

# Rescale
H <- G[ , try_step(process_function = rescale_sexes,
                   chunk = .SD,
                   byvars = c("Code", "Measure")), 
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]

# Remove sex totals
H <- H[Age != "TOT"]



### Both sexes combined calculated from sex-specifc #################

# Log
log_section("I")

# Calculate
I <- H[ , try_step(process_function = infer_both_sex,
                   chunk = .SD,
                   byvars = c("Code", "Measure")), 
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]


### Adjust closeout age #############################################

# Log
log_section("J")

# Make sure age is integer
J <- I[ , Age := as.integer(Age), ][, ..icols]

# Adjust
J <- J[ , try_step(process_function = maybe_lower_closeout,
                   chunk = .SD, 
                   byvars = c("Code", "Sex", "Measure"),
                   OAnew_min = 85), 
        by = list(Code, Sex, Measure),
        .SDcols = icols][,..icols]



### Saving ##########################################################

# Formatting 
inputCounts <- J %>% 
  arrange(Country, Region, Sex, Measure, Age) %>% 
  as.data.frame()

# Save
saveRDS(inputCounts, file = here("Data","inputCounts.rds"))

# List of everything
COMPONENTS <- list(inputDB = inputDB, 
                   A = A, 
                   B = B, 
                   C = C, 
                   D = D, 
                   E = E, 
                   G = G, 
                   H = H, 
                   I = I, 
                   J = J)

# Save list
save(COMPONENTS, file = here("Data","ProcessingSteps.Rdata"))


