# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- kikepaila@gmail.com
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")



library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)
library(zip)

# Authorizing authentification or Drive (edit these lines with the user's email)
drive_auth(email = email)
gs4_auth(email = email)

db <- read_csv("https://www.datos.gov.co/api/views/gt2j-8ykr/rows.csv?accessType=DOWNLOAD")
db_muestras <- read_csv("https://www.datos.gov.co/api/views/8835-5baf/rows.csv")

unique(db$Estado)
unique(db$"Departamento o Distrito")

db2 <- db %>% 
  rename(Sex = Sexo,
         Region = 'Departamento o Distrito',
         status = 'Estado') %>% 
  mutate(Age = as.character(Edad),
         Region = case_when(
           Region == "Bogot? D.C." ~ "Bogota",
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
           Region == "Quind?o" ~ "Quindio",
           Region == "Tolima" ~ "Tolima",
           Region == "Cauca" ~ "Cauca",
           Region == "Santa Marta D.T. y C." ~ "Magdalena",
           Region == "Cesar" ~ "Cesar",
           Region == "Archipi?lago de San Andr?s Providencia y Santa Catalina" ~ "San Andres",
           Region == "Casanare" ~ "Casanare",
           Region == "Nari?o" ~ "Nari?o",
           Region == "Atl?ntico" ~ "Atlantico",
           Region == "Boyac?" ~ "Boyaca",
           Region == "C?rdoba" ~ "Cordoba",
           Region == "Bol?var" ~ "Bolivar",
           Region == "Sucre" ~ "Sucre",
           Region == "Magdalena" ~ "Magdalena",
           Region == "La Guajira" ~ "Guajira",
           Region == "Buenaventura D.E." ~ "Valle del Cauca",
           Region == "Choc?" ~ "Choco",
           Region == "Amazonas" ~ "Amazonas",
           Region == "Caquet?" ~ "Caqueta",
           Region == "Putumayo" ~ "Putumayo",
           Region == "Arauca" ~ "Arauca",
           Region == "Vaup?s" ~ "Vaupes",
           Region == "Guain?a" ~ "Guainia",
           Region == "Vichada" ~ "Vichada")) 

# cases ----------------------------------------------
# three dates for cases, preferred in this order: diagnosed, symptoms, reported to web
db_cases <- db2 %>% 
  rename(date_diag = 'Fecha diagnostico',
         date_repo = 'fecha reporte web') %>% 
  mutate(date_diag = ymd(str_sub(date_diag, 1, 10)),
         date_sint = ymd(str_sub(FIS, 1, 10)),
         date_repo = ymd(str_sub(date_repo, 1, 10)),
         date_f = case_when(
           !is.na(date_diag) ~ date_diag,
           is.na(date_diag) & !is.na(date_sint) ~ date_sint,
           is.na(date_diag) & is.na(date_sint) ~ date_repo
         ),
         Measure = "Cases") %>% 
  select(date_f, Age, Sex, Region, Measure)

# deaths -----------------------------------------------------------
db_deaths <- db2 %>% 
  filter(status == "Fallecido") %>% 
  rename(date = 'Fecha de muerte') %>% 
  mutate(date_f = ymd(str_sub(date, 1, 10)),
         Measure = "Deaths") %>% 
  select(date_f, Age, Sex, Region, Measure)

# identifuying regions with 50+ deaths -----------------------------
regions_deaths <- db_deaths %>% 
  group_by(Region) %>% 
  summarise(new = n()) %>% 
  ungroup()

reg_inc <- regions_deaths %>%
  filter(new >= 50) %>%
  dplyr::pull(Region)

# summarising new cases for each combination -----------------------
db3 <- bind_rows(db_cases, db_deaths) %>% 
  mutate(Region = ifelse(Region %in% reg_inc, Region, "Resto"),
         Sex = case_when(Sex == 'F' ~ 'f',
                         Sex == 'f' ~ 'f',
                         Sex == 'M' ~ 'm',
                         Sex == 'm' ~ 'm',
                         TRUE ~ 'o')) %>% 
  group_by(Region, date_f, Measure, Sex, Age) %>% 
  summarise(new = n()) %>% 
  ungroup()

# expanding the database to all posible combinations and cumulating values -------------
ages <- as.character(seq(0, 100, 1))
all_dates <- db3 %>% 
  filter(!is.na(date_f)) %>% 
  dplyr::pull(date_f) %>% 
  unique()
dates_f <- seq(min(all_dates), max(all_dates), by = '1 day')

db4 <- db3 %>% 
  complete(Region, Measure, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
  group_by(Region, Measure, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(-new) %>% 
  ungroup()

#######################
# template for database ------------------------------------------------------
#######################

# National data --------------------------------------------------------------
db_co <- db4 %>% 
  group_by(date_f, Sex, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Region = "All")

# 5-year age intervals for regional data -------------------------------------
db_regions <- db4 %>% 
  mutate(Age2 = ifelse(as.numeric(Age) <= 4, Age, as.character(floor(as.numeric(Age)/5) * 5))) %>% 
  group_by(date_f, Region, Sex, Age2, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age2))) %>% 
  ungroup() %>% 
  rename(Age = Age2)

# merging national and regional data -----------------------------------
db_co_comp <- bind_rows(db_regions, db_co)

