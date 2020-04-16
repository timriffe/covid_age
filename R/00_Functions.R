

# ----------------------------------------------
# dependency preamble
# ----------------------------------------------
# install pacman to streamline further package installation
if (!require("pacman", character.only = TRUE)){
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package not found")
}

packages_CRAN <- c("tidyverse","lubridate","here","gargle","ungroup","HMDHFDplus")

if(!sum(!p_isinstalled(packages_CRAN))==0){
  p_install(
    package = packages_CRAN[!p_isinstalled(packages_CRAN)], 
    character.only = TRUE
  )
}

gphgs <- c("googlesheets4","DemoTools")
# install from github if necessary
if (!p_isinstalled("googlesheets4")){
  library(remotes)
  install_github("tidyverse/googlesheets4")
}
if (!p_isinstalled("DemoTools")){
  library(remotes)
  install_github("timriffe/DemoTools")
}

# load the packages
p_load(packages_CRAN, character.only = TRUE)
p_load(gphgs, character.only = TRUE)

# --------------------------------



#--------------------------------------------------
sort_input_data <- function(X){
  X %>% 
  mutate(Date2 = dmy(Date)) %>% 
    arrange(Country,
            Date2,
            Code,
            Sex, 
            Measure,
            Metric,
            suppressWarnings(as.integer(Age))) %>% 
    select(-Date2)
}

# -------------------------------------------------

get_input_rubric <- function(tab = "input"){
  ss_rubric <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0"
  input_rubric <- sheets_read(ss_rubric, sheet = tab) %>% 
    filter(!is.na(Sheet))
  input_rubric
}

compile_inputDB <- function(){

  rubric <- get_input_rubric(tab = "input")

  input_list <- list()
  for (i in rubric$Short){
    ss_i           <- rubric %>% filter(Short == i) %>% pull(Sheet)
    X <- sheets_read(ss_i, 
                     sheet = "database", 
                     na = "NA", 
                     col_types = "cccccccccd") %>% 
      mutate(Short = i)
    input_list[[i]] <- X
    Sys.sleep(30)
  }
  # bind and sort:
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    sort_input_data()
  
  inputDB
}

# load just a single country
get_country_inputDB <- function(ShortCode){
  rubric <- get_input_rubric(tab = "input")
  ss_i   <- rubric %>% filter(Short == ShortCode) %>% pull(Sheet)
  sheets_read(ss_i, sheet = "database", na = "NA", col_types= "cccccccccd")
}
  


get_standby_inputDB <- function(){
  rubric <- get_input_rubric(tab = "output")
  inputDB_ss <- 
    rubric %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  standbyDB <- sheets_read(inputDB_ss, sheet = "inputDB", na = "NA", col_types= "cccccccccdc")
  standbyDB
}

check_input_updates <- function(inputDB  = NULL, standbyDB = NULL){

  if (is.null(standbyDB)){
    standbyDB <- get_standby_inputDB()
  }
  if (is.null(inputDB)){
    inputDB <- compile_inputDB()
  }
  codes_have      <- standbyDB %>% pull(Code) %>% unique()
  codes_collected <- inputDB %>% pull(Code) %>% unique()
  
  new_codes <- codes_collected[!codes_collected%in%codes_have]
  if (length(new_codes)  > 0){
    cat(new_codes)
    nr <- nrow(standbyDB) - nrow(inputDB)
    cat(nr, "total new values collected")
  } else {
    cat("no new updates to add")
  }
}


# inspect_code(inputDB,"ES31.03.2020)
inspect_code <- function(DB, .Code){
  DB %>% 
    filter(Code == .Code) %>% 
    View()
}

# agressive push
push_inputDB <- function(inputDB = NULL){

  inputDB_ss <- 
    get_input_rubric(tab="output") %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  
  sheets_write(inputDB, ss = inputDB_ss, sheet = "inputDB")
}


