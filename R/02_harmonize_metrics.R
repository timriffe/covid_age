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

inputDB %>% pull(Age) %>% is.na() %>% any()

A <-
  inputDB %>% 
  filter(!(Age == "TOT" & Metric == "Fraction"),
         !(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Sex == 0)) %>% 
  group_by(Code, Measure) %>%
  # do_we_convert_fractions_all_sexes(chunk)
  do(convert_fractions_all_sexes(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex, Measure) %>% 
  # do_we_convert_fractions_within_sex(chunk)
  do(convert_fractions_within_sex(chunk = .data))                
 
B <- A  %>% 
  # do_we_redistribute_unknown_age()
  do(redistribute_unknown_age(chunk = .data))
 
C <- B %>% 
  # do_we_rescale_to_total()
  do(rescale_to_total(chunk = .data)) %>% 
  ungroup() 

D <- C %>% 
  group_by(Code, Sex) %>% 
  # TR: This step can be improved I think.
  # do_we_infer_cases_from_deaths_and_ascfr() "ITinfo15.04.2020"
  do(infer_cases_from_deaths_and_ascfr(chunk = .data))

E <- D %>% 
  # do_we_infer_deaths_from_cases_and_ascfr()
  do(infer_deaths_from_cases_and_ascfr(chunk = .data)) %>%  
  ungroup() 

G <- E %>% 
  group_by(Code, Age, Measure) %>% 
  # do_we_redistribute_unknown_sex()
  do(redistribute_unknown_sex(chunk = .data)) %>% 
  ungroup() 

H <- G %>% 
  group_by(Code, Measure) %>% 
  # TR: change this to happen within Age
  # do_we_rescale_sexes()
  do(rescale_sexes(chunk = .data)) %>% 
  # possibly there was a Sex = "b" Age = "TOT" left here.
  # These would have made it this far if preserved to rescale sexes
  filter(Age != "TOT")

I <- H %>% 
  # do_we_infer_both_sex()
  do(infer_both_sex(chunk = .data)) %>% 
  ungroup() 

J <- I %>% 
  mutate(Age = as.integer(Age)) %>% 
  group_by(Code, Sex, Measure) %>% 
  #do_we_maybe_lower_closeout()
  do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 
  ungroup()

inputCounts <- J %>% 
  arrange(Country, Region, Sex, Measure, Age)

saveRDS(inputCounts, file = "Data/inputCounts.rds")
  # TR: add rescale_to_total() into the chain

# inputCounts %>% filter(is.na(Value)) %>% View()

# inputCounts %>% filter(is.infinite(Value)) %>% View()
# -------------------------------#
# Next step harmonize age groups #
# -------------------------------#

# NOTE: add function to check that for subsets with m and f Sex there is also a b
# and create it if necessary.

# inputCounts %>% pull(Age) %>% is.na() %>% sum()
# inputCounts %>% 
#   filter(is.na(Age))


