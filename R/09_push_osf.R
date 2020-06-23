
#install.packages("osfr")

library(osfr)
library(here)
library(lubridate)
coveragedb_project <- osf_retrieve_node("mpwjq")

# files_new = here("Data",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
# files_to_current =  here("Data","Current",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
# file.copy(from = files_new, to = files_to_current)

move_to_current <- function(){
  files_new = here("Data",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
  files_to_current =  here("Data","Current",c("offsets.csv","inputDB.csv","Output_5.csv","Output_10.csv"))
  file.copy(from = files_new, to = files_to_current, overwrite = TRUE)
}

push_current <- function(){
  osf_retrieve_node("mpwjq") %>% 
    osf_upload(path = "Data/Current",
               conflicts = "overwrite")
}

# This takes a few minutes.
# just do this every week or so.
archive_current <- function(){
  new_folder <- today() %>% as.character() %>% paste0("DB",.)
  utils::zip(here("Data","Archive",new_folder), 
             files = here("Data/Current",dir("Data/Current")))
  
  osf_retrieve_node("mpwjq") %>% 
    osf_upload(path = here("Data/Archive",paste0(new_folder,".zip")),
               conflicts = "overwrite")

}



# Basic
move_to_current()
push_current()

# zip(zipfile = 'testZip', files = 'testDir/test.csv')

# 
coveragedb_project %>% 
  osf_mkdir("Data")
  
osf_upload(coveragedb_project,
           path = c("Data/inputDB.csv","Data/offsets.csv"),
           conflicts = "overwrite")

coveragedb_project %>% 
  osf_ls_nodes()
