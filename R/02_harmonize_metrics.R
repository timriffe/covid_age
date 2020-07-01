# TODO: make error trapping wrappers for parallelization of each step.

source(here("R","00_Functions.R"))
# mc.cores <- 6

inputDB <- readRDS(here("Data","inputDB.rds"))

# this script transforms the inputDB as required, and produces standardized measures and metrics

inputDB %>% pull(Age) %>% is.na() %>% any()
inputDB %>% pull(Value) %>% is.na() %>% any()

icols <- colnames(inputDB)

#log_section("New build run!", append = FALSE)

A <-
  inputDB %>% 
  filter(!(Age == "TOT" & Metric == "Fraction"),
         !(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Sex == 0)) %>% 
  as.data.table() %>% 
  mutate(AgeInt = as.integer(AgeInt))

# Fraction conversion, consider as single step
log_section("A", logfile = logfile)
A <- A[ , try_step(process_function = convert_fractions_all_sexes,
                   chunk = .SD,
                   byvars = c("Code","Measure")),
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]

A <- A[ , try_step(process_function = convert_fractions_within_sex,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")),
        by=list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]

# Unk Age redist
log_section("B", logfile = logfile)
B <- A[ , try_step(process_function = redistribute_unknown_age,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")), 
        by = list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]

# Scale to totals (within sex)
log_section("C", logfile = logfile)
C <- B[ , try_step(process_function = rescale_to_total,
                   chunk = .SD,
                   byvars = c("Code","Sex","Measure")), 
        by = list(Code, Sex, Measure), 
        .SDcols = icols][,..icols]

# Deaths + ASCFR -> Cases (not so good)
log_section("D", logfile = logfile)
D <- C[ , try_step(process_function = infer_cases_from_deaths_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code", "Sex")), 
        by = list(Code, Sex), 
        .SDcols = icols][,..icols]

# Cases + ASCFR -> Deaths (not bad)
log_section("E", logfile = logfile)
E <- D[ , try_step(process_function = infer_deaths_from_cases_and_ascfr,
                   chunk = .SD,
                   byvars = c("Code", "Sex")), 
        by = list(Code, Sex), 
        .SDcols = icols][,..icols]
E <- E[Metric != "Ratio"]

# UNK Sex (within age)
log_section("G", logfile = logfile)
G <- E[ , try_step(process_function = redistribute_unknown_sex,
                   chunk = .SD,
                   byvars = c("Code", "Age", "Measure")), 
        by = list(Code, Age, Measure), 
        .SDcols = icols][,..icols]

# sex-specific scaled to both-sex
log_section("H", logfile = logfile)
H <- G[ , try_step(process_function = rescale_sexes,
                   chunk = .SD,
                   byvars = c("Code", "Measure")), 
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]
H <- H[Age != "TOT"]

# both-sex calculated as sum of sex-specific (when not collected seprarately)
log_section("I", logfile = logfile)
I <- H[ , try_step(process_function = infer_both_sex,
                   chunk = .SD,
                   byvars = c("Code", "Measure")), 
        by = list(Code, Measure), 
        .SDcols = icols][,..icols]


# if closeout ends in 0s, lower the closeout age as far as 85+
log_section("J", logfile = logfile)
J <- I[ , Age := as.integer(Age), ][, ..icols]
J <- J[ , try_step(process_function = maybe_lower_closeout,
                   chunk = .SD, 
                   byvars = c("Code", "Sex", "Measure"),
                   OAnew_min = 85), 
        by = list(Code, Sex, Measure),
        .SDcols = icols][,..icols]

# output
inputCounts <- J %>% 
  arrange(Country, Region, Sex, Measure, Age) %>% 
  as.data.frame()

# n <- duplicated(inputCounts[,c("Code","Sex","Age","Measure","Metric")])
# sum(n)
saveRDS(inputCounts, file = here("Data","inputCounts.rds"))

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
save(COMPONENTS, file = here("Data","ProcessingSteps.Rdata"))

rm(list=setdiff(ls(), c("logfile","creds")))
# TR: add rescale_to_total() into the chain

# inputCounts %>% filter(is.na(Value)) %>% View()

# inputCounts %>% filter(is.infinite(Value)) %>% View()
# -------------------------------#
# Next step harmonize age groups #
# -------------------------------#

# NOTE: add function to check that for subsets with m and f Sex there is also a b
# and create it if necessary.


# The previous dplyr chain
# tic()
# A <-
#   inputDB %>% 
#   filter(!(Age == "TOT" & Metric == "Fraction"),
#          !(Age == "UNK" & Value == 0),
#          !(Sex == "UNK" & Sex == 0)) %>% 
#   group_by(Code, Measure) %>%
#   # do_we_convert_fractions_all_sexes(chunk)
#   do(convert_fractions_all_sexes(chunk = .data)) %>% 
#   ungroup() %>% 
#   group_by(Code, Sex, Measure) %>% 
#   # do_we_convert_fractions_within_sex(chunk)
#   do(convert_fractions_within_sex(chunk = .data)) %>% 
#  toc() # 857 ...

# B <- A  %>% 
#   # do_we_redistribute_unknown_age()
#   do(redistribute_unknown_age(chunk = .data))

# C <- B %>% 
#   # do_we_rescale_to_total()
#   do(rescale_to_total(chunk = .data)) %>% 
#   ungroup() 

# D <- C %>% 
#   group_by(Code, Sex) %>% 
#   # TR: This step can be improved I think.
#   # do_we_infer_cases_from_deaths_and_ascfr() "ITinfo15.04.2020"
#   do(infer_cases_from_deaths_and_ascfr(chunk = .data))

# E <- D %>% 
#   # do_we_infer_deaths_from_cases_and_ascfr()
#   do(infer_deaths_from_cases_and_ascfr(chunk = .data)) %>%  
#   ungroup() %>% 
#   # finally remove this
#   filter(Metric != "Ratio")

# G <- E %>% 
#   group_by(Code, Age, Measure) %>% 
#   # do_we_redistribute_unknown_sex()
#   do(redistribute_unknown_sex(chu# 
# I <- H %>% 
#   # do_we_infer_both_sex()
#   do(infer_both_sex(chunk = .data)) %>% 
#   ungroup() nk = .data)) %>% 
#   ungroup() 

# H <- G %>% 
#   group_by(Code, Measure) %>% 
#   # TR: change this to happen within Age
#   # do_we_rescale_sexes()
#   do(rescale_sexes(chunk = .data)) %>% 
#   # possibly there was a Sex = "b" Age = "TOT" left here.
#   # These would have made it this far if preserved to rescale sexes
#   filter(Age != "TOT")
# 
# I <- H %>% 
#   # do_we_infer_both_sex()
#   do(infer_both_sex(chunk = .data)) %>% 
#   ungroup() 

# J <- I %>% 
#   mutate(Age = as.integer(Age)) %>% 
#   group_by(Code, Sex, Measure) %>% 
#   #do_we_maybe_lower_closeout()
#   do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 
#   ungroup()



