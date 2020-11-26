# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("U:/gits/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("Automation/00_Functions_automation.R")

drive_auth(email = email)
gs4_auth(email = email)

VE_rubric <- get_input_rubric() %>% filter(Short == "VE")
ss_i  <- VE_rubric %>% dplyr::pull(Sheet)
ss_db <-  VE_rubric %>% dplyr::pull(Source)
# reading data from Montreal and last date entered 
db_drive <- read_sheet(ss_i,
                       sheet = "database")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

# reading data from the website 
r <- GET("https://covid19.patria.org.ve/api/v1/summary")
a <- content(r, "text", encoding = "ISO-8859-1")
b <- fromJSON(a)

r2 <- GET("https://covid19.patria.org.ve/api/v1/timeline")
a2 <- content(r2, "text", encoding = "ISO-8859-1")
b2 <- fromJSON(a2)

date_f <- b2 %>% 
  dplyr::pull(Date) %>% 
  max()

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

if (date_f > last_date_drive){

  db <- b$Confirmed$ByAgeRange %>% 
    bind_cols %>% 
    gather(key = age_g, value = Value) %>% 
    separate(age_g, c("Age", "res")) %>% 
    select(-res) %>% 
    bind_rows(tibble(Age = "TOT", 
                     Value = b$Confirmed$Count)) %>% 
    mutate(Sex = "b") %>% 
    bind_rows(tibble(Age = "TOT", 
                     Sex = c("f", "m"), 
                     Value = c(b$Confirmed$ByGender$female, b$Confirmed$ByGender$male))) %>% 
    mutate(Measure = "Cases") %>% 
    bind_rows(tibble(Age = "TOT", 
                     Sex = c("b"), 
                     Measure = "Deaths",
                     Value = b$Deaths$Count)) %>%
    mutate(Region = "All",
           Date = d,
           Country = "Venezuela",
           Code = paste0("VE", Date),
           AgeInt = case_when(Age == "TOT" ~ "", 
                              Age == "90" ~ "15",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 
  
  db
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(db,
               ss = ss_i,
               sheet = "database")
  log_update(pp = "Venezuela", N = nrow(db))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  temp <- tempfile(fileext = ".txt")
  writeLines(a, temp)
  drive_upload(
    temp,
    path = ss_db,
    name = paste0("VE", d, "_cases.txt"),
    overwrite = TRUE)
  unlink(temp)

} else {
  cat(paste0("no new updates so far, last date: ", date_f))
}


