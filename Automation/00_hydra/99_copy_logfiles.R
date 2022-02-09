
# identify the folders
current.folder <- "U:/gits/covid_age/Automation/00_hydra/triggers"
new.folder <- "N:/COVerAGE-DB/Quality Checks/Automation_logfiles"
# find the files that you want
list.of.files <- list.files(current.folder, pattern = ".log",
                            full.names = TRUE)


# copy the files to the new folder
file.copy(list.of.files, new.folder, overwrite = TRUE)
