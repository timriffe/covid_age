
#install.packages("osfr")
source(here("R","00_Functions.R"))
library(osfr)
library(here)
library(lubridate)

files_new = here("Data",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
# files_to_current =  here("Data","Current",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
# file.copy(from = files_new, to = files_to_current)

# osf_retrieve_node("5wup8")
osf_retrieve_node("mpwjq")

target_dir <- osf_retrieve_node("mpwjq") %>% 
    osf_ls_files(pattern = "Data") 
  
osf_upload(target_dir,
             path = files_new,
             conflicts = "overwrite")



# Basic
# log_section("Push build to Data/Current folder on OSF", append = TRUE)
# move_to_current()
push_current()



# # On Friday's we archive the build.
# wkdy <- weekdays(today())
# 
# if (wkdy == "Friday"){
#   log_section("Archive build to Data/Archive on OSF", append = TRUE)
#   cat("Because it's Friday...\n", file = "buildlog.md")
#   archive_current()
# }