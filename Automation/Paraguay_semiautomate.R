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
cases_url <- "https://public.tableau.com/vizql/w/COVID19PY-Registros/v/Descargardatos/vudcsv/sessions/8FD41F0435C4449691EC5A661007FB97-0:0/views/7713620505763405234_2641841674343653269?summary=true"
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
download.file(cases_url, destfile = data_source_c)

# microdata of deaths
deaths_url <- "https://public.tableau.com/vizql/w/COVID19PY-Registros/v/FALLECIDOS/vudcsv/sessions/D239EE68457442C9B3B08FECB8AF6AE0-0:0/views/7713620505763405234_5043410824490810379?summary=true"
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
download.file(deaths_url, destfile = data_source_d)

db_c <- read_delim(data_source_c, delim = ",")
db_d <- read_delim(data_source_d, delim = ",")

# data from deaths and tests
tests <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/10XayKoMKOOOJrZBPcUbd_SIZgBIC5eNt9ei4oVVw-SY/edit#gid=0",
                    sheet = "database_deaths_tests")

tests2 <- tests %>% 
  mutate(date_f = dmy(Date),
         Region = "All") %>% 
  drop_na(Value) %>% 
  filter(Measure == "Tests") %>% 
  select(Region, date_f, Sex, Age, Measure, Value)

unique(db_c$'Departamento Residencia') %>% sort()
unique(db_c$'Distrito Residencia') %>% sort()

unique(db_c2$Region) %>% sort()
unique(db_c$Edad) %>% sort()


db_c2 <- db_c %>% 
  rename(date_f = "Fecha Confirmacion",
         Sex = Sexo,
         Region = 'Departamento Residencia') %>% 
  select(Region, date_f, Sex, Edad) %>% 
  mutate(Region = str_to_title(Region),
         date_f = as.character(date_f),
         date_f = ifelse(str_length(date_f) == 7, paste0("0", date_f), date_f),
         date_f = mdy(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = case_when(Edad <= 100 ~ Edad, 
                         Edad > 100 & Edad < 120 ~ 100,
                         Edad >= 120 ~ 999)) %>% 
  group_by(Region, date_f, Sex, Age) %>% 
  summarise(new = sum(n())) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases")

db_d2 <- db_d %>% 
  rename(date_f = 2,
         Sex = Sexo,
         Edad = 'Sum of Edad',
         Region = 'Departamento Residencia') %>% 
  select(Region, date_f, Sex, Edad) %>% 
  separate(date_f, c("f", "s", "t"), sep = "/") %>% 
  mutate(Region = str_to_title(Region),
         date_f = case_when(t == "2020" ~ make_date(year = t, month = f, day = s),
                            t == "2021" & as.integer(f) <= 12 & as.integer(s) <= 12 ~ make_date(year = t, month = s, day = f),
                            t == "2021" & (as.integer(f) >= 12 | as.integer(s) >= 12) ~ make_date(year = t, month = f, day = s)),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = case_when(Edad <= 100 ~ Edad, 
                         Edad > 100 & Edad < 120 ~ 100,
                         Edad >= 120 ~ 999)) %>% 
  group_by(Region, date_f, Sex, Age) %>% 
  summarise(new = sum(n())) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths")

db <- bind_rows(db_d2, db_c2)

sexes <- unique(db$Sex)
dates_f <- unique(db$date_f) %>% sort()
ages <- unique(db$Age) %>% sort()

unique(db$Region)

db2 <- db %>% 
  tidyr::complete(date_f = dates_f, Region, Sex, Age = ages, Measure, fill = list(new = 0)) %>% 
  arrange(Region, suppressWarnings(as.integer(Age)), Sex, Measure, date_f) %>% 
  group_by(Region, Measure, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup()

db_reg <- db2 %>% 
  mutate(Age = case_when(Age >= 5 ~ floor(Age / 5) * 5,
                         Age < 1 ~ 0,
                         Age >= 1 & Age < 5 ~ 1)) %>% 
  group_by(date_f, Region, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  drop_na(Region)

db_nal <- db2 %>% 
  group_by(date_f, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All") %>% 
  filter(Age != "UNK")

db_tot_sex <- bind_rows(db_reg, db_nal) %>% 
  group_by(date_f, Region, Measure, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

# Starting the report in the date in which cases and deaths for all ages are more than 50

db3 <- bind_rows(db_reg, db_nal) %>% 
  group_by(date_f, Region, Measure) %>% 
  filter(sum(Value) >= 50) %>% 
  ungroup() %>% 
  filter(Age < 105) %>% 
  mutate(Age = as.character(Age)) %>% 
  bind_rows(db_tot_sex, tests2)

unique(db_reg$Region)
unique(db_nal$Region)
unique(db_tot_sex$Region)
unique(db_nal$date_f)


unique(db3$Region)

out <- db3 %>%
  mutate(Date = ddmmyyyy(date_f),
         Country = "Paraguay",
         short = case_when(Region == 'Asuncion' ~ 'ASU',
                           Region == 'Central' ~ '16',
                           Region == 'Caaguazu' ~ '10',
                           Region == 'Alto Parana' ~ '13',
                           Region == 'San Pedro' ~ '19',
                           Region == 'Itapua' ~ '5',
                           Region == 'Paraguari' ~ '6',
                           Region == 'Concepcion' ~ '14',
                           Region == 'Cordillera' ~ '11',
                           Region == 'Guaira' ~ '1',
                           Region == 'Pte. Hayes' ~ '3',
                           Region == 'Canindeyu' ~ '4',
                           Region == 'Amambay' ~ '7',
                           Region == 'Caazapa' ~ '8',
                           Region == 'Boqueron' ~ '12',
                           Region == 'Misiones' ~ '9',
                           Region == 'Alto Paraguay' ~ '15',
                           Region == 'Ñeembucu' ~ '2',
                           Region == 'All' ~ ''),
         Code = case_when(Region == "All" ~ paste0("PY_", Date),
                          TRUE ~ paste0("PY_", short, "_", Date)),
         AgeInt = case_when(Region == "All" & !(Age %in% c("TOT", "100")) ~ 1,
                            Region != "All" & !(Age %in% c("0", "1", "TOT")) ~ 5,
                            Region != "All" & Age == "0" ~ 1,
                            Region != "All" & Age == "1" ~ 4,
                            Age == "100" ~ 5,
                            Age == "TOT" ~ NA_real_),
         Metric = "Count") %>% 
  # bind_rows(deaths2) %>% 
  sort_input_data()
  
unique(out$Region)

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

