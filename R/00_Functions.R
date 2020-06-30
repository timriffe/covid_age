### Dependency preamble #############################################

# install pacman to streamline further package installation
if(!require("pacman", character.only = TRUE)) {
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package pacman not found")
}

library(pacman)

# Required CRAN packages
packages_CRAN <- c("tidyverse","lubridate","gargle","ungroup",
                   "HMDHFDplus","tictoc","parallel","osfr",
                   "data.table","git2r","usethis","remotes","here")

# Install required CRAN packages if not available yet
if(!sum(!p_isinstalled(packages_CRAN))==0) {
  p_install(
    package = packages_CRAN[!p_isinstalled(packages_CRAN)], 
    character.only = TRUE
  )
}

# Reuired github packages
packages_git <- c("googlesheets4","DemoTools","parallelsugar")

# install from github if necessary
if (!p_isinstalled("googlesheets4")) {
  library(remotes)
  install_github("tidyverse/googlesheets4")
}

if (!p_isinstalled("DemoTools")) {
  library(remotes)
  install_github("timriffe/DemoTools")
}

if (!p_isinstalled("parallelsugar")){
  library(remotes)
  install_github("nathanvan/parallelsugar")
}

# Load the required CRAN/github packages
p_load(packages_CRAN, character.only = TRUE)
p_load(packages_git, character.only = TRUE)



### Functions used in production routine ############################

### change_here()
# Required for timed batch processing, changes output of here()
# @param new_path character. New directory

change_here <- function(new_path) {
  
  # Get current root 
  new_root <- here:::.root_env
  
  # Set new root
  new_root$f <- function(...){file.path(new_path, ...)}
  assignInNamespace(".root_env", new_root, ns = "here")
  
}


### push_current()
# Pushes compiled files to OSF

push_current <- function() {
  
  # Get directory on OSF
  target_dir <- osf_retrieve_node("mpwjq") %>% 
    osf_ls_files(pattern = "Data") 
  
  # Complete paths for CSV files
  files_data <- c("offsets.csv","inputDB.csv",
                  "Output_5.csv","Output_10.csv")
  files <- here("Data",files_data)
  
  # Push to OSF
  osf_upload(target_dir,
             path = files,
             conflicts = "overwrite")
  
}


### log_section()
# Write on error log: Name of step and timestap
# @param step character Name/description of step
# @param append logical Append to existing log file
# @param logfile character Name of the log file

log_section <- function(step = "A", append = TRUE, 
                        logfile = "buildlog.md") {
  
  # Paste step and timestamp
  header <- paste("\n#", 
                  step, 
                  "Build error log\n",
                  timestamp(prefix="",suffix=""),
                  "\n\n")
  
  cat(header,file=logfile,append=append)   
  
}


### try_step()
# Try function on data and if error capture in log
# @param process_function function Name of function to apply
# @param chunk tibble Name of data
# @param byvars character Names of grouping variables
# @param logfile Name of log file

try_step <- function(process_function, 
                     chunk, 
                     byvars = c("Code","Sex"),
                     logfile = "buildlog.md", 
                     ...) {
  
  # Try function on chunc
  out <- try(process_function(chunk = chunk, ...))
  
  # If error happens...
  if (class(out)[1] == "try-error"){
    
    # ...write error to log
    log_processing_error(chunk = chunk, 
                         byvars = byvars,
                         logfile = logfile)
    
    # ... return empty chunk
    out <- chunk[0]
  }
  
  # Return result (potentially empty chunk)
  return(out)
  
}



### Main compile functions ##########################################

### compile_inputDB()
# Compiles database
# @param rubric Main spreadsheet

# leave rubric as NULL for full build
compile_inputDB <- function(rubric = NULL) {
  
  # Get spreadsheet
  if (is.null(rubric)){
    rubric <- get_input_rubric(tab = "input")
  }
  
  # Only get countries with at least one row of data
  rubric <- rubric %>% 
    filter(Rows > 0)
  
  # Empty list for results
  input_list <- list()
  
  # Loop over countries
  for (i in rubric$Short) {
    
    # Get spreadsheet address
    ss_i <- rubric %>% filter(Short == i) %>% pull(Sheet)
    
    # Try to read spreadsheet
    X <- try(read_sheet(ss_i, 
                        sheet = "database", 
                        na = "NA", 
                        col_types = "cccccciccd"))
    
    # If error
    if (class(X)[1] == "try-error") {
      
      # Wait two minutes
      cat(i,"didn't load, waiting 2 min to try again")
      Sys.sleep(120)
      
      # Try to load again
      X <- try(read_sheet(ss_i, 
                          sheet = "database", 
                          na = "NA", 
                          col_types = "cccccciccd"))
      
    }
    
    # If again error
    if (class(X)[1] == "try-error") {
      
      cat(i,"failure\n")
      
    } else {
      
      # If data loaded get code
      X <- 
        X %>% 
        mutate(Short = add_Short(Code, Date))
      
      # Add to result list
      input_list[[i]] <- X
      
    }
    
    # Wait a moment
    Sys.sleep(45) 
    
  }
  
  # Bind and sort
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    sort_input_data()
  
  # Return data base
  inputDB
  
}


