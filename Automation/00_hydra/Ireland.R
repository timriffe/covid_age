#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
# setwd(wd_sched_detect())
# here::i_am("covid_age.Rproj")
# startup::startup()

source(here::here("Automation/00_Functions_automation.R"))
library(readr)
library(tidyverse)
library(janitor)
library(rjson)


email <- Sys.getenv("email")


ctr          <- "Ireland" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

if (email == "tim.riffe@gmail.com"){
  gs4_auth(email = email, 
           scopes = c("https://www.googleapis.com/auth/spreadsheets",
                      "https://www.googleapis.com/auth/drive"))
  drive_auth(email = email,
             scopes = c("https://www.googleapis.com/auth/spreadsheets",
                        "https://www.googleapis.com/auth/drive"))
} else {
  # gs4_auth(email)
  # drive_auth(email)
  # Drive credentials
  drive_auth(email = Sys.getenv("email"))
  gs4_auth(email = Sys.getenv("email"))
}

## Source website for all Data <- "https://covid-19.geohive.ie/pages/helpfaqs#collapse25"

## Source website for vaccinations: https://covid-19.geohive.ie/datasets/0101ed10351e42968535bb002f94c8c6_0/about

## Source website for Booster vaccinations: https://covid-19.geohive.ie/datasets/2a4814b66d0d459cbb80dea30f61fbfe_0/about

cases_url_fat <- "https://opendata.arcgis.com/api/v3/datasets/67b8175576fe44e9ab193c4a5dc2ff9a_0/downloads/data?format=csv&spatialRefId=4326"
cases_url  <- "https://opendata.arcgis.com/api/v3/datasets/d8eb52d56273413b84b0187a4e9117be_0/downloads/data?format=csv&spatialRefId=4326"
vac_url    <- "https://opendata.arcgis.com/api/v3/datasets/0101ed10351e42968535bb002f94c8c6_0/downloads/data?format=csv&spatialRefId=4326"
boost_url  <- "https://opendata.arcgis.com/api/v3/datasets/2a4814b66d0d459cbb80dea30f61fbfe_0/downloads/data?format=csv&spatialRefId=4326"

# Deaths by age from web in a single chain
deaths_append <-
fromJSON(
  readLines(
    "https://services3.arcgis.com/dQsP3byyKkTT53Ep/arcgis/rest/services/deaths_extract/FeatureServer/0/query?f=json&cacheHint=true&groupByFieldsForStatistics=subcat&orderByFields=value%20ASC&outFields=*&outStatistics=%5B%7B%22onStatisticField%22%3A%22value%22%2C%22outStatisticFieldName%22%3A%22value%22%2C%22statisticType%22%3A%22sum%22%7D%5D&resultType=standard&returnGeometry=false&spatialRel=esriSpatialRelIntersects&where=(cat%3D%27Cumulative%27)%20AND%20(indicator%3D%27Age%27)%20AND%20(format%3D%27Deaths%27)")
  ) %>% 
  '[['("features") %>% 
  lapply(
    function(X){
    tibble(Age = X$attributes$subcat,
           Value = X$attributes$value)
  }) %>% 
    bind_rows() %>% 
  mutate(Age = case_when(Age == "<45" ~ "0",
                         Age == "45-64" ~ "45",
                         Age == "65-74" ~ "65",
                         Age == "75-84" ~ "75",
                         Age == "85+" ~ "85"),
         Sex = "b",
         Date = today() %>% ddmmyyyy(),
         Measure = "Deaths",
         AgeInt = case_when(Age == "0" ~ 45L,
                            Age == "45" ~ 20L,
                            Age == "65" ~ 10L,
                            Age == "75" ~ 10L,
                            Age == "85" ~ 20L))

# dIN <- read_csv(deaths_url)

cIN <- read_csv(cases_url)
# This is mainly cases, but we also get total deaths here
Cases <-
  cIN %>% 
  clean_names() %>% 
  select(date,
         TOT = total_confirmed_covid_cases,
         TOT_d = total_covid_deaths,
         TOT_m = male,
         TOT_f=female,
         UNK = unknown, 
          `0` = aged1to4,
          `5` = aged5to14,
          `15` = aged15to24,
          `25` = aged25to34,
          `35` = aged35to44,
          `45` = aged45to54,
          `55` = aged55to64,
          `65` = aged65to74,
          `75` = aged75to84,
          `85` = aged85up) %>% 
  drop_na() %>%
  pivot_longer(TOT:`85`, names_to = "Age", values_to = "Value") %>% 
  mutate(Date = date %>% as_date() %>% ddmmyyyy(),
         Sex = case_when(Age == "TOT_m" ~ "m",
                      Age == "TOT_f" ~ "f",
                      TRUE ~ "b"),
         Measure = ifelse(Age == "TOT_d", "Deaths","Cases"),
         Age = ifelse(Age %in% c("TOT_m","TOT_f","TOT_d"), "TOT",Age),
         AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                            Age == "0" ~ 5L,
                            Age == "85" ~20L,
                            TRUE ~ 10L)) %>% 
  select(-date) 

