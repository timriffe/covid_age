# 20210329 Update by Diego:
# Vaccination data was added recently; eg. 
# https://www.mass.gov/doc/weekly-covid-19-municipality-vaccination-report-march-18-2021/download
# And should be also collected. I followed the same worflow for adding vaccination
# data that I used for the Swedish script when they too adeed vaccine data

# 1. Preamble ---------------

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  # email <- "kikepaila@gmail.com"
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "US_Massachusetts"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#print(paste0("Starting data retrieval for US-MA..."))

# 2. Get data from the input rubric-----
# 
# rubric_i <- get_input_rubric() %>% filter(Short == "US_MA")
# ss_i <- rubric_i %>% dplyr::pull(Sheet)
# 
# reading data from Drive and last date entered 

db_drive <- read_rds(paste0(dir_n,ctr,".rds")) %>% 
  filter(Measure != "Cases",
         Measure != "Deaths")


db_drive_combs <- db_drive %>% 
  select(Date, Sex, Age, Measure) %>% 
  mutate(drive = 1)

# 3. Download latest web data -----

# 3.1. Cases and deaths =============
# 
# m_url <- "https://www.mass.gov/info-details/archive-of-covid-19-cases-in-massachusetts"
# 
# links <- 
#   scraplinks(m_url) %>% 
#   filter(str_detect(url, "raw-data")) %>% 
#   select(url) %>% 
#   mutate(p2 = str_locate(url, "/dow") - 1,
#          date = str_sub(url, 24, p2[,"start"]),
#          url2 = paste0("https://www.mass.gov", url))
# 
# links$date <- gsub("january", "01", links$date)
# links$date <- gsub("february", "02", links$date)
# links$date <- gsub("march", "03", links$date)
# links$date <- gsub("april", "04", links$date)
# links$date <- gsub("may", "05", links$date)
# links$date <- gsub("june", "06", links$date)
# links$date <- gsub("july", "07", links$date)
# links$date <- gsub("august", "08", links$date)
# links$date <- gsub("september", "09", links$date)
# links$date <- gsub("october", "10", links$date)
# links$date <- gsub("november", "11", links$date)
# links$date <- gsub("december", "12", links$date)
# links$date <- gsub("21-0", "21", links$date)
# 
# 
# links <- links %>% 
#   mutate(date_f = mdy(date))
# 
# # to download all previous dates
# # for(i in 1:nrow(links)){
# #   date <- links[i, 5] %>% dplyr::pull()
# #   data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".zip")
# #   # data_source <- paste0(dir_n, "Data_sources/", ctr, "/covid-19-dashboard-10-15-2020.zip")
# #   cases_url <- links[i, 4] %>% dplyr::pull()
# #   download.file(cases_url, destfile = data_source, mode="wb")
# # }
# 
# last_file <- 
#   links %>% 
#   arrange(desc(date_f)) %>% 
#   slice(1)
#   # group_by() %>% 
#   # filter(date_f == max(date_f)) %>% 
#   # ungroup() 
# 
# date <- 
#   last_file %>% 
#   dplyr::pull(date_f) 
# 
# url <- 
#   last_file %>% 
#   select(url2) %>% 
#   dplyr::pull()
# 
# # DIEGO UPDATE 20210115:
# # The data format change in the webiste. Up to Dec 2020the data file was a zip file with different
# # Excel files inside, but it seems that since Jan 2021, the download is a sinlge Excel sheet
# 
# # OLD CODE(2020) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # data_source <- 
# #   paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".zip")
# 
# # download.file(url, destfile = data_source, mode="wb")
# # 
# # data_source1 <- "CasesByAge.xlsx"
# # unzip(zipfile = data_source, files = data_source1, exdir=".")
# # age <- read_xlsx(data_source1)
# # 
# # data_source2 <- "CasesByDate.xlsx"
# # unzip(zipfile = data_source, files = data_source2, exdir=".")
# # cases_t <- read_xlsx(data_source2)
# # 
# # data_source3 <- "DateOfDeath.xlsx"
# # unzip(zipfile = data_source, files = data_source3, exdir=".")
# # deaths_t <- read_xlsx(data_source3)
# # 
# # file.remove(c(data_source1, data_source2, data_source3))
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# # NEW CODE ~~~~~~~~~~~~~
# data_source <- 
#   paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".xlsx")
# 
# download.file(url, destfile = data_source, mode="wb")
# 
# age <- read_xlsx(data_source, sheet = "CasesbyAge")
# cases_t <- read_xlsx(data_source, sheet = "Cases (Report Date)")
# deaths_t <- read_xlsx(data_source, sheet = "DateofDeath")
# 
# 
# #JD: Made adjustment here: Prev. code was not selecting all columns with age groups
# #Source prob. added columns later on
# 
# # age2 <- 
# #   age %>% 
# #   select(1:9) %>% 
# #   gather(-1, key = "Age", value = "Value") %>% 
# #   separate(Age, c("Age", "trash")) %>% 
# #   mutate(date_f = ymd(Date),
# #          Age = ifelse(Age == "Unknown", "UNK", Age),
# #          Sex = "b",
# #          Measure = "Cases") %>% 
# #   select(date_f, Sex, Age, Measure, Value) 
# 
# 
# age2 <- 
#   age %>% 
#   #select(1:9) %>% 
#   gather(-1, key = "Age", value = "Value") %>% 
#   #remove Values from the columns we dont need 
#   subset(Age != "Start Date")%>%
#   subset(Age != "End Date")%>%
#   subset(Age != "Average daily incidence rate per 100,000 (last 14 days)")%>%
#   #add AgeInt before separating age groups because of distinction between 0-4 and 0-19 
#   mutate(AgeInt = case_when(
#     Age == "0-4 years" ~ 5L,
#     Age == "0-19 years" ~ 20L,
#     Age == "5-9 years" ~ 5L,
#     Age == "10-14 years" ~ 5L,
#     Age == "15-19 years" ~ 5L,
#     Age == "80+ years" ~ 25L,
#     Age == "UNK" ~ NA_integer_,
#     TRUE ~ 10L))%>%
#   separate(Age, c("Age", "trash")) %>% 
#   mutate(date_f = ymd(Date),
#          Age = ifelse(Age == "Unknown", "UNK", Age),
#          Sex = "b",
#          Measure = "Cases") %>% 
#   select(date_f, Sex, Age, Measure, Value, AgeInt)
# 
# # c2 <- 
# #   cases_t %>% 
# #   rename(Value = "Positive Total") %>% 
# #   mutate(Sex = "b",
# #          Age = "TOT",
# #          date_f = ymd(Date),
# #          Measure = "Cases") %>% 
# #   select(date_f, Sex, Age, Measure, Value)
# 
# c2 <- 
#   cases_t %>% 
#   rename(Value = "Positive Total") %>% 
#   mutate(Sex = "b",
#          Age = "TOT",
#          date_f = ymd(Date),
#          Measure = "Cases",
#          AgeInt = case_when(Age == "TOT" | Age == "UNK" ~ NA_real_,
#                             TRUE ~ as.numeric(Age))) %>% 
#   select(date_f, Sex, Age, Measure, Value, AgeInt)
# 
# # d2 <- deaths_t %>% 
# #   rename(Value = "Confirmed Total",
# #          Date = "Date of Death") %>% 
# #   mutate(Sex = "b",
# #          Age = "TOT",
# #          date_f = ymd(Date),
# #          Measure = "Deaths") %>% 
# #   select(date_f, Sex, Age, Measure, Value)
# 
# d2 <- deaths_t %>% 
#   rename(Value = "Confirmed Total",
#          Date = "Date of Death") %>% 
#   mutate(Sex = "b",
#          Age = "TOT",
#          date_f = ymd(Date),
#          Measure = "Deaths",
#          AgeInt = case_when(Age == "TOT" | Age == "UNK" ~ NA_real_,
#                             TRUE ~ as.numeric(Age))) %>% 
#   select(date_f, Sex, Age, Measure, Value, AgeInt)
# 
# # db_all <- 
# #   bind_rows(age2, c2, d2) %>% 
# #   mutate(Country = "USA",
# #          Region = "Massachusetts",
# #          Date = paste(sprintf("%02d", day(date_f)),
# #                       sprintf("%02d", month(date_f)),
# #                       year(date_f), sep = "."),
# #          Code = paste0("US_MA", Date),
# #          Metric = "Count",
# #          AgeInt = case_when(Age == "0" ~ 20,
# #                             Age == "80" ~ 25,
# #                             Age == "TOT" | Age == "UNK" ~ NA_real_,
# #                             TRUE ~ 10)) %>% 
# #   arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
# #   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# db_all <- 
#   bind_rows(age2, c2, d2) %>% 
#   mutate(Country = "USA",
#          Region = "Massachusetts",
#          Date = paste(sprintf("%02d", day(date_f)),
#                       sprintf("%02d", month(date_f)),
#                       year(date_f), sep = "."),
#          Code = paste0("US-MA"),
#          Metric = "Count") %>% 
#   arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# db_all_combs <- 
#   db_all %>% 
#   select(Date, Sex, Age, Measure) %>% 
#   mutate(drive = 1)

