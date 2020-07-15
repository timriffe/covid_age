library(here)

# -------------------------------------- #
source(here("R","00_Functions.R"))

# ----------------------#
logfile <- here("buildlog.md")
# --------------------- #
# logfile = here("buildlog.md")

gs4_auth(email = "tim.riffe@gmail.com")

log_section("New build run!", 
            append = FALSE, 
            logfile = logfile)

log_section("Compile inputDB from Drive", 
            append = TRUE,
            logfile = logfile)
inputDB  <- compile_inputDB()

saveRDS(inputDB,here("Data","inputDBhold.rds"))
# --------------------- #

# remove non-standard Measure:
# filters: remove any code that has a duplicate entry
Measures <- c("Cases","Deaths","Tests","ASCFR")
n <- inputDB %>% pull(Measure) %>% `%in%`(Measures)
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
n <- inputDB %>% pull(Metric) %>% `%in%`(Metrics)
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
n <- inputDB %>% pull(Sex) %>% `%in%`(Sexes)
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
  rmcodes <- inputDB %>% filter(n) %>% pull(Code) %>% unique()
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

# does AgeInt add up to 105?

# BadRange <-
#   inputDB %>% 
#   filter(!Age %in% c("TOT","UNK"),
#          Sex != "UNK") %>% 
#   group_by(Code, Sex, Metric, Measure) %>% 
#   summarize(Range = sum(AgeInt)) %>% 
#   filter(Range != 105)
# 
# if (nrow(BadRange) > 0){
#   rmcodes <- BadRange %>% pull(Code) %>% unique()
#   inputDB <- inputDB %>% filter(!Code%in%rmcodes)
#   log_section("Following codes removed for ill-formed AgeInt entries (must sum to 105):", 
#               append = TRUE, 
#               logfile = logfile)
#   cat(paste(rmcodes, collapse = "\n"), 
#       file = logfile, 
#       append = TRUE)
# }



# --------------------- #

# public file, full precision.
header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
write_lines(header_msg, path = here("Data","inputDB.csv"))
write_csv(inputDB, path = here("Data","inputDB.csv"), append = TRUE, col_names = TRUE)

# localy binary
saveRDS(inputDB, here("Data","inputDB.rds"))

# ---------------------- #

# Harmonize Measure, Metric, and Scaling
source(here("R","02_harmonize_metrics.R"))

# ---------------------- #

# Offset compilation is manual and separate for now.

# ---------------------- #

# Harmonize Age groups
source(here("R","04_harmonize_age_groups.R"))

# ---------------------- #

# 05_quick_updates.R is not in use anymore

# ---------------------- #

# Build dashboards
# Temporarily disabled on hydra because default run
# doesn't have pandoc?
#source(here("R","06_data_dashes.R"))

# ---------------------- #

# Coverage Map

source(here("R","08_coverage_map.R"))

# ---------------------- #

# push to OSF

# Coverage Map
# getting 401 errors
#source(here("R","09_push_osf.R"))

# ---------------------- #

# git commit artifacts
source(here("R","10_commit_files.R"))

# ---------------------- #

# update build log / comminucations
source(here("R","11_email_and_tweet.R"))

