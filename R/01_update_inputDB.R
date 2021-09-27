### Functions & settings ############################################

# prelims
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

change_here(wd_sched_detect())

setwd(here::here())
startup::startup()
# always work with the most uptodate repository

repo <- git2r::repository(here::here())
#init()
a <- git2r::pull(repo,credentials = cred_token())
if (class(a)[1]=="try-error"){
  a <- try(git2r::pull(repo,credentials = cred_token()) )
}
if (class(a)[1]=="try-error"){
  a <- try(git2r::pull(repo,credentials = cred_token()) )
}

# Functions
source(here::here("R","00_Functions.R"))

logfile <- here::here("inputDB_compile_log.md")

# read in the log file, do we start a new one?
# if it's Sunday then yes.
new_log <- !(today() %>% weekdays()) == "Sunday" & 
  (Sys.time() %>% hour()) < 8

log_section(paste(today(),"inputDB updates"), 
            append = new_log, 
            logfile = logfile)

log_section(paste(Sys.time(),"updates"),
            append = TRUE,
            logfile = logfile)

#source("R_checks/inputDB_check.R")
email <- Sys.getenv("email")
gs4_auth(email = email)
drive_auth(email = email)

# these parameters to grab templates that were modified between 12 and 2 hours ago,
# a 10-hour window. This will be run every 8 hours, so this implies overlap.
hours_from <- 12
hours_to   <- 2


# which templates were updated within last hours_from hours?

# at least at first seems like Namibia gets passed over
# changed Short code to _NA but still. Check again in a few days.
# Until then always load Namibia.
rubric <- get_input_rubric()
NAM    <- rubric %>% filter(Country == "Namibia")
rubric <- get_rubric_update_window(hours_from, hours_to)
rubric <- bind_rows(rubric, NAM)