### compile_offsetsDB()
# Compile offsets for splitting of age intervals

compile_offsetsDB <- function() {
  
  # Load offset overview spreadsheet
  ss_offsets <- "https://docs.google.com/spreadsheets/d/1z9Dg7iQWPdIGRI3rvgd-Dx3rE5RPNd7B_paOP86FRzA/edit#gid=0"
  offsets_rubric <- read_sheet(ss_offsets, sheet = 'checklist') %>% 
    filter(!is.na(Sheet))
  
  # Empty list for results
  off_list <- list()
  
  # Loop over countries
  for (i in offsets_rubric$Short){
    
    # Get spreadsheet for country
    ss_i <- offsets_rubric %>% filter(Short == i) %>% pull(Sheet)
    
    # Try reading spreadhseet
    X <- try(read_sheet(ss_i, 
                        sheet = "population", 
                        na = "NA", 
                        col_types = "ccccicd"))
    
    # If error
    if (class(X)[1] == "try-error") {
      
      # Wait two minutes to try again
      cat(i,"didn't load, waiting 2 min to try again")
      Sys.sleep(120)
      
      # Try again
      X <- try(read_sheet(ss_i, 
                          sheet = "population", 
                          na = "NA", 
                          col_types = "ccccicd"))
      
    }
    
    # Set Short label
    X <-  X %>% 
      mutate(Short = i)
    
    # Add country to list for results
    off_list[[i]] <- X
    
    # Wait a bit
    Sys.sleep(20) 
    
  }
  
  # Catch additional errors
  errors <- lapply(off_list,function(x){length(x)==1}) %>% unlist()
  
  # Show countries with additional errors
  if (sum(errors) > 0){
    prob_codes <- offsets_rubric$Short[errors]
    cat("\nThe following code(s) did not read properly:\n",paste(prob_codes,collapse = "\n"))
    off_list <- off_list[!errors]
  }
  
  # Bind and sort
  offsetsDB <- 
    off_list %>% 
    bind_rows() %>% 
    arrange(Country, Region, Sex)
  
  # Output
  offsetsDB
  
}



### Functions for loading/getting data ##############################

### get_input_rubric()
# Get overview spreadsheet with input data sources
# @param tab character, which sheet to get

get_input_rubric <- function(tab = "input") {
  
  # Spreadsheet on Google Docs
  ss_rubric <- "https://docs.google.com/spreadsheets/d/1IDQkit829LrUShH-NpeprDus20b6bso7FAOkpYvDHi4/edit#gid=0"
  
  # Read spreadsheet
  input_rubric <- read_sheet(ss_rubric, sheet = tab) %>% 
    # Drop if no source spreadsheet
    filter(!is.na(Sheet))
  
  # Return tibble
  input_rubric
  
}


### get_country_inputDB()
# Load just a single country
# @param ShortCode character specifying country to load

get_country_inputDB <- function(ShortCode) {
  
  # Get spreadsheet
  rubric <- get_input_rubric(tab = "input")
  
  # Find spreadsheet for country
  ss_i   <- rubric %>% filter(Short == ShortCode) %>% pull(Sheet)
  
  # Load spreadsheet
  out <- read_sheet(ss_i, 
                    sheet = "database", 
                    na = "NA", 
                    col_types= "cccccciccd")
  
  # Assign short code
  out$Short <- ShortCode
  
  # Output
  out
  
}


### swap_country_inputDB()
# Replace subset with new load after Date correction
# @param inputDB tibble Input data with data to be replaced
# @param ShortCode character Code of country 

swap_country_inputDB <- function(inputDB, ShortCode) {
  
  # Get data for country
  X <- get_country_inputDB(ShortCode)
  
  # Filter old data out
  inputDB <-
    inputDB %>% 
    filter(!grepl(ShortCode,Code)) %>% 
    # Attach new data
    rbind(X) %>% 
    # Sort
    sort_input_data()
  
  # Output
  inputDB
  
}



### Functions for editing data ######################################

### sort_input_data()
# Sorts input data nicely
# @param X 

sort_input_data <- function(X) {
  
  X %>% 
    # Date to DDMMYYYY
    mutate(Date2 = dmy(Date)) %>% 
    # Sort data
    arrange(Country,
            Region,
            Date2,
            Code,
            Sex, 
            Measure,
            Metric,
            suppressWarnings(as.integer(Age))) %>% 
    # Drop extra date variable
    select(-Date2)
  
}


### add_short()
# Create short labels from long labels
# @param Code Character vector of long labels
# @param Date Vector of dates

add_Short <- function(Code, Date) {
  
  # Apply elementwise
  mapply(function(Code, Date){
    
    # Remove date
    Short <- gsub(pattern = Date, replacement = "", Code)
    
    # Remove last character if not a letter
    last_char <- str_sub(Short,-1)
    if (last_char %in% c("\\.","_","-")){
      Short <- substr(Short,1,nchar(Short)-1)
    }
    
    # Return short label
    Short
    
  }, Code, Date)
  
}


