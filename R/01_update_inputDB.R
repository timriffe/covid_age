### Functions & settings ############################################

# prelims
library(here)
change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
  source("~/.Rprofile")
}

me.this.is.me <- Sys.getenv("USERNAME")
change_here(paste0("C:/Users/",me.this.is.me,"/Documents/covid_age"))

setwd(here())
startup::startup()
# always work with the most uptodate repository


 creds <- structure(list(username = Sys.getenv("GITHUB_USER"), 
                         password = Sys.getenv("GITHUB_PASS")), 
                    class = "cred_user_pass")
repo <- git2r::repository(here())
#init()
a <- git2r::pull(repo,credentials = creds)
if (class(a)[1]=="try-error"){
  a <- try(git2r::pull(repo,credentials = creds) )
}
if (class(a)[1]=="try-error"){
  a <- try(git2r::pull(repo,credentials = creds) )
}


# Functions
source(here("R","00_Functions.R"))

logfile <- here("inputDB_compile_log.md")

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
  inputDB <- compile_inputDB(rubric, hours = Inf)
  # saveRDS(inputDB,here("Data","inputDBhold.rds"))
  # what data combinations have we read in?
  codesIN     <- with(inputDB, paste(Country, Region, Measure, Short)) %>% unique()
  
  # Read in previous unfiltered inputDB
  inputDBhold <- readRDS(here("Data","inputDBhold.rds"))
  
  # remove any codes we just read in
  inputDBhold <- 
    inputDBhold %>% 
    mutate(checkid = paste(Country, Region, Measure, Short)) %>% 
    filter(!checkid %in% codesIN) %>% 
    select(-checkid)
  
  # bind on the data we just read in
  inputDBhold <- bind_rows(inputDBhold, inputDB) %>% 
    sort_input_data()
  
  # resave out to the full unfltered inputDB.
  saveRDS(inputDBhold, here("Data","inputDBhold.rds"))
  
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
  
  inputDB_prior <- readRDS(here("Data","inputDB.rds")) %>% 
    mutate(Short = add_Short(Code,Date))
  
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
  
  saveRDS(inputDB_out, here("Data","inputDB.rds"))

  #saveRDS(inputDB, here("Data","inputDB_i.rds"))
  
  # public file, full precision.
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
  data.table::fwrite(as.list(header_msg), 
                     file = here("Data","inputDB.csv"))
  data.table::fwrite(inputDB_out, 
                     file = here("Data","inputDB.csv"), 
                     append = TRUE, col.names = TRUE)
  
  # push logfile to github:
  library(usethis)
  library(git2r)
  
  repo <- git2r::repository(here())
  #init()

  # make a couple attempts
  a <- try(git2r::pull(repo,credentials = creds) )
  if (class(a)[1]=="try-error"){
    a <- try(git2r::pull(repo,credentials = creds) )
  }
  if (class(a)[1]=="try-error"){
    a <- try(git2r::pull(repo,credentials = creds) )
  }
  commit(repo, 
         message = "update inputDB logfile", 
         all = TRUE)
  
  git2r::push(repo,credentials = creds)
}
schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-every-8-hour-inputDB-updates", 
                       rscript =  paste0("C:/Users/",me.this.is.me,"/Documents/covid_age/R/01_update_inputDB.R"), 
                       schedule = "HOURLY", 
                       modifier = 8,
                       starttime = "16:30",
                       startdate = format(Sys.Date(), "%d/%m/%Y"))
  # 
}



