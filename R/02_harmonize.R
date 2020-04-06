source("R/00_Functions.R")

# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age

inputDB <- get_standby_inputDB()
chunk <- inputDB %>% filter(Code == "ITinfo30.03.2020")

# Need to subset on Measure as well!!
convert_fractions <- function(chunk){
  # subset should contain only Fractions and one Total Count
  
  if (! "Fraction" %in% chunk$Metric){
    return(chunk)
  }
  
  # one way to check a subset is single is that there should be a unique
  # Age for each row.
  stopifnot(nrow(chunk) == length(unique(chunk$Age)))
  stopifnot(sum(chunk$Metric == "Count") == 1)
  
  TOT <- chunk %>% 
    filter(Metric == "Count")
  
  stopifnot(TOT$Age == "TOT")
  TOT <- TOT %>% pull(Value)
  
  out <- chunk %>% 
    filter(Metric == "Fraction") %>% 
    mutate(Value = Value / sum(Value),
           Value = Value * TOT,
           Metric = "Count")
  
  out
}

# subset cannot include Metric or Measure
infer_cases_from_deaths_and_ascfr <- function(chunk){
  if (! all(c("Ratio","Count") %in% chunk$Metric)){
    return(chunk)
  }
  ASCFR  <- chunk %>% filter(Metric == "Ratio")
  stopifnot(all(ASCFR$Measure == "ASCFR"))
  Deaths <- chunk %>% filter(Metric == "Count")
  stopifnot(all(Deaths$Measure == "Deaths"))
  stopifnot(nrow(Deaths) == nrow(ASCFR))
  Cases  <- ASCFR
  
  if (any(ASCFR$Value == 0)){
    ind <- ASCFR$Value > 0 & !is.na(ASCFR$AgeInt)
    a <- smooth.spline(log(ASCFR$Value[ind]) ~ ASCFR$Age[ind])
  }
  
  Cases %>% 
    mutate(Value = Deaths$Value / ASCFR$Value,
           Measure = "Cases",
           Metric = "Count")
           
  
  
}



