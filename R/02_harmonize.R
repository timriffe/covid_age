source("R/00_Functions.R")

# this script transforms the inputDB as required, and produces standardized age groups
# and columns.

# priorities: 
# 1) convert Fractions to Counts
# 2) calculate Cases from ASCFR and Deaths
# 3) redistribute unknown Age

inputDB <- get_standby_inputDB()
chunk <- inputDB %>% filter(Code == "WA25.03.2020",
                            Measure == "Cases")
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



