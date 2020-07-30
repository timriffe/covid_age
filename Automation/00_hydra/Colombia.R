rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

db <- read_csv("https://www.datos.gov.co/api/views/gt2j-8ykr/rows.csv?accessType=DOWNLOAD")
db_muestras <- read_csv("https://www.datos.gov.co/api/views/8835-5baf/rows.csv")

unique(db$Estado)
unique(db$"Departamento o Distrito")

db2 <- db %>% 
  rename(Sex = Sexo,
         Region = 'Departamento o Distrito',
         status = 'Estado') %>% 
  mutate(Age = as.character(Edad),
         Value = 1,
         Region = case_when(
           Region == "Bogotá D.C." ~ "Bogota",
           Region == "Valle del Cauca" ~ "Valle del Cauca",
           Region == "Antioquia" ~ "Antioquia",
           Region == "Cartagena D.T. y C." ~ "Bolivar",
           Region == "Huila" ~ "Huila",
           Region == "Meta" ~ "Meta",
           Region == "Risaralda" ~ "Risaralda",
           Region == "Norte de Santander" ~ "Nte Santander",
           Region == "Caldas" ~ "Caldas",
           Region == "Cundinamarca" ~ "Cundinamarca",
           Region == "Barranquilla D.E." ~ "Atlantico",
           Region == "Santander" ~ "Santander",
           Region == "Quindío" ~ "Quindio",
           Region == "Tolima" ~ "Tolima",
           Region == "Cauca" ~ "Cauca",
           Region == "Santa Marta D.T. y C." ~ "Santa Marta",
           Region == "Cesar" ~ "Cesar",
           Region == "Archipiélago de San Andrés Providencia y Santa Catalina" ~ "San Andres",
           Region == "Casanare" ~ "Casanare",
           Region == "Nariño" ~ "Nariño",
           Region == "Atlántico" ~ "Atlantico",
           Region == "Boyacá" ~ "Boyaca",
           Region == "Córdoba" ~ "Cordoba",
           Region == "Bolívar" ~ "Bolivar",
           Region == "Sucre" ~ "Sucre",
           Region == "Magdalena" ~ "Magdalena",
           Region == "La Guajira" ~ "Guajira",
           Region == "Buenaventura D.E." ~ "Valle del Cauca",
           Region == "Chocó" ~ "Choco",
           Region == "Amazonas" ~ "Amazonas",
           Region == "Caquetá" ~ "Caqueta",
           Region == "Putumayo" ~ "Putumayo",
           Region == "Arauca" ~ "Arauca",
           Region == "Vaupés" ~ "Vaupes",
           Region == "Guainía" ~ "Guainia",
           Region == "Vichada" ~ "Vichada")) 

db_cases <- db2 %>% 
  rename(date = 'Fecha diagnostico') %>% 
  mutate(date_f = ymd(date),
         Measure = "Cases") %>% 
  select(date_f, Age, Sex, Region, Measure, Value)

db_deaths <- db2 %>% 
  filter(status == "Fallecido") %>% 
  rename(date = 'Fecha de muerte') %>% 
  mutate(date_f = ymd(str_sub(date, 1, 10)),
         Measure = "Deaths") %>% 
  select(date_f, Age, Sex, Region, Measure, Value)

regions_deaths <- db_deaths %>% 
  group_by(Region) %>% 
  summarise(d = sum(Value)) %>% 
  arrange(-d)

reg_inc <- regions_deaths %>% 
  filter(d >= 50) %>% 
  select(Region)

db_t <- db_cases
db_t <- db_deaths

unique(db_t$Sex)
unique(db_t$date_f)
unique(db_t$Region) %>% sort()

db3 <- bind_rows(db_cases, db_deaths) %>% 
  mutate(Region = ifelse(Region %in% reg_inc$Region, Region, "resto"),
         Sex = case_when(Sex == 'F' ~ 'f',
                         Sex == 'f' ~ 'f',
                         Sex == 'M' ~ 'm',
                         Sex == 'm' ~ 'm',
                         TRUE ~ 'o'))

unique(db3$Region)

db3 %>% group_by(Measure) %>% 
  summarise(sum(Value))

db3 %>% group_by(Region, Measure) %>% 
  summarise(sum(Value))

unique(db3$Sex)
unique(db3$Region)
unique(db3$date_f)
unique(db3$Age)

