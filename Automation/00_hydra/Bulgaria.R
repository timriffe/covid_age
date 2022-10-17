
library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(httr)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "Bulgaria" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Bulgaria/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#Read in data archive

BGArchive <- read_rds(paste0(dir_n, ctr, ".rds"))

# # Drive urls
# rubric <- get_input_rubric() %>% 
#   filter(Country == "Bulgaria")
# 
# ss_i <- rubric %>% 
#   dplyr::pull(Sheet)
# 
# ss_db <- rubric %>% 
#   dplyr::pull(Source)
# 
# BGdrive <- get_country_inputDB("BG") %>% 
#   select(-Short)

# autodownloads happening in python from here:
# https://data.egov.bg/data/resourceView/8f62cfcf-a979-46d4-8317-4e1ab9cbd6a8?fbclid=IwAR2mla-loksQXfbhIw1BAOzyXxyupB9aQPkxXQOqb7yhHbUVmldOlhyjnfY
# button in lower left corner, specify csv. This one is the age-specific data

# Totals of various kinds:
# This one is the time series of totals
# https://data.egov.bg/data/resourceView/e59f95dd-afde-43af-83c8-ea2916badd19
totals_url        <- "https://data.egov.bg/resource/download/e59f95dd-afde-43af-83c8-ea2916badd19/csv"
deaths_age_url    <- "https://data.egov.bg/resource/download/18851aca-4c9d-410d-8211-0b725a70bcfd/csv"
cases_age_url     <- "https://data.egov.bg/resource/download/8f62cfcf-a979-46d4-8317-4e1ab9cbd6a8/csv"


date_i <- today() %>% as.character()

cases_local_name  <- paste0("bulgaria_cases_age_", date_i, ".csv")
deaths_local_name <- paste0("bulgaria_deaths_age_", date_i, ".csv")
totals_local_name <- paste0("bulgaria_totals_age_", date_i, ".csv")

# Let's start by downloading and archiving:

cases_local_path  <- file.path(dir_n, "Data_sources", ctr, cases_local_name)
deaths_local_path <- file.path(dir_n, "Data_sources", ctr, deaths_local_name)
totals_local_path <- file.path(dir_n, "Data_sources", ctr, totals_local_name)

# download csvs as-is, try a lot of times at random intervals until it works :-/

for (i in 1:100){
    try_i <- GET(cases_age_url, 
                 write_disk(cases_local_path,
                            overwrite = TRUE), 
                 verbose())
    if (status_code(try_i)!= 200){
    wait_i <- runif(1, min = 0, max = 500) %>% round()
    Sys.sleep(wait_i)
    next
  } else {
    break
  }
}

for (i in 1:100){
  try_i <- GET(deaths_age_url, 
               write_disk(deaths_local_path,
                          overwrite = TRUE), 
               verbose())
  if (status_code(try_i)!= 200){
    wait_i <- runif(1, min = 0, max = 500) %>% round()
    Sys.sleep(wait_i)
    next
  } else {
    break
  }
}


for (i in 1:100){
  try_i <- GET(totals_url, 
              write_disk(totals_local_path,
                         overwrite = TRUE), 
              verbose())
  if (status_code(try_i)!= 200){
    wait_i <- runif(1, min = 0, max = 500) %>% round()
    Sys.sleep(wait_i)
    next
  } else {
    break
  }
}


# all source files
data_source <- c(cases_local_path, deaths_local_path, totals_local_path)

# zip and archive:
zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)


# read in all three
BG_cases_in               <- read_csv(cases_local_path)
BG_deaths_in              <- read_csv(deaths_local_path)
BG_totals_in              <- read_csv(totals_local_path)

# ------------------------------------
# Translations
# -------------------------------------