# summarising totals by age and sex in each date -----------------------------------
db_tot_age <- db_co_comp %>% 
  group_by(Region, date_f, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

db_tot_sex <- db_co_comp %>% 
  group_by(Region, date_f, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b")

db_tot <- db_co_comp %>% 
  group_by(Region, date_f, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b",
         Age = "TOT")

db_inc <- db_tot %>% 
  filter(Measure == "Deaths",
         Value >= 50) %>% 
  group_by(Region) %>% 
  summarise(date_start = ymd(min(date_f)))

# appending all data in one database ----------------------------------------------
db_all <- bind_rows(db_co_comp, db_tot_age, db_tot_sex, db_tot)

# filtering dates for each region (>50 deaths) -----------------------------------
db_all2 <- db_all %>% 
  left_join(db_inc) %>% 
  drop_na() %>% 
  filter((Region == "All" & date_f >= "2020-03-20") | date_f >= date_start)

# tests data -----------------------------------
db_m1 <- db_muestras %>% 
  filter(Fecha != "Acumulado Feb") %>% 
  rename(Value = Acumuladas) %>% 
  mutate(Region = "All",
         date_f = ymd(str_sub(Fecha, 1, 10)),
         Sex = "b", 
         Age = "TOT",
         Measure = "Tests") %>% 
  select(Region, date_f, Sex, Age, Measure, Value) 

# all data together in COVerAGE-DB format -----------------------------------
db_final <- db_all2 %>%
  bind_rows(db_m1) %>% 
  mutate(Country = "Colombia",
         AgeInt = case_when(Age == "100" ~ "5",
                            Age == "TOT" ~ "",
                            Region == "All" | as.numeric(Age) < 5 ~ "1",
                            TRUE ~ "5"),
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         Code = case_when(
           Region == "All" ~ paste0("CO", Date),
           Region == "Bogota" ~ paste0("CO_DC", Date),
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
           Region == "Nari?o" ~ paste0("CO_NAR", Date),
           Region == "Nte Santander" ~ paste0("CO_NSA", Date),
           Region == "Putumayo" ~ paste0("CO_PUT", Date),
           Region == "Quindio" ~ paste0("CO_QUI", Date),
           Region == "Risaralda" ~ paste0("CO_RIS", Date),
           Region == "San Andres" ~ paste0("CO_SAP", Date),
           Region == "Santander" ~ paste0("CO_SAN", Date),
           Region == "Sucre" ~ paste0("CO_SUC", Date),
           Region == "Tolima" ~ paste0("CO_TOL", Date),
           Region == "Valle del Cauca" ~ paste0("CO_VAC", Date),
           Region == "Vaupes" ~ paste0("CO_VAU", Date),
           TRUE ~ paste0("CO_Other", Date)
         ),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
# slicing the database by some regions ----------------------------------
############################################

regions <- db_final %>% dplyr::pull(Region) %>% unique()
length(regions)

db_final_co <- db_final %>% 
  filter(Region == "All")

db_final_1 <- db_final %>% 
  filter(Region %in% regions[2:5])

db_final_2 <- db_final %>% 
  filter(Region %in% regions[6:10])

db_final_3 <- db_final %>% 
  filter(Region %in% regions[11:15])

db_final_4 <- db_final %>% 
  filter(Region %in% regions[16:20])

db_final_5 <- db_final %>% 
  filter(Region %in% regions[21:length(regions)])

############################################
#### uploading database to Google Drive ####
############################################

# TR: pull urls from rubric instead
rubric <- get_input_rubric()
ss_0   <- rubric %>% filter(Short == "CO") %>% dplyr::pull(Sheet)
ss_1   <- rubric %>% filter(Short == "CO_1") %>% dplyr::pull(Sheet)
ss_2   <- rubric %>% filter(Short == "CO_2") %>% dplyr::pull(Sheet)
ss_3   <- rubric %>% filter(Short == "CO_3") %>% dplyr::pull(Sheet)
ss_4   <- rubric %>% filter(Short == "CO_4") %>% dplyr::pull(Sheet)
ss_5   <- rubric %>% filter(Short == "CO_5") %>% dplyr::pull(Sheet)

ss_db  <- rubric %>% filter(Short == "CO") %>% dplyr::pull(Source)


write_sheet(db_final_co, 
            ss = ss_0,
            sheet = "database")

write_sheet(db_final_1, 
            ss = ss_1,
            sheet = "database")

Sys.sleep(105)

write_sheet(db_final_2, 
            ss = ss_2,
            sheet = "database")

write_sheet(db_final_3, 
            ss = ss_3,
            sheet = "database")

Sys.sleep(105)

write_sheet(db_final_4, 
            ss = ss_4,
            sheet = "database")

write_sheet(db_final_5, 
            ss = ss_5,
            sheet = "database")

Sys.sleep(105)

N <- nrow(db_final_co) + nrow(db_final_1) + nrow(db_final_2) + nrow(db_final_3) + nrow(db_final_4) + nrow(db_final_5)
log_update(pp = "Colombia", N = N)
############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
date <- paste(sprintf("%02d", day(date_f)),
              sprintf("%02d", month(date_f)),
              year(date_f), sep = ".")

filename_1 <- file.path("Data",paste0("CO", date, "cases&deaths.csv"))
filename_2 <- file.path("Data",paste0("CO", date, "tests.csv"))



write_csv(db, filename_1)
write_csv(db_m1, filename_2)

filename <- file.path("Data",paste0("CO", date, "cases&deaths.zip"))

files <- c(filename_1, filename_2)
zip(filename, files, compression_level = 9)

drive_upload(
  filename,
  path = ss_db,
  name = filename,
  overwrite = TRUE)

# clean up file chaff
file.remove(c(filename_1,filename_2, filename))


