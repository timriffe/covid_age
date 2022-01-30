### Functions & settings ############################################

# prelims
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
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


# read in the log file, do we start a new one?
# # if it's Sunday then yes.
# new_log <- !(today() %>% weekdays()) == "Sunday" & 
#   (Sys.time() %>% hour()) < 8
# 
# log_section(paste(today(),"inputDB updates"), 
#             append = new_log, 
#             logfile = logfile)
# 
# log_section(paste(Sys.time(),"updates"),
#             append = TRUE,
#             logfile = logfile)

#source("R_checks/inputDB_check.R")
email <- Sys.getenv("email")
gs4_auth(email = email, 
         scopes = c("https://www.googleapis.com/auth/spreadsheets",
                    "https://www.googleapis.com/auth/drive"))
drive_auth(email = email,
           scopes = c("https://www.googleapis.com/auth/spreadsheets",
                      "https://www.googleapis.com/auth/drive"))

# these parameters to grab templates that were modified between 12 and 2 hours ago,
# a 10-hour window. This will be run every 8 hours, so this implies overlap.
# hours_from <- 175
# hours_to   <- 2


# which templates were updated within last hours_from hours?

# at least at first seems like Namibia gets passed over
# changed Short code to _NA but still. Check again in a few days.
# Until then always load Namibia.
rubric <- get_input_rubric()
# NAM    <- rubric %>% filter(Country == "Namibia")
# rubric <- get_rubric_update_window(hours_from, hours_to)
# rubric <- bind_rows(rubric, NAM)

if (nrow(rubric) > 0){
  # read in modified data templates (this is the slowest part)
  # rubric <- get_input_rubric()
  inputDB <- compile_inputDB(rubric, hours = Inf)
  
  data.table::fwrite(inputDB, file = here::here("Data","inputDBhold.csv"))
  # saveRDS(inputDB, here::here("Data","inputDBhold.rds"))
  # what data combinations have we read in?
  
  # TR: templateID is temporary:
  inputDB$templateID <- NULL
  
  # remove non-standard Measure:
  Measures <- c("Cases","Deaths","Tests","ASCFR","Vaccinations","Vaccination1","Vaccination2", "Vaccination3", "VaccinationBooster")
  measureCodes <- inputDB %>% 
    dplyr::filter(!Measure %in% Measures) %>% 
    mutate(reason = "Measure code")
  
  inputDB <- inputDB %>% 
    dplyr::filter(Measure %in% Measures)
  
  # remove non-standard Metric:
  Metrics <- c("Count","Fraction","Ratio")
  metricCodes <- inputDB %>% 
    dplyr::filter(!Metric %in% Metrics) %>% 
    mutate(reason = "bad Metric")
  
  inputDB <- inputDB %>% 
    dplyr::filter(Metric %in% Metrics)
  
  
  # remove non-standard Sex:
  Sexes <- c("m","f","b","UNK")
  sexCodes <- inputDB %>% 
    dplyr::filter(!Sex %in% Sexes)%>% 
    mutate(reason = "bad Sex code")
  
  inputDB <- inputDB %>% 
    dplyr::filter(Sex %in% Sexes)
  
  # filters: remove any code that has a duplicate entry
  # TR: this particular step is very slow to process.
  # There are quicker ways to do the filter, but to
  # both keep the discarded chunks and do the filter
  # we need a better strategy
  inputDB <- inputDB %>% 
    group_by(Code, Date, Sex, Age, Measure, Metric) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    group_by(Code, Date, Sex, Measure, Metric) %>% 
    mutate(keep = all(n == 1)) %>% 
    ungroup()
  
  # append this to failures later
  dups <- inputDB %>% 
    dplyr::filter(!keep) %>% 
    mutate(reason = "duplicate") %>% 
    dplyr::select(-n,-keep)
  
  # now for another filter
  inputDB <- inputDB %>% 
    dplyr::filter(keep) %>% 
    dplyr::select(-n, -keep)
  
  NAdates <- inputDB %>% 
    dplyr::filter(Date == "NA.NA.NA") %>% 
    mutate(reason = "NA dates")
  
  inputDB <- inputDB %>% 
    dplyr::filter(Date != "NA.NA.NA")
  
  
  # check for valid dates:
  inputDB <-
    inputDB %>% 
    mutate(keep = !is.na(dmy(Date))) %>% 
    ungroup()
  
  # save bad dates to append to failures
  badDates <- inputDB %>% 
    dplyr::filter(!keep) %>% 
    mutate(reason = "bad date") %>% 
    dplyr::select(-keep)
  
  # now for next filter
  inputDB <- inputDB %>% 
    dplyr::filter(keep) %>% 
    dplyr::select(-keep)


  # remove future dates
  inputDB <-
    inputDB %>% 
    mutate(keep = dmy(Date) <= today())
  
  futureDates <-
    inputDB %>% 
    dplyr::filter(!keep) %>% 
    mutate(reason = "future date") %>% 
    dplyr::select(-keep)
  
  inputDB <-
    inputDB %>%
    dplyr::filter(keep) %>% 
    select(-keep)
  # -------------------------------------- #

  inputDB_out <-
    inputDB %>% 
    sort_input_data() %>% 
    filter(!is.na(Value),
           !is.na(Region),
           !is.na(Country),
           !is.na(dmy(Date))) 
  
  # -------------------------------------- #
  inputDB_failures <- bind_rows(
    measureCodes,
    metricCodes,
    sexCodes,
    NAdates,
    badDates,
    futureDates,
    dups
  )
  
  
  data.table::fwrite(inputDB_out, file = here::here("Data","inputDB_internal.csv"))
  data.table::fwrite(inputDB_failures, file = here::here("Data","inputDB_failures.csv"))
  
  Sys.sleep(1)
  # public file, full precision.
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
  data.table::fwrite(as.list(header_msg), 
                     file = here::here("Data","inputDB.csv"))
  Sys.sleep(1)
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
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-thrice-weekly-inputDB-updates")
  taskscheduler_create(taskname = "COVerAGE-DB-thrice-weekly-inputDB-updates", 
                       rscript =  here::here("R","01_update_inputDB.R"), 
                       schedule = "WEEKLY",
                       days = c("SAT","TUE","THU"),
                       starttime = "23:07")
  # 
}

# library(taskscheduleR)
# taskscheduler_ls() %>% view()

schedule_this <- FALSE
if (schedule_this){
  # TR: note, if you schedule this, you should make sure it's not already scheduled
  # by someone else!
  
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-inputDB-updates-test")
  taskscheduler_create(taskname = "COVerAGE-DB-inputDB-updates-test", 
                       rscript =  here::here("R/01_update_inputDB.R"), 
                       schedule = "ONCE", 
                       starttime = "17:42")
  # 
}