# process case age data
colnames(BG_cases_in)[1] <- "Date"
BG_cases_out <- 
  BG_cases_in %>% 
  select(Date,`0 - 19`:ncol(.)) %>% 
  pivot_longer(2:ncol(.),names_to = "Age", values_to = "Value") %>% 
  mutate(Age = case_when(
    Age == "0 - 19" ~ "0",
    Age == "20 - 29" ~ "20",
    Age == "30 - 39" ~ "30",
    Age == "40 - 49" ~ "40",
    Age == "50 - 59" ~ "50",
    Age == "60 - 69" ~ "60",
    Age == "70 - 79" ~ "70",
    Age == "80 - 89" ~ "80",
    Age == "90+" ~ "90",
    TRUE ~ NA_character_),
    AgeInt = case_when(
      Age == "0" ~ 20L,
      Age == "90" ~ 15L,
      Age == "TOT" ~ NA_integer_,
      TRUE ~ 10L),
    Measure = "Cases",
    Metric = "Count",
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("BG"),
    Country = "Bulgaria",
    Region = "All",
    Sex = "b") %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
# process death age-sex data
colnames(BG_deaths_in ) <- c("Date","Sex","Age","Value")

all_ages <- c("0","12","15","17","20","30","40","50","60","70","80","90")


BG_deaths_in$Sex <- BG_deaths_in$Sex %>%  nchar()

BG_deaths_out <-
  BG_deaths_in %>% 
mutate(Sex = case_when(Sex =="3" ~ "m",
                                Sex == "4" ~ "f",
                                Sex == "1" ~ "UNK"),
         Age = case_when(Age == "-" ~ "UNK",
                         Age == "0 - 12" ~ "0",
                         Age == "12 - 14" ~ "12",
                         Age == "15 - 16" ~ "15",
                         Age == "17 - 19" ~ "17",
                         Age == "20 - 29" ~ "20",
                         Age == "30 - 39" ~ "30",
                         Age == "40 - 49" ~ "40",
                         Age == "50 - 59" ~ "50",
                         Age == "60 - 69" ~ "60",
                         Age == "70 - 79" ~ "70",
                         Age == "80 - 89" ~ "80",
                         Age == "90+" ~ "90")
        ) %>% 
  tidyr::complete(Age = all_ages, Sex, Date, fill = list(Value=0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(AgeInt = case_when(Age == "0" ~ 12L,
                            Age == "12" ~ 3L,
                            Age == "15" ~ 2L,
                            Age == "17" ~ 3L,
                            Age == "90+" ~ 15L,
                            TRUE ~ 10L),
          Measure = "Deaths",
          Metric = "Count",
          Date = ymd(Date),
          Date = paste(sprintf("%02d",day(Date)),    
                       sprintf("%02d",month(Date)),  
                       year(Date),sep="."),
          Code = paste0("BG"),
          Country = "Bulgaria",
          Region = "All")%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  


  
BG_TOT_out <-
  BG_totals_in %>% 
  select(Date = 1,
         Tests = 2,
         Cases = 4,
         Deaths = ncol(.)-1) %>% 
  pivot_longer(Tests:Deaths, names_to = "Measure", values_to = "Value") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         AgeInt = NA_integer_,
         Country = "Bulgaria",
         Region = "All",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("BG"),
         Metric = "Count"
         )

BG_out <- bind_rows(BG_cases_out,
                    BG_deaths_out,
                    BG_TOT_out) %>% 
  sort_input_data()

# In case we had earlier data, we keep it.
BG_out <- 
  BGArchive %>% 
  filter(dmy(Date) < min(dmy(BG_out$Date))) %>% 
  bind_rows(BG_out) %>% 
  sort_input_data()

# upload to Drive, overwrites
# write_sheet(BG_out, 
#             ss = ss_i, 
#             sheet = "database")


#moving data to N 

write_rds(BG_out, paste0(dir_n, ctr, ".rds"))


log_update("Bulgaria", N = nrow(BG_out))

# clean up locally downloaded files
file.remove(data_source)

# \_fin_/
