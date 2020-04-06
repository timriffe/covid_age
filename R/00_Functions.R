# dependency preamble
# ----------------------------------------------
# install pacman to streamline further package installation
if (!require("pacman", character.only = TRUE)){
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package not found")
}

packages_CRAN <- c("tidyverse","lubridate","here","gargle","ungroup")

if(!sum(!p_isinstalled(packages_CRAN))==0){
  p_install(
    package = packages_CRAN[!p_isinstalled(packages_CRAN)], 
    character.only = TRUE
  )
}

gphgs <-c("googlesheets4")

# install from github if necessary
if (!p_isinstalled(gphgs)){
  library(remotes)
  install_github("tidyverse/googlesheets4")
}
# load the packages
p_load(packages_CRAN, character.only = TRUE)
p_load(gphgs, character.only = TRUE)

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
            Age) %>% 
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
    (ss_i           <- rubric %>% filter(Short == i) %>% pull(Sheet))
    input_list[[i]] <- sheets_read(ss_i, sheet = "database", na = "NA", col_types= "ccccccccd")
    Sys.sleep(2)
  }
  # bind and sort:
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    sort_input_data()
  
  inputDB
}

get_standby_inputDB <- function(){
  rubric <- get_input_rubric(tab = "output")
  inputDB_ss <- 
    rubric %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  standbyDB <- sheets_read(inputDB_ss, sheet = "inputDB", na = "NA", col_types= "ccccccccd")
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

# aghressive push
push_inputDB <- function(inputDB = NULL){
  if (is.null(inputDB)){
    inputDB <- compile_inputDB()
  }
  inputDB_ss <- 
    get_input_rubric(tab="output") %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  
  sheets_write(inputDB, ss = inputDB_ss, sheet = "inputDB")
}
# TODO: write validation functions





# 1) convert fraction. Should be on 
# group_by(Code, Sex, Measure)
convert_fractions <- function(chunk){
  # subset should contain only Fractions and one Total Count
  
  if (! "Fraction" %in% chunk$Metric){
    return(chunk)
  }
  
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
  cat("ACSFR converted to counts for",unique(chunk$Code),"\n")
  Cases <-
    Cases %>% 
    mutate(Value = Deaths$Value / ASCFR$Value,
           Measure = "Cases",
           Metric = "Count")
  
  rbind(Cases, Deaths)
  
}


# Harmonization functions:

# 3)
# 
# group_by(Code, Sex, Measure)
# redistribute_unknown_age()
redistribute_unknown_age <- function(chunk){
  # this should happen after ratios turned to counts!
  stopifnot(all(chunk$Metric != "Ratio"))
  
  if ("UNK" %in% chunk$Age){
    UNK   <- chunk %>% filter(Age == "UNK")
    chunk <- chunk %>% 
      filter(Age != "UNK") %>% 
      mutate(Value = Value + (Value / sum(Value)) * UNK$Value)
  }
  chunk
}


