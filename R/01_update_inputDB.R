### Functions & settings ############################################

# prelims
library(here)
change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
}

change_here("C:/Users/riffe/Documents/covid_age")
setwd(here())
startup::startup()
# always work with the most uptodate repository
repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = creds)

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
gs4_auth(email = "tim.riffe@gmail.com")
drive_auth(email = "tim.riffe@gmail.com")
# these parameters to grab templates that were modified between 12 and 2 hours ago,
# a 10-hour window. This will be run every 8 hours, so this implies overlap.
hours_from <- 12
hours_to   <- 2


# which templates were updated within last hours_from hours?
#rubric <- get_input_rubric()
rubric <- get_rubric_update_window(hours_from, hours_to)

if (nrow(rubric) > 0){
  # read in modified data templates (this is the slowest part)
  inputDB <- compile_inputDB(rubric, hours = Inf)
  
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
  # filters: remove any code that has a duplicate entry
  Measures <- c("Cases","Deaths","Tests","ASCFR")
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
  # filters: remove any code that has a duplicate entry
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
  # filters: remove any code that has a duplicate entry
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
  
  # -------------------------------------- #
  # now swap out data in inputDB files
  
  ids_new       <- with(inputDB, paste(Country,Region,Measure,Short))
  
  inputDB_prior <- readRDS(here("Data","inputDB.rds"))
  
  inputDB_out <-
    inputDB_prior %>% 
    mutate(checkid = paste(Country,Region,Measure,Short)) %>% 
    filter(!checkid %in% ids_new) %>% 
    select(-checkid) %>% 
    bind_rows(inputDB) %>% 
    sort_input_data()
  
  saveRDS(inputDB_out, here("Data","inputDB.rds"))
  
  #saveRDS(inputDB, here("Data","inputDB_i.rds"))
  
  # public file, full precision.
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
  write_lines(header_msg, path = here("Data","inputDB.csv"))
  write_csv(inputDB_out, path = here("Data","inputDB.csv"), append = TRUE, col_names = TRUE)
  
  # push logfile to github:
  library(usethis)
  library(git2r)
  
  repo <- git2r::repository(here())
  #init()
  source("~/.Rprofile")
  git2r::pull(repo,credentials = creds) 
  
  commit(repo, 
         message = "update inputDB logfile", 
         all = TRUE)
  
  git2r::push(repo,credentials = creds)
}
schedule_this <- FALSE
if (schedule_this){
  library(taskscheduleR)
  taskscheduleR::taskscheduler_delete("COVerAGE-DB-every-8-hour-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-every-8-hour-inputDB-updates", 
                       rscript = "C:/Users/riffe/Documents/covid_age/R/01_update_inputDB.R", 
                       schedule = "HOURLY", 
                       modifier = 8,
                       starttime = "3:06",
                       startdate = format(Sys.Date()+2, "%d/%m/%Y"))
  # 
}



