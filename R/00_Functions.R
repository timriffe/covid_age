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
                   "tictoc","parallel","data.table","git2r","usethis",
                   "remotes","here","knitr","rmarkdown","googledrive","zip",
                   "cartography","rgdal","tmap","svglite",
                   "countrycode","wpp2019","memuse")

# Install required CRAN packages if not available yet
if(!sum(!p_isinstalled(packages_CRAN))==0) {
  p_install(
    package = packages_CRAN[!p_isinstalled(packages_CRAN)], 
    character.only = TRUE
  )
}

# Reuired github packages
packages_git <- c("googlesheets4","DemoTools","parallelsugar","osfr","covidAgeData")

# install from github if necessary
if (!p_isinstalled("googlesheets4")) {
  library(remotes)
  install_github("tidyverse/googlesheets4")
}
if (!p_isinstalled("covidAgeData")) {
  library(remotes)
  install_github("eshom/covid-age-data")
}
if (!p_isinstalled("parallelsugar")){
  library(remotes)
  install_github("nathanvan/parallelsugar")
}
if (!p_isinstalled("osfr")){
  library(remotes)
  install_github("ropensci/osfr", force = TRUE)
}
if (!p_isinstalled("DemoTools")) {
  library(remotes)
  install_github("timriffe/DemoTools")
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

push_current <- function(files_data = c("inputDB.csv","Output_5.csv","Output_10.csv")) {
  
  # Get directory on OSF
  target_dir <- osf_retrieve_node("mpwjq") %>% 
    osf_ls_files(pattern = "Data") 
  
  files <- here("Data",files_data)
  
  # Push to OSF
  for (i in 1:length(files)){
    osf_upload(target_dir,
               path = files[i],
               conflicts = "overwrite")  
  }
  
  
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
                  "\n",
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
                     write_log = TRUE,
                     ...) {
  
  # Try function on chunc
  out <- try(process_function(chunk = chunk, ...))
  
  # If error happens...
  if (class(out)[1] == "try-error"){
    
    if (write_log){
      # ...write error to log
      log_processing_error(chunk = chunk, 
                           byvars = byvars,
                           logfile = logfile)
    }
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
# @param hours (integer) just pull sheets modified within a specified window
#           Inf means it grabs all templates, no matter when they were last 
#           modified. Set to 4 if this is to be called as a cron job on a 4
#           hour timer, for example.

# leave rubric as NULL for full build
compile_inputDB <- function(rubric = NULL, hours = Inf) {
  
  # Get spreadsheet
  if (is.null(rubric)){
    rubric <- get_input_rubric(tab = "input")
  }
  
  # Only get countries with at least one row of data
  # rubric <- rubric %>% 
  #   filter(Rows > 0) # just always read all files from Hyrdra?
  # 
  on_hydra <- Sys.info()["nodename"] %in% c("HYDRA01","HYDRA02")
  if ( on_hydra ){
    
    rubric_hydra <- 
      get_input_rubric(tab = "input") %>% 
      filter(Loc == "n")
    
    rubric <- rubric %>% 
      filter(Loc != "n")
  }
  
  # Empty list for results
  input_list <- list()
  
  # cut down if hours < Inf
  if (hours < Inf){
    hours <- as.integer(hours)
    if (hours > 0){
      seconds <- hours*60*60
      cutofftime <- format(Sys.time()-hours*60*60, "%Y-%m-%dT%H:%M:00")
      query <- paste0("modifiedTime > '",
                     cutofftime,
                     "' and name contains 'input template'")
      A <- drive_find(q = query)
      ids <- A %>% 
        dplyr::pull(drive_resource) %>% 
        lapply(function(x){x$id[1]}) %>% unlist()
      
      cutID <- function(x){
        sheetID <- gsub(x,pattern = "https://docs.google.com/spreadsheets/d/", replacement = "")
        sheetID <- strsplit(sheetID, split = "/edit")[[1]][1]
        sheetID
      }
      
      # cut down to just those modified in last hours
      rubric <- 
        rubric %>%  
        mutate(sheetID = sapply(Sheet, cutID)) %>% 
        filter(sheetID %in% ids)
      
     }
  }
  
  
  
  failures <- rep(NA,nrow(rubric))
  # Loop over countries
  for (i in 1:nrow(rubric)) {
    
    # Get spreadsheet address
    ss_i <- rubric %>% '$'(Sheet) %>% '['(i)
    
    id <-  rubric %>% '$'(Short) %>% '['(i)
    
    # Try to read spreadsheet
    X <- try(read_sheet(ss_i, 
                        sheet = "database", 
                        na = "NA", 
                        col_types = "cccccciccd",
                        range = "database!A:J"))
    
    # If error
    if (class(X)[1] == "try-error") {
      
      # Wait two minutes
      cat(id,"didn't load, waiting 2 min to try again")
      Sys.sleep(120)
      
      # Try to load again
      X <- try(read_sheet(ss_i, 
                          sheet = "database", 
                          na = "NA", 
                          col_types = "cccccciccd",
                          range = "database!A:J"))
      
    }
    
    # If again error
    if (class(X)[1] == "try-error") {
      cat(id,"failure\n")
      failures[id] <- id
    } else {
      
      # If data loaded get code
      X <- 
        X %>% 
        mutate(Short = add_Short(Code, Date),
               templateID = id)
      
      # Add to result list
      input_list[[id]] <- X
      
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
                          col_types = "cccccciccd",
                          range = "database!A:J"))
      if (class(X)[1] == "try-error"){
        cat(i, "on 3rd try still didn't load\n")
      } else {
        X <- 
         X %>% 
          mutate(Short = add_Short(Code, Date),
                 templateID = i)
        input_list[[i]] <- X
      }
    }
  }
  
  if (on_hydra){
    
    hydra_path <- "N:/COVerAGE-DB/Automation/Hydra"
    
    # EA: Only reading those files in N:/ that were modified during the last 12 hours, similar to those in Drive
    # added on 13.08.2021
    max_t <- 12
    
    local_files <- 
      rubric_hydra %>% 
      mutate(local_files = paste0(hydra_path, "/", hydra_name, ".rds"),
             modif_time = file.info(local_files)$mtime,
             hours_diff = difftime(Sys.time(), modif_time, units = "hours") %>% unclass()) %>% 
      filter(hours_diff < max_t) %>% 
      dplyr::pull(local_files)
    
    # local_files <-
    #   rubric_hydra %>%
    #   dplyr::pull(hydra_name) %>%
    #   paste0(".rds")
    # 
    # local_files <-  file.path(hydra_path,local_files)
    
    
    
    # Breaking down the loading of data from N:/, so the process does not break down
    # each time it finds an issue
    
    hydra_data <- tibble()
    
    for(lf in local_files){
      try(
        temp <- 
          read_rds(lf) %>% 
          ungroup() %>% 
          mutate(Age = as.character(Age),
                 AgeInt = as.integer(AgeInt), 
                 Value = as.double(Value))
      )
        
      try(
        hydra_data <- 
          hydra_data %>% 
          bind_rows(temp)
      )
      
    }
    
    hydra_data <- 
      hydra_data %>% 
      mutate(Short = add_Short(Code, Date))
    
    # hydra_data <-
    #   lapply(local_files,
    #          readRDS) %>% 
    #   lapply(function(X){
    #     X %>% 
    #       ungroup() %>% 
    #       mutate(Age = as.character(Age),
    #              AgeInt = as.integer(AgeInt))
    #   }) %>% 
    #   bind_rows() %>% 
    #   mutate(Short = add_Short(Code, Date))
  
    
  } else {
    hydra_data <- tibble()
  }
  
  # remove readings with 0 rows (earmarked for collection)
  
  NROWS      <- lapply(input_list, nrow) %>% unlist()
  input_list <- input_list[NROWS != 0]
  # Bind and sort
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    bind_rows(hydra_data) %>% 
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
      cat(i,"didn't load, waiting 2 min to try again\n")
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
    
    
    prob_codes <- offsets_rubric %>% mutate(Code=paste(Country,Region)) %>% dplyr::pull(Code) %>% '['(errors)
    cat("\nThe following code(s) did not read properly:\n",paste(prob_codes,collapse = "\n"))
    off_list <- off_list[!errors]
  }
  
  # Bind and sort
  offsetsDB <- 
    off_list %>% 
    bind_rows() %>% 
    arrange(Country, Region, Sex) %>% 
    dplyr::select(Country, Region, Date, Sex, Age, AgeInt, Population)
  
  # Output
  offsetsDB
  
}



