

library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "US_California" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Region == "California")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# Get current data (to keep the tests)
Tests <-
  get_country_inputDB("US_CA") %>% 
  filter(Measure == "Tests") %>% 
  select(-Short)


# read in data by age
CAage_in <- 
  read_csv("https://data.ca.gov/dataset/590188d5-8545-4c93-a9a0-e230f0db7290/resource/339d1c4d-77ab-44a2-9b40-745e64e335f2/download/case_demographics_age.csv") 

CAage <-
  CAage_in %>% 
  mutate(Date = as_date(date)) %>% 
  select(-date, -case_percent, -deaths_percent, -ca_percent, Cases = totalpositive, Deaths = deaths) %>% 
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  filter(!is.na(Value)) %>% 
  mutate(Age = recode(age_group,
                      "0-17" = "0",
                      "18-49" = "18",
                      "50-64" = "50",
                      "65 and Older" = "65",
                      "Unknown" = "UNK"),
         Sex = "b",
         Country = "USA",
         Region = "California",
         Metric = "Count",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US_CA_",Date),
         AgeInt = case_when(Age == "0" ~ 18L,
                            Age == "18" ~ 32L,
                            Age == "50" ~ 15L,
                            Age == "65" ~ 30L,
                            Age == "UNK" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

# By Sex
CAsex_in <-
  read_csv("https://data.ca.gov/dataset/590188d5-8545-4c93-a9a0-e230f0db7290/resource/ee01b266-0a04-4494-973e-93497452e85f/download/case_demographics_sex.csv")  

CAsex <-
  CAsex_in%>% 
  mutate(Date = as_date(date)) %>% 
  select(Sex = sex, Cases = totalpositive2, Deaths = deaths, Date) %>% 
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  filter(!is.na(Value)) %>% 
  group_by(Date) %>% 
  mutate(Value = ifelse(Sex == "Unknown", sum(Value),Value)) %>% 
  ungroup() %>% 
  mutate(Sex = case_when(Sex == "Unknown"~ "b",
                         Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m"), 
         Country = "USA",
         Region = "California",
         Metric = "Count",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US_CA_",Date),
         Age = "TOT",
         AgeInt = NA_integer_)

# bind together
CAout <- bind_rows(CAage, CAsex, Tests) %>% 
  sort_input_data()

# push to drive

write_sheet(ss = ss_i,
            CAout,
            sheet = "database")

N <- nrow(CAage) + nrow(CAsex)
log_update(pp = ctr, N = N)

# store

storage_dir <- file.path(dir_n, "Data_sources",ctr)

if (!dir.exists(storage_dir)){
  dir.create(storage_dir)
}

data_source_1 <- file.path(storage_dir,paste0("/age_",today(), ".csv"))
data_source_2 <- file.path(storage_dir,paste0("/sex_",today(), ".csv"))

write_csv(CAage_in, path = data_source_1)
write_csv(CAsex_in, path = data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zip(zipfile = zipname, 
     files=data_source, 
     compression_level = 9,
     mode = "cherry-pick")

# clean up file chaff
file.remove(data_source)