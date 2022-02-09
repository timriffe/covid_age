#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(lubridate)
# assigning Drive credentials in the case the script is verified manually 

#Im changing this to not use the change_here function, sourced from the functions script
#which I cant run due to problems installing demotools-JD
#change_here(wd_sched_detect())
#startup::startup()
#setwd(here())

#nz <- read_rds(paste0(dir_n, ctr, ".rds"))


if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "US_California" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# Drive urls
# rubric <- get_input_rubric() %>% 
#   filter(Region == "California")
# 
# ss_i <- rubric %>% 
#   dplyr::pull(Sheet)
# 
# ss_db <- rubric %>% 
#   dplyr::pull(Source)

# Get current data (to keep the tests)
Tests <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  filter(Measure == "Tests")


#saving data before source changed  
Prior_data <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Date = dmy(Date))%>%
  filter(Date <= "2021-01-24")%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."))

### data processing

#url1 <-"https://data.ca.gov/dataset/covid-19-time-series-metrics-by-county-and-state/resource/4d93df07-7c4d-4583-af53-03f950fe4365/download/6e8f6324-172d-4869-8e1f-662b998c576e#"

url1 <- "https://data.chhs.ca.gov/dataset/f333528b-4d38-4814-bebb-12db1f10f535/resource/e2c6a86b-d269-4ce1-b484-570353265183/download/covid19casesdemographics.csv"
CAage_in <- 
  read_csv(url1) 

# TR: from here down needs a redux for the new data format.
# (unless the )
CAage <-
  CAage_in %>% 
  mutate(Date = as_date(report_date)) %>%
  filter(demographic_category == "Age Group") %>%
  select(-report_date, -percent_cases, -percent_deaths, -percent_of_ca_population,-demographic_category, Cases = total_cases, Deaths = deaths, Age=demographic_value) %>% 
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  filter(!is.na(Value)) %>% 
  mutate(Age = recode(Age,
                      "0-17" = "0",
                      "18-49" = "18",
                      "50-64" = "50",
                      "65 and Older" = "65",
                      "65+" = "65",
                      "Unknown" = "UNK",
                      "Missing" = "UNK",
                      "missing" = "UNK",
                      "Total" = "TOT"),
         Sex = "b",
         Country = "USA",
         Region = "California",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0("US-CA"),
         AgeInt = case_when(Age == "0" ~ 18L,
                            Age == "18" ~ 32L,
                            Age == "50" ~ 15L,
                            Age == "65" ~ 30L,
                            Age == "UNK" ~ NA_integer_,
                            Age == "TOT" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

# By Sex

###updated data processing for new url

CAsex_in <-
  read_csv(url1) 

CAsex <-
  CAsex_in%>% 
  mutate(Date = as_date(report_date)) %>%
  filter(demographic_category== "Gender")%>%
  select(-report_date, -percent_cases, -percent_deaths, -percent_of_ca_population,-demographic_category, Cases = total_cases, Deaths = deaths, Sex=demographic_value) %>%  
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  filter(!is.na(Value),
         Sex != "Unknown") %>% 
  mutate(Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex== "Total" ~ "b"), 
         Country = "USA",
         Region = "California",
         Metric = "Count",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US-CA"),
         Age = "TOT",
         AgeInt = NA_integer_)%>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)



#vaccine data 

urlvaccine <- "https://data.chhs.ca.gov/dataset/e283ee5a-cf18-4f20-a92c-ee94a2866ccd/resource/faee36da-bd8c-40f7-96d4-d8f283a12b0a/download/covid19vaccinesadministeredbydemographics.csv"
CAvaccine_in <- 
  read_csv(urlvaccine)

