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

# inputDB <- readRDS("Data/inputDB.rds")

# NYC <- inputDB %>% filter(Short == "US_NYC")
# Some UNK Values in Chile coded as NA 
#inputDB$Value[is.na(inputDB$Value)] <- 0

# TR: add Short to group_by!

inputCounts <-
  inputDB %>% 
  filter(!(Age == "TOT" & Metric == "Fraction")) %>% 
  group_by(Code, Sex, Measure) %>% 
  # do_we_convert_fractions(chunk)
  do(convert_fractions(chunk = .data)) %>%                  
  # do_we_redistribute_unknown_age()
  do(redistribute_unknown_age(chunk = .data)) %>% 
  # do_we_rescale_to_total()
  do(rescale_to_total(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex) %>% 
  # TR: This step can be improved I think.
  # do_we_infer_cases_from_deaths_and_ascfr()
  do(infer_cases_from_deaths_and_ascfr(chunk = .data)) %>%   
  # do_we_infer_deaths_from_cases_and_ascfr()
  do(infer_deaths_from_cases_and_ascfr(chunk = .data)) %>%  
  ungroup() %>% 
  group_by(Code, Age, Measure) %>% 
  # do_we_redistribute_unknown_sex()
  do(redistribute_unknown_sex(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Measure) %>% 
  # TR: change this to happen within Age
  # do_we_rescale_sexes()
  do(rescale_sexes(chunk = .data)) %>% 
  # do_we_infer_both_sex()
  do(infer_both_sex(chunk = .data)) %>% 
  ungroup() %>% 
  mutate(Age = as.integer(Age)) %>% 
  group_by(Code, Sex, Measure) %>% 
  #do_we_maybe_lower_closeout()
  do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 
  ungroup()

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