# Vaccines 1 (partial) and 2 (fully)

## MK 09.08.2022: 
## Short description: these data are weekly data by Age and by Sex
## the data have cumulative and weekly data; so we extract the cumulative
## added 80 + as AgeInt

vIN <- read_csv(vac_url)

Vaccinations1and2 <-
  vIN %>% 
  clean_names() %>% 
  select(week,  
         # m_TOT_bla = male,  
         # f_TOT_bla = female, 
         starts_with("par_cum"), starts_with("fully_cum")) %>% 
  pivot_longer(par_cum_age0to9:ncol(.), 
            names_to = c("Measure",NA,"Age"), 
            values_to = "Value",
            names_sep = "_") %>% 
  mutate(Measure = case_when(Measure == "par" ~ "Vaccination1",
                             Measure == "fully" ~ "Vaccination2"),
         Date = ISOweek::ISOweek2date(paste(week, "7", sep = "-")),
         Date = ddmmyyyy(Date),
         Age = gsub(Age, pattern = "age",replacement = ""),
         Age = case_when(Age == "0to9" ~ "0",
                         Age == "10to19" ~ "10",
                         Age == "20to29" ~ "20",
                         Age == "30to39" ~ "30",
                         Age == "40to49" ~ "40",
                         Age == "50to59" ~ "50",
                         Age == "60to69" ~ "60",
                         Age == "70to79" ~ "70",
                         Age == "na" ~ "UNK",
                         TRUE ~ Age),
         Sex = "b",
         AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                         #   Age == "70" ~ 35L,
                            Age == "80" ~ 25L,
                            TRUE ~ 10L)) %>% 
  select(-week)


bIN <- read_csv(boost_url)

Boosters <-
  bIN %>% 
  clean_names() %>% 
  select(epi_week, 
         m_TOT_bla = male, 
         f_TOT_bla = female, 
         UNK_TOT_bla = na, 
         ends_with("cum")) %>% 
  pivot_longer(m_TOT_bla:ncol(.),
               names_to = c("Sex","Age",NA), 
               names_sep = "_",
               values_to = "Value") %>% 
  mutate(Sex = case_when(Sex == "na" ~ "UNK",
                         Sex %in% c("im","ad") ~ "b",
                         TRUE ~ Sex)) %>% 
  group_by(epi_week, Sex, Age) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  mutate(
    Age = gsub(Age, pattern = "age", replacement = ""),
    Age = case_when(Age == "na" ~ "UNK",
                    Age == "0to9" ~ "0",
                    Age == "10to19" ~ "10",
                    Age == "20to29" ~ "20",
                    Age == "30to39" ~ "30",
                    Age == "40to49" ~ "40",
                    Age == "50to59" ~ "50",
                    Age == "60to69" ~ "60",
                    Age == "70to79" ~ "70",
                    TRUE ~ Age),
    AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                       #   Age == "70" ~ 35L,
                       Age == "80" ~ 25L,
                       TRUE ~ 10L),
    week = substr(epi_week,1,8),
         Date = ISOweek::ISOweek2date(paste(week, "7", sep = "-")),
         Date = ddmmyyyy(Date),
         # Date = dmy(paste(day, month, year, sep = "-")),
         # Date = ddmmyyyy(Date),
         Measure = "Vaccination3") %>% 
  select(Date, Sex, Age, Measure, Value, AgeInt) 



Everything <-
  bind_rows(deaths_append,
            Cases,
            Vaccinations1and2,
            Boosters) %>% 

  ungroup() %>% 
  mutate(Country = "Ireland",
         Region = "All",
         Metric = "Count") 

IE_in <- get_country_inputDB("IE")

Everything_new <-
  Everything %>% 
  dplyr::filter(Age != "TOT") %>% 
  select(Date, Measure, Sex) %>% 
  distinct()%>% 
  mutate(new = TRUE)


# inventory %>% 
#   select(Date, Measure, Sex)
Deaths_append <- 
  IE_in %>% 
  anti_join(Everything_new,
          by = c("Date","Measure","Sex"))
  
out <- bind_rows(Everything,
                        Deaths_append)

saveRDS(Everything, file = "N://COVerAGE-DB/Automation/Hydra/Ireland.rds")

log_update(pp = ctr, N = nrow(out)) 



#archive input data 

data_source_b <- paste0(dir_n, "Data_sources/", ctr, "/boosters_",today(), ".csv")
data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vaccinations_",today(), ".csv")
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")


write_csv(bIN, data_source_b)
write_csv(vIN, data_source_v)
write_csv(cIN, data_source_c)
write_csv(deaths_append, data_source_d)

data_source <- c(data_source_b, data_source_v,data_source_c, data_source_d )

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