empty_db <- expand_grid(Region = unique(db3$Region),
                        Sex = unique(db3$Sex),
                        Measure = c("Cases", "Deaths"),
                        Age = as.character(seq(0, 100, 1)))%>%
  bind_rows(expand_grid(Region = unique(db3$Region),
                        Sex = c(unique(db3$Sex), "b"),
                        Age = "TOT",
                        Measure = c("Cases", "Deaths")))

dates <- db3 %>% select(date_f) %>% drop_na() %>% pull(date_f)

db_all <- NULL
min(dates)
date_start <- dmy("20/03/2020")
date_end <- max(dates)

ref <- date_start

while (ref <= date_end){
  
  print(ref)
  db4 <- db3 %>% 
    filter(date_f <= ref) %>% 
    group_by(Age, Sex, Region, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() 
  
  db5 <- db4 %>% 
    group_by(Measure, Sex, Region) %>% 
    summarise(Value = sum(Value))%>% 
    mutate(Age = "TOT")
  
  db6 <- db4 %>% 
    group_by(Measure, Region) %>% 
    summarise(Value = sum(Value))%>% 
    mutate(Sex = "b", Age = "TOT")
  
  db7 <- bind_rows(db4, db5, db6) %>%
    ungroup()
  
  db8 <- empty_db %>%
    left_join(db7) %>%
    mutate(date_f = ref,
           Value = replace_na(Value, 0))
  
  db_all <- bind_rows(db_all, db8)
  
  ref = ref + 1
}

start <- db_all %>% 
  filter(Sex == "b",
         Measure == "Deaths",
         Value >= 50) %>% 
  group_by(Region) %>% 
  summarise(start = min(date_f))

db_all_start <- db_all %>% 
  left_join(start)

db_regions <- db_all_start %>% 
  filter(Region != "resto",
         date_f >= start) %>% 
  mutate(Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Colombia",
         Code = case_when(Region == "Bogota" ~ paste0("CO_DC", Date),
                          Region == "Amazonas" ~ paste0("CO_AMA", Date),
                          Region == "Antioquia" ~ paste0("CO_ANT", Date),
                          Region == "Arauca" ~ paste0("CO_ARA", Date),
                          Region == "Atlantico" ~ paste0("CO_ATL", Date),
                          Region == "Bolivar" ~ paste0("CO_BOL", Date),
                          Region == "Boyaca" ~ paste0("CO_BOY", Date),
                          Region == "Caldas" ~ paste0("CO_CAL", Date),
                          Region == "Caqueta" ~ paste0("CO_CAQ", Date),
                          Region == "Casanare" ~ paste0("CO_CAS", Date),
                          Region == "Cauca" ~ paste0("CO_CAU", Date),
                          Region == "Cesar" ~ paste0("CO_CES", Date),
                          Region == "Cordoba" ~ paste0("CO_COR", Date),
                          Region == "Cundinamarca" ~ paste0("CO_CUN", Date),
                          Region == "Choco" ~ paste0("CO_CHO", Date),
                          Region == "Guainia" ~ paste0("CO_GUA", Date),
                          Region == "Guaviare" ~ paste0("CO_GUV", Date),
                          Region == "Huila" ~ paste0("CO_HUI", Date),
                          Region == "Guajira" ~ paste0("CO_LAG", Date),
                          Region == "Magdalena" ~ paste0("CO_MAG", Date),
                          Region == "Meta" ~ paste0("CO_MET", Date),
                          Region == "Nariño" ~ paste0("CO_NAR", Date),
                          Region == "Nte Santander" ~ paste0("CO_NSA", Date),
                          Region == "Putumayo" ~ paste0("CO_PUT", Date),
                          Region == "Quindio" ~ paste0("CO_QUI", Date),
                          Region == "Risaralda" ~ paste0("CO_RIS", Date),
                          Region == "San Andres" ~ paste0("CO_SAP", Date),
                          Region == "Santander" ~ paste0("CO_SAN", Date),
                          Region == "Sucre" ~ paste0("CO_SUC", Date),
                          Region == "Tolima" ~ paste0("CO_TOL", Date),
                          Region == "Valle del Cauca" ~ paste0("CO_VAC", Date),
                          Region == "Vaupes" ~ paste0("CO_VAU", Date)),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            Age == "100" ~ 5,
                            TRUE ~ 1),
         Metric = "Count") %>% 
  arrange(date_f, Region, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

db_colombia <- db_all %>%
  group_by(date_f, Age, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Colombia",
         Code = paste0("CO_", Date),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            Age == 100 ~ 5,
                            TRUE ~ 1),
         Metric = "Count") %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 


