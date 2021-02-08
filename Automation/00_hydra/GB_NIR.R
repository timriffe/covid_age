
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
library(lubridate)
library(RCurl)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}


# info country and N drive address
ctr          <- "GB_NIR" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/GB_NIR"
# dir_n_source <- "Data/GB_NIR"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Short == "GB_NIR")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# -----------------

today_n <- function(n = 0){
  today() + n
}

ddmmyyyy(today_n(),sep="")

for (i in 0:-5){ # <- looks like an emoji
  url_i <- paste0("https://www.health-ni.gov.uk/sites/default/files/publications/health/dd%20-%20", 
                  ddmmyyyy(today_n(i), 
                           sep = ""),
                  ".xlsx")
  url_ok <- url.exists(url_i)
  if (url_ok){
    url_excel <- url_i
    break
  }
}

excel_file <- file.path(dir_n_source, paste0("GB_NIR_deaths-",today_n(i),".xlsx"))
download.file(url_excel, destfile = excel_file)


# ----------------------

DeathsIN <- read_excel(excel_file, sheet = "Deaths")

# Format
Deaths <-
  DeathsIN %>% 
  mutate(Age = case_when(
    `Age Band` == "Aged 0 - 19" ~ "0",
    `Age Band` == "Aged 20 - 39" ~ "20",
    `Age Band` == "Aged 40 - 59" ~ "40",
    `Age Band` == "Aged 60 - 79" ~ "60",
    `Age Band` == "Aged 80 & Over" ~ "80",
    `Age Band` == "Not Known" ~ "UNK"
  ),
  Sex = recode(Gender,
               "M" = "m",
               "F" = "f",
               "U" = "UNK")) %>% 
  select(Date = `Date of Death`,
         Sex,
         Age,
         New = `Number of Deaths`) %>% 
  group_by(Date,Sex,Age) %>% 
  summarize(New = sum(New), .groups = "drop") %>% 
  tidyr::complete(Date, Age, Sex, fill = list(New = 0))  %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  ungroup() %>% 
  filter(!(Sex == "UNK" & Value == 0)) %>% 
  arrange(Date, Sex, Age) %>% 
  mutate(Date = as_date(Date)) %>% 
  mutate(Country = "Northern Ireland",
         Region = "All",
         Date = ddmmyyyy(Date),
         Code = paste0("GB_NIR_",Date),
         Metric = "Count",
         Measure = "Deaths",
         AgeInt = case_when(
           Age == "80" ~ 25L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 20L
         )) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

# -------------------------

NIR_drive_folder <- drive_ls(ss_db)

Cases_to_capture <- 
NIR_drive_folder %>% 
  filter(grepl(name, pattern = "GB_NIR_cases_"))

cases_have <- dir(dir_n_source) 
cases_have <-cases_have[grepl(cases_have,pattern = "GB_NIR_cases_")]

cases_to_download <- Cases_to_capture$name[!Cases_to_capture$name %in% cases_have]

if (length(cases_to_download) > 0){
  cases_to_download <-Cases_to_capture %>% 
    filter(name %in% cases_to_download)
  drive_download(cases_to_download,
                 file.path(dir_n_source,cases_to_download$name),
                 overwrite = TRUE)
  
  
  library(tabulizer)
  #locate_areas(file.path(dir_n_source,cases_to_download$name))
hm <- extract_tables(file.path(dir_n_source,cases_to_download$name),
                         area=list(c(60.99214, 1407.81605,  643.77291, 2559.99287)))

}