vaccine=CAvaccine_in %>% 
  mutate(Date = as_date(administered_date)) %>%
  filter(demographic_category== "Age Group")%>%
  select(Date, Age=demographic_value, Vaccinations= cumulative_total_doses, Vaccination1=cumulative_at_least_one_dose, Vaccination2=cumulative_fully_vaccinated) %>% 
  pivot_longer(!Date &!Age, names_to = "Measure", values_to = "Value") %>% 
  filter(!is.na(Value)) %>% 
  mutate(Age = recode(Age,
                      "5-11" = "5",
                      "12-17" = "12",
                      "18-49" = "18",
                      "50-64" = "50",
                      "65+" = "65",
                      "Unknown Agegroup" = "UNK"),
         AgeInt = case_when(Age == "5" ~ 7L,
                            Age == "12" ~ 6L,
                            Age == "18" ~ 32L,
                            Age == "50" ~ 15L,
                            Age == "UNK" ~ NA_integer_,
                            Age == "65+" ~ 30L),
         Sex = "b",
         Country = "USA",
         Region = "California",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0("US-CA")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


# bind together 
CAout <- bind_rows(CAage, CAsex, Tests,vaccine,Prior_data) %>% 
  filter(Age != "Total") %>% 
  sort_input_data()%>% 
  mutate(Code = "US-CA")

n <- duplicated(CAout[,c("Date", "Sex","Age","Measure","Metric")]) 
CAout <- 
  CAout[!n, ]


# push to drive

# write_sheet(ss = ss_i,
#             CAout,
#             sheet = "database")
write_rds(CAout, paste0(dir_n, ctr, ".rds"))

N <- nrow(CAage) + nrow(CAsex)
log_update(pp = ctr, N = N)

# store


data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/age_sex",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_",today(), ".csv")

download.file(url1, destfile = data_source_1)
download.file(urlvaccine, destfile = data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)





###############################################################
#outdated code 

#vaccine data gets manually entered into drive sheet
#this can go now, there is an excel file now (03.06)
#Vaccine <-
#get_country_inputDB("US_CA") %>% 
#filter(Measure== "Vaccination1"| Measure== "Vaccination2"| Measure== "Vaccinations") %>%
#select(-Short)

#########################data processing prior 23.03.2021###############################################################
# read in data by age
#url1 <- "https://data.ca.gov/dataset/590188d5-8545-4c93-a9a0-e230f0db7290/resource/339d1c4d-77ab-44a2-9b40-745e64e335f2/download/case_demographics_age.csv"

#CAage <-
#CAage_in %>% 
#mutate(Date = as_date(date)) %>% 
#select(-date, -case_percent, -deaths_percent, -ca_percent, Cases = totalpositive, Deaths = deaths) %>% 
#pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
#filter(!is.na(Value)) %>% 
#mutate(Age = recode(age_group,
#"0-17" = "0",
#"18-49" = "18",
# "50-64" = "50",
# "65 and Older" = "65",
# "65+" = "65",
# "Unknown" = "UNK",
# "Missing" = "UNK"),
# Sex = "b",
# Country = "USA",
# Region = "California",
#Metric = "Count",
#Date = ddmmyyyy(Date),
# Code = paste0("US_CA_",Date),
# AgeInt = case_when(Age == "0" ~ 18L,
# Age == "18" ~ 32L,
# Age == "50" ~ 15L,
# Age == "65" ~ 30L,
# Age == "UNK" ~ NA_integer_)) %>% 
#select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
##############################################################################################

#########################data processing prior 23.03.2021##########################################################################
#url2 <- "https://data.ca.gov/dataset/590188d5-8545-4c93-a9a0-e230f0db7290/resource/ee01b266-0a04-4494-973e-93497452e85f/download/case_demographics_sex.csv"
#CAsex_in <-
#read_csv(url2)  

#CAsex <-
# CAsex_in%>% 
#mutate(Date = as_date(date)) %>% 
#select(Sex = sex, Cases = totalpositive2, Deaths = deaths, Date) %>% 
#pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
#filter(!is.na(Value)) %>% 
#group_by(Date) %>% 
#mutate(Value = ifelse(Sex == "Unknown", sum(Value),Value)) %>% 
#ungroup() %>% 
#mutate(Sex = case_when(Sex == "Unknown"~ "b",
#Sex == "Female" ~ "f",
#Sex == "Male" ~ "m"), 
# Country = "USA",
# Region = "California",
# Metric = "Count",
#Date = paste(sprintf("%02d",day(Date)),    
#sprintf("%02d",month(Date)),  
# year(Date),sep="."),
# Code = paste0("US_CA_",Date),
# Age = "TOT",
#AgeInt = NA_integer_)


# storage_dir <- file.path(dir_n, "Data_sources",ctr)
# 
# if (!dir.exists(storage_dir)){
#   dir.create(storage_dir)
# }
# 
# data_source_1 <- file.path(storage_dir,paste0("age_",today(), ".csv"))
# data_source_2 <- file.path(storage_dir,paste0("sex_",today(), ".csv"))

# write_csv(CAage_in, path = data_source_1)
# write_csv(CAsex_in, path = data_source_2)
##########################################################################################################################################