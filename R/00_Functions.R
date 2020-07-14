### Dependency preamble #############################################

# install pacman to streamline further package installation
if(!require("pacman", character.only = TRUE)) {
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package pacman not found")
}

library(pacman)

# Required CRAN packages
packages_CRAN <- c("tidyverse","lubridate","gargle","ungroup","HMDHFDplus",
                   "tictoc","parallel","osfr","data.table","git2r","usethis",
                   "remotes","here","knitr","rmarkdown")

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


### log_processing_error()
# Write error to log for chunk
# @param chunk Data chunk
# @param byvars character List of variables
# logfile character Name of log file

log_processing_error <- function(chunk,
                                 byvars = c("Code", "Sex", "Measure"),
                                 logfile = "buildlog.md"){
  
  # Get as data table
  chunk  <- data.table(chunk)
  
  # Get values
  marker <- chunk[1, ..byvars]
  
  # single quotes around char byvars: (only age isn't char..)
  marker <- ifelse(byvars == "Age",marker,paste0("'",marker,"'"))
  
  # List of variables
  marker <- paste(paste(byvars, marker, sep = " == "),collapse=", ")
  
  # Format
  marker <- c("filter(",marker,")\n")
  
  # Write to logfile
  cat(marker, file = logfile, append = TRUE)
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
  
  failures <- rep(NA,nrow(rubric))
  # Loop over countries
  for (i in rubric$Short) {
    
    # Get spreadsheet address
    ss_i <- rubric %>% filter(Short == i) %>% '$'(Sheet)
    
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
      failures[i] <- i
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
  
  
  # One last chance to pick up the failed loads...
  failures <- failures[!is.na(failures)]
  if (length(failures)>0){
    
    for (i in failures){
      Sys.sleep(200)
      # Get spreadsheet address
      ss_i <- rubric %>% filter(Short == i) %>% '$'(Sheet)
      X <- try(read_sheet(ss_i, 
                          sheet = "database", 
                          na = "NA", 
                          col_types = "cccccciccd"))
      if (class(X)[1] == "try-error"){
        cat(i, "on 3rd try still didn't load\n")
      } else {
        input_list[[i]] <- X
      }
    }
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
    ss_i <- offsets_rubric %>% filter(Short == i) %>% '$'(Sheet)
    
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
    # X <-  X %>% 
    #   mutate(Short = i)
    # 
    # Add country to list for results
    off_list[[i]] <- X
    
    # Wait a bit
    Sys.sleep(20) 
    
  }
  
  # Catch additional errors
  errors <- lapply(off_list,function(x){length(x)==1}) %>% unlist()
  
  # Show countries with additional errors
  if (sum(errors) > 0){
    
    
    prob_codes <- offsets_rubric %>% mutate(Code=paste(Country,Region)) %>% pull(Code) %>% '['(errors)
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
  ss_i   <- rubric %>% filter(Short == ShortCode) %>% '$'(Sheet)
  
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


### inspect_code()
# Views database entry
# @param DB Database
# @param .Code Country/day code
# inspect_code(inputDB,"ES31.03.2020)

inspect_code <- function(DB, .Code) {
  
  DB %>% 
    # Select rows with .Code
    filter(Code == .Code) %>% 
    View()
  
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
  if(verbose) cat("Fractions converted to Counts for",
                  unique(chunk$Code),"\n")
  
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
  if(verbose) cat("Fractions converted to Counts for",
                  unique(chunk[["Code"]]),"\n")
  
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
  if (verbose) cat("ACSFR converted to deaths for",
                   unique(chunk[["Code"]]),"\n")
  
  # Object for death counts
  Deaths  <- ASCFR
  
  # Calculate deaths
  Deaths <-
    Deaths[, c("Value", "Measure", "Metric") := 
             .(Cases[["Value"]] * ASCFR[["Value"]],"Deaths","Count")]
  
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
  if (verbose) cat("ACSFR converted to counts for",
                   unique(zunk[["Code"]]),"\n")
  
  # Calculate case counts
  cases <- Deaths[["Value"]] / ASCFR[["Value"]]
  
  # Replace NaN with 0
  cases <- ifelse(is.nan(cases),0,cases)
  
  # Format for output
  Cases <- ASCFR
  Cases <- Cases[, c("Value","Measure", "Metric") := 
                   .(cases,"Cases","Count")]
  
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
  v2    <- chunk[, Value] + 
          (chunk[, Value] / sum(chunk[, Value])) * UNK[, Value]
  
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
  
  # Replace NaN with 1
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
# Check if close out age needs to be lowered 
# @param chunk Data chunk
# param OAnew_min numeric Minimum close out age

do_we_maybe_lower_closeout <- function(chunk, OAnew_min) {
  
  # Check if chunk only has count data...
  maybe1 <- all(chunk[["Metric"]] == "Count")
  
  # ...if not return FALSE
  if(!maybe1){
    
    return(FALSE)
    
  }
  
  # Sort chunk by age
  chunk  <- chunk[order(Age)]
  
  # Get variables
  Age    <- chunk[["Age"]] 
  Value  <- chunk[["Value"]]
  AgeInt <- chunk[["AgeInt"]]
  
  # Check maximum age above new min...
  maybe2 <- max(Age) >= OAnew_min
  
  # ... if not return F
  if(!maybe2) {
    return(FALSE)
  }
  
  # Number of age groups
  n <- length(Age)
  
  # Find smallest age equal to OAnew_min
  nm <- (Age >= OAnew_min) %>% which() %>% min()
  
  # For ages above closeout age find largest with counts > 0
  for (i in n:nm){
    if (Value[i] > 0){
      break
    }
  }
  
  # Output
  i < n
}


### maybe_lower_closeout()
# Lower closeout age
# @param chunk Data chunk
# @param OAnew_min Minimum closeout age
# @param verbose logical Print console message

maybe_lower_closeout <- function(chunk, OAnew_min = 85, 
                                 verbose = FALSE){
  
  # Check if lower clouseout is needed...
  do_this <- do_we_maybe_lower_closeout(chunk, OAnew_min)
  
  # ... if no...
  if(!do_this) {
    
    # ... return unchanged chunk
    return(chunk)
    
  }
  
  # Order chunk
  chunk  <- chunk[order(Age)]
  
  # Get variables, in right format (integer)
  Age    <- chunk[["Age"]] %>% as.integer()
  Value  <- chunk[["Value"]] 
  AgeInt <- chunk[["AgeInt"]] %>% as.integer()
  
  # Get number of age groups
  n  <- length(Age)
  
  # Get youngest age group above min closeout age
  nm <- (Age >= OAnew_min) %>% which() %>% min()
  
  # Get oldest age above closeout with more than 0 cases
  for (i in n:nm){
    if (Value[i] > 0){
      break
    }
  }
  
  # If oldest age is not max age ein data
  if (i < n){
    
    # Get code, sex, measure
    .Code    <- chunk[["Code"]][1]
    .Sex     <- chunk[["Sex"]][1]
    .Measure <- chunk[["Measure"]][1]
    
    # Console message
    if (verbose) cat("Open age group lowered from",Age[n],
                     "to",Age[i],"for",.Code,.Sex,.Measure,"\n")
    
    # Get new values
    .Value  <- c(Value[1:(i-1)],sum(Value[i:n]))
    
    # Get new ages
    .Age    <- Age[1:i]
    
    # Turn to integer
    .AgeInt <- c(AgeInt[1:(i-1)], 105 - Age[i]) %>% as.integer()
    
    # Get chunk with ages up to open age group
    chunk <- chunk[1:i, ]
    chunk[,c("Age","AgeInt","Value") := .(.Age, .AgeInt, .Value)]
    
  }
  
  # Output
  chunk
  
}


### harmonize_offset_age()
# Harmonize highest age
# @param chunk Data chunk

harmonize_offset_age <- function(chunk){
  
  # Get age and population data
  Age     <- chunk %>% '$'(Age)
  Pop     <- chunk %>% '$'(Population) 
  
  # If already in shape, then skip it
  if(is_single(Age) & max(Age) == 104) {
    
    return(chunk[,"Age","Population"])
    
  }
  
  # if single, but high open age, then drop it:
  if(is_single(Age) & max(Age) > 104) {
    
    p1 <- groupOAG(Pop,Age,OAnew = 104)
    out <- tibble(Age = 0:104,
                  Population = p1)
    return(out)
    
  }
  
  # WIdth of current open interval
  nlast <- max(105 - max(Age), 5)
  
  # Widths of all age intervals
  AgeInt<- DemoTools::age2int(Age, OAvalue = nlast)
  
  # Split last age interval using PCLM
  p1 <- pclm(y = Pop, 
             x = Age, 
             nlast = nlast, 
             control = list(lambda = 10, deg = 3))$fitted
  
  # Rescale age groups
  p1  <- rescaleAgeGroups(Value1 = p1, 
                          AgeInt1 = rep(1,length(p1)), 
                          Value2 = Pop, 
                          AgeInt2 = AgeInt, 
                          splitfun = graduate_uniform)
  
  # Ages
  a1 <- 1:length(p1)-1
  
  # Group to new open age
  p1 <- groupOAG(p1, a1, OAnew = 104)
  
  out <- tibble(Age = 0:104,
                Population = p1)
  
  # Output
  out
  
}


### harmonize_offset_age_p()
# Wrapper for harmonizing age offset
# @param chunk Data chunk

harmonize_offset_age_p <- function(chunk) {
  
  # Get current country region sex
  .Country <- chunk %>% pull(Country) %>% '['(1)
  .Region  <- chunk %>% pull(Region) %>% '['(1)
  .Sex     <- chunk %>% pull(Sex) %>% '['(1)
  
  # Harmonize
  out <- harmonize_offset_age(chunk)
  
  # Add country region sex back
  out <-
    out %>% 
    mutate(Country = .Country,
           Region = .Region,
           Sex = .Sex)
  
  # Output
  out
  
}


### harmonize_age()
# Age harmonization
# @param chunk Data chunk
# @param Offsets Tibble/data frame with offsets
# @param N integer Age interval width
# @param OAnew integer Open age interval
# @param lambda Lambda value for PCLM

harmonize_age <- function(chunk, Offsets = NULL, N = 5, OAnew = 100, 
                          lambda = 100) {
  
  # Get age, interval width, counts
  Age     <- chunk %>% '$'(Age)
  AgeInt  <- chunk %>% '$'(AgeInt)
  Value   <- chunk %>% '$'(Value) 
  
  # Maybe we don't need to do anything but lower the OAG?
  if(all(AgeInt == N) & max(Age) >= OAnew) {
    
    # Lower open age group: Combine values
    Value   <- groupOAG(Value, Age, OAnew = OAnew)
    
    # Reduce ages and interval width
    Age     <- Age[1:length(Value)]
    AgeInt  <- AgeInt[1:length(Value)]
    
    # Output
    return(select(chunk, Age, AgeInt, Value))
    
  }
  
  # Get country, region, sex
  .Country <- chunk %>% '$'(Country) %>% "["(1)
  .Region  <- chunk %>% '$'(Region) %>% "["(1)
  .Sex     <- chunk %>% '$'(Sex) %>% "["(1)
  
  # If offsets available...
  if(!is.null(Offsets)) {
    
    # ...get offset for country/region/sex
    Offsets   <- Offsets %>% 
      filter(Country == .Country,
             Region == .Region,
             Sex == .Sex)
    
  } else {
    
    # Empty tibble if no offsets
    Offsets <- tibble()
    
  }
  
  # If offsets available...
  if (nrow(Offsets) == 105){
    
    # ... get offsets
    pop     <- Offsets %>% '$'(Population)
    age_pop <- Offsets %>% '$'(Age)
    
    # Apply PCLM with offsets
    V1 <- pclm(x = Age, 
               y = Value, 
               nlast = AgeInt[length(AgeInt)], 
               offset = pop, 
               control = list(lambda = lambda, deg = 3))$fitted * pop
  }  else {
    
    # If no offsets are available then run through without.
    V1 <- pclm(x = Age, 
               y = Value, 
               nlast = AgeInt[length(AgeInt)], 
               control = list(lambda = lambda, deg = 3))$fitted
  }
  
  # Rescale age groups
  V1      <- rescaleAgeGroups(Value1 = V1, 
                              AgeInt1 = rep(1,length(V1)), 
                              Value2 = Value, 
                              AgeInt2 = AgeInt, 
                              splitfun = graduate_mono)
  
  # Replace NaN with zero
  V1[is.nan(V1)] <- 0
  
  # Group to age intervals
  VN      <- groupAges(V1, 0:104, N = N, OAnew = OAnew)
  
  # First age of each age interval
  Age     <- names2age(VN)
  
  # Interval widths
  AgeInt  <- rep(N, length(VN))
  
  # Output
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
  
}


### harmonize_age_p()
# Age harmonization keeping format
# @param chunk Data chunk
# @param Offsets Tibble/data frame with offsets
# @param N integer Age interval width
# @param OAnew integer Open age interval
# @param lambda Lambda value for PCLM

harmonize_age_p <- function(chunk, Offsets, N = 5, 
                            OAnew = 100, lambda = 100){
  
  # Get country, region, etc.
  .Country <- chunk %>% '$'(Country) %>% "[["(1)
  .Region  <- chunk %>% '$'(Region) %>% "[["(1)
  .Code    <- chunk %>% '$'(Code) %>% "[["(1)
  .Date    <- chunk %>% '$'(Date) %>% "[["(1)
  .Sex     <- chunk %>% '$'(Sex) %>% "[["(1)
  .Measure <- chunk %>% '$'(Measure) %>% "[["(1)
  
  # Harmonize age
  out <- harmonize_age(chunk, Offsets = Offsets, N = N, 
                       OAnew = OAnew, lambda = lambda)
  
  # Add country, region, etc. information back
  out <- out %>% mutate(Country = .Country,
                        Region = .Region,
                        Code = .Code,
                        Date = .Date,
                        Sex = .Sex,
                        Measure = .Measure) %>% 
        select(Country, Region, Code, Date, Sex, 
               Measure, Age, AgeInt, Value)
  
  # Output
  out
}


### rescale_sexes_post()
# Rescales sex-specific counts to match combined-sex values
# @param chunk Data chunk

rescale_sexes_post <- function(chunk) {
  
  # Get sexes in data
  sexes  <- chunk %>% '$'(Sex) %>% unique()
  
  # Data includes b, m, f?
  maybe  <- setequal(sexes,c("b","f","m")) 
  
  # If so,
  if (maybe){
    
    chunk <- chunk %>% 
             # Sort by Sex and Age
             arrange(Sex, Age) %>% 
             # Reshape to wide
             pivot_wider(names_from = Sex,
                  values_from = Value) %>% 
             # Calculate/apply adjustment
             mutate(mf = m + f,
              adj = b / mf,
              adj = ifelse(mf == 0,1,adj),
              m = adj * m,
              f = adj * f) %>% 
             # Drop intermediate steps
             select(-c(mf,adj)) %>% 
             # Reshape back to long
             pivot_longer(cols = c("f","m","b") ,
                   names_to = "Sex",
                   values_to = "Value") %>% 
             # Sort 
             arrange(Sex,Age)
    
  } 
  
  # Output
  return(chunk)
  
}


### rescaleAgeGroups()
# Rescale counts in age groups to match counts in different age groups
# @param See help(rescaleAgeGroups)

rescaleAgeGroups <- function (Value1, AgeInt1, Value2, AgeInt2,
                              splitfun = c(graduate_uniform,graduate_mono),
                              recursive = FALSE, tol = 0.001) {
  
  # Number of counts
  N1 <- length(Value1)
  
  # Stop if total number of ages does not match
  stopifnot(sum(AgeInt1) == sum(AgeInt2))
  
  # Lower bounds of age classes
  Age1 <- int2age(AgeInt1)
  Age2 <- int2age(AgeInt2)
  
  # Stop if counts do not match number of age classes
  stopifnot(N1 == length(Age1))
  
  # Duplicate lowe bounds
  AgeN <- rep(Age2, times = AgeInt2)
  
  # Split counts
  ValueS <- splitfun(Value1, AgeInt = AgeInt1, OAG = FALSE)
  
  # Single ages
  AgeS <- 0:104
  
  # Duplicate lower bounds
  AgeN2 <- rep(Age2, times = AgeInt2)
  
  # Group into age groups
  beforeN <- groupAges(ValueS, AgeS, AgeN = AgeN2)
  
  # Duplicate values
  beforeNint <- rep(beforeN, times = AgeInt2)
  afterNint <- rep(Value2, times = AgeInt2)
  
  # Calculate ratios
  ratio <- afterNint/beforeNint
  
  # Rescale
  SRescale <- ValueS * ratio
  AgeN1 <- rep(Age1, times = AgeInt1)
  
  # Output
  out <- groupAges(SRescale, AgeS, AgeN = AgeN1)
  
  # If not recursive...
  if(!recursive) {
    return(out)
  }
  
  # Split and regroup
  newN <- splitfun(out, AgeInt = AgeInt1, OAG = FALSE)
  check <- groupAges(newN, AgeS, AgeN = AgeN2)
  
  # If recursive and match within tolerance return...
  if(max(abs(check - Value2)) < tol) {
    return(out)
  }
  # ... otherwise repeat
  else {
    rescaleAgeGroups(Value1 = out, AgeInt1 = AgeInt1, Value2 = Value2, 
                     AgeInt2 = AgeInt2, splitfun = splitfun, tol = tol, 
                     recursive = recursive)
  }
  
}


# -------------------------------------------------
# -------------------------------------------------
# -------------------------------------------------

### process_counts()
# This encapsulates the entire processing chain.
# TODO: ensure match to current chain.
# TODO: Document properly

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
