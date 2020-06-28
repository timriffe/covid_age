library(here)
source(here("R","00_Functions.R"))


# --------------------- #
# pull from github first, in case there has been a fix
# or change.
startup::startup()
library(usethis)
library(git2r)

repo <- init()

git2r::pull(credentials = creds)

# --------------------- #


gs4_auth(email = "tim.riffe@gmail.com")

log_section("New build run!", append = FALSE)

log_section("Compile inputDB from Drive", append = TRUE)
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
  log_section("Filter valid Measure entries:", append = TRUE)
  cat("Valid Measures include:",paste(Measures,collapse=","), file = "buildlog.md", append = TRUE)
  cat("\n",sum(!n),"rows removed", file = "buildlog.md", append = TRUE)
}

# remove non-standard Metric:
# filters: remove any code that has a duplicate entry
Metrics <- c("Count","Fraction","Ratio")
n <- inputDB %>% pull(Metric) %>% `%in%`(Metrics)
# sum(n)
if (sum(!n) > 0){
  inputDB <- inputDB %>% filter(n)
  log_section("Filter valid Metric entries:", append = TRUE)
  cat("Valid Metrics include:",paste(Metrics,collapse=","), file = "buildlog.md", append = TRUE)
  cat("\n",sum(!n),"rows removed", file = "buildlog.md", append = TRUE)
}

# remove non-standard Sex:
# filters: remove any code that has a duplicate entry
Sexes <- c("m","f","b","UNK")
n <- inputDB %>% pull(Sex) %>% `%in%`(Sexes)
# sum(n)
if (sum(!n) > 0){
  inputDB <- inputDB %>% filter(n)
  log_section("Filter valid Sex entries:", append = TRUE)
  cat("Valid Sex values include:",paste(Sexes,collapse=","), file = "buildlog.md", append = TRUE)
  cat("\n",sum(!n),"rows removed", file = "buildlog.md", append = TRUE)
}


# filters: remove any code that has a duplicate entry
n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
# sum(n)
if (sum(n) > 0){
  rmcodes <- inputDB %>% filter(n) %>% pull(Code) %>% unique()
  inputDB <- inputDB %>% filter(!Code%in%rmcodes)
  if (length(rmcodes)>0){
    log_section("Duplicates detected. Following `Code`s removed:", append = TRUE)
    cat(paste(rmcodes, collapse = "\n"), file = "buildlog.md", append = TRUE)
  }
}

# does AgeInt add up to 105?

BadRange <-
  inputDB %>% 
  filter(!Age %in% c("TOT","UNK"),
         Sex != "UNK") %>% 
  group_by(Code, Sex, Metric, Measure) %>% 
  summarize(Range = sum(AgeInt)) %>% 
  filter(Range != 105)

if (nrow(BadRange) > 0){
  rmcodes <- BadRange %>% pull(Code) %>% unique()
  inputDB <- inputDB %>% filter(!Code%in%rmcodes)
  log_section("Following codes removed for ill-formed AgeInt entries (must sum to 105):", append = TRUE)
  cat(paste(rmcodes, collapse = "\n"), file = "buildlog.md", append = TRUE)
}



# --------------------- #

# public file, full precision.
header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
write_lines(header_msg, path = here("Data","inputDB.csv"))
write_csv(inputDB, path = here("Data","inputDB.csv"), append = TRUE, col_names = TRUE)

# localy binary
saveRDS(inputDB, here("Data","inputDB.rds"))

# ---------------------- #

# Harmonize Measure, Metric, and Scaling
source("R/02_harmonize_metrics.R")

# ---------------------- #

# Offset compilation is manual and separate for now.

# ---------------------- #

# Harmonize Age groups
source("R/04_harmonize_age_groups.R")

# ---------------------- #

# 05_quick_updates.R is not in use anymore

# ---------------------- #

# Build dashboards
source("R/06_data_dashes.R")

# ---------------------- #

# Coverage Map

source("R/08_coverage_map.R")

# ---------------------- #

# push to OSF

# Coverage Map
# getting 401 errors
#source("R/09_push_osf.R")

# ---------------------- #

# git commit artifacts
source("R/10_commit_files.R")



