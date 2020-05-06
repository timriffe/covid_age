

# ----------------------------------------------
# dependency preamble
# ----------------------------------------------
# install pacman to streamline further package installation
if (!require("pacman", character.only = TRUE)){
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package not found")
}

packages_CRAN <- c("tidyverse","lubridate","here","gargle","ungroup","HMDHFDplus","tictoc")

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
            Region,
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
  input_rubric <- read_sheet(ss_rubric, sheet = tab) %>% 
    filter(!is.na(Sheet))
  input_rubric
}

add_Short <- function(Code, Date){
  mapply(function(Code, Date){
    Short <- gsub(pattern = Date, replacement = "", Code)
    last_char <- str_sub(Short,-1)
    if (last_char %in% c("\\.","_","-")){
      Short <- substr(Short,1,nchar(Short)-1)
    }
    Short
  }, Code, Date)

}

compile_inputDB <- function(){

  rubric <- get_input_rubric(tab = "input")

  input_list <- list()
  for (i in rubric$Short){
    ss_i           <- rubric %>% filter(Short == i) %>% pull(Sheet)
    X <- try(read_sheet(ss_i, 
                     sheet = "database", 
                     na = "NA", 
                     col_types = "cccccciccd"))
    if (class(X) == "try-error"){
      cat(i,"didn't load, waiting 2 min to try again")
      Sys.sleep(120)
      X <- try(read_sheet(ss_i, 
                          sheet = "database", 
                          na = "NA", 
                          col_types = "cccccciccd"))
    }
    X <- 
      X %>% 
      mutate(Short = add_Short(Code, Date))
    input_list[[i]] <- X
    Sys.sleep(45) # this is getting absurd
  }
  # bind and sort:
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    sort_input_data()
  
  inputDB
}

compile_offsetsDB <- function(){
  ss_offsets <- "https://docs.google.com/spreadsheets/d/1z9Dg7iQWPdIGRI3rvgd-Dx3rE5RPNd7B_paOP86FRzA/edit#gid=0"
  offsets_rubric <- read_sheet(ss_offsets, sheet = 'checklist') %>% 
    filter(!is.na(Sheet))
  
  off_list <- list()
  for (i in offsets_rubric$Short){
    ss_i           <- offsets_rubric %>% filter(Short == i) %>% pull(Sheet)
    X <- try(read_sheet(ss_i, 
                        sheet = "population", 
                        na = "NA", 
                        col_types = "ccccicd"))
    if (class(X)[1] == "try-error"){
      cat(i,"didn't load, waiting 2 min to try again")
      Sys.sleep(100)
      X <- try(read_sheet(ss_i, 
                          sheet = "population", 
                          na = "NA", 
                          col_types = "ccccicd"))
    }
    X <- 
      X %>% 
      mutate(Short = i)
    off_list[[i]] <- X
    Sys.sleep(20) # this is getting absurd
  }
  # bind and sort:
  offsetsDB <- 
    off_list %>% 
    bind_rows() %>% 
    arrange(Country, Region, Sex)
  offsetsDB
}




# load just a single country
get_country_inputDB <- function(ShortCode){
  rubric <- get_input_rubric(tab = "input")
  ss_i   <- rubric %>% filter(Short == ShortCode) %>% pull(Sheet)
  out <- read_sheet(ss_i, 
                     sheet = "database", 
                     na = "NA", 
                     col_types= "cccccciccd")
  out$Short <- ShortCode
  out
}
  


get_standby_inputDB <- function(){
  rubric <- get_input_rubric(tab = "output")
  inputDB_ss <- 
    rubric %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  standbyDB <- read_sheet(inputDB_ss, sheet = "inputDB", na = "NA", col_types= "cccccciccdc")
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
  
  write_sheet(inputDB, ss = inputDB_ss, sheet = "inputDB")
}


# Output can live straight in github now
# push_outputDB <- function(outputDB = NULL){
# 
#   inputDB_ss <- 
#     get_input_rubric(tab="output") %>% 
#     filter(tab == "outputDB") %>% 
#     pull(Sheet)
#   
#   write_sheet(outputDB, ss = inputDB_ss, sheet = "outputDB")
# }



# TODO: write validation functions




# 1) convert fraction. Should be on 
# group_by(Code, Sex, Measure)

do_we_convert_fractions <- function(chunk){
  have_fracs <- "Fraction" %in% chunk$Metric 
  scaleable  <- chunk %>% 
    filter(Metric == "Count",
           Age == "TOT")
  (nrow(scaleable) == 1) & have_fracs
}

