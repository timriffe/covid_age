library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "Peru"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

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

db_c <- read_delim(cases_url, delim = ";") %>% 
  as_tibble()

db_d <- read_delim(deaths_url, delim = ";") %>% 
  as_tibble()

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
         Age = as.character(Age),
         Region = str_to_title(Region)) %>% 
  group_by(date_f, Sex, Age, Region) %>% 
  summarise(new = n()) %>% 
  ungroup()

dates_f <- seq(min(db_d2$date_f),max(db_d2$date_f), by = '1 day')
ages <- as.character(seq(0, 100, 1))

db_d3 <- db_d2 %>% 
  tidyr::complete(Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new),
         Measure = "Deaths") %>% 
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
         Age = as.character(Age),
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
  select(-new)

# template for database ------------------------------------------------------------
db_dc <- bind_rows(db_d3, db_c3)

db_pe <- db_dc %>% 
  group_by(date_f, Sex, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All")

# 5-year age intervals for regional data -------------------------------

db_dc2 <- db_dc %>% 
  mutate(Age2 = ifelse(as.numeric(Age) <= 4, Age, as.character(floor(as.numeric(Age)/5) * 5))) %>% 
  group_by(date_f, Region, Sex, Age2, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age2))) %>% 
  ungroup() %>% 
  rename(Age = Age2)
# ----------------------------------------------------------------------

db_pe_comp <- bind_rows(db_dc2, db_pe)

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
         AgeInt = case_when(Age == "100" ~ "5",
                            Age == "TOT" ~ "",
                            Region == "All" | as.numeric(Age) < 5 ~ "1",
                            TRUE ~ "5"),
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         Code = case_when(
           Region == "All" ~ paste0("PE", Date),
           Region == "Amazonas" ~ paste0("PE_AMA", Date),
           Region == "Ancash" ~ paste0("PE_ANC", Date),
           Region == "Apurimac" ~ paste0("PE_APU", Date),
           Region == "Arequipa" ~ paste0("PE_ARE", Date),
           Region == "Ayacucho" ~ paste0("PE_AYA", Date),
           Region == "Cajamarca" ~ paste0("PE_CAJ", Date),
           Region == "Callao" ~ paste0("PE_CUS", Date),
           Region == "Cusco" ~ paste0("PE_CAL", Date),
           Region == "Huancavelica" ~ paste0("PE_HUV", Date),
           Region == "Huanuco" ~ paste0("PE_HUC", Date),
           Region == "Ica" ~ paste0("PE_ICA", Date),
           Region == "Junin" ~ paste0("PE_JUN", Date),
           Region == "La Libertad" ~ paste0("PE_LAL", Date),
           Region == "Lambayeque" ~ paste0("PE_LAM", Date),
           Region == "Lima" ~ paste0("PE_LIM", Date),
           Region == "Loreto" ~ paste0("PE_LOR", Date),
           Region == "Madre De Dios" ~ paste0("PE_MDD", Date),
           Region == "Moquegua" ~ paste0("PE_MOQ", Date),
           Region == "Pasco" ~ paste0("PE_PAS", Date),
           Region == "Piura" ~ paste0("PE_PIU", Date),
           Region == "Puno" ~ paste0("PE_PUN", Date),
           Region == "San Martin" ~ paste0("PE_SAM", Date),
           Region == "Tacna" ~ paste0("PE_TAC", Date),
           Region == "Tumbes" ~ paste0("PE_TUM", Date),
           Region == "Ucayali" ~ paste0("PE_UCA", Date),
           TRUE ~ "Other"
         ),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

test <- db_final %>% 
  filter(Sex == "b",
         Age == "TOT")

#########################
# save data in N: -------------------------------------------------
#########################

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out))

#########################
# Push zip file to Drive -------------------------------------------------
#########################

# saving compressed data to N: drive
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")

download.file(cases_url, destfile = data_source_c)
download.file(deaths_url, destfile = data_source_d)

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

