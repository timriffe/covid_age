
source(here::here("Automation/00_Functions_automation.R"))
#install.packages("archive")
library(archive)
#install.packages("archive")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "Peru"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# load data
m_url1 <- "https://www.datosabiertos.gob.pe/dataset/casos-positivos-por-covid-19-ministerio-de-salud-minsa"
m_url2 <- "https://www.datosabiertos.gob.pe/dataset/fallecidos-por-covid-19-ministerio-de-salud-minsa"

html1 <- read_html(m_url1)
html2 <- read_html(m_url2)

# locating the links for Excel files
cases_url <- html_nodes(html1, xpath = '//*[@id="data-and-resources"]/div/div/ul/li/div/span/a') %>%
  html_attr("href")

deaths_url <- html_nodes(html2, xpath = '//*[@id="data-and-resources"]/div/div/ul/li/div/span/a') %>%
  html_attr("href")

#JD: updating the vaccine link

#vacc_url <- "https://cloud.minsa.gob.pe/s/ZgXoXqK2KLjRLxD/download"
vacc_url <- "https://cloud.minsa.gob.pe/s/To2QtqoNjKqobfw/download"

data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
#source changed to provide data in 7z file
data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vacc_",today(), ".7z")
#data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vacc_",today(), ".csv")


# EA: needed to add the index [1] because there is more than one link, while the first one is the 
# full database that we need
download.file(cases_url[1], destfile = data_source_c, mode = "wb")
download.file(deaths_url[1], destfile = data_source_d, mode = "wb")
download.file(vacc_url, destfile = data_source_v, mode = "wb")


#JD: read in from Url was failing, I changed it to reading in the downloaded csv
# cases
#db_c <- read_delim(cases_url, delim = ";") %>% 
# as_tibble()
# deaths
#db_d <- read_delim(deaths_url, delim = ";") %>% 
#as_tibble()
# Vaccines
#db_v <- read_csv(data_source_v)

db_c <- read.csv(data_source_c, sep = ";")
db_d <- read.csv(data_source_d, sep = ";")
#db_v <- read.csv(data_source_v, sep = ",")
db_v=read_csv(archive_read(data_source_v), col_types = cols())

# deaths ----------------------------------------------

db_d2 <- db_d %>% 
  rename(date_f = FECHA_FALLECIMIENTO,
         Sex = SEXO,
         Age = EDAD_DECLARADA,
         Region = DEPARTAMENTO) %>% 
  select(date_f, Sex, Age, Region) %>% 
  mutate(date_f = ymd(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = ifelse(Age > 100, 100, Age),
         Region = str_to_title(Region)) %>% 
  group_by(date_f, Sex, Age, Region) %>% 
  summarise(new = n()) %>% 
  ungroup()

dates_f <- seq(min(db_d2$date_f),max(db_d2$date_f), by = '1 day')
ages <- 0:100

db_d3 <- db_d2 %>% 
  tidyr::complete(Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new),
         Measure = "Deaths") %>% 
  ungroup() %>% 
  select(-new)

# cases ----------------------------------------------

db_c2 <- db_c %>% 
  rename(date_f = FECHA_RESULTADO,
         Sex = SEXO,
         Age = EDAD,
         Region = DEPARTAMENTO) %>% 
  select(date_f, Sex, Age, Region) %>% 
  mutate(date_f = ymd(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = ifelse(Age > 100, 100, Age),
         Region = str_to_title(Region)) %>% 
  group_by(date_f, Sex, Age, Region) %>% 
  summarise(new = n()) %>% 
  ungroup()

dates <- db_c2 %>% drop_na(date_f) %>% select(date_f) %>% unique()

dates_f <- seq(min(dates$date_f),max(dates$date_f), by = '1 day')

db_c3 <- db_c2 %>% 
  tidyr::complete(Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new),
         Measure = "Cases") %>% 
  ungroup() %>% 
  select(-new)

# vaccines ---------------------------------------------------
db_v2 <- db_v %>% 
  select(Age = EDAD,
         Sex = SEXO,
         date_f = FECHA_VACUNACION,
         Dosis = DOSIS,
         Region = DEPARTAMENTO) %>% 
  mutate(date_f = ymd(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f",
                         TRUE ~ "UNK"),
         Age = ifelse(Age > 100, 100, Age),
         Region = str_to_title(Region),
         Measure = case_when(Dosis == 1 ~ "Vaccination1", 
                             Dosis == 2 ~ "Vaccination2", 
                             Dosis == 3 ~ "Vaccination3",
                             TRUE ~ "UNK")) %>% 
  group_by(date_f, Sex, Age, Region, Measure) %>% 
  summarise(new = n()) %>% 
  ungroup() %>% 
  filter(Measure != "UNK")