if (nrow(rubric) > 0){
  # read in modified data templates (this is the slowest part)
  # rubric <- get_input_rubric()
  inputDB <- compile_inputDB(rubric, hours = Inf)
  
  # EA: temporal fix while solving issue with additional columns in the InputDB.csv (12.08.2021)
  try(inputDB <- 
        inputDB %>% 
        select(-y))
  
  try(inputDB <- 
        inputDB %>% 
        select(-'2499'))
  
  # saveRDS(inputDB,here("Data","inputDBhold.rds"))
  # what data combinations have we read in?
  
  # EA: No need to paste "Country", "Region", as "Short" variable includes information of both.
  # Better to only use "Short", as there could be wrong spelling of Country names or regions
  # Added on 16.08.2021
  
  codesIN     <- with(inputDB, paste(Short, Measure)) %>% unique()
  
  # Read in previous unfiltered inputDB
  inputDBhold <- readRDS(here::here("Data","inputDBhold.rds"))
  
  # EA: temporal fix while solving issue with additional columns in the InputDB.csv (12.08.2021)
  try(inputDBhold <- 
        inputDBhold %>% 
        select(-y))
  
  try(inputDBhold <- 
        inputDBhold %>% 
        select(-'2499'))
  
  # remove any codes we just read in
  inputDBhold <- 
    inputDBhold %>% 
    mutate(checkid = paste(Short, Measure)) %>% 
    filter(!checkid %in% codesIN) %>% 
    select(-checkid)

  # bind on the data we just read in
  inputDBhold <- bind_rows(inputDBhold, inputDB) %>% 
    sort_input_data()
  
  # resave out to the full unfiltered inputDB.
  saveRDS(inputDBhold, here::here("Data","inputDBhold.rds"))
  
  # TR: this is temporary:
  inputDB$templateID <- NULL
  
  
  # remove non-standard Measure:
  Measures <- c("Cases","Deaths","Tests","ASCFR","Vaccinations","Vaccination1","Vaccination2")
  n <- inputDB %>% dplyr::pull(Measure) %>% `%in%`(Measures)
  # sum(n)
  if (sum(!n) > 0){
    inputDB <- inputDB %>% filter(n) 
    log_section("Filter valid Measure entries:", 
                append = TRUE, 
                logfile = logfile)
    cat("Valid Measures include:", paste(Measures, collapse = ","), 
        file = logfile, 
        append = TRUE)
    cat("\n",sum(!n),"rows removed", 
        file = logfile, 
        append = TRUE)
  }
  
  # remove non-standard Metric:
  Metrics <- c("Count","Fraction","Ratio")
  n <- inputDB %>% dplyr::pull(Metric) %>% `%in%`(Metrics)
  # sum(n)
  if (sum(!n) > 0){
    inputDB <- inputDB %>% filter(n)
    log_section("Filter valid Metric entries:", 
                append = TRUE, 
                logfile = logfile)
    cat("Valid Metrics include:",paste(Metrics,collapse=","), 
        file = logfile, 
        append = TRUE)
    cat("\n",sum(!n),"rows removed", 
        file = logfile, 
        append = TRUE)
  }
  
  # remove non-standard Sex:
  Sexes <- c("m","f","b","UNK")
  n <- inputDB %>% dplyr::pull(Sex) %>% `%in%`(Sexes)
  # sum(n)
  if (sum(!n) > 0){
    inputDB <- inputDB %>% filter(n)
    log_section("Filter valid Sex entries:", 
                append = TRUE, 
                logfile = logfile)
    cat("Valid Sex values include:",paste(Sexes,collapse=","), 
        file = logfile, 
        append = TRUE)
    cat("\n",sum(!n),"rows removed", 
        file = logfile, 
        append = TRUE)
  }
  
  # filters: remove any code that has a duplicate entry
  n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
  # sum(n)
  if (sum(n) > 0){
    rmcodes <- inputDB %>% filter(n) %>% dplyr::pull(Code) %>% unique()
    inputDB <- inputDB %>% filter(!Code%in%rmcodes)
    if (length(rmcodes)>0){
      log_section("Duplicates detected. Following `Code`s removed:", 
                  append = TRUE, 
                  logfile = logfile)
      cat(paste(rmcodes, collapse = "\n"), 
          file = logfile, 
          append = TRUE)
    }
  }
  
  n <- is.na(dmy(inputDB$Date))
  # sum(n)
  if (sum(n) > 0){
    rmcodes <- inputDB %>% filter(n) %>% dplyr::pull(Code) %>% unique()
    inputDB <- inputDB %>% filter(!Code%in%rmcodes)
    if (length(rmcodes)>0){
      log_section("Bad Dates detected. Following `Code`s removed:", 
                  append = TRUE, 
                  logfile = logfile)
      cat(paste(rmcodes, collapse = "\n"), 
          file = logfile, 
          append = TRUE)
    }
  }
  
  # remove future dates
  n <- dmy(inputDB$Date) > today()
  if (sum(n) > 0){
    rmcodes <- inputDB %>% filter(n) %>% dplyr::pull(Code) %>% unique()
    inputDB <- inputDB %>% filter(!Code%in%rmcodes)
    if (length(rmcodes)>0){
      log_section("Future Dates detected. Following `Code`s removed:", 
                  append = TRUE, 
                  logfile = logfile)
      cat(paste(rmcodes, collapse = "\n"), 
          file = logfile, 
          append = TRUE)
    }
  }
  
  # -------------------------------------- #
  # now swap out data in inputDB files
  
  ids_new       <- with(inputDB, paste(Country,Region,Measure,Short))
  
  inputDB_prior <- readRDS(here::here("Data","inputDB.rds")) %>% 
    mutate(Short = add_Short(Code,Date))
  
  # EA: temporal fix while solving issue with additional columns in the InputDB.csv
  try(inputDB_prior <- 
        inputDB_prior %>% 
        select(-'2499'))
  
  try(inputDB_prior <- 
        inputDB_prior %>% 
        select(-y))
  
  inputDB_out <-
    inputDB_prior %>% 
    mutate(checkid = paste(Country,Region,Measure,Short)) %>% 
    filter(!checkid %in% ids_new) %>% 
    select(-checkid) %>% 
    bind_rows(inputDB) %>% 
    sort_input_data()
  
  # TR: added 09.11.2020 because some people seem to reserve blocks in the database with NAs. hmm.
  inputDB_out <- 
    # inputDB %>% 
    inputDB_out %>% 
    filter(!is.na(Value),
           !is.na(Region),
           !is.na(Country),
           !is.na(dmy(Date))) 
  
  # inputDB_out <- 
  #   inputDB_out %>% 
  #   filter(Country != "1")
  
  saveRDS(inputDB_out, here::here("Data","inputDB.rds"))

  #saveRDS(inputDB, here("Data","inputDB_i.rds"))
  
  # public file, full precision.
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
  data.table::fwrite(as.list(header_msg), 
                     file = here::here("Data","inputDB.csv"))
  data.table::fwrite(inputDB_out, 
                     file = here::here("Data","inputDB.csv"), 
                     append = TRUE, col.names = TRUE)
  
  # push logfile to github:
  library(usethis)
  library(git2r)
  
  repo <- git2r::repository(here::here())
  #init()
  
  # make a couple attempts
  a <- git2r::pull(repo,credentials = cred_token())
  if (class(a)[1]=="try-error"){
    a <- try(git2r::pull(repo,credentials = cred_token()) )
  }
  if (class(a)[1]=="try-error"){
    a <- try(git2r::pull(repo,credentials = cred_token()) )
  }
  
  b <- git2r::status()
  if (length(b$unstaged) > 0){
    commit(repo, 
           message = "update inputDB logfile", 
           all = TRUE)
  }
  
  git2r::push(repo,credentials = cred_token())
}
schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  me.this.is.me <- Sys.getenv("USERNAME")
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-every-8-hour-inputDB-updates", 
                       rscript =  paste0(Sys.getenv("path_repo"), "/R/01_update_inputDB.R"), 
                       schedule = "HOURLY", 
                       modifier = 8,
                       starttime = "10:00",
                       startdate = format(Sys.Date(), "%m/%d/%Y"))
  # 
}

# library(taskscheduleR)
# taskscheduler_ls() %>% view()

schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  me.this.is.me <- Sys.getenv("USERNAME")
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates-test")
  taskscheduler_create(taskname = "COVerAGE-DB-every-8-hour-inputDB-updates-test", 
                       rscript =  paste0(Sys.getenv("path_repo"), "/R/01_update_inputDB.R"), 
                       schedule = "ONCE", 
                       starttime = "17:25",
                       startdate = format(Sys.Date(), "%m/%d/%Y"))
  # 
}