### do_we_convert_fractions_sexes()
# Checks if fractions shoudl be converted to case counts
# @param chunk Data chunk
# @param logfile character Name of the log file

do_we_convert_fractions_sexes <- function(chunk, 
                                          logfile = "buildlog.md") {
  
  # No of entries which are fractions
  Fracs <-  chunk[["Metric"]] %>% '=='("Fraction") %>% sum()
  
  # Any fractions in data? T/F
  maybe <- Fracs > 0 
  
  # If fractions in data
  if(maybe) {
    
    # Get fraction data
    Fracs      <- chunk[Metric == "Fraction"]
    
    # Check if data for both sexes
    have_sexes <- all(c("m","f") %in% Fracs[["Sex"]])
    
    # Check if case count for both sexes combined
    yes_b_scalar <- chunk[Metric == "Count" &
                            Sex == "b"] %>% 
                    nrow() %>% 
                    '>'(0)
    
    # Check if sex-specific case counts (TRUE if not available)
    no_sex_scalars <- chunk[Sex %in% c("m","f")][["Metric"]] %>% 
                      '=='("Count") %>% 
                      sum() %>% 
                      "=="(0)
    
    # T if fraction for both sexes, total case counts, but no
    # sex specific case counts
    out <- have_sexes & yes_b_scalar & no_sex_scalars
    
  } else{
    
    # If no need to convert fractions
    out <- FALSE
    
  }
  
  # Output
  out
  
}


### convert_fractions_sexes()
# Converts fractions into counts
# @param chunk Data chunk
# @param verbose logical Print console messages

convert_fractions_sexes <- function(chunk, verbose = FALSE) {
  
  # Check if conversion is needed
  do_this <- do_we_convert_fractions_sexes(chunk)
  
  # If no conversion needed return unchanged chunk
  if(!do_this) {
    
    return(chunk)
    
  }
  
  # Split chunk into two parts: Combined vs sex-specific
  b    <- chunk[Sex == "b"]
  rest <- chunk[Sex != "b"]
  
  # Double-check that only fractions available as sex-specific
  stopifnot(all(rest[["Metric"]] == "Fraction"))
  
  # Console message
  if(verbose) cat("Fractions converted to Counts for",unique(chunk$Code),"\n")
  
  # Get totals for combined-sex data
  if(any(b[["Age"]] == "TOT")) {
    
    # If total is included take it
    BB <- b[Age == "TOT"][["Value"]]
    
  } else {
    
    # If no total included calculate it as sum
    BB <- b[["Value"]] %>% sum()
    
  }
  
  # Rescale sex-specific values according to total
  v2 <- rescale_vector(rest[["Value"]], scale = BB)
  
  # Format and merge sex-specific with combined-sex data
  out <- rest[,c("Value", "Metric") := .(v2,"Count")] %>% 
          rbind(b)
  
  # Output
  out
  
}


### do_we_convert_fractions_within_sex()
# Convert fractions within sex to totals?
# @param chunk Data chunk

do_we_convert_fractions_within_sex <- function(chunk) {
  
  # Fractions in data?
  have_fracs <- "Fraction" %in% chunk[["Metric"]] 
  
  # Total counts available?
  scaleable  <- chunk[Metric == "Count" & Age == "TOT"]
  
  # Output (TRUE if fractions can be converted)
  (nrow(scaleable) == 1) & have_fracs
  
}


### convert_fractions_within_sex()
# Convert fractions to counts within a sex
# Chunk should contain only Fractions and one Total Count
# @param chunk Data chunk
# @param verbose logical Print console messages

convert_fractions_within_sex <- function(chunk, verbose = FALSE) {
  
  # Check if conversion is necessary
  do.this <- do_we_convert_fractions_within_sex(chunk)
  
  # If not necessary return unchanged chunk
  if(!do.this) {
    
    return(chunk)
    
  }
  
  # Get counts
  TOT <- chunk[Metric == "Count"]
  
  # Stop if no total is available
  stopifnot(TOT[["Age"]] == "TOT")
  
  # Console message
  if(verbose) cat("Fractions converted to Counts for",unique(chunk[["Code"]]),"\n")
  
  # Get total count
  TOT <- TOT[["Value"]]
  
  # Get fractions
  out <- chunk[Metric == "Fraction"]
  
  # Rescale fractions
  v2  <- rescale_vector(out[["Value"]], scale = TOT)
  
  # Format output
  out <- out[, c("Value", "Metric") := .(v2, "Count")]
  
  # Output
  out
  
}


### do_we_infer_deaths_from_cases_and_ascfr()
# Check if deaths need to be calculated from case counts and CFRs
# @param chunk Data chunk

