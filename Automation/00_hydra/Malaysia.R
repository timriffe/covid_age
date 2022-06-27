# Created on: 27.06.2022

## README: Malaysia MOH is publishing the linelists in parquet format; 
## read_parquet is not reading URLs yet, so we will download the file first
## and then read using arrow::read_parquet()

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr <- "Malaysia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## Malaysia MOH GITHUB repo: https://github.com/MoH-Malaysia/covid19-public
###################################

# GEO PARAMS #
state_dist <- read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/linelist/param_geo.csv")

# CASES: LINELIST #

cases_url <- "https://moh-malaysia-covid19.s3.ap-southeast-1.amazonaws.com/linelist_cases.parquet"
cases_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-cases_linelist_",today(), ".parquet", ".zip")

 
## DOWNLOAD CASES AND READ IN THE DATA ##

download.file(cases_url,
              destfile = cases_source,
              mode = "wb")

cases_linelist <- arrow::read_parquet(cases_source)  

## WRNAGLING, ETC ##

cases_linelist2 <- cases_linelist %>% 
  mutate(age = as.character(age),
         male = as.character(male)) %>% 
  left_join(state_dist, by = c("state" = "idxs", 
                               "district" = "idxd")) %>% 
  select(-state, -district,
         Region = state.y, 
         District = district.y) %>% 
  mutate(Date = ymd(date),
         Age = if_else(age == "-1", "UNK", age),
         Sex = if_else(male == "1", "m", "f")) %>% 
  group_by(Date, Age, Sex, Region, District) %>%
  count(name = "Value") %>% 
  ungroup()
  
  
cases <- cases_linelist2 %>% 
  mutate(Country = "Malaysia",
         Age = case_when(Age == "<5" ~ "0",
                         Age == ">84" ~ "85",
                         TRUE ~ Age),
         AgeInt = case_when(Age == "0" ~ "5",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         AgeInt = as.integer(AgeInt),
         Code = "MY",
         Metric = "Count",
         Measure = "Cases") %>% 
# TODO: will work on regions codes tomorrow 
  select(Country, Region, District, 
         Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  
  
  
# DEATHS: LINELIST #

deaths_url <- "https://moh-malaysia-covid19.s3.ap-southeast-1.amazonaws.com/linelist_deaths.parquet"
deaths_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-deaths_linelist_",today(), ".parquet", ".zip")


## DOWNLOAD CASES AND READ IN THE DATA ##

download.file(deaths_url,
              destfile = deaths_source,
              mode = "wb")

deaths_linelist <- arrow::read_parquet(deaths_source)  

## WRNAGLING, ETC ##

deaths_linelist2 <- deaths_linelist %>% 
  mutate(age = as.character(age),
         male = as.character(male)) %>%  
  mutate(Date = ymd(date),
         Age = if_else(age == "-1", "UNK", age),
         Sex = if_else(male == "1", "m", "f")) %>% 
  group_by(Date, Age, Sex, Region = state) %>%
  count(name = "Value") %>% 
  ungroup()


deaths <- deaths_linelist2 %>% 
  mutate(Country = "Malaysia",
         Age = case_when(Age == "<5" ~ "0",
                         Age == ">84" ~ "85",
                         TRUE ~ Age),
         AgeInt = case_when(Age == "0" ~ "5",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         AgeInt = as.integer(AgeInt),
         Code = "MY",
         Metric = "Count",
         Measure = "deaths") %>% 
  # TODO: will work on regions codes tomorrow 
  select(Country, Region, 
         Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


malaysia <- bind_rows(cases, deaths)

# TO DO: Vaccination #
#BYE :)
  
  

























                   