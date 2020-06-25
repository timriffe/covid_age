
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