do_we_infer_deaths_from_cases_and_ascfr <- function(chunk) {
  
  # Does data contain ratios and counts
  have_ratios_counts <- setequal(chunk[["Metric"]], 
                                 c("Ratio","Count") )
  
  # Are ratios CFRs?
  ascfr_ratio <- chunk[Metric == "Ratio", Measure] %>% 
                  `==`("ASCFR") %>% 
                  all()
  
  # Are counts case counts and no deaths?
  cases_count <- chunk[Metric == "Count", Measure] %>% 
                  `==`("Cases") %>% 
                  all()
  
  # Output (TRUE if data has CFRs, case counts, but no deaths)
  have_ratios_counts & ascfr_ratio & cases_count
  
}


### infer_deaths_from_cases_and_ascfr()
# Calculate deaths from cacse counts and CFRs
# @param chunk Data chunk
# @param verbose logical Print messages to console

infer_deaths_from_cases_and_ascfr <- function(chunk, verbose=FALSE) {
  
  # Check if calculation is necessary
  do_this <- do_we_infer_deaths_from_cases_and_ascfr(chunk)
  
  # If not necessary, return unchanged chunk
  if(!do_this) {
    
    return(chunk)
    
  }
  
  # Get total case count
  TOT   <- chunk[Age == "TOT"]
  
  # Rest of chunk
  chunk <- chunk[Age != "TOT"]
  
  # Get CFRs and case counts
  ASCFR  <- chunk[Metric == "Ratio"]
  Cases  <- chunk[Metric == "Count"]
  
  # Stop if no CFRs or case counts
  stopifnot(all(ASCFR[["Measure"]] == "ASCFR"))
  stopifnot(all(Cases[["Measure"]] == "Cases"))
  
  # Stop if CFRs do not match case counts
  if (nrow(Cases)!=nrow(ASCFR)){
    cat(unique(chunk[["Code"]]),"\n")
  }
  stopifnot(nrow(Cases) == nrow(ASCFR))
  
  # Console message
  if (verbose) cat("ACSFR converted to deaths for",unique(chunk[["Code"]]),"\n")
  
  # Object for death counts
  Deaths  <- ASCFR
  
  # Calculate deaths
  Deaths <-
    Deaths[, c("Value", "Measure", "Metric") := .(Cases[["Value"]] * ASCFR[["Value"]],"Deaths","Count")] 
  
  # Output
  rbind(Cases, Deaths, TOT)
  
}


### do_we_infer_cases_from_deaths_and_ascfr()
# Do cases need to be inferred from deaths and CFRs?
# @param chunk Data chunk

do_we_infer_cases_from_deaths_and_ascfr <- function(chunk) {
  
  # Does chunk have ratio and count?
  have_ratios_counts <- setequal(chunk[["Metric"]], 
                                 c("Ratio","Count") )
  
  # Are the ratios CFRs?
  ascfr_ratio <- chunk[Metric == "Ratio", Measure] %>% 
                  `==`("ASCFR") %>% 
                  all()
  
  # Are all counts death counts?
  deaths_count <- chunk[Metric== "Count" & Age!= "TOT", Measure] %>% 
                    `==`("Deaths") %>% 
                    all()
  
  # Output (TRUE if CFRs and death counts but no case counts)
  have_ratios_counts & ascfr_ratio & deaths_count
  
}


### infer_cases_from_deaths_and_ascfr()
# Calculate cases from deaths and CFRs
# @param chunk Data chunk
# @param verbose logical Print console message?

infer_cases_from_deaths_and_ascfr <- function(chunk, verbose= FALSE){
  
  # Check if calculation is necessary
  do_this <- do_we_infer_cases_from_deaths_and_ascfr(chunk)
  
  # If not necessary, return unchanged chunk
  if(!do_this) {
    
    return(chunk)
    
  }
  
  # Copy chunk
  zunk <- copy(chunk)
  
  # Separate total deaths from rest of chunk
  TOT   <- zunk[Age == "TOT"]
  zunk <- zunk[Age != "TOT"]
  
  # Split chunk into CFRs and death counts
  ASCFR  <- zunk[Metric == "Ratio"]
  Deaths <- zunk[Metric == "Count"]
  
  # Stop if no CFRs or no death counts
  stopifnot(all(ASCFR[["Measure"]] == "ASCFR"))
  stopifnot(all(Deaths[["Measure"]] == "Deaths"))
  
  # Check if CFRs do not match death counts
  if(nrow(Deaths)!=nrow(ASCFR)) {
    
    # Print country code 
    cat(unique(zunk[["Code"]]),"\n")
    
  }
  
  # Stop if CFRs do not match death counts
  stopifnot(nrow(Deaths) == nrow(ASCFR))
  
  # If CFRs are zero (due to rounding): Impute
  if(any(ASCFR[["Value"]] == 0)) {
    
    # remove UNK
    UNK        <- ASCFR[Age == "UNK"]
    
    # convert Age to integer
    ASCFR      <- ASCFR[Age != "UNK"] 
    v          <- ASCFR[["Value"]]
    ai         <- ASCFR[["AgeInt"]]
    a          <- ASCFR[["Age"]] %>% as.integer()
    
    # indicate 0s
    ind        <- v > 0 & !is.na(ai) & a < 60
    ind2       <- v == 0 & !is.na(ai)
    vi         <- v[ind]
    aii        <- ai[ind]
    ai         <- a[ind]
    
    # fit linear model to fill in
    mod        <- lm(log(vi) ~ ai)
    
    # ages we need to predict for
    #apred     <- a[!ind]
    
    # impute prediction
    vpred      <- exp(predict(mod, newdata = data.frame(ai = a)))
    v[ind2]    <- vpred[ind2]
    
    # stick UNK back on (assuming sorted properly)
    ASCFR <-
      ASCFR[,Value := v] %>% 
      rbind(UNK)
    
  }
  
  # Console message
  if (verbose) cat("ACSFR converted to counts for",unique(zunk[["Code"]]),"\n")
  
  # Calculate case counts
  cases <- Deaths[["Value"]] / ASCFR[["Value"]]
  
  # Replace NaN with 0
  cases <- ifelse(is.nan(cases),0,cases)
  
  # Format for output
  Cases  <- ASCFR
  Cases <- Cases[, c("Value","Measure", "Metric") := .(cases,"Cases","Count")]
  
  # Output
  rbind(Cases, Deaths, TOT)
  
}


