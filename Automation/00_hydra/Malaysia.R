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


## SOURCE: Malaysia MOH GITHUB repo: https://github.com/MoH-Malaysia/covid19-public
###################################

# GEO PARAMETERS #
state_dist <- read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/linelist/param_geo.csv") %>% 
  dplyr::distinct(state, idxs)

# CASES & DEATHS ===============

## SOURCE: https://github.com/MoH-Malaysia/covid19-public/tree/main/epidemic/linelist

# CASES: LINELIST # ================

cases_url <- "https://moh-malaysia-covid19.s3.ap-southeast-1.amazonaws.com/linelist_cases.parquet"
cases_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-cases_linelist_",today(), ".parquet")

 
## DOWNLOAD CASES AND READ IN THE DATA ##

download.file(cases_url,
              destfile = cases_source,
              mode = "wb")

cases_linelist <- arrow::read_parquet(cases_source) 

## PLAN B: to download & read in the parquet file
#download.file(cases_url, destfile = "Data/malaysia_cases.parquet",method="libcurl")`
# arrow::read_parquet() worked after reinstalled like so in a fresh session: 
# Sys.setenv(ARROW_WITH_BROTLI = "ON")
# install.packages("arrow")
# cases_linelist <- arrow::read_parquet(cases_url) 

## WRNAGLING, ETC ##

## Purpose is to convert the linelist dataset into cumulative time series dataset, so:
## 1- we need to fill the gaps in between the dates 
## 2- we need to cumsum value. 

dates_f <- seq(min(cases_linelist$date), 
               max(cases_linelist$date), by = "day")


cases_linelist2 <- cases_linelist %>% 
  dplyr::mutate(age = as.character(age),
                male = as.character(male)) %>% 
  dplyr::mutate(Date = ymd(date),
                Age = if_else(age < 0, "UNK", age),
                Sex = if_else(male == "1", "m", "f")) %>% 
  dplyr::select(Date, Age, 
                Sex, state) %>% 
## Since the deaths data are only by State, and for the sake of consistency, 
## Cases are also will be by State, though District & other epi-data are available.
  dplyr::group_by(Date, Age, Sex, state) %>% 
  dplyr::count(name = "Value") %>% 
  dplyr::ungroup()  %>% 
  tidyr::complete(Sex, Age, state, Date=dates_f, fill=list(Value=0)) %>% 
  dplyr::group_by(Date, Age, Sex, state) %>% 
  dplyr::mutate(Value = cumsum(Value))
  
  
cases <- cases_linelist2 %>% 
    dplyr::left_join(state_dist, by = c("state" = "idxs")) %>% 
    dplyr::mutate(Country = "Malaysia",
                  AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                                     TRUE ~ 1L),
                  Code = paste0("MY-", 
                                str_pad(state, width=2, side="left", pad="0")),
                  Metric = "Count",
                  Measure = "Cases") %>% 
    dplyr::select(Country, Region = state.y, Code, 
                  Date, Sex, Age, AgeInt, 
                  Metric, Measure, Value)
  
  
  
  
# DEATHS: LINELIST # ================

deaths_url <- "https://moh-malaysia-covid19.s3.ap-southeast-1.amazonaws.com/linelist_deaths.parquet"
deaths_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-deaths_linelist_",today(), ".parquet")


## DOWNLOAD CASES AND READ IN THE DATA ##

download.file(deaths_url,
              destfile = deaths_source,
              mode = "wb")

deaths_linelist <- arrow::read_parquet(deaths_source)  

## WRNAGLING, ETC ##

deaths_linelist2 <- deaths_linelist %>% 
  dplyr::mutate(age = as.character(age),
         male = as.character(male)) %>%  
  dplyr::mutate(Date = ymd(date),
         Age = if_else(age < 0, "UNK", age),
         Sex = if_else(male == "1", "m", "f")) %>% 
  dplyr::group_by(Date, Age, Sex, Region = state) %>%
  dplyr::count(name = "Value") %>% 
  dplyr::ungroup() %>% 
  tidyr::complete(Sex, Age, Region, Date=dates_f, fill=list(Value=0)) %>% 
  dplyr::group_by(Date, Age, Sex, Region) %>% 
  dplyr::mutate(Value = cumsum(Value))


deaths <- deaths_linelist2 %>% 
  dplyr::left_join(state_dist, by = c("Region" = "state")) %>% 
  dplyr::mutate(Country = "Malaysia",
                AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                                   TRUE ~ 1L),
                Code = paste0("MY-", 
                              str_pad(idxs, width=2, side="left", pad="0")),
                Metric = "Count",
                Measure = "Deaths")  %>% 
  dplyr::select(Country, Region, Code, 
                Date, Sex, Age, AgeInt, 
                Metric, Measure, Value)


