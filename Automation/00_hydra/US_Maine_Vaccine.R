##Maine Vaccine

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "US_Maine_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

###pull data from Drive and write rds###
rubric <- get_input_rubric() %>% filter(Short == "US_ME")
ss_i <- rubric %>% 
  dplyr::pull(Sheet)
ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

In_drive <-  read_sheet(ss = ss_i, sheet = "database_vaccine") %>% 
  mutate(Code = "US-ME")


write_rds(In_drive, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(In_drive))
