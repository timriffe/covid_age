source("R/00_Functions.R")
#source("R/01_grab_data.R")
# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age
# Careful to subset on the right things for each step.

# Temp filter, can't include Ecuador just yet:
# inputDB <- 
#   inputDB %>% 
#   filter(Country != "Ecuador")

# Some UNK Values in Chile coded as NA 
#inputDB$Value[is.na(inputDB$Value)] <- 0

# TR: add Short to group_by!

inputCounts <-
  inputDB %>% 
  filter(!(Age == "TOT" & Metric == "Fraction")) %>% 
  group_by(Code, Sex, Measure) %>% 
  do(convert_fractions(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex) %>% 
  # TR: This step can be improved I think.
  do(infer_cases_from_deaths_and_ascfr(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex, Measure) %>% 
  do(redistribute_unknown_age(chunk = .data)) %>% 
  do(rescale_to_total(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Age, Measure) %>% 
  do(redistribute_unknown_sex(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Measure) %>% 
  # TR: change this to happen within Age
  do(rescale_sexes(chunk = .data)) %>% 
  do(infer_both_sex(chunk = .data)) %>% 
  ungroup() %>% 
  # Needs debugging
  # Error in n:nm : result would be too long a vector
  # group_by(Code, Sex, Measure) %>% 
  # do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 
  # ungroup() %>% 
  mutate(Age = as.integer(Age),
         AgeInt = as.integer(AgeInt)) 

  # TR: add rescale_to_total() into the chain

inputCounts %>% 
  filter(is.na(Value)) %>% 
  View()


# -------------------------------#
# Next step harmonize age groups #
# -------------------------------#

# NOTE: add function to check that for subsets with m and f Sex there is also a b
# and create it if necessary.

# inputCounts %>% pull(Age) %>% is.na() %>% sum()
# inputCounts %>% 
#   filter(is.na(Age))


