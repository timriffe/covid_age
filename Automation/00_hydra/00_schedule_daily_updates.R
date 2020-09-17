
# TR: modifying this script to assume we're working inside the repository, and are relative to it.
# should detect if it's tim, enrique, or diego.

auto_update_wd    <- here()

if (grepl("riffe", auto_update_wd)){
   auto_update_email <- '"tim.riffe@gmail.com"'   
}
if (grepl("acosta", auto_update_wd)){
        auto_update_email <- '"kikepaila@gmail.com"'
}

# we assume this tasks are scheduled in a here()-aware fashion


# broken scripts:
# CA_Montreal
# Mexico
# Sweden

# sched("Netherlands", "15:12")
# delete_sched("US_New_Jersey")

# broken:
sched("CA_Montreal", tm = "13:57",email = auto_update_email, wd = auto_update_wd)

sched("Colombia",  tm = "12:30",email = auto_update_email, wd = auto_update_wd)
sched("Venezuela", tm = "13:48",email = auto_update_email, wd = auto_update_wd)

# broken
sched("Slovenia", tm = "15:48",email = auto_update_email, wd = auto_update_wd)
sched("Germany", tm = "16:12",email = auto_update_email, wd = auto_update_wd)

# Massachussets no longer gives age, grr. Only weekly, with new counts for the past two weeks.
#sched("US_Massachusetts", tm = "17:04",email = auto_update_email, wd = auto_update_wd)

sched("Austria", tm = "18:50",email = auto_update_email, wd = auto_update_wd)
sched("US_Virginia", tm = "19:50",email = auto_update_email, wd = auto_update_wd)

# broken
sched("Mexico", tm = "20:50",email = auto_update_email, wd = auto_update_wd)

sched("US_NYC", tm = "22:38",email = auto_update_email, wd = auto_update_wd)
sched("USA_all_deaths", tm = "01:00",email = auto_update_email, wd = auto_update_wd)

sched("US_Texas", tm = "01:30",email = auto_update_email, wd = auto_update_wd)
sched("US_Wisconsin", tm = "02:10",email = auto_update_email, wd = auto_update_wd)
sched("US_Michigan", tm = "02:40",email = auto_update_email, wd = auto_update_wd)

# broken (works if manually sourced)
sched("Sweden", tm = "03:40",email = auto_update_email, wd = auto_update_wd)
#sched("Sweden", tm = "03:40",email = auto_update_email, wd = auto_update_wd)


sched("Netherlands", tm = "04:00",email = auto_update_email, wd = auto_update_wd)
sched("Estonia", tm = "04:31",email = auto_update_email, wd = auto_update_wd)

# TR: back to manual execution
#sched("New_Zealand", "18:20",email = auto_update_email, wd = auto_update_wd)
sched("Peru", tm = "05:31",email = auto_update_email, wd = auto_update_wd)
 # delete_sched("Austria")
 # delete_sched("CA_Montreal")
 # delete_sched("Colombia")
 # delete_sched("Estonia")
 # delete_sched("Germany")
 # delete_sched("Mexico")
 # delete_sched("Netherlands")
 # delete_sched("New_Zeland")
 # delete_sched("Peru")
 # delete_sched("Slovenia")
 # delete_sched("Sweden")
 # delete_sched("US_Massachusetts")
 # delete_sched("US_Michigan")
 # delete_sched("US_New_Jersey")
 # delete_sched("US_NYC")
 # delete_sched("US_Texas")
 # delete_sched("US_Virginia")
 # delete_sched("US_Wisconsin")
 # delete_sched("USA_all_deaths")
 # delete_sched("Venezuela")

# 
# taskscheduler_ls()
# 
# scripts <- c(
#   "Colombia",
#   "Germany",
#   "US_Massachusetts",
#   "Austria",
#   "US_Virginia",
#   "US_NYC",
#   "USA_all_deaths",
#   "CA_Montreal",
#   "US_Texas", 
#   "US_Wisconsin",
#   "US_Michigan",
#   "Sweden",
#   "Netherlands",
#   "Venezuela",
#   "New_Zeland"
# )
# 
### Delete all 
# for (sc in scripts){
#   print(sc)
#   delete_sched(sc)
# }
# 
# i <- 0
# for (sc in scripts){
#   print(sc)
#   t <- paste0("15:2", as.character(i))
#   sched(sc, t)
#   i <- i + 5
# }

# taskscheduler_delete(taskname = "usa_daily")
# myscript <- "U:/Projects/COVerAge-BD/automate_codes/US_wisconsin.R"
# taskscheduler_create(taskname = "wisconsin_daily", rscript = myscript,
#                      schedule = "DAILY", starttime = "12:16", startdate = "30/06/2020")
taskscheduler_ls()
