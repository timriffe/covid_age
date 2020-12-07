library(here)

############################################################################
# Deprecated!!!! Massachusetts stopped reporting age groups on August 11 :(
# Task schedule deleted!
############################################################################

# TR New: you must be in the repo environment 
source("Automation/00_Functions_automation.R")

# info country and N drive address
ctr <- "Sweden"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

m_url <- "https://www.mass.gov/info-details/covid-19-response-reporting#covid-19-cases-in-massachusetts-"
root <- "https://www.mass.gov"
html <- read_html(m_url)

db_p_all <- NULL

##################################
### Retrospective data before June
##################################

# Files for previous-June
url_file2 <- "https://www.mass.gov/doc/covid-19-raw-data-august-11-2020/download"
temp <- tempfile()
download.file(url_file2, temp, mode="wb")

age_p <- read_csv(unz(temp, "Age.csv"))
c_sex_p <- read_csv(unz(temp, "Sex.csv"))
d_sex_p <- read_csv(unz(temp, "Death Pies.csv"))
tests_p <- read_csv(unz(temp, "TestingByDate.csv"))
c_p <- read_csv(unz(temp, "CasesByDate.csv"))
d_p <- read_csv(unz(temp, "DateofDeath.csv"))
unlink(temp)

date_1 <- "2020/03/22"

age_p2 <- age_p %>% 
  separate(Age, c("Age", "trash")) %>% 
  mutate(date_f = mdy(Date),
         Age = ifelse(Age == "Unknown", "UNK", Age),
         Sex = "b") %>% 
  select(date_f, Sex, Age, Cases, Deaths) %>% 
  gather(Cases, Deaths, key = Measure, value = Value) %>% 
  filter(date_f >= date_1)

c_sex_p2 <- c_sex_p %>% 
  drop_na() %>% 
  rename(m = Male,
         f = Female,
         UNK = Unknown) %>% 
  gather(-Date, key = Sex, value = Value) %>% 
  mutate(Age = "TOT",
         date_f = mdy(Date),
         Measure = "Cases") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_1)

d_sex_p2 <- d_sex_p %>% 
  filter(Category == "Sex") %>% 
  rename(Value = Deaths) %>% 
  mutate(Sex = ifelse(Response == "Male", "m", "f"),
         Age = "TOT",
         date_f = mdy(Date),
         Measure = "Deaths") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_1)

c_p2 <- c_p %>% 
  rename(Value = `Positive Total`) %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = mdy(Date),
         Measure = "Cases") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_1)

d_p2 <- d_p %>% 
  rename(Value = "Confirmed Total",
         Date = "Date of Death") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = mdy(Date),
         Measure = "Deaths") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_1)

db_p_all <- bind_rows(age_p2,
                      c_sex_p2,
                      d_sex_p2,
                      c_p2,
                      d_p2) %>% 
  mutate(Country = "USA",
         Region = "Massachusetts",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("US_MA", Date),
         Metric = "Count",
         AgeInt = case_when(Age == "0" ~ "20",
                            Age == "80" ~ "25",
                            Age == "TOT" | Age == "UNK" ~ "",
                            TRUE ~ "10")) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

##################################
### Current data 
##################################

# locating the links for most recent data
url1 <- html_nodes(html, xpath = '//*[@id="main-content"]/div[2]/div/div/section[1]/div/div/p[3]/a') %>%
  html_attr("href")
url_file <- paste0(root, url1)
temp <- tempfile()
download.file(url_file, temp, mode="wb")
age <- read_csv(unz(temp, "Age.csv"))
d_sex <- read_csv(unz(temp, "Death Pies.csv"))
c_sex <- read_csv(unz(temp, "Sex.csv"))
tests <- read_csv(unz(temp, "TestingByDate.csv"))
c <- read_csv(unz(temp, "CasesByDate.csv"))
d <- read_csv(unz(temp, "DateofDeath.csv"))
unlink(temp)


date_2 <- "2020/6/1"

age2 <- age %>% 
  separate(Age, c("Age", "trash")) %>% 
  mutate(date_f = mdy(Date),
         Age = ifelse(Age == "Unknown", "UNK", Age),
         Sex = "b") %>% 
  select(date_f, Sex, Age, Cases, Deaths) %>% 
  gather(Cases, Deaths, key = Measure, value = Value) %>% 
  filter(date_f >= date_2)

c_sex2 <- c_sex %>% 
  drop_na() %>% 
  rename(m = Male,
         f = Female,
         UNK = Unknown) %>% 
  gather(-Date, key = Sex, value = Value) %>% 
  mutate(Age = "TOT",
         date_f = mdy(Date),
         Measure = "Cases") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_2)