# 3.2. Vaccine data =========

v_url <- "https://www.mass.gov/info-details/massachusetts-covid-19-vaccination-data-and-updates#weekly-covid-19-municipality-vaccination-data-"

v_links <-
  scraplinks(v_url) %>% 
  filter(str_detect(url, "weekly-covid-19-municipality-vaccination-report")) %>% 
  select(url) %>% 
  mutate(p2 = str_locate(url, "/dow") - 1,
         date = str_sub(url, 24, p2[,"start"]),
         url2 = paste0("https://www.mass.gov", url),
         date_f = mdy(date)) %>% 
    data.frame()

v_last_file <- 
  v_links %>% 
  arrange(desc(date_f)) %>% 
  slice(1)

v_date <- 
  v_last_file %>% 
  dplyr::pull(date_f) 

v_url <- 
  v_last_file %>% 
  select(url2) %>% 
  dplyr::pull()

# Get data

v_data_source <- 
  paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_vaccines_", v_date, ".xlsx")

download.file(v_url, destfile = v_data_source, mode="wb")

# Email conversation Diego-Jessica on 20210330
# Diego:
# There are several columns in the Massachussets data that could be interesting, 
# but I am not sure I should include in the data collection. I think that the column 
# “Individuals with at least one dose” would be equivalent to the code “Vaccination1” 
# I used when including Swedish vaccination data to the Coverage database. 
# The other candidate columns is “Fully vaccinated individuals” but this is not equivalent 
# to the “Vaccinated2” code since the J&J vaccine only requires one shot. 
# Should I only include the first column I mentioned?
# Jessica:
# at least one dose is Vaccination1. Fully vaccinated will be counted in Vaccination2, 
# even if it is only one dose. We defined that as “fully vaccinated, second dose” at 
# the beginning to include the one dose vaccines as well. 
# So please include both column. 

