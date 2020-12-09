
library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "Afghanistan" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/Afghanistan"
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Country == "Afghanistan")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# read in current state of the data
AFin <- get_country_inputDB("AF") %>% 
  select(-Short)

dates_in  <- AFin %>% 
  dplyr::pull(Date) %>% 
  dmy() %>% 
  unique()

dates_in_strings <-
  AFin %>% 
  dplyr::pull(Date) %>% 
  gsub(pattern = "\\.", replacement = "") %>% 
  unique()

# what do we have so far?
files_have <- dir_n_source %>% 
  dir()

files_have <- files_have[!grepl(files_have, 
                                pattern = paste(dates_in_strings, 
                                                collapse="|"))]


files_Deaths <- files_have[grepl(pattern = "Death.txt",files_have)] 
files_tests  <- files_have[grepl(pattern = "Sample-test.txt",files_have)] 

if (length(files_Deaths) > 0){
  read_AF_deaths <- function(path){
  
  Date <- path %>% 
    str_split(pattern="/") %>% 
    unlist() %>% 
    rev() %>% 
    '['(1) %>% 
  gsub(pattern = " ", replacement = "") %>% 
    substr(1,8) %>% 
    dmy()
  
  incoming<-
  suppressWarnings(readLines(path)) %>% 
    gsub(pattern = ",years", replacement = "") %>% 
    str_split(pattern=",") %>% 
    unlist() %>% 
    '['(-1)
  
  incoming[!grepl(incoming,pattern="\\%")] %>% 
    matrix(ncol=4,byrow=TRUE,dimnames=list(NULL,c("Age","Cases","Hospitalizations","Deaths"))) %>% 
    '['(-1,) %>% 
    as_tibble() %>% 
    mutate(Age = recode(Age,
                        "0-9" = "0",
                        "10-19" = "10",
                        "20-29" = "20",
                        "30-39" = "30",
                        "40-49" = "40",
                        "50-59" = "50",
                        "60-69" = "60",
                        "70-79" = "70",
                        "80+" = "80",
                        "Total" = "TOT"),
           Cases = as.integer(Cases),
           Deaths = as.integer(Deaths)) %>% 
    select(-Hospitalizations) %>% 
    mutate(AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                              Age == "80" ~ 25L,
                              TRUE ~ 10L),
           Sex = "b",
           Date = Date) %>% 
    pivot_longer(Cases:Deaths,
                 names_to = "Measure",
                 values_to = "Value")
}
  
  read_AF_tests <- function(path){
    
    Date <- path %>% 
      str_split(pattern="/") %>% 
      unlist() %>% 
      rev() %>% 
      '['(1) %>% 
      gsub(pattern = " ", replacement = "") %>% 
      substr(1,8) %>% 
      dmy()
    
    Datec <-  paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep=".")
    tests <- 
      suppressWarnings(readLines(path)) %>% 
      str_split(pattern=" ") %>% 
      unlist() %>% 
      rev() %>% 
      '['(1) %>% 
      gsub(pattern = ",", replacement = "") %>% 
      as.integer()
    
    tibble(Country = "Afghanistan",
           Region = "All",
           Code = paste0("AF",Datec),
           Date = Datec, 
           Sex = "b", 
           Age = "TOT", 
           AgeInt = NA_integer_, 
           Metric = "Count",
           Measure = "Tests",
           Value = tests)
  }
  # Read in, filter down if necessary, finalize
  AutoCollected <-
    lapply(file.path(dir_n_source,files_Deaths), 
           read_AF_deaths) %>% 
    bind_rows() %>% 
    filter(!Date %in% dates_in) %>% 
    mutate(Country = "Afghanistan",
           Region = "All",
           Metric = "Count",
           Date = paste(sprintf("%02d",day(Date)),    
                        sprintf("%02d",month(Date)),  
                        year(Date),sep="."),
           Code = paste0("AF",Date)) %>% 
    select(all_of(colnames(AFin))) %>% 
    sort_input_data()
  
  Tests <- 
    lapply(file.path(dir_n_source,files_tests),
           read_AF_tests) %>% 
    bind_rows()
    
  # stick together
  AutoCollected <-
    AutoCollected %>% 
    bind_rows(Tests)
  # Append to Drive
  
  sheet_append(ss = ss_i, AutoCollected, sheet = "database")
  
  # update log
  N <- nrow(AutoCollected)
  log_update("Afghanistan", N)
  
  # save source data to archive
  
  data_source <- file.path(dir_n_source, files_Deaths)
  
  zipname <- paste0(dir_n, 
                    "Data_sources/", 
                    ctr,
                    "/", 
                    ctr,
                    "_data_",
                    today(), 
                    ".zip")
  
  zipr(zipname, 
       data_source, 
       recurse = TRUE, 
       compression_level = 9,
       include_directories = TRUE)
  
  
}







