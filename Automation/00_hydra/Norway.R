source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  # email <- "tim.riffe@gmail.com"
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr    <- "Norway"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
NO_dir <- paste0(dir_n, "Data_sources/", ctr, "/")

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# drive urls
rubric <- get_input_rubric() %>% 
  filter(Country == "Norway")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)
ss_db <- rubric %>% 
  dplyr::pull(Source)

# Read in current Norway data ####
##################################

# db_drive <- get_country_inputDB("NO") %>% 
#   select(-Short)

db_drive <- read_sheet("https://docs.google.com/spreadsheets/d/1b-vhrc3ZAW-Mp5FU31QI-1tRj3r0E5Ew-Nkb-fHqpmA/", 
                       sheet = "database") %>% 
  mutate(Date = dmy(Date))

# Detect files to capture ####
##############################

# Cases and Tests only from recent days, because these contain
# longer time series.
check_dates <- seq(today()-7,today(),by="days")

case_urls <- paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_msis_by_time_sex_age_",as.character(check_dates),".csv")

skip_to_next <- TRUE
for (l in rev(case_urls)){
  tryCatch({
    print(l)
    db_c <- read_csv(l)
  }, error=function(e){ skip_to_next <<- FALSE})
  
  if(skip_to_next) { break } 
}


test_urls <- paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_lab_by_time_",as.character(check_dates),".csv")
skip_to_next <- TRUE
for (l in rev(test_urls)){
  tryCatch({
    print(l)
    db_t <- read_csv(l)
  }, error=function(e){ skip_to_next <<- FALSE})
  
  if(skip_to_next) { break } 
}

death_dates <- seq(ymd("2020-06-01"), today(),by="days")
db_d_all <- tibble()

for (i in 1:length(death_dates)){
  skip_to_next <- FALSE
  tryCatch({
    print(death_dates[i])
    db_d <- read_csv(paste0("https://raw.githubusercontent.com/folkehelseinstituttet/surveillance_data/master/covid19/data_covid19_demographics_",as.character(death_dates[i]),".csv"))
  }, error=function(e){ skip_to_next <<- TRUE})
  if(skip_to_next) { next } 
  db_d_all <- db_d_all %>% 
    bind_rows(db_d %>%
    mutate(Date = death_dates[i])) 
}

# do some preliminary formatting ####
###########################################################
db_c2 <-
  db_c %>% 
  mutate(Age = recode(age,
      "0-9" = "0",
      "10-19" = "10",
      "20-29" = "20",
      "30-39" = "30",
      "40-49" = "40",
      "50-59" = "50",
      "60-69" = "60",
      "70-79" = "70",
      "80-89" = "80",
      "90+" = "90"),
      Sex = case_when(sex == "male" ~ "m",
                      sex == "female" ~ "f",
                      sex == "total" ~ "b",
                      TRUE ~ "o")) %>% 
  arrange(Sex, Age, date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(Date = date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Cases",
         AgeInt = ifelse(Age == "90", 15, 10))

# Total Tests
db_t2 <-
  db_t %>% 
  mutate(Age = "TOT",
         Sex = "TOT",
         n = n_pos + n_neg) %>% 
  arrange(date) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(Date = date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Tests",
         AgeInt = NA_real_)
  
# Deaths_in %>% 
#   group_by(Date, sex) %>% 
#   mutate(TOT = sum(n[age != "total"])) %>% 
#   filter(age == "total") %>% 
#   select(Date, sex, n, TOT) %>% 
#   View()

get_zero <- function(chunk){
  if (!"0" %in% chunk$Age){
    chunk <- chunk %>% 
    slice(1) %>% 
    mutate(Age = "0",
           Value = 0) %>% 
    bind_rows(chunk)
  }
  chunk
}

db_d2 <-
  db_d_all %>% 
  rename(Value = n) %>% 
  mutate(Age = recode(age,
                      "0-39" = "0",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80-89" = "80",
                      "90+" = "90",
                      "total" = "TOT"),
         Sex = recode(sex,
                      "male" = "m",
                      "female" = "f",
                      "total" = "b")) %>% 
  group_by(Sex, Date) %>% 
  do(get_zero(chunk = .data)) %>% 
  ungroup() %>% 
  arrange(Date, Sex, Age) %>% 
  select(Date,
         Sex,
         Age, 
         Value) %>% 
  mutate(Country = "Norway",
         Region = "All",
         Metric = "Count",
         Measure = "Deaths",
         AgeInt = case_when(Age == "0" ~ 40L,
                            Age == "90" ~15L,
                            Age == "TOT" ~ NA_integer_,
                            TRUE ~ 10L)) %>% 
  filter(Age != "TOT")

# Merge files, create more columns ####
#######################################

captured <- 
  db_d2 %>% 
  bind_rows(db_c2) %>% 
  bind_rows(db_t2) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("NO",Date)) 

# bind data, only keeping Deaths prior to just-captured deaths ####
# treat cases and tests as completely refreshing
###########################################################

dates_db_c2 <- db_c2 %>% 
  dplyr::pull(Date) %>% 
  unique()

dates_db_t2 <- db_t2 %>% 
  dplyr::pull(Date) %>% 
  unique()

dates_db_d2 <- db_d2 %>% 
  dplyr::pull(Date) %>% 
  unique()

db_drive2 <- db_drive %>%
  filter(!(Date %in% dates_db_d2 & Measure == "Deaths"),
         !(Date %in% dates_db_c2 & Measure == "Cases"),
         !(Date %in% dates_db_t2 & Measure == "Tests")) %>% 
  mutate(Value = as.double(Value)) 

out <- 
  bind_rows(db_drive2, db_d2, db_c2, db_t2) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("NO",Date)) %>% 
  sort_input_data() %>% 
  unique()

# Push to Drive ####
####################

#write_sheet(out,
#            ss_i,
#            sheet = "database")

############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))



N <- nrow(out) - nrow(db_drive)
log_update(pp = "Norway", N = N)


# log source files ####
#######################

data_source_1 <- paste0(dir_n, 
                        "Data_sources/", 
                        ctr,
                        "/NO_deaths.csv")

data_source_2 <- paste0(dir_n, 
                        "Data_sources/", 
                        ctr,
                        "/NO_cases.csv")

data_source_3 <- paste0(dir_n, 
                        "Data_sources/", 
                        ctr,
                        "/NO_tests.csv")

write_csv(db_d_all, data_source_1)
write_csv(db_c, data_source_2)
write_csv(db_t, data_source_3)

data_source <- c(data_source_1, data_source_2, data_source_3)
#ex_files <- c(paste0(PH_dir, files))

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname,
          files = data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)