### Functions for loading/getting data ##############################

### get_input_rubric()
# Get overview spreadsheet with input data sources
# @param tab character, which sheet to get

get_input_rubric <- function(tab = "input") {
  
  # Spreadsheet on Google Docs
  ss_rubric <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0"
  
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
                    col_types= "cccccciccd",
                    range = "database!A:J")
  
  # Assign short code
  out$Short <- add_Short(out$Code,out$Date)
  
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


#----------------------
# TR: this will be a bigger pain than it needs to be...
# still needs to be called AFTER Age is integer
add_AgeInt <- function(Age, omega = 105){
   
    DemoTools::age2int(Age = Age, OAvalue = omega - max(Age))
}
#---------------------



### a modularized check on Age AgeInt consistency
# @param chunk data chunk consisting in unique combo of Code, Sex, Measure, Metric
check_age_seq <- function(chunk){
  chunki <- copy(chunk)
  chunki <- chunki[!Age%in%c("TOT","UNK")]
  
  if (nrow(chunki) == 0){
    return(TRUE)
  }
  
  keep   <- chunki$Sex != "UNK"
  chunki <- chunki[keep]
  if (nrow(chunki) == 0){
    return(TRUE)
  }
  chunki[, Age := as.integer(Age)]
  chunki <- chunki[order(Age)]
  chunki[, Age2 := Age + AgeInt]
  chunki[, Age2 := lag(Age2)]
  
  all(chunki[["Age"]] == chunki[["Age2"]], na.rm=TRUE) & min(chunki[["Age"]]) == 0
}