### do_we_redistribute_unknown_age()
# Are there cases with unknown age?
# @param chunk Data chunk

do_we_redistribute_unknown_age <- function(chunk){
  
  # Are there cases with unknown age?
  maybe <- "UNK" %in% chunk[, Age] & 
            all(chunk[, Metric] != "Ratio")
  
  # If yes
  if(maybe) {
    
    # 'Unknown age' has more than zero cases
    positive <- chunk[Age == "UNK",Value] %>% `>`(0)
    
  } else {
    
    positive <- FALSE
    
  }
  
  # Output (TRUE if more than 0 cases with unknown age)
  maybe & positive
  
}


### redistribute_unknown_age()
# Distribute cases with unknown age
# This should happen after ratios turned to counts!
# @param chunk Data chunk
# @param verbose logical Print console message?

redistribute_unknown_age <- function(chunk, verbose = FALSE) {
  
  # Cases with unknown age?
  do_this <- do_we_redistribute_unknown_age(chunk)
  
  # If not, return unchanged chunk
  if(!do_this) {
    
    # Remove "unknown" category -> zero cases
    chunk <- chunk[Age != "UNK"]
    
    # Return
    return(chunk)
    
  }
  
  # Split total and rest of chunk
  TOT   <- chunk[Age == "TOT"]
  chunk <- chunk[Age != "TOT"]
  
  # Split unknown ages and other ages
  UNK   <- chunk[Age == "UNK"]
  chunk <- chunk[Age != "UNK"]
  
  # Redistribute unknown age
  v2    <- chunk[, Value] + (chunk[, Value] / sum(chunk[, Value])) * UNK[, Value]
  
  # Replace NaN with 0
  v2    <- ifelse(is.nan(v2),0,v2)
  
  # Replace old counts with new counts
  chunk <- chunk[, Value := v2]  
    
  # Console message
  if(verbose) {
      cat(paste("UNK Age redistributed for",
                unique(chunk[,Code]),
                unique(chunk[,Sex]),
                unique(chunk[,Measure])),"\n")
    }
  
  # Combine total and redistributed cases
  chunk <- rbind(chunk, TOT)
  
  # Output
  chunk
  
}


### do_we_rescale_to_total()
# Do counts need to be rescaled to match total?
# @param chunk Data chunk

do_we_rescale_to_total <- function(chunk) {
  
  # Chunk has more than one row
  has_rows   <- nrow(chunk) > 1
  
  # Chunk has total
  has_TOT    <- any("TOT" %in% chunk[["Age"]])
  
  # Chunk has counts
  all_counts <- all(chunk[["Metric"]] == "Count")
  
  # Potential need of rescaling?
  maybe <- has_rows & has_TOT & all_counts
  
  # If yes
  if(maybe) {
    
    # is the TOT different from the marginal sum?
    marginal_sum <- chunk[Age != "TOT",Value] %>% sum()
    TOT          <- chunk[Age == "TOT",Value] 
    out <- abs(marginal_sum - TOT) > 1e-4
    
  } else {
    
    out <- FALSE
    
  }
  
  # Output
  out
  
}


### rescale_to_total()
# Rescale age-specifc counts to maatch total
# @param chunk Data chunk
# @param verbose logical Print console message?

rescale_to_total <- function(chunk, verbose = FALSE){
  
  # Check if rescaling is needed
  do_this <- do_we_rescale_to_total(chunk)
  
  # If no rescaling is needed return unchanged chung
  if(!do_this) {
    
    # Keeo both sex tot
    i1    <- chunk[["Sex"]] %in% c("m","f","UNK")
    i2    <- chunk[["Age"]] == "TOT"
    ind   <- !(i1 & i2)
    chunk <- chunk[ind] 
    
    # Output
    return(chunk)
  }
  
  # Get total
  TOT <- chunk[Age == "TOT"]
  
  # Stop if not exactly one total
  stopifnot(nrow(TOT) == 1)
 
  # Get chunk without total
  chunk <- chunk[Age != "TOT"]
  
  # Get counts
  v2    <- chunk[["Value"]]
  
  # Rescale to total
  v2    <- rescale_vector(v2, scale = TOT[["Value"]])
  
  # Set NaNs to zero
  v2    <- ifelse(is.nan(v2),0,v2)
  
  # Replace old values with rescaled values
  chunk <- chunk[, Value := v2]
  
  # Console message
  if(verbose) {
    
    cat(paste("Counts rescaled to TOT for",
              unique(chunk[["Code"]]),
              unique(chunk[["Sex"]]),
              unique(chunk[["Measure"]])),"\n")
    
  }
  
  # Output
  chunk
  
}