d_sex2 <- d_sex %>% 
  filter(Category == "Sex") %>% 
  rename(Value = Deaths) %>% 
  mutate(Sex = ifelse(Response == "Male", "m", "f"),
         Age = "TOT",
         date_f = mdy(Date),
         Measure = "Deaths") %>% 
  select(date_f, Sex, Age, Measure, Value) %>% 
  filter(date_f >= date_2)

c2 <- c %>% 
  rename(Confirmed = "Positive Total",
         Probable = "Probable Total") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = mdy(Date),
         Cases = Confirmed + Probable) %>% 
  select(date_f, Sex, Age, Confirmed, Probable, Cases) %>% 
  filter(date_f >= date_2) %>% 
  gather(Confirmed, Probable, Cases, key = Measure, value = Value) %>% 
  mutate(Measure = case_when(Measure == "Confirmed" ~ "Confirmed Cases", 
                             Measure == "Probable" ~ "Probable Cases", 
                             Measure == "Cases" ~ "Cases"))

d2 <- d %>% 
  rename(Confirmed = "Confirmed Total",
         Probable = "Probable Total",
         Date = "Date of Death") %>% 
  mutate(Sex = "b",
         Age = "TOT",
         date_f = mdy(Date),
         Deaths = Confirmed + Probable) %>% 
  select(date_f, Sex, Age, Confirmed, Probable, Deaths) %>% 
  filter(date_f >= date_2) %>% 
  gather(Confirmed, Probable, Deaths, key = Measure, value = Value) %>% 
  mutate(Measure = case_when(Measure == "Confirmed" ~ "Confirmed Deaths", 
                             Measure == "Probable" ~ "Probable Deaths", 
                             Measure == "Deaths" ~ "Deaths"))

db_c_all <- bind_rows(age2,
                      c_sex2,
                      d_sex2,
                      c2,
                      d2) %>% 
  mutate(Country = "USA",
         Region = "Massachusetts",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("US_MA", Date),
         Metric = "Count",
         AgeInt = case_when(Age == "0" ~ "20",
                            Age == "80" ~ "25",
                            Age == "TOT" | Age == "UNK" ~ "",
                            TRUE ~ "10")) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  drop_na()

db_all <- bind_rows(db_p_all, db_c_all)

last_date_f <- max(c2$date_f)
last_date <- paste(sprintf("%02d", day(last_date_f)),
                   sprintf("%02d", month(last_date_f)),
                   year(last_date_f), sep = ".")

############################################
#### uploading database to Google Drive ####
############################################
write_rds(db_all, "N:/COVerAGE-DB/Automation/Hydra/US_Massachusetts.rds")

log_update(pp = "US_Massachusetts", N = nrow(db_all))
############################################
#### uploading metadata to Google Drive ####
############################################

# TR: pull urls from rubric instead 
us_ma_rubric <- get_input_rubric() %>% filter(Short == "US_MA")
ss_i   <- us_ma_rubric %>% dplyr::pull(Sheet)
ss_db  <- us_ma_rubric %>% dplyr::pull(Source)

sheet_name <- paste0("US_MA_", last_date_f, "_cases&deaths")

meta <- drive_create(sheet_name,
                     path = ss_db,
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(age,
            ss = meta$id,
            sheet = "cases_deaths_age")

write_sheet(d_sex,
            ss = meta$id,
            sheet = "deaths_sex")

Sys.sleep(105)

write_sheet(c_sex,
            ss = meta$id,
            sheet = "cases_sex")

write_sheet(tests,
            ss = meta$id,
            sheet = "tests")

Sys.sleep(105)

write_sheet(c,
            ss = meta$id,
            sheet = "cases_sex")

write_sheet(d,
            ss = meta$id,
            sheet = "cases_sex")

Sys.sleep(105)

write_sheet(age_p,
            ss = meta$id,
            sheet = "cases_deaths_age_previous")

write_sheet(d_sex_p,
            ss = meta$id,
            sheet = "deaths_sex_previous")

Sys.sleep(105)

write_sheet(c_sex_p,
            ss = meta$id,
            sheet = "cases_sex_previous")

write_sheet(tests_p,
            ss = meta$id,
            sheet = "tests_previous")

Sys.sleep(105)

write_sheet(c_p,
            ss = meta$id,
            sheet = "cases_sex_previous")

write_sheet(d_p,
            ss = meta$id,
            sheet = "cases_sex_previous")

sheet_delete(meta$id, "Sheet1")