### resolve_UNKUNK() we don't want UNK Sex and UNK Age in same row. Instead,
# generate both-sex TOT count if needed, then everythnig will rescale properly.
# downstream.
# @param chunk Data chunk
resolve_UNKUNK <- function(chunk){
  has_unkunk <- any(chunk[["Sex"]] == "UNK" & chunk[["Age"]] == "UNK")
  has_tot_b  <- any(chunk[["Age"]] == "TOT" & chunk[["Sex"]] == "b")
  
  all_counts <- all(chunk[["Metric"]] == "Count")
  # if there's already tot b, then return without UNKUNK, adds nothing.
  if (has_tot_b | !all_counts){
    chunk <- chunk %>% 
      filter(!(.data$Age == "UNK" & .data$Sex == "UNK"))
    return(chunk)
  }
  # In this case we calculate TOT b, one way or another and remove UNKUNK
  
  if (has_unkunk & !has_tot_b){
    totb     <- slice(chunk,1)
    totb[["Sex"]] <- "b"
    totb[["Age"]] <- "TOT"
    
    maybe_b    <- chunk %>% 
      filter(Age != "TOT",
             !Sex %in% c("m","f","UNK"))
    
    # Case 1: we have a marginal disttribution of both-sex
    has_b <- nrow(maybe_b) > 3
    if (has_b){
      TOT <- sum(maybe_b[["Value"]])
      totb[["Value"]] <- TOT
    } 
    
    # case 2 If male, female, UNK marginal totals are given
    tot_mfunk <- chunk %>% 
      filter(.data$Sex %in% c("m","f","UNK"), 
             .data$Age == "TOT")
    has_tot_mfunk <- nrow(tot_mfunk) %in% c(2,3)
    
    # doesn't repeat if case 1 is done
    if (!has_b & has_tot_mfunk){
      TOT <- sum(tot_mfunk[["Value"]])
      totb[["Value"]] <- TOT
    }
    
    # case 3 the marginal total of everything except b
    if (!(has_b | has_tot_mfunk)){
      just_mfunk <- chunk %>% 
        filter(.data$Sex != "b",
               .data$Age != "TOT")
      TOT <- sum(just_mfunk[["Value"]])
      totb[["Value"]] <- TOT
    }
    chunk <- chunk %>% 
      filter(!(.data$Age == "UNK" & .data$Sex == "UNK")) %>% 
      bind_rows(totb)
  }
  
  chunk
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
 
    a          <- ASCFR[["Age"]] %>% as.integer()
    
    # indicate 0s
    ind        <- v > 0 & !is.na(a) & a < 60
    ind2       <- v == 0 & !is.na(a)
    vi         <- v[ind]
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
  chunk   <- as.data.table(chunk)
  # Check if rescaling is needed
  do_this <- do_we_rescale_to_total(chunk)
  
  # If no rescaling is needed return unchanged chunk
  if(!do_this) {
    
    # TR: no need to keep both-sex TOT age.
    # it can be summed from the margins if needed.
    # Keep both sex tot
   #i1    <- chunk[["Sex"]] %in% c("m","f","UNK")
    i1    <- chunk[["Age"]] == "TOT"
    ind   <- !i1
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
# @param OAnew_min numeric Minimum close out age

do_we_maybe_lower_closeout <- function(chunk, OAnew_min, Amax) {
  
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
  
  # Check maximum age above new min...
  maybe2 <- max(Age) >= OAnew_min
  
  # ... if not return F
  if(!maybe2) {
    return(FALSE)
  }
  
  # also need to group down if top age too high
  maybe3 <- max(Age) > Amax
  if (maybe3){
    return(TRUE)
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

maybe_lower_closeout <- function(chunk, 
                                 OAnew_min = 85, 
                                 Amax = 104,
                                 verbose = FALSE){
  
  # Check if lower clouseout is needed...
  do_this <- do_we_maybe_lower_closeout(chunk, OAnew_min, Amax) 
  
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
  
  # Get number of age groups
  n  <- length(Age)
  
  # Get oldest age group under max closeout age
  nmax <- (Age <= Amax) %>% which() %>% max()
  
  if (nmax < n){
    # Get code, sex, measure
    .Code    <- chunk[["Code"]][1]
    .Sex     <- chunk[["Sex"]][1]
    .Measure <- chunk[["Measure"]][1]
    
    # Console message
    if (verbose) cat("Open age group lowered from",Age[n],
                     "to",maxA,"for",.Code,.Sex,.Measure,"\n")
    
    # Get new values
    .Value  <- c(Value[1:(nmax-1)],sum(Value[nmax:n]))
    
    # Get new ages
    .Age    <- Age[1:nmax]
    
    # Get chunk with ages up to open age group
    chunk <- chunk[1:nmax, ]
    chunk[,c("Age","Value") := .(.Age,  .Value)]
    
    # reform parameter to pass on
    n <- length(.Age)
  }
  
  
  # Get youngest age group above min closeout age
  nmin <- (Age >= OAnew_min) %>% which() %>% min()
  
  # Get oldest age above closeout with more than 0 cases
  for (i in n:nmin){
    if (Value[i] > 0){
      break
    }
  }
  
  # If oldest age is not max age in data
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
    

    # Get chunk with ages up to open age group
    chunk <- chunk[1:i, ]
    chunk[,c("Age","Value") := .(.Age, .Value)]
    
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
    
    return(dplyr::select(chunk,Age,Population))
    
  }
  
  # if single, but high open age, then drop it:
  if(is_single(Age) & max(Age) > 104) {
    
    p1 <- groupOAG(Pop,Age,OAnew = 104)
    out <- tibble(Age = 0:104,
                  Population = p1)
    return(out)
    
  }
  
  if (max(Age) > 104){
    Pop <- groupOAG(Pop,Age,OAnew = 104)
  }
  # Width of current open interval
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
  .Country <- chunk %>% dplyr::pull(Country) %>% '['(1)
  .Region  <- chunk %>% dplyr::pull(Region) %>% '['(1)
  .Sex     <- chunk %>% dplyr::pull(Sex) %>% '['(1)
  
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
  .id.      <- chunk %>% '$'(id) %>% '[['(1)
  # .id      <- chunk %>% '$'(id) %>% "[["(1)
  # Harmonize age
  out <- harmonize_age(chunk, Offsets = Offsets, N = N, 
                       OAnew = OAnew, lambda = lambda)
  
  # Add country, region, etc. information back
  out <- out %>% mutate(Country = .Country,
                        Region = .Region,
                        Code = .Code,
                        Date = .Date,
                        Sex = .Sex,
                        Measure = .Measure,
                        id = .id.) %>% 
        select(Country, Region, Code, Date, Sex, 
               Measure, Age, AgeInt, Value, id)
  
  # Output
  out
}
# @param chunk Data chunk
# @param Offsets Tibble/data frame with offsets
# @param N integer Age interval width
# @param OAnew integer Open age interval
# @param lambda Lambda value for PCLM
harmonize_age_p_del <- function(chunk, 
                                Offsets, 
                                N = 5, 
                                OAnew = 100, 
                                lambda = 100){
  out <- try(harmonize_age_p(chunk = chunk, 
                             Offsets = Offsets, 
                             N = N, 
                             OAnew = OAnew, 
                             lambda = lambda))
  if (class(out)[1] == "try-error"){
    out <- chunk[0,] %>% 
      select(Country, Region, Code, Date, Sex, Measure, Age, AgeInt, Value, id)
  }
  out
}

# @param bigchunk Data with id variable indicating subsets, roughly 1/33 of the inputCounts
# @param Offsets Tibble/data frame with offsets
# @param N integer Age interval width
# @param OAnew integer Open age interval
# @param lambda Lambda value for PCLM 
harmonize_age_p_bigchunks <- function(bigchunk,
                                      Offsets, 
                                      N = 5, 
                                      OAnew = 100, 
                                      lambda = 100){
  bigchunk <- bigchunk %>% 
    arrange(.data$id,.data$Age)
    
  innerL <- split(bigchunk, list(bigchunk$id)) 
  harmonizedL <- lapply(innerL,
                harmonize_age_p_del,
                Offsets = Offsets,
                OAnew = OAnew,
                N = N,
                lambda = lambda) 
  out <- rbindlist(harmonizedL)
  return(out)
}



### rescale_sexes_post()
# Rescales sex-specific counts to match combined-sex values
# @param chunk Data chunk
rescale_sexes_post<- function(chunk) {
  # TR 13.02.2021: new data.table (albeit a hacky one) redux
  dat <- copy(chunk)
  # Get sexes in data
  sexes  <- dat %>% '$'(Sex) %>% unique()
  
  # Data includes b, m, f?
  maybe  <- setequal(sexes,c("b","f","m")) 
  
  # If so,
  if (maybe){
    dat <-
      dat %>% 
      .[,Value := as.double(Value)] %>% 
      dcast(Age~Sex,value.var = "Value") %>% 
      .[,mf := m + f] %>% 
      .[,adj := b / mf] %>% 
      .[,adj := nafill(adj,nan = NA, fill = 1)] %>% 
      .[,m := adj * m] %>% 
      .[,f := adj * f] %>% 
      .[,adj := NULL] %>% 
      .[,mf := NULL] %>% 
      melt(measure.vars = c("b","m","f"),
           variable.name = "Sex",
           value.name = "Value",
           verbose = FALSE)
    
    
  } 
  icols <- c("Sex","Age","Value")
  # Output
  dat[,..icols] %>% 
    .[,.(Value = as.double(Value),
         Sex = as.character(Sex),
         Age = as.integer(Age))] %>% 
    return()
}

# dplyr version replaced w above data.table
# rescale_sexes_post <- function(chunk) {
#   
#   # Get sexes in data
#   sexes  <- chunk %>% '$'(Sex) %>% unique()
#   
#   # Data includes b, m, f?
#   maybe  <- setequal(sexes,c("b","f","m")) 
#   
#   # If so,
#   if (maybe){
#     
#     chunk <- chunk %>% 
#              # Sort by Sex and Age
#              arrange(Sex, Age) %>% 
#              # Reshape to wide
#              pivot_wider(names_from = Sex,
#                   values_from = Value) %>% 
#              # Calculate/apply adjustment
#              mutate(mf = m + f,
#               adj = b / mf,
#               adj = ifelse(mf == 0,1,adj),
#               m = adj * m,
#               f = adj * f) %>% 
#              # Drop intermediate steps
#              select(-c(mf,adj)) %>% 
#              # Reshape back to long
#              pivot_longer(cols = c("f","m","b") ,
#                    names_to = "Sex",
#                    values_to = "Value") %>% 
#              # Sort 
#              arrange(Sex,Age)
#     
#   } 
#   
#   # Output
#   return(chunk)
#   
# }


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

# function that filters rubric down to just those templates that have been updated
# in a given time reference window (t-hours_from, t-hours_to)
get_rubric_update_window <- function(hours_from = 12, hours_to = 2){
  rubric <- get_input_rubric(tab = "input")
  
  cutofftime <- format(Sys.time()-hours_from*60*60, "%Y-%m-%dT%H:%M:00")
  query <- paste0("modifiedTime > '",
                  cutofftime,
                  "' and name contains 'input template'")
  A <- drive_find(q = query)
  ids_read <- A %>% 
    dplyr::pull(drive_resource) %>% 
    lapply(function(x){x$id[1]}) %>% unlist()
  
  # which templates were updated within last hours_to hours
  cutofftime <- format(Sys.time()-hours_to*60*60, "%Y-%m-%dT%H:%M:00")
  query <- paste0("modifiedTime > '",
                  cutofftime,
                  "' and name contains 'input template'")
  B <- drive_find(q = query)
  ids_rm <- B %>% 
    dplyr::pull(drive_resource) %>% 
    lapply(function(x){x$id[1]}) %>% unlist()
  
  ids_read <- ids_read[!ids_read%in%ids_rm]
  
  cutID <- function(x){
    sheetID <- gsub(x,pattern = "https://docs.google.com/spreadsheets/d/", replacement = "")
    sheetID <- strsplit(sheetID, split = "/edit")[[1]][1]
    sheetID
  }
  
  # cut down to just those modified in last hours
  rubric <- 
    rubric %>%  
    mutate(sheetID = sapply(Sheet,cutID )) %>% 
    filter(sheetID %in% ids_read)
  
  rubric
}

# Functions inherited from EA, modifed by TR.

# @param pp base name of script (needs to be inside Automation/00_hydra/)
# @param tm what time should it be run at?
# @param email gmail account with permissions and local PAT set up
# @param wd repo base path.
sched <- function(
  pp = "CA_montreal", 
  tm = "06:00", 
  email = "tim.riffe@gmail.com",
  wd = here()){
  script <- here("Automation/00_hydra/", paste0(pp, ".R")  )
  
  # modify the script to know who scehduled it and where it is
  A        <- readLines(script)
  ind      <- (A == "# ##  ###") %>% which() %>% '['(1)
  A[ind+1] <- paste("email <-",email)
  A[ind+2] <- paste0('setwd("',wd,'")')
  writeLines(A,script)
  # -------------------
  
  tskname <- paste0("coverage_db_", pp, "_daily")
  
  try(taskscheduler_delete(taskname = tskname))
  
  taskscheduler_create(taskname = tskname, 
                       rscript = script, 
                       schedule = "DAILY", 
                       starttime = tm, 
                       startdate = "30/06/2020")
}
# remove a scheduled task
# @param pp script base name
delete_sched <- function(pp = "CA_montreal"){
  tskname <- paste0("coverage_db_", pp, "_daily")
  taskscheduler_delete(taskname = tskname)
}

log_update <- function(pp, N){
  ss <- "https://docs.google.com/spreadsheets/d/1ftqFwX_Z29OrXxH9HnQWo31ApoEpxSqYOJspnIUAUbk/edit#gid=0"
  log_this <- tibble(pp = pp, Date = lubridate::today(), rows = N)
  sheet_append(log_this, ss = ss, sheet = "log")
}

Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL","English")

# useful for automated capture
ddmmyyyy <- function(Date,sep = "."){
  paste(sprintf("%02d",day(Date)),
        sprintf("%02d",month(Date)),  
        year(Date),sep=sep)
}

change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
  source("~/.Rprofile")
}
wd_sched_detect <- function(){
  if (!interactive()){
    initial.options <- commandArgs(trailingOnly = FALSE)
    file.arg.name   <- "--file="
    script.name     <- sub(file.arg.name,"",initial.options[grep(file.arg.name,initial.options)]) 
    
    wd <- script.name 
  }else {
    wd <- getwd()
  }
  for (i in 1:3){
    bname <- basename(wd)
    if (bname == "covid_age"){
      break
    }
    wd <- dirname(wd)
  }
  wd
}