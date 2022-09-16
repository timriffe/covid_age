source(here::here("Automation/00_Functions_automation.R"))
#install.packages("archive")
library(archive)


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

#JD: updating the vaccine link

#vacc_url <- "https://cloud.minsa.gob.pe/s/ZgXoXqK2KLjRLxD/download"
vacc_url <- "https://cloud.minsa.gob.pe/s/To2QtqoNjKqobfw/download"

#source changed to provide data in 7z file
data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vacc_", lubridate::today(), ".7z")
#data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vacc_",today(), ".csv")


# EA: needed to add the index [1] because there is more than one link, while the first one is the 
# full database that we need

## MK: 06.07.2022: large file and give download error, so stopped this step and read directly instead
#download.file(cases_url[1], destfile = data_source_c, mode = "wb")
#download.file(deaths_url[1], destfile = data_source_d, mode = "wb")
#download.file(vacc_url, destfile = data_source_v, mode = "wb")


#JD: read in from Url was failing, I changed it to reading in the downloaded csv
# cases
#db_c <- read_delim(cases_url, delim = ";") %>% 
# as_tibble()
# deaths
#db_d <- read_delim(deaths_url, delim = ";") %>% 
#as_tibble()
# Vaccines
#db_v <- read_csv(data_source_v)

#db_c <- read.csv(data_source_c, sep = ";")
#db_d <- read.csv(data_source_d, sep = ";")
#db_v <- read.csv(data_source_v, sep = ",")
#db_v=read_csv(archive_read(data_source_v), col_types = cols())
#db_v <- read_csv(vacc_url)

## MK: 07.07.2022: due to large file size (use fread to read first, and then write a copy), and 
## .7z (vaccination file), we need to download it first then read.

vac_file <- download.file(vacc_url, destfile = data_source_v, mode = "wb")

db_v <- readr::read_csv(archive_read(data_source_v), 
                        col_select = c("EDAD", "SEXO", "FECHA_VACUNACION", "DOSIS", "DEPARTAMENTO"))


# vaccines ---------------------------------------------------
db_v2 <- db_v %>% 
  select(Age = EDAD,
         Sex = SEXO,
         date_f = FECHA_VACUNACION,
         Dosis = DOSIS,
         Region = DEPARTAMENTO) %>% 
  mutate(date_f = ymd(date_f),
         Sex = case_when(Sex == "MASCULINO" ~ "m",
                         Sex == "FEMENINO" ~ "f"),
         Age = ifelse(Age > 100, 100, Age),
         Region = str_to_title(Region),
         Measure = case_when(Dosis == 1 ~ "Vaccination1", 
                             Dosis == 2 ~ "Vaccination2", 
                             Dosis == 3 ~ "Vaccination3",
                             Dosis == 4 ~ "Vaccination4",
                             Dosis == 5 ~ "Vaccination5",
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

db_pe_comp <- db_v3 %>% 
  group_by(date_f, Sex, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All",
         Age = as.character(Age))


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


db_all <- bind_rows(db_pe_comp, db_tot_age, db_tot_sex, db_tot)

out <- db_all %>% 
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
# save processed data in N: -------------------------------------------------
#########################

log_update(pp = "PeruVaccine", N = nrow(out))

write_rds(out, paste0(dir_n, "PeruVaccine", ".rds"))