############################################
#### comparison with reported aggregate data
############################################

last_date <- db_colombia %>% 
  mutate(date_f = dmy(Date)) %>% 
  select(date_f) %>% 
  group_by() %>% 
  summarise(date_f = max(date_f))

db_colombia %>%
  filter(dmy(Date) == last_date$date_f,
         Sex == "b",
         Age == "TOT") %>%
  select(Region, Measure, Value) %>% 
  spread(Measure, Value)

db_regions %>% 
  filter(dmy(Date) == last_date$date_f,
         Sex == "b", 
         Age == "TOT") %>% 
  group_by(Region) %>% 
  select(Measure, Value)

############################################
#### tests
############################################

db_m1 <- db_muestras %>% 
  filter(Fecha != "Acumulado Feb") %>% 
  rename(Value = Acumuladas) %>% 
  mutate(Country = "Colombia",
         Region = "All",
         Date = paste(str_sub(Fecha, 9, 10), str_sub(Fecha, 6, 7), "2020", sep = "."),
         Sex = "b", 
         Age = "TOT",
         AgeInt = NA,
         Code = paste0("CO_", Date),
         Measure = "Tests",
         Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

db_colombia2 <- bind_rows(db_colombia, db_m1)


unique(db_colombia2$Region)

db_bogota <- db_regions %>% 
  filter(Region == "Bogota")

db_atlantico <- db_regions %>% 
  filter(Region == "Atlantico")

db_bolivar <- db_regions %>% 
  filter(Region == "Bolivar")

db_valle <- db_regions %>% 
  filter(Region == "Valle del Cauca")

db_amazonas <- db_regions %>% 
  filter(Region == "Amazonas")

regs <- c("Bogota", "Atlantico", "Bolivar", "Valle del Cauca", "Amazonas")

db_others <- db_regions %>% 
  filter(!(Region %in% regs))

table(db_others$Region)

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db_colombia2, 
            ss = "https://docs.google.com/spreadsheets/d/14IQValalDu927CHyeDpIqSvT6cvo-ZyWHUx6DD64638/edit#gid=0",
            sheet = "database")

Sys.sleep(105)

write_sheet(db_bogota, 
            ss = "https://docs.google.com/spreadsheets/d/10JBHD_XM5u4-F5jrIMJxmmjHmkINnegzVqTDl-8zZz0/edit#gid=1328391221",
            sheet = "database")

Sys.sleep(105)

write_sheet(db_atlantico, 
            ss = "https://docs.google.com/spreadsheets/d/1xkIcSML7sNq--wWpw9CndS_cNRYVpo11yqgRfCpwyDM/edit#gid=1328391221",
            sheet = "database")

write_sheet(db_bolivar, 
            ss = "https://docs.google.com/spreadsheets/d/11E0HhABStIbegfKAbBJHACgW7FF01CJcRsJrpABUQkc/edit#gid=1328391221",
            sheet = "database")

Sys.sleep(105)

write_sheet(db_valle, 
            ss = "https://docs.google.com/spreadsheets/d/1HfGYxza9hvGwnZf4iP9V6CUPUUb7BLGLCKbdi2oPKXw/edit#gid=1328391221",
            sheet = "database")

write_sheet(db_amazonas, 
            ss = "https://docs.google.com/spreadsheets/d/1COWAPqF9Ih6GIdR41rKW6pkIm1YeNz8f8bPsyM_e1jk/edit#gid=1328391221",
            sheet = "database")

Sys.sleep(105)

write_sheet(db_others, 
            ss = "https://docs.google.com/spreadsheets/d/1OLIiPQq3ZEkoTGowWpWTehTDhP7ETNsa71zdQVDhvwc/edit#gid=1328391221",
            sheet = "database")


############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
              sprintf("%02d", month(date_f)),
              year(date_f), sep = ".")

sheet_name <- paste0("CO", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1PUMLfc_YKEnMX22gbwb0rWB-1tm-rVq8?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "cases&deaths_age_sex")

write_sheet(db_muestras, 
            ss = meta$id,
            sheet = "tests")

sheet_delete(meta$id, "Sheet1")
