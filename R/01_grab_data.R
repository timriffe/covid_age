### Functions & settings ############################################

# Functions
source("R/00_Functions.R")
source("R_checks/inputDB_check.R")

# For authentication
gs4_auth(email = "christa.ledud@gmail.com")

  

### Check what to update ############################################

# Check for new data
rubric     <- get_input_rubric()

# Load old metadata
rubric_old <- readRDS("Data/rubric_old.rds")

# Get short codes and number of data rows
rubric_old <- rubric_old %>% select(Short, Rows)

# Which countries to compile without data updates
extra_keep <- c("AR")

# Determine updates
Updates <- 
        # Merge old and new rubric
        left_join(rubric, rubric_old, by = "Short") %>% 
        # Get number of rows and change in number of rows
        mutate(
          Rows.y = ifelse(is.na(Rows.y),0,Rows.y),
          Change = Rows.x - Rows.y) %>% 
        # Drop if no change in number of rows
        filter(abs(Change) > 0 | Short %in% extra_keep) %>% 
        # Select interesting variables from rubroc
        select(Country, Region, Short, Rows = Rows.x, Change, Sheet)

# Save current rubric data as old rubric
saveRDS(rubric, "Data/rubric_old.rds")



### Compiling & updating ############################################

# Settings
check_db <- FALSE
full     <- FALSE

if (check_db){   
  
  # Run a full build...
  if (full){
     tic() # For timing
     inputDB <- compile_inputDB()
     toc()
  } else {
    # ... or just parts of data which changed
    tic()
    inputDB <- compile_inputDB(Updates)
    toc()
  }

  # If no full build
  if (!full){
    
    # Get codes of new rows
    new_codes <- inputDB %>% '$'(Short) %>% unique()
    
    # Read old DB
    holdDB <- readRDS("Data/inputDBhold.rds")
    
    holdDB <-
      holdDB %>% 
      # Drop rows with new codes
      filter(!Short %in% new_codes) %>% 
      # Combine with new data
      bind_rows(inputDB) %>% 
      # Drop rows with 0 cases and unknown age/sex
      filter(!(Sex == "UNK" & Value == 0),
             !(Age == "UNK" & Value == 0)) %>% 
      # Sort
      sort_input_data()
    
    # Save
    saveRDS(holdDB,here::here("Data/inputDBhold.rds"))
 
  } else {
    
    # Drop rows with 0 cases and unknown age/sex
    inputDB <- inputDB %>% 
      filter(!(Sex == "UNK" & Value == 0),
             !(Age == "UNK" & Value == 0)) 
    
    # Save
    saveRDS(inputDB,here::here("Data/inputDBhold.rds"))
    
  }
  
  # Date range check
  inputDB %>% 
    mutate(date = dmy(Date)) %>% 
    '$'(date) %>% 
    range()    
  
  # once-off fix for Sweden input:
  inputDB <- 
    inputDB %>% 
    mutate(AgeInt = ifelse(Age %in% c("UNK","TOT"),NA,AgeInt))
  
  # These are special cases that we would like to account for
  # eventually, but that we don't have a protocol for at this time.
  inputDB <- inputDB %>% filter(Measure != "Probable deaths")
  inputDB <- inputDB %>% filter(Measure != "Probable cases")
  inputDB <- inputDB %>% filter(Measure != "Confirmed deaths")
  inputDB <- inputDB %>% filter(Measure != "Confirmed cases")
  inputDB <- inputDB %>% filter(Metric != "Rate")
  inputDB <- inputDB %>% filter(Measure != "Tested")

  # Some tables
  inputDB %>% '$'(Sex) %>% table(useNA = "ifany")
  inputDB %>% '$'(Measure) %>% table(useNA = "ifany")
  inputDB %>% '$'(Metric) %>% table(useNA = "ifany")
  inputDB %>% '$'(Age) %>% table(useNA = "ifany") 
 
  # Remove duplicates
  n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
  sum(n)
  rmcodes <- inputDB %>% filter(n) %>% '$'(Code) %>% unique()
  inputDB <- inputDB %>% filter(!Code%in%rmcodes)

  # Drop NAs
  any(is.na(inputDB$Value))
  inputDB <- inputDB %>% filter(!is.na(Value))
  
  # Run checks
  run_checks(inputDB, ShortCodes = inputDB %>% '$'(Short) %>% unique())
  
  # If it's a partial build then swap out the data.
  if (!full){
    swap_codes  <- inputDB %>% '$'(Short) %>% unique()
    inputDB_old <- readRDS("Data/inputDB.rds")
    inputDB_old <- inputDB_old %>% 
      filter(!(Short %in% swap_codes))
    inputDB <- 
      bind_rows(inputDB_old,
                inputDB) %>% 
      sort_input_data()
  }
  
  # Save CSV
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix="",suffix=""))
  write_lines(header_msg, path = "Data/inputDB.csv")
  write_csv(inputDB, path = "Data/inputDB.csv", append = TRUE, col_names = TRUE)
  
  # Save rds
  saveRDS(inputDB, "Data/inputDB.rds")
  
  # ---------------------------------------------------
  # # replace subset with new load after Date correction
  # NOTE THIS WILL FAIL FOR REGIONS!!
  do_this <-FALSE
  if(do_this){
    inputDB <- swap_country_inputDB(inputDB, "ML")
  }
  # ----------------------------------------------------


}

