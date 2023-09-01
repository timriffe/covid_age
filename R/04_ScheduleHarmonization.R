library(taskscheduleR)
taskscheduler_delete("COVerAGE-DB-harmonization")
taskscheduler_create(taskname = "COVerAGE-DB-harmonization", 
                     rscript =  here::here("R","04_harmonize_age_groups_changes.R"), 
                     schedule = "ONCE",
                     days = c("WED"),
                     starttime = "12:45")
