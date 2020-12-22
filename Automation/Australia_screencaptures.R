

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
  filter(Country == "Australia") %>% 
  dplyr::pull(Source)

#  
use_condaenv("coveragedb", required = TRUE)
conda_install(packages = "selenium")
py_run_string("import selenium")


py_file <- "C:/Users/riffe/Documents/covid_age/Automation/Australia_screencaptures.py"
source_python(file=py_file)
#py_run_file("Automation/Australia_screencaptures.py")

file_out <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Australia/Australia_demo_",today(),".png")
file.rename("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Australia/Australia_demo.png",
            file_out)

drive_put(media = file_out,
          path = googledrive::as_id(ss_db))

log_update("Australia",N = "captured")

schedule.this <- FALSE
if (schedule.this){
  library(taskscheduleR)
  taskscheduler_delete("COVerAGE-DB-Australia_screencaptures")
  taskscheduler_create(taskname = "COVerAGE-DB-Australia_screencaptures", 
                       rscript = "C:/Users/riffe/Documents/covid_age/Automation/Australia_screencaptures.R", 
                       schedule = "DAILY", 
                       starttime = format(Sys.time() + 61, "%H:%M"))
}




















# cases_url <- "https://www.health.gov.au/news/health-alerts/novel-coronavirus-2019-ncov-health-alert/coronavirus-covid-19-current-situation-and-case-numbers#cases-and-deaths-by-age-and-sex"
# 
# webshot(url = cases_url,
#         file = "Data/AustraliaTest.png",
#         vwidth = 500,
#         vheight = 2500, 
#         delay = 30)
# 
# 
# AUS_ACT_url <- "https://app.powerbi.com/view?r=eyJrIjoiZTY4NTI1NzQtYTBhYy00ZTY4LTk3NmQtYjBjNzdiOGMzZjM3IiwidCI6ImI0NmMxOTA4LTAzMzQtNDIzNi1iOTc4LTU4NWVlODhlNDE5OSJ9"
# 
# webshot(url = AUS_ACT_url,
#         file = "Data/AustraliaACTtest.png",
#         vwidth = 700,
#         vheight = 500, 
#         delay = 20)
# 
# 
# # Australia New South Wales:
# AUS_NSW_cases_csv <- "https://data.nsw.gov.au/data/dataset/3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf/resource/24b34cb5-8b01-4008-9d93-d14cf5518aec/download/confirmed_cases_table2_age_group.csv"
# 
# AUS_NSW_tests_csv <- "https://data.nsw.gov.au/data/dataset/793ac07d-a5f4-4851-835c-3f7158c19d15/resource/28730d42-675b-4573-ad71-8156313c73a1/download/pcr_testing_table2_age_group_agg.csv"
# 
# AUS_NSW_tests2_csv <- "https://data.nsw.gov.au/data/dataset/793ac07d-a5f4-4851-835c-3f7158c19d15/resource/eea464a4-ae89-4c97-8880-c00c0dc7031c/download/pcr_testing_table2_age_group.csv"
# 
# 
# # South Australia:
# AUS_SA_cases_html_table_url <- 
# "https://www.covid-19.sa.gov.au/home/dashboard/dashboard-table-data#covid-19-age"
# 
# # Queensland:
# 
# AUS_Q_cases_Age_Sex_table_url <- 
#   "https://www.qld.gov.au/health/conditions/health-alerts/coronavirus-covid-19/current-status/statistics"
# 
# # Victoria:
# # microdata: cases with diagnosis dates, gives time series
# AUS_Vic_cases_by_age <- "https://www.dhhs.vic.gov.au/ncov-covid-cases-by-age-group-csv"
# 
