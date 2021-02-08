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
drive_auth(email = email)
gs4_auth(email = email)

# data from the input rubric
rubric_i <- get_input_rubric() %>% filter(Short == "US_MA")
ss_i <- rubric_i %>% dplyr::pull(Sheet)

# reading data from Drive and last date entered 
db_drive <- get_country_inputDB("US_MA") 

db_drive_combs <- db_drive %>% 
  select(Date, Sex, Age, Measure) %>% 
  mutate(drive = 1)



m_url <- "https://www.mass.gov/info-details/archive-of-covid-19-cases-in-massachusetts"

links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "raw-data")) %>% 
  select(url) %>% 
  mutate(p2 = str_locate(url, "/dow") - 1,
         date = str_sub(url, 24, p2[,"start"]),
         url2 = paste0("https://www.mass.gov", url),
         date_f = mdy(date))

# to download all previous dates
################################
# for(i in 1:nrow(links)){
#   date <- links[i, 5] %>% dplyr::pull()
#   data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".zip")
#   # data_source <- paste0(dir_n, "Data_sources/", ctr, "/covid-19-dashboard-10-15-2020.zip")
#   cases_url <- links[i, 4] %>% dplyr::pull()
#   download.file(cases_url, destfile = data_source, mode="wb")
# }

last_file <- 
  links %>% 
  group_by() %>% 
  filter(date_f == max(date_f)) %>% 
  ungroup() 

date <- 
  last_file %>% 
  select(date_f) %>% 
  dplyr::pull()

url <- 
  last_file %>% 
  select(url2) %>% 
  dplyr::pull()

# DIEGO UPDATE 20210115:
# The data format change in the webiste. Up to Dec 2020the data file was a zip file with different
# Excel files inside, but it seems that since Jan 2021, the download is a sinlge Excel sheet

# OLD CODE(2020) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# data_source <- 
#   paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".zip")

# download.file(url, destfile = data_source, mode="wb")
# 
# data_source1 <- "CasesByAge.xlsx"
# unzip(zipfile = data_source, files = data_source1, exdir=".")
# age <- read_xlsx(data_source1)
# 
# data_source2 <- "CasesByDate.xlsx"
# unzip(zipfile = data_source, files = data_source2, exdir=".")
# cases_t <- read_xlsx(data_source2)
# 
# data_source3 <- "DateOfDeath.xlsx"
# unzip(zipfile = data_source, files = data_source3, exdir=".")
# deaths_t <- read_xlsx(data_source3)
# 
# file.remove(c(data_source1, data_source2, data_source3))
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# NEW CODE ~~~~~~~~~~~~~
data_source <- 
  paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", date, ".xlsx")

download.file(url, destfile = data_source, mode="wb")

age <- read_xlsx(data_source, sheet = "CasesbyAge")
cases_t <- read_xlsx(data_source, sheet = "Cases (Report Date)")
deaths_t <- read_xlsx(data_source, sheet = "DateofDeath")

age2 <- age %>% 
  select(1:9) %>% 
  gather(-1, key = "Age", value = "Value") %>% 
  separate(Age, c("Age", "trash")) %>% 
  mutate(date_f = ymd(Date),
         Age = ifelse(Age == "Unknown", "UNK", Age),
         Sex = "b",
         Measure = "Cases") %>% 
  select(date_f, Sex, Age, Measure, Value) 

c2 <- cases_t %>% 
  rename(Value = "Positive Total") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = ymd(Date),
         Measure = "Cases") %>% 
  select(date_f, Sex, Age, Measure, Value)
  
d2 <- deaths_t %>% 
  rename(Value = "Confirmed Total",
         Date = "Date of Death") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = ymd(Date),
         Measure = "Deaths") %>% 
  select(date_f, Sex, Age, Measure, Value)

db_all <- bind_rows(age2,
                      c2,
                      d2) %>% 
  mutate(Country = "USA",
         Region = "Massachusetts",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("US_MA", Date),
         Metric = "Count",
         AgeInt = case_when(Age == "0" ~ 20,
                            Age == "80" ~ 25,
                            Age == "TOT" | Age == "UNK" ~ NA_real_,
                            TRUE ~ 10)) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

db_all_combs <- db_all %>% 
  select(Date, Sex, Age, Measure) %>% 
  mutate(drive = 1)

db_drive2 <- db_drive %>% 
  left_join(db_all_combs) %>% 
  replace_na(list(drive = 2)) %>% 
  filter(drive == 2,
         Sex != "UNK",
         Age != "UNK") %>% 
  select(-drive)

out <- bind_rows(db_drive2, db_all) %>% 
  mutate(date_f = dmy(Date)) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


############################################
#### uploading database to Google Drive ####
############################################

# This command append new rows at the end of the sheet
write_sheet(out,
            ss = ss_i,
            sheet = "database")

log_update(pp = ctr, N = nrow(out))


############################################
#### uploading database to Google Drive ####
############################################

write_rds(db_all, "N:/COVerAGE-DB/Automation/Hydra/US_Massachusetts.rds")

log_update(pp = "US_Massachusetts", N = nrow(db_all))