epiData_malaysia <- dplyr::bind_rows(cases, deaths) 


# Vaccination =======================================

# Vaccination data are available by age and by sex, separately, 
# and each has state (& district) level.
# we will use the age-specific data only and identify sex as 'b' for both

Vacc_age <- read.csv("https://github.com/MoH-Malaysia/covid19-public/raw/main/vaccination/vax_demog_age.csv") %>% 
  dplyr::select(-district)

# Vacc_sex <- read.csv("https://github.com/MoH-Malaysia/covid19-public/raw/main/vaccination/vax_demog_sex.csv") %>% 
#   dplyr::select(-district)
# 
# 
# Sex_vacc <- Vacc_sex %>% 
#   tidyr::pivot_longer(cols = -c("date", "state"),
#                       names_to = c("Measure", "Sex"),
#                       names_sep = "_",
#                       values_to = "Value") %>% 
#   dplyr::mutate(date = ymd(date),
#                 Measure = case_when(Measure == "partial" ~ "Vaccination1",
#                                     Measure == "full" ~ "Vaccination2",
#                                     Measure == "booster" ~ "Vaccination3",
#                                     TRUE ~ Measure),
#                 Sex = case_when(Sex == "female" ~ "f",
#                                 Sex == "male" ~ "m",
#                                 Sex == "missing" ~ "UNK",
#                                 TRUE ~ Sex)) %>% 
#   dplyr::select(Date = date, Region = state,
#                   Sex, Measure, Value) %>% 
#   dplyr::group_by(Date, Region, Sex, Measure) %>% 
#   dplyr::summarise(Value = sum(Value)) %>% 
#   dplyr::left_join(state_dist, by = c("Region" = "state")) %>% 
#   dplyr::mutate(Country = "Malaysia",
#                 Code = paste0("MY-", 
#                              str_pad(idxs, width=2, side="left", pad="0")),
#                Metric = "Count",
#                Age = NA_character_,
#                AgeInt = NA_integer_)  %>% 
#    dplyr::select(Country, Region, Code, 
#                 Date, Sex, Age, AgeInt,
#                 Metric, Measure, Value)



Age_Vacc <- Vacc_age %>% 
  tidyr::pivot_longer(cols = -c("date", "state"),
                      names_to = c("Measure"),
                      values_to = "Value")  %>% 
  dplyr::mutate(Measure = str_replace(Measure, "_", " ")) %>% 
  tidyr::separate(Measure,
                  into = c("Measure", "Age"),
                  sep = " ",
                  convert = TRUE) %>% 
  dplyr::mutate(date = ymd(date),
                Age = str_replace(Age, "_", "-"),
                Age = case_when(Age == "missing" ~ "UNK",
                                Age == "5-11" ~ "5",
                                Age == "12-17" ~ "12",
                                Age == "18-29" ~ "18",
                                Age == "30-39" ~ "30",
                                Age == "40-49" ~ "40",
                                Age == "50-59" ~ "50",
                                Age == "60-69" ~ "60",
                                Age == "70-79" ~ "70",
                                Age == "80" ~ "80"),
                AgeInt = case_when(
                  Age == "5" ~ 5L,
                  Age == "80" ~ 25L,
                  Age == "UNK" ~ NA_integer_,
                  TRUE ~ 10L),
                Measure = case_when(Measure == "partial" ~ "Vaccination1",
                                    Measure == "full" ~ "Vaccination2",
                                    Measure == "booster" ~ "Vaccination3",
                                    TRUE ~ Measure)) %>% 
  dplyr::select(Date = date, Region = state,
               Age, AgeInt, Measure, Value) %>% 
  dplyr::group_by(Date, Region, Age, AgeInt, Measure) %>% 
  dplyr::summarise(Value = sum(Value)) %>% 
  dplyr::left_join(state_dist, by = c("Region" = "state")) %>% 
  dplyr::mutate(Country = "Malaysia",
                Code = paste0("MY-", 
                              str_pad(idxs, width=2, side="left", pad="0")),
                Metric = "Count",
                Sex = "b")  %>% 
  dplyr::select(Country, Region, Code, 
                Date, Age, AgeInt, 
                Sex, Metric, Measure, Value)

# ## binding all vaccination data into one dataframe
# vacc_all <- Age_Vacc %>% 
#   dplyr::bind_rows(Sex_vacc)

## binding epi-data & vaccination data into one df

out <- epiData_malaysia %>% 
  dplyr::bind_rows(Age_Vacc)


############################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))

## Updating Hydra :)

log_update(pp = ctr, N = nrow(out))


#END

                   