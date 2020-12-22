library(here)
source(here("Automation/00_Functions_automation.R"))

email <- "kikepaila@gmail.com"

drive_auth(email = email)
gs4_auth(email = email)

ctr <- "Paraguay"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# open connexion for the link
# https://www.mspbs.gov.py/reporte-covid19.html

# microdata of cases
cases_url <- "https://public.tableau.com/vizql/w/COVID19PY-Registros/v/Descargardatos/vudcsv/sessions/15AC27FC45FA44A18DA1E2982DBF0CF2-0:0/views/7713620505763405234_2641841674343653269?summary=true"
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
download.file(deaths_url, destfile = data_source_d)

# microdata of deaths
deaths_url <- "https://public.tableau.com/vizql/w/COVID19PY-Registros/v/FALLECIDOS/vudcsv/sessions/F2346EFBD1024EFA9684EB4E4B3D2836-0:0/views/7713620505763405234_5043410824490810379?summary=true"
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
download.file(cases_url, destfile = data_source_c)

db_c <- read_csv(data_source_c)
db_d <- read_csv(data_source_d)

# data from deaths and tests
tests <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/10XayKoMKOOOJrZBPcUbd_SIZgBIC5eNt9ei4oVVw-SY/edit#gid=0",
                    sheet = "database_deaths_tests")

tests2 <- tests %>% 
  mutate(date_f = dmy(Date)) %>% 
  drop_na(Value) %>% 
  filter(Measure == "Tests") %>% 
  select(date_f, Sex, Age, Measure, Value)




unique(db$Edad) %>% sort()

db_c2 <- db_c %>% 
  rename(date_f = "Fecha Confirmacion",
         Sex = Sexo) %>% 
  select(date_f, Sex, Edad) %>% 
  mutate(date_f = mdy(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = case_when(Edad <= 100 ~ as.character(floor(Edad/5)*5), 
                         Edad > 100 & Edad < 120 ~ "100",
                         Edad >= 120 ~"UNK")) %>% 
  group_by(date_f, Sex, Age) %>% 
  summarise(new = sum(n())) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases")


db_d2 <- db_d %>% 
  rename(date_f = 2,
         Sex = Sexo,
         Edad = 'Sum of Edad') %>% 
  select(date_f, Sex, Edad) %>% 
  mutate(date_f = mdy(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = case_when(Edad <= 100 ~ as.character(floor(Edad/5)*5), 
                         Edad > 100 & Edad < 120 ~ "100",
                         Edad >= 120 ~"UNK")) %>% 
  group_by(date_f, Sex, Age) %>% 
  summarise(new = sum(n())) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths")

db <- bind_rows(db_d2, db_c2)

sexes <- unique(db$Sex)
dates_f <- unique(db$date_f) %>% sort()
ages <- unique(db$Age) %>% sort()

db2 <- db %>% 
  complete(Sex, Age = ages, date_f = dates_f, Measure, fill = list(new = 0)) %>% 
  arrange(suppressWarnings(as.integer(Age)), Sex, Measure, date_f) %>% 
  group_by(Measure, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup()

db_tot_sex <- db2 %>% 
  group_by(date_f, Measure, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

# Starting the report in the date in which cases and deaths for all ages are more than 50
db3 <- db2 %>% 
  group_by(date_f, Measure) %>% 
  mutate(All_ages = sum(Value)) %>% 
  filter(All_ages >= 50) %>% 
  ungroup() %>% 
  filter(Age != "UNK") %>% 
  select(-new, -All_ages) %>% 
  bind_rows(db_tot_sex, tests2)

out <- db3 %>%
  mutate(Region = "All",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Paraguay",
         Code = paste0("PY_", Date),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            TRUE ~ 5),
         Metric = "Count") %>% 
  # bind_rows(deaths2) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

# total cummulative values
date_end <- max(dates_f)

date_end_format <- paste(sprintf("%02d", day(date_end)),
                         sprintf("%02d", month(date_end)),
                         year(date_end), sep = ".")



write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

# Compressing source files 
data_source <- c(data_source_c, data_source_d)

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