# Output can live straight in github now
# push_outputDB <- function(outputDB = NULL){
# 
#   inputDB_ss <- 
#     get_input_rubric(tab="output") %>% 
#     filter(tab == "outputDB") %>% 
#     pull(Sheet)
#   
#   sheets_write(outputDB, ss = inputDB_ss, sheet = "outputDB")
# }



# TODO: write validation functions




# 1) convert fraction. Should be on 
# group_by(Code, Sex, Measure)
convert_fractions <- function(chunk){
  # subset should contain only Fractions and one Total Count
  
  if (! "Fraction" %in% chunk$Metric){
    return(chunk)
  }
  
  # Console message
  cat("Fractions converted for", unique(chunk$Code),"\n")
  # one way to check a subset is single is that there should be a unique
  # Age for each row.
  # stopifnot(nrow(chunk) == length(unique(chunk$Age)))
  
  
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

# 2) convert infografica style data to counts
# subset cannot include Metric or Measure as splitters
# group_by(Code, Sex)
infer_cases_from_deaths_and_ascfr <- function(chunk){
  if (! setequal(chunk$Metric, c("Ratio","Count") )){
    return(chunk)
  }
  
  TOT <- chunk %>% filter(Age == "TOT")
  chunk <- chunk %>% filter(Age != "TOT")
  
  ASCFR  <- chunk %>% filter(Metric == "Ratio")
  stopifnot(all(ASCFR$Measure == "ASCFR"))
  Deaths <- chunk %>% filter(Metric == "Count")
  stopifnot(all(Deaths$Measure == "Deaths"))
  
  if (nrow(Deaths)!=nrow(ASCFR)){
    cat(unique(chunk$Code),"\n")
  }
  stopifnot(nrow(Deaths) == nrow(ASCFR))
  Cases  <- ASCFR
  
  # Problem is that ASCFRs are often rounded, which can lead to
  # apparent 0 cases in young ages, doh! This is a kludge. Better
  # would be a time series of Bollettin data, interpolated and then
  # constrained to observed deaths in the Infografica...
  if (any(ASCFR$Value == 0)){
    # remove UNK
    UNK <- filter(ASCFR, Age == "UNK")
    # convert Age to integer
    ASCFR <- ASCFR %>% 
      filter(Age != "UNK") %>% 
      mutate(Age = as.integer(Age))
    # indicate 0s
    ind   <- ASCFR$Value > 0 & !is.na(ASCFR$AgeInt)
    # fit linear model to fill in
    mod   <- lm(log(Value) ~ Age, data = filter(ASCFR,ind))
    # ages we need to predict for
    apred <- filter(ASCFR,!ind) %>% pull(Age)
    # impute prediction
    ASCFR$Value[!ind] <- exp(predict(mod, newdata=data.frame(Age =apred)))
    # stick UNK back on (assuming sorted properly)
    ASCFR <- rbind(ASCFR,UNK)
  }
  # Console message
  cat("ACSFR converted to counts for",unique(chunk$Code),"\n")
  
  Cases <-
    Cases %>% 
    mutate(Value = Deaths$Value / ASCFR$Value,
           Value = ifelse(is.nan(Value),0,Value), # in case UNK deaths was 0
           Measure = "Cases",
           Metric = "Count")
  
  rbind(Cases, Deaths, TOT)
  
}


# Harmonization functions:

# 3)
# 
# group_by(Code, Sex, Measure)
# redistribute_unknown_age()
redistribute_unknown_age <- function(chunk){
  # this should happen after ratios turned to counts!
  stopifnot(all(chunk$Metric != "Ratio"))
  
  # foresee TOT,
  TOT   <- chunk %>% filter(Age == "TOT")
  chunk <- chunk %>% filter(Age != "TOT")
  
  if ("UNK" %in% chunk$Age){
    UNK   <- chunk %>% filter(Age == "UNK")
    chunk <- chunk %>% 
      filter(Age != "UNK") %>% 
      mutate(Value = Value + (Value / sum(Value)) * UNK$Value,
             Value = ifelse(is.nan(Value),0,Value))
    
    # Console message
    cat(paste("UNK Age redistributed for",
        unique(chunk$Code),
        unique(chunk$Sex),
        unique(chunk$Measure)),"\n")
  }
  chunk <- rbind(chunk, TOT)
  chunk
}

# This function to be run on a given Code * Sex subset.
# This could be run before redistributing UNK, for example.
rescale_to_total <- function(chunk){
  hasTOT    <- any("TOT" %in% chunk$Age)
  allCounts <- all(chunk$Metric == "Count")
  if (!hasTOT | !allCounts){
    return(chunk)
  }
  
  # Also could be only TOT is given, in which
  # case we return zero rows. Such cases
  # can remain in the inputDB, but not used downstream
  if (nrow(chunk) == 1){
    chunk %>% 
      filter(Age != "TOT") %>% 
      return()
  }
  
  TOT <- chunk %>% filter(Age == "TOT")
  # foresee this pathology
  stopifnot(nrow(TOT) == 1)
  
  chunk <- chunk %>% 
    filter(Age != "TOT") %>% 
    mutate(Value = rescale_vector(Value, 
                                  scale = TOT$Value))
  
  # Console message
  cat(paste("Counts rescaled to TOT for",
      unique(chunk$Code),
      unique(chunk$Sex),
      unique(chunk$Measure)),"\n")
  
  chunk
}

# step must precede sex rescaling, right?

# this should happen within age, though
# group_by(Code, Age, Measure)
redistribute_unknown_sex <- function(chunk){
  # this should happen after ratios turned to counts!
  stopifnot(all(chunk$Metric != "Ratio"))
  
  if ("UNK" %in% chunk$Sex){
    UNK   <- chunk %>% filter(Sex == "UNK")
    chunk <- chunk %>% 
      filter(Sex != "UNK") %>% 
      mutate(Value = Value + (Value / sum(Value)) * UNK$Value,
             Value = ifelse(is.nan(Value),0,Value))
    
    # Console message
    cat("UNK Sex redistributed for",
        unique(chunk$Code),
        unique(chunk$Age),
        unique(chunk$Measure),"\n")
  }

  chunk
}
# inputDB %>%
#   filter(Code == "US_IL14.04.2020") %>% 
#   group_by(Code, Age, Measure) %>% 
#   do(redistribute_unknown_sex(chunk = .data)) %>% 
#   ungroup() %>% 
#   group_by(Code, Sex, Measure) %>% 
#   do(redistribute_unknown_age(chunk = .data)) %>% 
#   View()

# Here group_by(Country, Region, Code, Date, Measure).
# AFTER all Measure == "Count", ergo at the end of the pipe.
# this scales to totals (either stated or derived).
# it doesn't scale within age groups. Hmmm.

# This can produce NAs in early Belgium Deaths (presumably)
rescale_sexes <- function(chunk){
  sexes <- chunk %>% pull(Sex) %>% unique()
  Counts <- all(chunk$Metric == "Count")
  if (!setequal(sexes,c("b","f","m")) | ! Counts){
    return(chunk)
  }
  
  # Console message
  cat("Sex-specific estimates rescaled to both-sex Totals for",
      unique(chunk$Code),
      unique(chunk$Measure),"\n")
  
  # separate chunks
  m    <- chunk %>% filter(Sex == "m")
  f    <- chunk %>% filter(Sex == "f")
  b    <- chunk %>% filter(Sex == "b")
  
  # Get marginal sums
  if ("TOT" %in% m$Age){
    MM   <- m %>% filter(Age=="TOT") %>% pull(Value)
  } else {
    MM   <- m %>% pull(Value) %>% sum()
  }
  if ("TOT" %in% f$Age){
    FF   <- f %>% filter(Age=="TOT") %>% pull(Value)
  } else {
    FF   <- f %>% pull(Value) %>% sum()
  }
  if ("TOT" %in% b$Age){
    BB   <- b %>% filter(Age=="TOT") %>% pull(Value)
  } else {
    BB   <- b %>% pull(Value) %>% sum()
  }
  # Get adjustment coefs
  PM     <- MM / (MM + FF)
  Madj   <- (PM * BB) / MM
  Fadj   <- ((1 - PM) * BB) / FF
  
  Madj <- ifelse(is.nan(Madj),1,Madj)
  Fadj <- ifelse(is.nan(Fadj),1,Fadj)
  # adjust Value
  m      <- m %>% filter(Age != "TOT") %>% mutate(Value = Value * Madj)
  f      <- f %>% filter(Age != "TOT") %>% mutate(Value = Value * Fadj)
  
  # return binded, no need for TOT columns,
  # If these were previously there, they should
  # have been used and thrown out already.
  rbind(f,m,b)
}

infer_both_sex <- function(chunk){
  sexes  <- chunk %>% pull(Sex) %>% unique()
  Counts <- all(chunk$Metric == "Count")
  if (!setequal(sexes,c("f","m")) | ! Counts){
    return(chunk)
  }
  
  chunk %>% 
    pivot_wider(names_from = "Sex",
                values_from = "Value") %>% 
    mutate(b = f + m) %>% 
    pivot_longer(cols = c(f,m,b),
                 values_to = "Value",
                 names_to = "Sex")
}


# Age harmonization is the last step.

harmonize_age <- function(chunk, Offsets, N = 5, OAnew = 100){
  Age     <- chunk %>% pull(Age)
  AgeInt  <- chunk %>% pull(AgeInt)
  Value   <- chunk %>% pull(Value) 
  
  .Country <- chunk %>% pull(Country) %>% "["(1)
  .Region  <- chunk %>% pull(Region) %>% "["(1)
  .Sex     <- chunk %>% pull(Sex) %>% "["(1)
  Offset   <- Offsets %>% 
    filter(Country == .Country,
           Region == .Region,
           Sex == .Sex)
  
  pop     <- Offset %>% pull(Population)
  age_pop <- Offset %>% pull(Age)
  # maybe we don't need to do anything but lower the OAG?
  if (all(AgeInt == N) & max(Age) >= OAnew){
    Value   <- groupOAG(Value, Age, OAnew = OAnew)
    Age     <- Age[1:length(Value)]
    AgeInt  <- AgeInt[1:length(Value)]
    return(select(chunk, Age, AgeInt, Value))
  }
  
  # otherwise get offset sorted out.
  if (max(age_pop) < 104 | !is_single(age_pop)){
    p1 <- pclm(y = pop, x = age_pop, nlast = 105-max(age_pop), control = list(lambda = 10))$fitted
    # Some series report Cases before deaths start,
    # and they're filled in with 0s, so this catches those?
    # p1[is.nan(p1)] <- 0
    if (is_single(age_pop)){
      ind            <- c(diff(age_pop)==1,FALSE)
      p1[which(ind)] <- pop[ind]
      
    } 
    pop            <- p1
    age_pop        <- 0:104
  }
  
  if (max(age_pop) > 104){
    pop      <- groupOAG(pop, age_pop, OAnew = 104)
    age_pop  <- 0:104
  }
  
  # TR: I thought multiplying with offset would bring back to scale, but sum doesn't match.
  # so need to rescale in next step (pattern looks OK)
  V1      <- pclm(x = Age, 
                  y = Value, 
                  nlast = AgeInt[length(AgeInt)], 
                  offset = pop, control = list(lambda = 10))$fitted * pop
  # plot(V1)
  # lines(rescaleAgeGroups(V1, rep(1,length(V1)), Value, AgeInt,splitfun=graduate_uniform) )
  # Important to rescale
  V1      <- rescaleAgeGroups(Value1 = V1, 
                              AgeInt1 = rep(1,length(V1)), 
                              Value2 = Value, 
                              AgeInt2 = AgeInt, 
                              splitfun = graduate_uniform)
  VN      <- groupAges(V1, age_pop, N = N, OAnew = OAnew)
  Age     <- names2age(VN)
  AgeInt  <- rep(N, length(VN))
  
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
}



















