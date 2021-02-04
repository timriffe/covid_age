
#install.packages("osfr")
library(here)
source(here("R","00_Functions.R"))

# TR: let's start zipping, it's time. Can delete the .csv files after a while.
logfile <- here("buildlog.md")

log_section("push outputs to OSF", append = TRUE, logfile = logfile)

files_data <- c("inputDB","Output_5","Output_10","qualityMetrics")
for (fl in files_data){
  zip::zip(here("Data",paste0(fl,".zip")), 
         files = file.path("Data",paste0(fl,".csv")), 
         compression_level = 9)
 Sys.sleep(2)
}

# Basic
# log_section("Push build to Data/Current folder on OSF", append = TRUE)
# move_to_current()
files_data_zipped <- paste0(files_data,".zip")


# Get directory on OSF
target_dir <- osf_retrieve_node("mpwjq") %>% 
  osf_ls_files(pattern = "Data") 

files <- here("Data",files_data_zipped)

# Push to OSF
for (i in 1:length(files)){
  osf_upload(target_dir,
             path = files[i],
             conflicts = "overwrite")  
  Sys.sleep(2)
}

################################################
# also copy rds files to N://COVerAGE-DB/Data
cdb_files <- c("inputDB.rds","inputDBhold.rds",
                "inputCounts.rds","Output_5.rds",
                "Output_10.rds","Offsets.rds")
files_from <- file.path("Data",cdb_files)

file.copy(from = files_from, to = "N://COVerAGE-DB/Data")


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