### do_we_rescale_sexes()
# Do sexes need rescaling?
# @param chunk Data chunk

do_we_rescale_sexes <- function(chunk) {
  
  # Get sexes in chunk
  sexes  <- chunk[["Sex"]] %>% unique()
  
  # All metrics are counts in chunk?
  Counts <- all(chunk[["Metric"]] == "Count")
  
  # All sexes in data and all counts?
  maybe  <- setequal(sexes,c("b","f","m")) & Counts
  
  # If yes
  if(maybe) {
    
    # separate chunks
    m    <- chunk[Sex == "m"]
    f    <- chunk[Sex == "f"]
    b    <- chunk[Sex == "b"]
    
    # Get total for males
    if ("TOT" %in% m[["Age"]]){
      MM   <- m[Age=="TOT",Value]
    } else {
      MM   <- m[["Value"]] %>% sum()
    }
    
    # Get total for females
    if ("TOT" %in% f[["Age"]]){
      FF   <- f[Age=="TOT", Value]
    } else {
      FF   <- f[["Value"]] %>% sum()
    }
    
    # Get total for both sexes combined
    if ("TOT" %in% b[["Age"]]){
      BB   <- b[Age=="TOT", Value]
    } else {
      BB   <- b[["Value"]] %>% sum()
    }
    
    # Do totals match?
    out <- abs(MM + FF - BB) > 1e-4
    
  } else {
    
    out <- FALSE
    
  }
  
  # Output (TRUE if rescaling needed)
  out
  
}


### rescale_sexes()
# Rescale sexes according to total
# @param chunk Data chunk
# @param verbose logical Print console message?

rescale_sexes <- function(chunk, verbose = FALSE) {
  
  # Do sexes need to be rescaled
  do_this <- do_we_rescale_sexes(chunk)
  
  # If no rescaling needed:
  if(!do_this) {
    
    # Return unchanged chunk
    return(chunk)
    
  }
  
  # Console message
  if(verbose) {
    
    cat("Sex-specific estimates rescaled to both-sex Totals for",
        unique(chunk[["Code"]]),
        unique(chunk[["Measure"]]),"\n")
  }
  
  # separate chunks
  m    <- chunk[Sex == "m"]
  f    <- chunk[Sex == "f"]
  b    <- chunk[Sex == "b"]
  
  # Get total men
  if("TOT" %in% m[["Age"]]) {
    MM   <- m[Age=="TOT", Value]
  } else {
    MM   <- m[["Value"]] %>% sum()
  }
  
  # Get total women
  if("TOT" %in% f$Age) {
    FF   <- f[Age=="TOT", Value]
  } else {
    FF   <- f[["Value"]] %>% sum()
  }
  
  # Get total sexes combined
  if("TOT" %in% b$Age) {
    BB   <- b[Age=="TOT", Value]
  } else {
    BB   <- b[["Value"]] %>% sum()
  }
  
  # Get adjustment coefs
  PM     <- MM / (MM + FF)
  Madj   <- (PM * BB) / MM
  Fadj   <- ((1 - PM) * BB) / FF
  
  # Replace NaN with zero
  Madj <- ifelse(is.nan(Madj),1,Madj)
  Fadj <- ifelse(is.nan(Fadj),1,Fadj)
  
  # adjust Value
  m      <- m[Age != "TOT", Value := Value * Madj]
  f      <- f[Age != "TOT", Value := Value * Fadj]
  
  # Output
  rbind(f,m,b)
  
}


### do_we_redistribute_unknown_sex()
# Are there cases with unknown sex?
# @param chunk Data chunk

do_we_redistribute_unknown_sex <- function(chunk) {
  
  # Check for cases with unknown sex
  "UNK" %in% chunk[["Sex"]]
  
}


### redistribute_unknown_sex()
# Distribute cases with unknown sex
# This should happen after ratios turned to counts
# @param chunk
# @param verbose

