# Latvia Epi-data 
## MK: Latvia data is collected manually in google drive sheet, deaths by age and cases by sex and age,
## the below link has the cases by age, total cases per day, and total deaths, tests as totals. 
## since these data are collected manually, i will keep this script just in case we moved to automated collection. 

## 12.08.2022: I extract the data before 13.05.2021 and append manually to Google Drive input template
## tip from Maxi: to copy the data to the drive:
## sheet_write(data, ss = ss_i, sheet = "database")

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# info country and N drive address

ctr          <- "Latvia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/Data_sources/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# main source: https://data.gov.lv/dati/lv/group/veseliba
## Source Website: https://data.gov.lv/dati/lv/dataset/covid-19/resource/d499d2f0-b1ea-4ba2-9600-2c701b03bd4a

data <- read_csv2("https://data.gov.lv/dati/dataset/f01ada0a-2e77-4a82-8ba2-09cf0cf90db3/resource/d499d2f0-b1ea-4ba2-9600-2c701b03bd4a/download/covid_19_izmeklejumi_rezultati.csv")

historicaldata <- data %>% 
  dplyr::select(Date = 'Datums',
                contains("Gadi"),
                Tests = 'TestuSkaits',
                Cases = 'ApstiprinataCOVID19InfekcijaSkaits',
                Deaths = "MirusoPersonuSkaits") %>% 
  dplyr::mutate(Date = ymd(Date)) %>% 
  dplyr::filter(Date < "2021-05-13") %>% 
  dplyr::mutate(across(.cols = -c("Date"), ~ as.double(.x)),
                across(.cols = -c("Date"), ~ replace_na(.x, 0)),
  ## conversion to cumsum value; since these are daily new values ## 
                across(.cols = -c("Date"), ~ cumsum(.x))) %>% 
  tidyr::pivot_longer(cols = -("Date"),
                      names_to = "Measure",
                      values_to = "Value") %>% 
  dplyr::filter(Measure != "ApstiprinatiVecGr_70GadiUnVairak") %>% # remove 70+ to avoid duplicates
  dplyr::mutate(Age = str_extract(Measure, "\\d+"),
                Measure = case_when(str_detect(Measure, "\\d+") ~ "Cases",
                                     TRUE ~ Measure),
                Age = case_when(is.na(Age) ~ "TOT",
                                TRUE ~ Age),
                AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                                   TRUE ~ 10L),
                Sex = "b",
                Metric = "Count",
                Date = ymd(Date),
                Date = ddmmyyyy(Date),
                Code = paste0("LV"),
                Country = "Latvia",
                Region = "All",
                Age = as.character(Age)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


## save the output to csv file and add manually to google drive input Template

write.csv(historicaldata, file = paste0(dir_n, ctr, "/HistoricalData.csv"))

## END ## 