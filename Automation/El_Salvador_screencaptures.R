source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(reticulate)

# conda_create("coveragedb")
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)
ss_db <- get_input_rubric() %>% 
  filter(Country == "El Salvador") %>% 
  dplyr::pull(Source)

# use_python("C://Users//riffe//AppData//Local//R-MINI~1//envs//coveragedb//python.exe")
#  # conda_create("coveragedb")
#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "C:/Users/riffe/Documents/covid_age/Automation/El_Salvador_screencaptures.py"
# py_file <- "Automation/El_Salvador_screencaptures.py"
source_python(file=py_file)
#py_run_file("C:/Users/riffe/Documents/covid_age/Automation/US_AZ_screencaptures.py")
#py_run_file("Automation/US_AZ_screencaptures.py")

file_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/El_Salvador/El_Salvador_demo_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/El_Salvador/El_Salvador_demo.png",
            file_out)

drive_put(media = file_out,
          path = googledrive::as_id(ss_db))


log_update("El Salvador",N = "captured")
# document.querySelector("#ecb6c8f2-75e1-4a0f-aae4-87ebb7d0958b > div.ContentBlock__ContentWrapper-sizwox-2.haiZJd > div > div:nth-child(38) > div > div > div > div > svg")
# #ecb6c8f2-75e1-4a0f-aae4-87ebb7d0958b > div.ContentBlock__ContentWrapper-sizwox-2.haiZJd > div > div:nth-child(38) > div > div > div > div > svg
# /html/body/div[2]/div/div[1]/div[1]/div[1]/div/div/div/div[1]/div/div[38]/div/div/div/div/svg
#ecb6c8f2-75e1-4a0f-aae4-87ebb7d0958b > div.ContentBlock__ContentWrapper-sizwox-2.haiZJd > div > div:nth-child(38) > div > div > div > div > svg
schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-El_Salvador_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-El_Salvador_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/El_Salvador_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}



# webshot::webshot("https://e.infogram.com/_/fx5xud0FhM7Z9NS6qpxs?src=embed&v=1?parent_url=https%3A%2F%2Fcovid19.gob.sv%2F","test.pdf",delay=45)