dates_f <- seq(min(db_v2$date_f), max(db_v2$date_f), by = '1 day')
ages <- 0:100

db_v3 <- db_v2 %>% 
  tidyr::complete(Measure, Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  group_by(Region, Measure, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new)

# template for database ------------------------------------------------------------
db_dc <- bind_rows(db_d3, db_c3, db_v3)

db_pe <- db_dc %>% 
  group_by(date_f, Sex, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All")

# 5-year age intervals for regional data -------------------------------

db_dc2 <- db_dc %>% 
  mutate(Age = ifelse(Age <= 4, Age, floor(Age/5) * 5)) %>% 
  group_by(date_f, Region, Sex, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  arrange(date_f, Region, Measure, Sex, Age)

# ----------------------------------------------------------------------

db_pe_comp <- bind_rows(db_dc2, db_pe) %>% 
  mutate(Age = as.character(Age))

db_tot_age <- db_pe_comp %>% 
  group_by(Region, date_f, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

db_tot_sex <- db_pe_comp %>% 
  group_by(Region, date_f, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b")

db_tot <- db_pe_comp %>% 
  group_by(Region, date_f, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b",
         Age = "TOT")

db_inc <- db_tot %>% 
  filter(Measure == "Deaths",
         Value >= 100) %>% 
  group_by(Region) %>% 
  summarise(date_start = ymd(min(date_f)))

db_all <- bind_rows(db_pe_comp, db_tot_age, db_tot_sex, db_tot)

db_all2 <- db_all %>% 
  left_join(db_inc) %>% 
  drop_na() %>% 
  filter((Region == "All" & date_f >= "2020-03-01") | date_f >= date_start)

out <- db_all2 %>% 
  mutate(Country = "Peru",
         AgeInt = case_when(Region == "All" & !(Age %in% c("TOT", "100")) ~ 1,
                            Region != "All" & !(Age %in% c("0", "1", "TOT")) ~ 5,
                            Region != "All" & Age == "0" ~ 1,
                            Region != "All" & Age == "1" ~ 4,
                            Age == "100" ~ 5,
                            Age == "TOT" ~ NA_real_),
         Date = ddmmyyyy(date_f),
         Code = case_when(
           Region == "All" ~ paste0("PE"),
           Region == "Amazonas" ~ paste0("PE-AMA"),
           Region == "Ancash" ~ paste0("PE-ANC"),
           Region == "Apurimac" ~ paste0("PE-APU"),
           Region == "Arequipa" ~ paste0("PE-ARE"),
           Region == "Ayacucho" ~ paste0("PE-AYA"),
           Region == "Cajamarca" ~ paste0("PE-CAJ"),
           Region == "Callao" ~ paste0("PE-CUS"),
           Region == "Cusco" ~ paste0("PE-CAL"),
           Region == "Huancavelica" ~ paste0("PE-HUV"),
           Region == "Huanuco" ~ paste0("PE-HUC"),
           Region == "Ica" ~ paste0("PE-ICA"),
           Region == "Junin" ~ paste0("PE-JUN"),
           Region == "La Libertad" ~ paste0("PE-LAL"),
           Region == "Lambayeque" ~ paste0("PE-LAM"),
           Region == "Lima" ~ paste0("PE-LIM"),
           Region == "Loreto" ~ paste0("PE-LOR"),
           Region == "Madre De Dios" ~ paste0("PE-MDD"),
           Region == "Moquegua" ~ paste0("PE-MOQ"),
           Region == "Pasco" ~ paste0("PE-PAS"),
           Region == "Piura" ~ paste0("PE-PIU"),
           Region == "Puno" ~ paste0("PE-PUN"),
           Region == "San Martin" ~ paste0("PE-SAM"),
           Region == "Tacna" ~ paste0("PE-TAC"),
           Region == "Tumbes" ~ paste0("PE-TUM"),
           Region == "Ucayali" ~ paste0("PE-UCA"),
           TRUE ~ "Other"
         ),
         Metric = "Count") %>% 
  sort_input_data()

# test <- db_final %>% 
#   filter(Sex == "b",
#          Age == "TOT")

#########################
# save data in N: -------------------------------------------------
#########################

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out))

#########################
# Push zip file to Drive -------------------------------------------------
#########################

# saving compressed data to N: drive


data_source <- c(data_source_c, data_source_d, data_source_v)

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