redistribute_unknown_sex <- function(chunk, verbose = FALSE) {

  # Stop if ratio in chunk
  stopifnot(all(chunk[["Metric"]] != "Ratio"))
  
  # Check if unknown sexes
  do_this <- do_we_redistribute_unknown_sex(chunk)
  
  # If no unknown sex return unchanged chunk
  if(!do_this) return(chunk)
  
  # Split chunk: Unknown vs known sex
  UNK   <- chunk[Sex == "UNK"]
  chunk <- chunk[Sex != "UNK"]
  
  # Get counts with known sex
  v <- chunk[["Value"]]
  
  # Rescale counts with unknown sex
  v <- v + rescale_vector(v, scale = UNK[["Value"]])
  
  # TR: I don't remember what I was thinking with this line...
  v <- ifelse(is.nan(v), UNK[["Value"]] / 2, v)
  
  # Replace old values with rescaled values
  chunk <- chunk[, Value := v]
  
  # Console message
  if (verbose){
    cat("UNK Sex redistributed for",
      unique(chunk[["Code"]]),
      unique(chunk[["Age"]]),
      unique(chunk[["Measure"]]),"\n")
    }

  # Output
  chunk
  
}


### do_we_infer_both_sex()
# Check if no combined sex counts
# @param chunk Data chunk

do_we_infer_both_sex <- function(chunk){
  
  # Get sexes in data
  sexes  <- chunk[["Sex"]] %>% unique()
  
  # Everything in chunk is count data?
  Counts <- all(chunk[["Metric"]] == "Count")
  
  # No 'b' and everything is count?
  setequal(sexes,c("f","m")) & Counts
  
}


### infer_both_sex()
# Get combined sex counts from sex-specific counts
# @param chunk Data chunk
# @param verbose logical Print console message?

infer_both_sex <- function(chunk, verbose = FALSE){
  
  # Check if needed
  do_this <- do_we_infer_both_sex(chunk)
  
  # If not needed...
  if(!do_this) {
    
    # ... return unchanged chunk
    return(chunk)
    
  }
  
  # Get current code, sex, measure
  Code    <- chunk[["Code"]][1]
  Sex     <- chunk[["Sex"]][1]
  Measure <- chunk[["Measure"]][1]
  
  # Console message
  if (verbose) {
    cat("Both sex counts created by summing sex-specific counts",
         Code,Sex,Measure,"\n")
  }
  
  # Copy chunk
  zunk <- copy(chunk)
  
  # Calculate combined sex totals by age
  b <- zunk[ ,Value := sum(Value), by = list(Age)]
  
  # Set sex variable
  b <- b[,Sex := "b"]
  
  # Remove duplicates
  b <- b[!duplicated(Age)]
  
  # Output
  rbind(chunk,b)
  
}


### do_we_maybe_lower_closeout()
#
# @param chunk
# param OAnew_min

do_we_maybe_lower_closeout <- function(chunk, OAnew_min){
  
  maybe1 <- all(chunk[["Metric"]] == "Count")
  if (!maybe1){
    return(FALSE)
  }
  
  chunk  <- chunk[order(Age)]
  Age    <- chunk[["Age"]] 
  Value  <- chunk[["Value"]]
  AgeInt <- chunk[["AgeInt"]]
  
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


# -------------------------------------------------
# -------------------------------------------------
# -------------------------------------------------

# Here group_by(Country, Region, Code, Date, Measure).
# AFTER all Measure == "Count", ergo at the end of the pipe.
# this scales to totals (either stated or derived).
# it doesn't scale within age groups. Hmmm.





# Standardize closeout.
# closing out with 0 counts is pretty bad.
# closing out with known single ages that 
# don't go cleanly to 105 is also a pain for processing.
# age ranges that don't start at 0 are a pain for processing.
# need to standardize these things. What shall it be?
# on the lower end, if there are 0s

# TODO: maybe a general "patch zeros" function premised on 
# intermediary grouping to 5 years, then detection of lone 0s,
# then grouping to 10 (but not all ages, just the necessary ones).




maybe_lower_closeout <- function(chunk, OAnew_min = 85, verbose = FALSE){

  do_this <- do_we_maybe_lower_closeout(chunk, OAnew_min)
  if (!do_this){
    return(chunk)
  }
  
  chunk  <- chunk[order(Age)]
  Age    <- chunk[["Age"]] %>% as.integer()
  Value  <- chunk[["Value"]] 
  AgeInt <- chunk[["AgeInt"]] %>% as.integer()

  n  <- length(Age)
  nm <- (Age >= OAnew_min) %>% which() %>% min()
  for (i in n:nm){
    if (Value[i] > 0){
      break
    }
  }
  if (i < n){
    .Code    <- chunk[["Code"]][1]
    .Sex     <- chunk[["Sex"]][1]
    .Measure <- chunk[["Measure"]][1]
    if (verbose) cat("Open age group lowered from",Age[n],"to",Age[i],"for",.Code,.Sex,.Measure,"\n")
    .Value  <- c(Value[1:(i-1)],sum(Value[i:n]))
    .Age    <- Age[1:i]
    .AgeInt <- c(AgeInt[1:(i-1)], 105 - Age[i]) %>% as.integer()
    
    chunk <- chunk[1:i, ]
    chunk[,c("Age","AgeInt","Value") := .(.Age, .AgeInt, .Value)]
  }
  chunk
}
      

# inspect_code(inputDB,"ES31.03.2020)
inspect_code <- function(DB, .Code){
  DB %>% 
    filter(Code == .Code) %>% 
    View()
}

# This encapsulates the entire processing chain.
# TODO: ensure match to current chain.
process_counts <- function(inputDB, Offsets = NULL, N = 10){
  
  
  A <-
    inputDB %>% 
    filter(!(Age == "TOT" & Metric == "Fraction"),
           !(Age == "UNK" & Value == 0),
           !(Sex == "UNK" & Sex == 0)) %>% 
    group_by(Code, Measure) %>%
    # do_we_convert_fractions_sexes(chunk)
    do(convert_fractions_sexes(chunk = .data)) %>% 
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
  
  K <- J %>% 
    arrange(Country, Region, Sex, Measure, Age)
  
  
  K %>% 
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
harmonize_age <- function(chunk, Offsets = NULL, N = 5, OAnew = 100, lambda = 100){
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
                  control = list(lambda = lambda, deg = 3))$fitted * pop
  }  else {
    # if no offsets are available then run through without.
    V1      <- pclm(x = Age, 
                    y = Value, 
                    nlast = AgeInt[length(AgeInt)], 
                    control = list(lambda = lambda, deg = 3))$fitted
  }

  # Important to rescale
  V1      <- rescaleAgeGroups(Value1 = V1, 
                              AgeInt1 = rep(1,length(V1)), 
                              Value2 = Value, 
                              AgeInt2 = AgeInt, 
                              splitfun = graduate_mono)
  
  # division by 0, it's a thing
  V1[is.nan(V1)] <- 0
  
  VN      <- groupAges(V1, 0:104, N = N, OAnew = OAnew)
  Age     <- names2age(VN)
  AgeInt  <- rep(N, length(VN))
  
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
}


