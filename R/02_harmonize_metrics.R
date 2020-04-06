source("R/00_Functions.R")
source("R/01_grab_data.R")
# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age

# inputDB <- get_standby_inputDB()
# chunk   <- inputDB %>% filter(Code == "ITinfo30.03.2020")

# Need to subset on Measure as well!!
inputCounts <- 
  inputDB %>% 
  group_by(Code, Sex, Measure) %>% 
  do(convert_fractions(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex) %>% 
  do(infer_cases_from_deaths_and_ascfr(chunk = .data)) %>% 
  ungroup() %>% 
  group_by(Code, Sex, Measure) %>% 
  do(redistribute_unknown_age(chunk = .data)) %>% 
  ungroup() 



