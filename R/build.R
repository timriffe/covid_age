library(here)


# Set the time lag for reading in modified templates. 
# For now leave as-is.
hours <- Inf
# 
# # -------------------------------------- #
# source(here("R","00_Functions.R"))
# 
# # ----------------------#
# logfile <- here("buildlog.md")
# # --------------------- #
# # logfile = here("buildlog.md")
# 
# gs4_auth(email = "tim.riffe@gmail.com")
# 
# log_section("New build run!", 
#             append = FALSE, 
#             logfile = logfile)
# 
# log_section("Compile inputDB from Drive", 
#             append = TRUE,
#             logfile = logfile)
# 
# 
# inputDB  <- compile_inputDB(hours = hours)
# 
# 
# if (hours < Inf){
#   # What unique templates were loaded?
#   codesIN     <- with(inputDB, paste(Country,Region,Measure,Short)) %>% unique()
#     
#   # Read in previous unfiltered inputDB
#   inputDBhold <- readRDS(here("Data","inputDBhold.rds"))
#     
#   # remove any codes we just read in
#   inputDBhold <- 
#       inputDBhold %>% 
#       mutate(checkid = paste(Country,Region,Measure,Short)) %>% 
#       filter(!checkid %in% codesIN) %>% 
#       select(-checkid)
#     
#   # bind on the data we just read in
#   inputDBhold <- bind_rows(inputDBhold, inputDB)
#   
#   # resave out to the full unfltered inputDB.
#   saveRDS(inputDBhold, here("Data","inputDBhold.rds"))
#   # CAVEAT: if we meant to DELETE a subset in the data, it won't be captured by this.
# } else {
#   
#   # otherwise we must have compiled the whole thing
#   saveRDS(inputDB, here("Data","inputDBhold.rds"))
#   
#   # if hours = Inf only once a week, then we'd take care of deletions on that time scale.
# }
# 
# # TR: this is temporary:
# inputDB$templateID <- NULL
# 
# # --------------------- #
# 
# # remove non-standard Measure:
# # filters: remove any code that has a duplicate entry
# Measures <- c("Cases","Deaths","Tests","ASCFR")
# n <- inputDB %>% pull(Measure) %>% `%in%`(Measures)
# # sum(n)
# if (sum(!n) > 0){
#   inputDB <- inputDB %>% filter(n) 
#   log_section("Filter valid Measure entries:", 
#               append = TRUE, 
#               logfile = logfile)
#   cat("Valid Measures include:", paste(Measures, collapse = ","), 
#       file = logfile, 
#       append = TRUE)
#   cat("\n",sum(!n),"rows removed", 
#       file = logfile, 
#       append = TRUE)
# }
# 
# # remove non-standard Metric:
# # filters: remove any code that has a duplicate entry
# Metrics <- c("Count","Fraction","Ratio")
# n <- inputDB %>% pull(Metric) %>% `%in%`(Metrics)
# # sum(n)
# if (sum(!n) > 0){
#   inputDB <- inputDB %>% filter(n)
#   log_section("Filter valid Metric entries:", 
#               append = TRUE, 
#               logfile = logfile)
#   cat("Valid Metrics include:",paste(Metrics,collapse=","), 
#       file = logfile, 
#       append = TRUE)
#   cat("\n",sum(!n),"rows removed", 
#       file = logfile, 
#       append = TRUE)
# }
# 
# # remove non-standard Sex:
# # filters: remove any code that has a duplicate entry
# Sexes <- c("m","f","b","UNK")
# n <- inputDB %>% pull(Sex) %>% `%in%`(Sexes)
# # sum(n)
# if (sum(!n) > 0){
#   inputDB <- inputDB %>% filter(n)
#   log_section("Filter valid Sex entries:", 
#               append = TRUE, 
#               logfile = logfile)
#   cat("Valid Sex values include:",paste(Sexes,collapse=","), 
#       file = logfile, 
#       append = TRUE)
#   cat("\n",sum(!n),"rows removed", 
#       file = logfile, 
#       append = TRUE)
# }
# 
# 
# # filters: remove any code that has a duplicate entry
# n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
# # sum(n)
# if (sum(n) > 0){
#   rmcodes <- inputDB %>% filter(n) %>% pull(Code) %>% unique()
#   inputDB <- inputDB %>% filter(!Code%in%rmcodes)
#   if (length(rmcodes)>0){
#     log_section("Duplicates detected. Following `Code`s removed:", 
#                 append = TRUE, 
#                 logfile = logfile)
#     cat(paste(rmcodes, collapse = "\n"), 
#         file = logfile, 
#         append = TRUE)
#   }
# }
# 
# # TR: AgeInt checks are on the way out.
# 
# # Are Age and AgeInt consistent? (kind of slow)
# # inputDB <- as.data.table(inputDB)
# # inputDB[, consistent := check_age_seq(chunk = .SD), by=list(Code, Sex, Measure, Metric)]
# # 
# # rm_this <- inputDB[consistent == FALSE]
# # if (nrow(rm_this)>0){
# #   rmcodes <- rm_this %>% pull(Code) %>% unique()
# #   
# # 
# #   log_section("Inconsistent Age, AgeInt detected. Following `Code`s removed:", 
# #               append = TRUE, 
# #               logfile = logfile)
# #   cat(paste(rmcodes, collapse = "\n"), 
# #       file = logfile, 
# #       append = TRUE)
# # }
# # inputDB <- inputDB[, consistent := NULL]
# # BadRange <-
# #   inputDB %>% 
# #   filter(!Age %in% c("TOT","UNK"),
# #          Sex != "UNK") %>% 
# #   group_by(Code, Sex, Metric, Measure) %>% 
# #   summarize(Range = sum(AgeInt)) %>% 
# #   filter(Range != 105)
# # 
# # if (nrow(BadRange) > 0){
# #   rmcodes <- BadRange %>% pull(Code) %>% unique()
# #   inputDB <- inputDB %>% filter(!Code%in%rmcodes)
# #   log_section("Following codes removed for ill-formed AgeInt entries (must sum to 105):", 
# #               append = TRUE, 
# #               logfile = logfile)
# #   cat(paste(rmcodes, collapse = "\n"), 
# #       file = logfile, 
# #       append = TRUE)
# # }
# 
# 
# 
# # --------------------- #
# 
# # local binary
# if (hours < Inf){
#   # this is for partial builds (save complete inputDB, but also separately just the new stuff)
#   ids_new <- with(inputDB, paste(Country,Region,Measure,Short))
#   
#   inputDB_prior <- readRDS(here("Data","inputDB.rds"))
#   
#   inputDB_out <-
#   inputDB_prior %>% 
#     mutate(checkid = paste(Country,Region,Measure,Short)) %>% 
#     filter(!checkid %in% ids_new) %>% 
#     select(-checkid) %>% 
#     bind_rows(inputDB) %>% 
#     sort_input_data()
#   
#   saveRDS(inputDB_out, here("Data","inputDB.rds"))
#   
#   saveRDS(inputDB, here("Data","inputDB_i.rds"))
#   
#   # public file, full precision.
#   header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
#   write_lines(header_msg, path = here("Data","inputDB.csv"))
#   write_csv(inputDB_out, path = here("Data","inputDB.csv"), append = TRUE, col_names = TRUE)
#   
# } else {
#   # this toggled if it's a full build
#   
#   saveRDS(inputDB, here("Data","inputDB.rds"))
#   # public file, full precision.
#   header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix = "", suffix = ""))
#   write_lines(header_msg, path = here("Data","inputDB.csv"))
#   write_csv(inputDB, path = here("Data","inputDB.csv"), append = TRUE, col_names = TRUE)
# }

# ---------------------- #

# Harmonize Measure, Metric, and Scaling
source(here("R","02_harmonize_metrics.R"))

# ---------------------- #

# Offset compilation is manual and separate for now.

# ---------------------- #

# Harmonize Age groups
source(here("R","04_harmonize_age_groups.R"))

# ---------------------- #

# um, let's just do this Wed and Sun?
source(here("R","05_compile_metadata.R"))

# ---------------------- #

# Build dashboards
# Temporarily disabled on hydra because default run
# doesn't have pandoc?
source(here("R","06_data_dashes.R"))

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

