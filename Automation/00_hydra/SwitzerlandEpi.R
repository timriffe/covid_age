## Switzerland and Liechtenstein EPI-DATA 
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "SwitzerlandEpi" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## dataset for epi-data

## SOURCE of the datasets: https://www.covid19.admin.ch/en/epidemiologic/death

## Documentation of files description: https://www.covid19.admin.ch/api/data/documentation

## Variables definition: https://www.covid19.admin.ch/api/data/documentation/models/sources-definitions-weeklyincomingdata.md

epi_url <- "https://www.covid19.admin.ch/en/epidemiologic/death"

zip_all <- scraplinks(epi_url) %>% 
  filter(link == " Data as .csv file ") %>% 
  mutate(url = paste0("https://www.covid19.admin.ch", url)) %>% 
  dplyr::pull(url)

data_source_zip <- paste0(dir_n, "Data_sources/", ctr, "/SwitzerlandEpi",today(), ".zip")
download.file(zip_all, destfile = data_source_zip, mode = "wb")


## Reading the files of interest

data_source <- paste0(dir_n, "Data_sources/", ctr, "/SwitzerlandEpi",today())

unzipping <- unzip(data_source_zip, exdir = data_source)

raw_cases_age <- read_csv(paste0(data_source, "/data/COVID19Cases_geoRegion_AKL10_w.csv"))
raw_cases_sex <- read_csv(paste0(data_source, "/data/COVID19Cases_geoRegion_sex_w.csv"))

raw_tests_age <- read_csv(paste0(data_source, "/data/COVID19Test_geoRegion_AKL10_w.csv"))
raw_tests_sex <- read_csv(paste0(data_source, "/data/COVID19Test_geoRegion_sex_w.csv"))

raw_deaths_age <- read_csv(paste0(data_source, "/data/COVID19Death_geoRegion_AKL10_w.csv"))
raw_deaths_sex <- read_csv(paste0(data_source, "/data/COVID19Death_geoRegion_sex_w.csv"))



## Functions to process raw data & processed datasets by Age & by Sex 

## BY AGE

process_age <- function(tbl, measure_name){
  tbl %>% 
    dplyr::select(Age = altersklasse_covid19, 
                  Region = geoRegion,
                  YearWeek = datum,
                  Value = sumTotal) %>% 
    dplyr::filter(!Region %in% c("CH01", "CH02", "CH03", "CH04", "CH05", "CH06", "CH07", "CHFL")) %>% 
    dplyr::mutate(ISO_WEEK = str_replace(YearWeek,"^(\\d{4})(\\d{2})$", "\\1-W\\2-7"),
                  Date = ISOweek::ISOweek2date(ISO_WEEK),
                  Age = str_extract(Age, "\\d+"),
                  Age = case_when(is.na(Age) ~ "UNK",
                                  TRUE ~ Age),
                  AgeInt = case_when(Age == "80" ~ 25L,
                                     Age == "UNK" ~ NA_integer_,
                                     TRUE ~ 10L),
                  Country = case_when(Region == "FL" ~ "Liechtenstein",
                                      TRUE ~ "Switzerland"),
                  Code = case_when(Region == "CH" ~ paste0("CH"),
                                   Region == "FL" ~ paste0("LI"),
                                   TRUE ~ paste0("CH-", Region)), 
                  Region = case_when(Region == "CH" ~ "All",
                                     Region == "FL" ~ "All",
                                     TRUE ~ Region)) %>% 
    dplyr::mutate(Metric = "Count",
                  Measure = measure_name,
                  Date = ddmmyyyy(Date),
                  Sex = "b") %>% 
    dplyr::select(Country, Region, Code, Date, Sex, 
                  Age, AgeInt, Metric, Measure, Value)
  
  
}

## Processed datasets by Age 

processed_cases_age <- raw_cases_age %>% process_age("Cases")
processed_deaths_age <- raw_deaths_age %>% process_age("Deaths")
processed_tests_age <- raw_tests_age %>% process_age("Tests")


## BY SEX: 

process_sex <- function(tbl, measure_name){
  tbl %>% 
    dplyr::select(Sex = sex, 
                  Region = geoRegion,
                  YearWeek = datum,
                  Value = sumTotal) %>% 
    dplyr::filter(!Region %in% c("CH01", "CH02", "CH03", "CH04", "CH05", "CH06", "CH07", "CHFL")) %>% 
    dplyr::mutate(ISO_WEEK = str_replace(YearWeek,"^(\\d{4})(\\d{2})$", "\\1-W\\2-7"),
                  Date = ISOweek::ISOweek2date(ISO_WEEK),
                  Sex = case_when(Sex == "male" ~ "m",
                                  Sex == "female" ~ "f",
                                  Sex == "unknown" ~ "UNK"),
                  Country = case_when(Region == "FL" ~ "Liechtenstein",
                                      TRUE ~ "Switzerland"),
                  Code = case_when(Region == "CH" ~ paste0("CH"),
                                   Region == "FL" ~ paste0("LI"),
                                   TRUE ~ paste0("CH-", Region)),
                  Region = case_when(Region == "CH" ~ "All",
                                     Region == "FL" ~ "All",
                                     TRUE ~ Region)) %>% 
    dplyr::mutate(Metric = "Count",
                  Measure = measure_name,
                  Age = "TOT",
                  AgeInt = NA_integer_,
                  Date = ddmmyyyy(Date)) %>% 
    dplyr::select(Country, Region, Code, Date, Sex, 
                  Age, AgeInt, Metric, Measure, Value)
  
  
}


## Processed datasets by Sex 

processed_cases_sex <- raw_cases_sex %>% process_sex("Cases")
processed_deaths_sex <- raw_deaths_sex %>% process_sex("Deaths")
processed_tests_sex <- raw_tests_sex %>% process_sex("Tests")


## MERGE ALL DATASETS AND OUT PREPARATION 

out <- bind_rows(processed_cases_age,
                 processed_cases_sex,
                 processed_deaths_age,
                 processed_deaths_sex,
                 processed_tests_age,
                 processed_tests_sex) %>% 
  sort_input_data()


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 


## we have the zip file downloaded, so we just remove the unzipped folder 

unlink(data_source, recursive = TRUE)


## END


