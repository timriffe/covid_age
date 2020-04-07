source("R/00_Functions.R")
source("R/01_grab_data.R")
# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age
# Careful to subset on the right things for each step.

inputCounts <- 
  inputDB %>% 
  group_by(Code, Sex, Measure) %>% 
  do(convert_fractions(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex) %>% 
  # TR: This step can be improved I think.
  do(infer_cases_from_deaths_and_ascfr(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex, Measure) %>% 
  do(redistribute_unknown_age(chunk = .data)) %>% 
  ungroup() %>% 
  mutate(Age = as.integer(Age))

inputCounts %>% 
  filter(is.na(Age))
# -------------------------------#
# Next step harmonize age groups #
# -------------------------------#