# Get by age but not sex
v_age <- read_xlsx(v_data_source, sheet = 2, skip = 1)
v_age[v_age == "*"] <- NA                 

v_age2 <-
  v_age %>% 
  select(
    Age = `Age Group`
    , Vaccination1 = `Individuals with at least one dose`
    , Vaccination2 = `Fully vaccinated individuals`
    ) %>% 
  # The data is given at the town level, so aggregate to State
  pivot_longer(-Age, names_to = "Measure", values_to = "Value") %>% 
  filter(Age != "Total") %>% 
  group_by(Age, Measure) %>% 
  summarise(Value = sum(as.numeric(Value), na.rm = T)) %>% 
  ungroup() %>% 
  mutate(
    Sex = "b"
    , date_f = ymd(v_date)
    , Age = gsub(" Years", "", Age)
    , Age_low = as.numeric(gsub("-","",  str_extract(Age, "^[0-9]+\\-")))
    , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
    , Age = ifelse(grepl("\\+", Age), str_extract(Age, "^[0-9]{2}"), Age_low)
    , AgeInt = ifelse(!is.na(Age_high), Age_high-Age_low+1, 105-as.numeric(Age))
    ) %>% 
  arrange(Measure, Age) %>% 
  select(date_f, Sex, Age, AgeInt, Measure, Value) 

# Get by sex but not age

# Note that sex == other is coded as unknown, after checking with Jessica on 
# 20210330

v_sex <- read_xlsx(v_data_source, sheet = 4, skip = 1)
v_sex[v_sex == "*"] <- NA

v_sex2 <- 
  v_sex %>% 
  select(
    Sex
    , Vaccination1 = `Individuals with at least one dose`
    , Vaccination2 = `Fully vaccinated individuals`
  ) %>% 
  # The data is given at the town level, so aggregate to State
  pivot_longer(-Sex, names_to = "Measure", values_to = "Value") %>% 
  filter(Sex != "Total") %>% 
  group_by(Sex, Measure) %>% 
  summarise(Value = sum(as.numeric(Value), na.rm = T)) %>% 
  ungroup() %>% 
  mutate(
    Age = "TOT"
    , date_f = ymd(v_date)
    # , Sex = ifelse(Sex == "Other", "UNK", Sex)
    , Sex = case_when(Sex == "Male" ~ "m",
                    Sex == "Female" ~ "f",
                    Sex == "Other" ~ "UNK")
  ) %>% 
  arrange(Measure, Age) %>% 
  select(date_f, Sex, Age, Measure, Value) 
 
# Format for export

out_vac <-
  bind_rows(v_sex2, v_age2) %>% 
  mutate(
    Country = "USA",
    Region = "Massachusetts",
    Date = paste(sprintf("%02d", day(date_f)),  sprintf("%02d", month(date_f)), year(date_f), sep = "."),
    Code = "US-MA",
    Metric = "Count",
  ) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  arrange(Measure)

# 4. Combine to existing data --------------

# Add cases

# db_drive2 <- 
#   db_drive %>% 
#   replace_na(list(drive = 2)) %>% 
#   filter(drive == 2,
#          Sex != "UNK",
#          Age != "UNK") %>% 
#   select(-drive)


out <- 
db_drive %>% 
  mutate(date_f = dmy(Date),
         Code = "US-MA") %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


# Add vaccines

# Find which values do not exist yet in table

new_vac <- with(out_vac, paste(Date, Sex, Age, Measure))
old_vac <- with(out, paste(Date, Sex, Age, Measure))

rows_to_add <- !new_vac %in% old_vac  
  
vac_data <- out_vac[rows_to_add, ]

out <- bind_rows(out, vac_data) 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#### uploading database to Google Drive 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# This command append new rows at the end of the sheet
# write_sheet(out,
#             ss = ss_i,
#             sheet = "database")

#log_update(pp = ctr, N = nrow(out))

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#### uploading database to Google Drive 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

write_rds(out, "N:/COVerAGE-DB/Automation/Hydra/US_Massachusetts.rds")

log_update(pp = "US_Massachusetts", N = nrow(out))
