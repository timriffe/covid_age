source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()


# TR: let's start zipping, it's time. Can delete the .csv files after a while.
logfile <- here::here("buildlog.md")

log_section("push outputs to OSF", append = TRUE, logfile = logfile)

files_data <- c("inputDB","Output_5","Output_10","qualityMetrics") # TR: add quality metrics after it's vetted
for (fl in files_data){
  zip::zip(here::here("Data", paste0(fl,".zip")), 
         files = file.path("Data", paste0(fl,".csv")), 
         compression_level = 9)
 Sys.sleep(2)
}

# Basic
# log_section("Push build to Data/Current folder on OSF", append = TRUE)
# move_to_current()
files_data_zipped <- paste0(files_data, ".zip")


# Get directory on OSF

manual_osf <- TRUE
if (!manual_osf){

target_dir <- osf_retrieve_node("mpwjq") %>% 
  osf_ls_files(pattern = "Data") 

files <- here::here("Data", files_data_zipped)

# Push to OSF
for (i in 1:length(files)){
  osf_upload(target_dir,
             path = files[i],
             conflicts = "overwrite")  
  Sys.sleep(2)
}
}
# for (i in 1:length(files)){
#   osf_upload(target_dir,
#              path = files[i],
#              overwrite = TRUE)  
#   Sys.sleep(2)
# }
################################################
# also copy rds files to N://COVerAGE-DB/Data
cdb_files <- c("inputDB.csv","inputDB_internal.csv","inputDBhold.csv","inputDB_failures.csv",
                "inputCounts.csv","Output_5.csv","Output_5_internal.csv",
                "Output_10.csv","Output_10_internal.csv","Offsets.csv",
               "HarmonizationFailures.csv","qualityMetrics.csv") #a dd quality metrics later
files_from <- file.path("Data",cdb_files)

file.copy(from = files_from, 
          to = "N:/COVerAGE-DB/Data", 
          overwrite = TRUE)


# # On Friday's we archive the build.
# wkdy <- weekdays(today())
# 
# if (wkdy == "Friday"){
#   log_section("Archive build to Data/Archive on OSF", append = TRUE)
#   cat("Because it's Friday...\n", file = "buildlog.md")
#   archive_current()
# }

test.osf <- FALSE
if (test.osf){
  target_dir <- osf_retrieve_node("mpwjq") %>% 
    osf_ls_files(pattern = "Data") 
  
  write.csv(subset(iris, Species != "setosa"), file = "test.csv")
  
  target_dir %>%
    osf_upload("test.csv", conflicts = "overwrite")
  
  target_dir %>%
    osf_upload("test.csv", conflicts = "overwrite")
}