harmonize_age_p <- function(chunk, Offsets, N = 5, OAnew = 100, lambda = 100){
  .Country <- chunk %>% pull(Country) %>% "[["(1)
  .Region  <- chunk %>% pull(Region) %>% "[["(1)
  .Code    <- chunk %>% pull(Code) %>% "[["(1)
  .Date    <- chunk %>% pull(Date) %>% "[["(1)
  .Sex     <- chunk %>% pull(Sex) %>% "[["(1)
  .Measure <- chunk %>% pull(Measure) %>% "[["(1)
  
  out <- harmonize_age(chunk, Offsets = Offsets, N = N, OAnew = OAnew, lambda = lambda)
  out <- out %>% mutate(Country = .Country,
                        Region = .Region,
                        Code = .Code,
                        Date = .Date,
                        Sex = .Sex,
                        Measure = .Measure) %>% 
    select(Country, Region, Code, Date, Sex, Measure, Age, AgeInt, Value)
  out
}


# this is similar to the other one, except
# it's within age, so be done after age splitting
rescale_sexes_post <- function(chunk){
  sexes  <- chunk %>% pull(Sex) %>% unique()
  maybe  <- setequal(sexes,c("b","f","m")) 
  if (maybe){
    chunk <-
      chunk %>% 
      arrange(Sex, Age) %>% 
      pivot_wider(names_from = Sex,
                  values_from = Value) %>% 
      mutate(mf = m + f,
             adj = b / mf,
             adj = ifelse(mf == 0,1,adj),
             m = adj * m,
             f = adj * f) %>% 
      select(-c(mf,adj)) %>% 
      pivot_longer(cols = c("f","m","b") ,
                   names_to = "Sex",
                   values_to = "Value") %>% 
      arrange(Sex,Age)
    
  } 
  return(chunk)
}





# Slightly modified...
rescaleAgeGroups <- function (Value1, AgeInt1, Value2, AgeInt2, splitfun = c(graduate_uniform, 
                                                         graduate_mono), recursive = FALSE, tol = 0.001) 
{
  N1 <- length(Value1)
  stopifnot(sum(AgeInt1) == sum(AgeInt2))
  Age1 <- int2age(AgeInt1)
  Age2 <- int2age(AgeInt2)
  stopifnot(N1 == length(Age1))
  AgeN <- rep(Age2, times = AgeInt2)
  ValueS <- splitfun(Value1, AgeInt = AgeInt1, OAG = FALSE)
  AgeS <- 0:104
  AgeN2 <- rep(Age2, times = AgeInt2)
  beforeN <- groupAges(ValueS, AgeS, AgeN = AgeN2)
  beforeNint <- rep(beforeN, times = AgeInt2)
  afterNint <- rep(Value2, times = AgeInt2)
  ratio <- afterNint/beforeNint
  SRescale <- ValueS * ratio
  AgeN1 <- rep(Age1, times = AgeInt1)
  out <- groupAges(SRescale, AgeS, AgeN = AgeN1)
  if (!recursive) {
    return(out)
  }
  newN <- splitfun(out, AgeInt = AgeInt1, OAG = FALSE)
  check <- groupAges(newN, AgeS, AgeN = AgeN2)
  if (max(abs(check - Value2)) < tol) {
    return(out)
  }
  else {
    rescaleAgeGroups(Value1 = out, AgeInt1 = AgeInt1, Value2 = Value2, 
                     AgeInt2 = AgeInt2, splitfun = splitfun, tol = tol, 
                     recursive = recursive)
  }
}




