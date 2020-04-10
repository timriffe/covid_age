source("R/00_Functions.R")
#source("R/01_grab_data.R")
# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age
# Careful to subset on the right things for each step.

inputCounts <- 
  inputDB %>% 
  filter(Sex != "UNK",
         !(Age == "TOT" & Metric == "Fraction")) %>% 
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
  mutate(Age = as.integer(Age),
         AgeInt = as.integer(AgeInt)) 

# -------------------------------#
# Next step harmonize age groups #
# -------------------------------#

# NOTE: add function to check that for subsets with m and f Sex there is also a b
# and create it if necessary.

# inputCounts %>% pull(Age) %>% is.na() %>% sum()
# inputCounts %>% 
#   filter(is.na(Age))
