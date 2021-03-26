
library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "Bulgaria" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Bulgaria/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Country == "Bulgaria")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

BGdrive <- get_country_inputDB("BG") %>% 
  select(-Short)

# autodownloads happening in python from here:
# https://data.egov.bg/data/resourceView/8f62cfcf-a979-46d4-8317-4e1ab9cbd6a8?fbclid=IwAR2mla-loksQXfbhIw1BAOzyXxyupB9aQPkxXQOqb7yhHbUVmldOlhyjnfY
# button in lower left corner, specify csv. This one is the age-specific data

# Totals of various kinds:
# This one is the time series of totals
# https://data.egov.bg/data/resourceView/e59f95dd-afde-43af-83c8-ea2916badd19

# age_name_csv           <- "Разпределение по дата и по възрастови групи.csv"
# "BG_age_2020-12-15.csv"
BG_files <- dir(dir_n_source) 
♠BG_csvs <- 
  BG_files[grepl(BG_files,pattern = ".csv")] %>% 
  str_split(pattern = "-") %>% 
  do.call("rbind",.)

date_i <- BG_csvs[,2] %>% 
  gsub(pattern = ".csv",
       replacement = "") %>% 
  ymd() %>% 
  max(na.rm=TRUE) %>% 
  as.character() %>% 
  gsub(pattern = "-", replacement = "")

age_name_csv           <- paste0("BG_age-",date_i,".csv")

# Encoding(age_name_csv) <-"UTF-8"
age_file_path_csv      <- file.path(dir_n_source, age_name_csv)

# This sucessfully reads the file in, but column headers will be distorted:
tmp <- tempfile(fileext = ".csv", tmpdir = dir_n_source)
file.link(age_file_path_csv, tmp)
# BG_age_in              <- read_csv(tmp,
#                                    locale = readr::locale(encoding = "UTF-8"))
BG_age_in              <- read_csv(tmp)

# BG_age_in              <- read_csv(age_file_path_csv,
#                                    col_names = F) # Fails on Hydra
# totals_name_csv        <-"Обща статистика за разпространението.csv"
unlink(tmp)

totals_name_csv         <- paste0("BG_total-",date_i,".csv")

totals_file_path_csv   <- file.path(dir_n_source, totals_name_csv)
# 
# BG_TOT_in              <- read_csv(totals_file_path_csv)

tmp2 <- tempfile(fileext = ".csv",tmpdir = dir_n_source)
file.link(totals_file_path_csv, tmp2)
# BG_TOT_in              <- read_csv(tmp,
#                                    locale = readr::locale(encoding = "UTF-8"))
BG_TOT_in              <- read_csv(tmp2)
unlink(tmp2)
# list.files(dir_n_source, "*.csv")

print(4)

# ------------------------------------
# Translations
#"Дата"                     "Date"
#"Направени тестове"        "Tests"
#"Тестове за денонощие"     "New Tests"
#"Потвърдени случаи"        "Cases"
#"Активни случаи"           "Active cases"
#"Нови случаи за денонощие" "New cases"
#"Хоспитализирани"          "Hospitalized"
#"В интензивно отделение"   "ICU"
#"Излекувани"               "Recovered" 
#"Излекувани за денонощие"  "New recovered"
#"Починали"                 "Deaths"
#"Починали за денонощие"    "New deaths"
# -------------------------------------

# Now process the data

BG_cases_out <-
  BG_age_in %>% 
  pivot_longer(-1,
               names_to = "Age",
               values_to = "Value") %>% 
  rename('Date' = 1) %>% 
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
    TRUE ~ "TOT"),
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
    Code = paste0("BG",Date),
    Country = "Bulgaria",
    Region = "All",
    Sex = "b") %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  
BG_TOT_out <-
  BG_TOT_in %>% 
  select(Date = 1,
         Tests = 2,
         Cases = 4,
         Deaths = 11) %>% 
  pivot_longer(Tests:Deaths, names_to = "Measure", values_to = "Value") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         AgeInt = NA_integer_,
         Country = "Bulgaria",
         Region = "All",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("BG",Date),
         Metric = "Count"
         )

BG_out <- bind_rows(BG_cases_out,
                    BG_TOT_out)

# In case we had earlier data, we keep it.
BG_out <- 
  BGdrive %>% 
  filter(dmy(Date) < min(dmy(BG_out$Date))) %>% 
  bind_rows(BG_out) %>% 
  sort_input_data()

# upload to Drive, overwrites

write_sheet(BG_out, 
            ss = ss_i, 
            sheet = "database")

log_update("Bulgaria", N = nrow(BG_out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/totals_",today(), ".csv")

write_csv(BG_age_in, data_source_1)
write_csv(BG_TOT_in, data_source_2)

data_source <- c(data_source_1, data_source_2)

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

file.remove(data_source)

# This block isn't completed, and the above refreshing
# time series overrides it.
# single_day_append <- FALSE
# if (single_day_append){
# library(rvest)
# 
# BG_Cases_url <- "https://coronavirus.bg/bg/statistika"
# 
# page        <- read_html(BG_Cases_url) 
# tables      <- html_nodes(page, "table") 
# Cases_Age   <- html_table(tables[1], fill = TRUE)[[1]]
# 
# # Break apart header containing ref date
# DateBGsplit <- html_nodes(page, "h4") %>% 
#   html_nodes(xpath = "/html/body/main/div[1]/div/div/div[1]/p[2]") %>% 
#   html_text() %>% 
#   str_split(DateBG, pattern = " ") %>% 
#   unlist() 
# 
# # identify locations on may and year 
# dy <- 
#   DateBGsplit %>% 
#   as.integer() %>% 
#   is.na() %>% 
#   '!'() %>% 
#   which()
# 
# # extract the date elements
# DateParts <- DateBGsplit[dy[1]:dy[2]]
# 
# # identify the month nr
# bgmonths <- c("януари","февруари","март","април","май","юни","юли","август",
#               "септември","октомври","ноември","декември")
# this_month <- which(bgmonths == DateParts[2])
# 
# # construct incoming date
# date_in <- paste(DateParts[3],this_month,DateParts[1],sep="-") %>% 
#   as_date()
# 
# Cases_out <-
#   Cases_Age %>% 
#   mutate(Age = case_when(
#     Age == "0 - 19" ~ "0",
#     Age == "20 - 29" ~ "20",
#     Age == "30 - 39" ~ "30",
#     Age == "40 - 49" ~ "40",
#     Age == "50 - 59" ~ "50",
#     Age == "60 - 69" ~ "60",
#     Age == "70 - 79" ~ "70",
#     Age == "80 - 89" ~ "80",
#     Age == "90+" ~ "90",
#     TRUE ~ "TOT"),
#     AgeInt = case_when(
#       Age == "0" ~ 20L,
#       Age == "90" ~ 15L,
#       Age == "TOT" ~ NA_integer_,
#       TRUE ~ 10L),
#     Measure = "Cases",
#     Metric = "Count",
#     Date = date_in,
#     Date = paste(sprintf("%02d",day(Date)),    
#           sprintf("%02d",month(Date)),  
#           year(Date),sep="."),
#     Code = paste0("BG",Date),
#     Country = "Bulgaria",
#     Region = "All",
#     Sex = "b") %>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# }
# 
# 
