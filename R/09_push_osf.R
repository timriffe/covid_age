
#install.packages("osfr")
source(here("R","00_Functions.R"))
library(osfr)
library(here)
library(lubridate)


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