convert_fractions <- function(chunk){
  # subset should contain only Fractions and one Total Count
  
  do.this <- do_we_convert_fractions(chunk)
  if (!do.this){
    return(chunk)
  }
  
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
do_we_infer_deaths_from_cases_and_ascfr <- function(chunk){
  have_ratios_counts <- setequal(chunk$Metric, c("Ratio","Count") )
  ascfr_ratio <- chunk %>% 
    filter(Metric == "Ratio") %>% 
    pull(Measure) %>% 
    `==`("ASCFR") %>% 
    all()
  cases_count <- chunk %>% 
    filter(Metric == "Count") %>% 
    pull(Measure) %>% 
    `==`("Cases") %>% 
    all()
  have_ratios_counts & ascfr_ratio & cases_count
}

infer_deaths_from_cases_and_ascfr <- function(chunk){
  do_this <- do_we_infer_deaths_from_cases_and_ascfr(chunk)
  if (!do_this){
    return(chunk)
  }
  
  TOT   <- chunk %>% filter(Age == "TOT")
  chunk <- chunk %>% filter(Age != "TOT")
  
  ASCFR  <- chunk %>% filter(Metric == "Ratio")
  stopifnot(all(ASCFR$Measure == "ASCFR"))
  Cases <- chunk %>% filter(Metric == "Count")
  stopifnot(all(Cases$Measure == "Cases"))
  
  if (nrow(Cases)!=nrow(ASCFR)){
    cat(unique(chunk$Code),"\n")
  }
  stopifnot(nrow(Cases) == nrow(ASCFR))
  Deaths  <- ASCFR
  
  # Console message
  cat("ACSFR converted to deaths for",unique(chunk$Code),"\n")
  
  Deaths <-
    Deaths %>% 
    mutate(Value = Cases$Value * ASCFR$Value,
           Measure = "Deaths",
           Metric = "Count")
  
  rbind(Cases, Deaths, TOT)
  
}


do_we_infer_cases_from_deaths_and_ascfr <- function(chunk){
  have_ratios_counts <- setequal(chunk$Metric, c("Ratio","Count") )
  ascfr_ratio <- chunk %>% 
    filter(Metric == "Ratio") %>% 
    pull(Measure) %>% 
    `==`("ASCFR") %>% 
    all()
  
  deaths_count <- chunk %>% 
    filter(Metric == "Count",
           Age != "TOT") %>% 
    pull(Measure) %>% 
    `==`("Deaths") %>% 
    all()
  
  have_ratios_counts & ascfr_ratio & deaths_count
}
# 2) convert infografica style data to counts
# subset cannot include Metric or Measure as splitters
# group_by(Code, Sex)
infer_cases_from_deaths_and_ascfr <- function(chunk){
  do_this <- do_we_infer_cases_from_deaths_and_ascfr(chunk)
  if (!do_this){
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

do_we_redistribute_unknown_age <- function(chunk){
  maybe <- "UNK" %in% chunk$Age & all(chunk$Metric != "Ratio")
  if (maybe){
  positive <- chunk %>% 
                filter(Age == "UNK") %>% 
                pull(Value) %>% 
                `>`(0)
  } else {
    positive <- FALSE
  }
  maybe & positive
}

# 3)
# 
# group_by(Code, Sex, Measure)
# redistribute_unknown_age()
redistribute_unknown_age <- function(chunk){
  # this should happen after ratios turned to counts!
  do_this <- do_we_redistribute_unknown_age(chunk)
  if (!do_this){
    # could be returning chunk with UNK value of 0,
    # so remove just in case
    chunk <- chunk %>% 
      filter(Age != "UNK") 
    return(chunk)
  }
  
  # foresee TOT,
  TOT   <- chunk %>% filter(Age == "TOT")
  chunk <- chunk %>% filter(Age != "TOT")
  
  if (do_this){
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



do_we_rescale_to_total <- function(chunk){
  has_rows   <- nrow(chunk) > 1
  has_TOT    <- any("TOT" %in% chunk$Age)
  all_counts <- all(chunk$Metric == "Count")
  

  
  maybe <- has_rows & has_TOT & all_counts
  
  if (maybe){
    # is the TOT different from the marginal sum?
    marginal_sum <- chunk %>% filter(Age != "TOT") %>% pull(Value) %>% sum()
    TOT          <- chunk %>% filter(Age == "TOT") %>% pull(Value)
    out <- abs(marginal_sum - TOT) > 1e-4
  } else {
    out <- FALSE
  }
  out
}
# This function to be run on a given Code * Sex subset.
# This could be run before redistributing UNK, for example.

rescale_to_total <- function(chunk){
  do_this <- do_we_rescale_to_total(chunk)
  if (!do_this){
    # looks silly, but possibly subset contains only TOT,
    # in which case we throw out moving forward. BUT
    # we might want to keep both-sex TOT for scaling
    # m and f ...
    chunk <- chunk %>% 
      filter(!(Age == "TOT" & Sex %in% c("m","f","UNK")))
    return(chunk)
  }

  
  TOT <- chunk %>% filter(Age == "TOT")
  # foresee this pathology
  stopifnot(nrow(TOT) == 1)
  # if (TOT$Value == 0){
  #   chunk <- chunk %>% 
  #     filter(Age != "TOT")
  #   return(chunk)
  # }
  
  chunk <- chunk %>% 
    filter(Age != "TOT") %>% 
    mutate(Value = rescale_vector(Value, 
                                  scale = TOT$Value),
           Value = ifelse(is.nan(Value),0,Value))
  
  # Console message
  cat(paste("Counts rescaled to TOT for",
      unique(chunk$Code),
      unique(chunk$Sex),
      unique(chunk$Measure)),"\n")
  
  chunk
}

do_we_rescale_sexes <- function(chunk){
  sexes  <- chunk %>% pull(Sex) %>% unique()
  Counts <- all(chunk$Metric == "Count")
  maybe  <- setequal(sexes,c("b","f","m")) & Counts
  if (maybe){
    # separate chunks
    m    <- chunk %>% filter(Sex == "m")
    f    <- chunk %>% filter(Sex == "f")
    b    <- chunk %>% filter(Sex == "b")
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
    out <- abs(MM + FF - BB) < 1e-4
  } else {
    out <- FALSE
  }
  out
}
# This can produce NAs in early Belgium Deaths (presumably)
rescale_sexes <- function(chunk){
  do_this <- do_we_rescale_sexes(chunk)
  if (!do_this){
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

do_we_redistribute_unknown_sex <- function(chunk){
  "UNK" %in% chunk$Sex
}
# this should happen within age, though
# group_by(Code, Age, Measure)
redistribute_unknown_sex <- function(chunk){
  # this should happen after ratios turned to counts!
  stopifnot(all(chunk$Metric != "Ratio"))
  do_this <- do_we_redistribute_unknown_sex(chunk)
  if (do_this){
    UNK   <- chunk %>% filter(Sex == "UNK")
    chunk <- chunk %>% 
      filter(Sex != "UNK") %>% 
      mutate(Value = Value + (Value / sum(Value)) * UNK$Value,
             Value = ifelse(is.nan(Value), UNK$Value / 2, Value))
    
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
do_we_infer_both_sex <- function(chunk){
  sexes  <- chunk %>% pull(Sex) %>% unique()
  Counts <- all(chunk$Metric == "Count")
  setequal(sexes,c("f","m")) & Counts
}


infer_both_sex <- function(chunk){
  do_this <- do_we_infer_both_sex(chunk)
  # 2 things: 
  # 1) could be a both-sex total available, so far unused.
  if (!do_this){
    return(chunk)
  }
  
  chunk %>% 
    pivot_wider(names_from = "Sex",
                values_from = "Value",
                values_fill = list(m=0,f=0)) %>% 
    mutate(b = f + m) %>% 
    pivot_longer(cols = c(f,m,b),
                 values_to = "Value",
                 names_to = "Sex")
}

# Standardize closeout.
# closing out with 0 counts is pretty bad.
# closing out with known single ages that 
# don't go cleanly to 105 is also a pain for processing.
# age ranges that don't start at 0 are a pain for processing.
# need to standardize these things. What shall it be?
# on the lower end, if there are 0s

# 

# chunk <- inputDB %>% 
#   filter(Code =="MX19.04.2020",
#          Measure == "Deaths",
#          Sex == "m")
# group_by(Code, Sex, Measure) %>% 
# do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 

# pad_single_zeros <- function(chunk, OAnew_min = 85){
#   if (!all(chunk$Metric == "Count")){
#     return(chunk)
#   }
#   chunk <- chunk %>% 
#     mutate(Age = as.integer(Age)) %>% 
#     arrange(Age)
#   Age    <- chunk %>% pull(Age) %>% as.integer()
#   Value  <- chunk %>% pull(Value) 
#   AgeInt <- chunk %>% pull(AgeInt)%>% as.integer()
#   
#   ind1   <- AgeInt == 1
#   if (all(ind1[Age < 100])){
#     
#   }
# 
# }

# iL <- split(inputCounts, list(inputCounts$Code, inputCounts$Sex, inputCounts$Measure),drop = TRUE) 
# 
# for (i in 1:length(iL)){
#   chunk <- iL[[i]]
#   maybe_lower_closeout(iL[[i]])
# }
# this is after all rescaling is done. Group OAG down to the 
# highest age with a positive count.
# group_by(Code, Sex, Measure) %>% 
do_we_maybe_lower_closeout <- function(chunk, OAnew_min){

  maybe1 <- all(chunk$Metric == "Count")
  if (!maybe1){
    return(FALSE)
  }
  
  chunk <- chunk %>% 
    mutate(Age = as.integer(Age)) %>% 
    arrange(Age)
  Age    <- chunk %>% pull(Age) %>% as.integer()
  Value  <- chunk %>% pull(Value) 
  AgeInt <- chunk %>% pull(AgeInt)%>% as.integer()
  
  maybe2 <- max(Age) >= OAnew_min
  if (!maybe2){
    return(FALSE)
  }
  
  n <- length(Age)
  nm <- (Age >= OAnew_min) %>% which() %>% min()
  for (i in n:nm){
    if (Value[i] > 0){
      break
    }
  }
  i < n
}
maybe_lower_closeout <- function(chunk, OAnew_min = 85){

  do_this <- do_we_maybe_lower_closeout(chunk, OAnew_min)
  if (!do_this){
    return(chunk)
  }
  
  chunk <- chunk %>% 
    mutate(Age = as.integer(Age)) %>% 
    arrange(Age)
  Age    <- chunk %>% pull(Age) %>% as.integer()
  Value  <- chunk %>% pull(Value) 
  AgeInt <- chunk %>% pull(AgeInt)%>% as.integer()

  n  <- length(Age)
  nm <- (Age >= OAnew_min) %>% which() %>% min()
  for (i in n:nm){
    if (Value[i] > 0){
      break
    }
  }
  if (i < n){
    .Code    <- chunk %>% pull(Code) %>% '[['(1)
    .Sex     <- chunk %>% pull(Sex) %>% '[['(1)
    .Measure <- chunk %>% pull(Measure) %>% '[['(1)
    cat("Open age group lowered from",Age[n],"to",Age[i],"for",.Code,.Sex,.Measure,"\n")
    Value  <- c(Value[1:(i-1)],sum(Value[i:n]))
    Age    <- Age[1:i]
    AgeInt <- c(AgeInt[1:(i-1)], 105 - Age[i])
    
    chunk <- chunk[1:i, ]
    chunk$Age = Age
    chunk$AgeInt = AgeInt
    chunk$Value = Value
  }
  chunk
}
                
# This encapsulates the entire processing chain.
process_counts <- function(inputDB, Offsets = NULL, N = 10){
  A <- 
  inputDB %>% 
    filter(!(Age == "TOT" & Metric == "Fraction")) %>% 
    
    # 1. Multiply Fraction Metrics into stated total counts
    group_by(Code, Sex, Measure) %>% 
    do(convert_fractions(chunk = .data)) %>% 
    ungroup() %>% 
    
    # 2. Redistribute counts of unknown age proportional to counts 
    # of known age
    group_by(Code, Sex, Measure) %>% 
    do(redistribute_unknown_age(chunk = .data)) %>% 
    
    # 3. Age distribution should sum to total, if specified separately
    do(rescale_to_total(chunk = .data)) %>% 
    ungroup() %>% 
    
    # 4. Infer cases as Deaths / ASCFR. This is a problem in young ages
    # if there are cases but no deaths, or even if there are deaths
    # it's a problem if there is rounding. Therefore we model it. The
    # present model sucks and needs to be improved. This only affects
    # ITinfo. Inferring Deaths from cases and ASCFR is straightforward,
    # on the other hand.
    group_by(Code, Sex) %>% 
    do(infer_cases_from_deaths_and_ascfr(chunk = .data)) %>% 
    do(infer_deaths_from_cases_and_ascfr(chunk = .data)) %>% 
    ungroup() %>% 
    
    # 5. Counts of unknown sex redistributed with age
    group_by(Code, Age, Measure) %>% 
    do(redistribute_unknown_sex(chunk = .data)) %>% 
    ungroup() %>% 
    
    # 6. Rescale sexes to sum to same as both-sex margin total
    group_by(Code, Measure) %>% 
    do(rescale_sexes(chunk = .data)) %>% 
    
    # 7. if sexes given but not both-sex, then generate it
    do(infer_both_sex(chunk = .data)) %>% 
    ungroup() %>% 
    
    # pre-step
    mutate(Age = as.integer(Age)) %>% 
    # 8. If upper tail in 0s then group down until there are positive counts,
    # but not lower than 85
    group_by(Code, Sex, Measure) %>% 
    do(maybe_lower_closeout(chunk = .data, OAnew_min = 85)) %>% 
    ungroup() 
  
    A %>% 
    # do PCLM splitting
    sort_input_data() %>% 
    group_by(Country, Region, Code, Date, Sex, Measure) %>% 
    do(harmonize_age(chunk = .data, 
                     Offsets = Offsets, 
                     N = N, 
                     OAnew = 100)) %>% 
    ungroup() %>% 
    pivot_wider(names_from = Measure,
                values_from = Value) 
}

# Separate harmonize_offsets() is better,
# it saves multiple redundant

harmonize_offset_age <- function(chunk){
  Age     <- chunk %>% pull(Age)
  Pop     <- chunk %>% pull(Population) 
  
  # if already in shape, then skip it
  if (is_single(Age) & max(Age) == 104){
    return(chunk[,"Age","Population"])
  }
  
  # if single, but high open age, then drop it:
  if (is_single(Age) & max(Age) > 104){
    p1 <- groupOAG(Pop,Age,OAnew = 104)
    out <- tibble(Age = 0:104,
                  Population = p1)
    return(out)
  }
  
  nlast <- max(105 - max(Age), 5)
  AgeInt<- DemoTools::age2int(Age, OAvalue = nlast)
  p1 <- pclm(y = Pop, 
             x = Age, 
             nlast = nlast, 
             control = list(lambda = 10, deg = 3))$fitted
  
  p1      <- rescaleAgeGroups(Value1 = p1, 
                              AgeInt1 = rep(1,length(p1)), 
                              Value2 = Pop, 
                              AgeInt2 = AgeInt, 
                              splitfun = graduate_uniform)
  
  a1 <- 1:length(p1)-1
  p1 <- groupOAG(p1, a1, OAnew = 104)
  
  out <- tibble(Age = 0:104,
                Population = p1)
  out
}








# Age harmonization is the last step.
harmonize_age <- function(chunk, Offsets = NULL, N = 5, OAnew = 100){
  Age     <- chunk %>% pull(Age)
  AgeInt  <- chunk %>% pull(AgeInt)
  Value   <- chunk %>% pull(Value) 
  
   # maybe we don't need to do anything but lower the OAG?
  if (all(AgeInt == N) & max(Age) >= OAnew){
    Value   <- groupOAG(Value, Age, OAnew = OAnew)
    Age     <- Age[1:length(Value)]
    AgeInt  <- AgeInt[1:length(Value)]
    return(select(chunk, Age, AgeInt, Value))
  }
  # --------------------------------- #
  # otherwise get offset sorted out.  #
  # Offsets now handled in advance    #
  # --------------------------------- #
  .Country <- chunk %>% pull(Country) %>% "["(1)
  .Region  <- chunk %>% pull(Region) %>% "["(1)
  .Sex     <- chunk %>% pull(Sex) %>% "["(1)
  
  if (!is.null(Offsets)){
    Offsets   <- Offsets %>% 
      filter(Country == .Country,
             Region == .Region,
             Sex == .Sex)
  } else {
    Offsets <- tibble()
  }
  
  if (nrow(Offsets) == 105){
    pop     <- Offsets %>% pull(Population)
    age_pop <- Offsets %>% pull(Age)

  # so need to rescale in next step (pattern looks OK)
    V1      <- pclm(x = Age, 
                  y = Value, 
                  nlast = AgeInt[length(AgeInt)], 
                  offset = pop, 
                  control = list(lambda = 100, deg = 3))$fitted * pop
  }  else {
    # if no offsets are available then run through without.
    V1      <- pclm(x = Age, 
                    y = Value, 
                    nlast = AgeInt[length(AgeInt)], 
                    control = list(lambda = 100, deg = 3))$fitted
  }

  # Important to rescale
  V1      <- rescaleAgeGroups(Value1 = V1, 
                              AgeInt1 = rep(1,length(V1)), 
                              Value2 = Value, 
                              AgeInt2 = AgeInt, 
                              splitfun = graduate_uniform)
  
  # division by 0, it's a thing
  V1[is.nan(V1)] <- 0
  
  VN      <- groupAges(V1, 0:104, N = N, OAnew = OAnew)
  Age     <- names2age(VN)
  AgeInt  <- rep(N, length(VN))
  
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
}



















