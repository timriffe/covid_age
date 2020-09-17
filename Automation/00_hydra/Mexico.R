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
library(rvest)

drive_auth(email = email)
gs4_auth(email = email)

# reading data from the website ------------------------------------------------------ 
m_url <- "https://www.gob.mx/salud/documentos/datos-abiertos-152127"
html <- read_html(m_url)
# locating the links for the data
url1 <- html_nodes(html, xpath = '/html/body/main/div/div[1]/div[4]/div/table[2]/tbody/tr[1]/td[2]/a') %>%
  html_attr("href")

temp <- tempfile()
download.file(url1, temp)
# download.file("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip", temp)

zipdf <- unzip(temp, list = TRUE)
csv_file <- zipdf$Name
db <- read_csv(unz(temp, csv_file))

unique(db$SEXO)
unique(db$EDAD)
unique(db$ENTIDAD_RES) %>% as.numeric() %>% sort()
table(db$ENTIDAD_RES)

# filter confirmed cases and standardize data ----------------------------------------

db2 <- db %>% 
  filter(RESULTADO == 1) %>% 
  rename(Age = EDAD,
         date_c = FECHA_SINTOMAS,
         date_d = FECHA_DEF) %>% 
  mutate(Sex = case_when(SEXO == 1 ~ "f",
                         SEXO == 2 ~ "m",
                         T ~ "UNK"),
         Age = ifelse(Age >= 100, 100, Age),
         Region = case_when(
           ENTIDAD_RES == '01' ~ 'Aguascalientes',
           ENTIDAD_RES == '02' ~ 'Baja California',
           ENTIDAD_RES == '03' ~ 'Baja California Sur',
           ENTIDAD_RES == '04' ~ 'Campeche',
           ENTIDAD_RES == '05' ~ 'Coahuila de Zaragoza',
           ENTIDAD_RES == '06' ~ 'Colima',
           ENTIDAD_RES == '07' ~ 'Chiapas',
           ENTIDAD_RES == '08' ~ 'Chihuahua',
           ENTIDAD_RES == '09' ~ 'Ciudad de M?xico',
           ENTIDAD_RES == '10' ~ 'Durango',
           ENTIDAD_RES == '11' ~ 'Guanajuato',
           ENTIDAD_RES == '12' ~ 'Guerrero',
           ENTIDAD_RES == '13' ~ 'Hidalgo',
           ENTIDAD_RES == '14' ~ 'Jalisco',
           ENTIDAD_RES == '15' ~ 'M?xico',
           ENTIDAD_RES == '16' ~ 'Michoac?n de Ocampo',
           ENTIDAD_RES == '17' ~ 'Morelos',
           ENTIDAD_RES == '18' ~ 'Nayarit',
           ENTIDAD_RES == '19' ~ 'Nuevo Le?n',
           ENTIDAD_RES == '20' ~ 'Oaxaca',
           ENTIDAD_RES == '21' ~ 'Puebla',
           ENTIDAD_RES == '22' ~ 'Quer?taro',
           ENTIDAD_RES == '23' ~ 'Quintana Roo',
           ENTIDAD_RES == '24' ~ 'San Luis Potos?',
           ENTIDAD_RES == '25' ~ 'Sinaloa',
           ENTIDAD_RES == '26' ~ 'Sonora',
           ENTIDAD_RES == '27' ~ 'Tabasco',
           ENTIDAD_RES == '28' ~ 'Tamaulipas',
           ENTIDAD_RES == '29' ~ 'Tlaxcala',
           ENTIDAD_RES == '30' ~ 'Veracruz de Ignacio de la Llave',
           ENTIDAD_RES == '31' ~ 'Yucat?n',
           ENTIDAD_RES == '32' ~ 'Zacatecas',
           TRUE ~ 'Other'
         )) %>% 
  select(Sex, Age, date_c, date_d, Region) 

unique(db2$Region)

db_d <- db2 %>% 
  filter(!is.na(date_d))

db_c <- db2 %>% 
  filter(!is.na(date_c))

ages <- seq(0, 100, 1)

dates_d <- seq(min(db_d$date_d), max(max(db_d$date_d), max(db_c$date_c)), by = '1 day')

dates_c <- seq(min(db_c$date_c), max(max(db_d$date_d), max(db_c$date_c)), by = '1 day')


# deaths ---------------------------------------------------------------------------

db_d2 <- db_d %>% 
  group_by(Region, Sex, Age, date_d) %>% 
  summarise(new = n()) %>% 
  ungroup()

db_d3 <- db_d2 %>% 
  complete(Region, Sex, Age = ages, date_d = dates_d, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new),
         Age = as.character(Age),
         Measure = "Deaths") %>% 
  rename(date_f = date_d) %>% 
  select(-new)

# cases ---------------------------------------------------------------------------

db_c2 <- db_c %>% 
  group_by(Region, Sex, Age, date_c) %>% 
  summarise(new = n()) %>% 
  ungroup()

db_c3 <- db_c2 %>% 
  complete(Region, Sex, Age = ages, date_c = dates_c, fill = list(new = 0)) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new),
         Age = as.character(Age),
         Measure = "Cases") %>% 
  rename(date_f = date_c) %>% 
  select(-new)

# template for database ------------------------------------------------------------
db_dc <- bind_rows(db_d3, db_c3)

db_mx <- db_dc %>% 
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

db_mx_comp <- bind_rows(db_dc2, db_mx)

db_tot_age <- db_mx_comp %>% 
  group_by(Region, date_f, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

db_tot_sex <- db_mx_comp %>% 
  group_by(Region, date_f, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b")

db_tot <- db_mx_comp %>% 
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

db_all <- bind_rows(db_mx_comp, db_tot_age, db_tot_sex, db_tot)

db_all2 <- db_all %>% 
  left_join(db_inc) %>% 
  drop_na() %>% 
  filter((Region == "All" & date_f >= "2020-03-01") | date_f >= date_start)

db_final <- db_all2 %>% 
  mutate(Country = "Mexico",
         AgeInt = case_when(Age == "100" ~ "5",
                            Age == "TOT" ~ "",
                            Region == "All" | as.numeric(Age) < 5 ~ "1",
                            TRUE ~ "5"),
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         iso = case_when(
           Region == 'All' ~ 'MX',
           Region == 'Ciudad de M?xico' ~ 'MX_CMX',
           Region == 'Aguascalientes' ~ 'MX_AGU',
           Region == 'Baja California' ~ 'MX_BCN',
           Region == 'Baja California Sur' ~ 'MX_BCS',
           Region == 'Campeche' ~ 'MX_CAM',
           Region == 'Coahuila de Zaragoza' ~ 'MX_COA',
           Region == 'Colima' ~ 'MX_COL',
           Region == 'Chiapas' ~ 'MX_CHP',
           Region == 'Chihuahua' ~ 'MX_CHH',
           Region == 'Durango' ~ 'MX_DUR',
           Region == 'Guanajuato' ~ 'MX_GUA',
           Region == 'Guerrero' ~ 'MX_GRO',
           Region == 'Hidalgo' ~ 'MX_HID',
           Region == 'Jalisco' ~ 'MX_JAL',
           Region == 'M?xico' ~ 'MX_MEX',
           Region == 'Michoac?n de Ocampo' ~ 'MX_MIC',
           Region == 'Morelos' ~ 'MX_MOR',
           Region == 'Nayarit' ~ 'MX_NAY',
           Region == 'Nuevo Le?n' ~ 'MX_NLE',
           Region == 'Oaxaca' ~ 'MX_OAX',
           Region == 'Puebla' ~ 'MX_PUE',
           Region == 'Quer?taro' ~ 'MX_QUE',
           Region == 'Quintana Roo' ~ 'MX_ROO',
           Region == 'San Luis Potos?' ~ 'MX_SLP',
           Region == 'Sinaloa' ~ 'MX_SIN',
           Region == 'Sonora' ~ 'MX_SON',
           Region == 'Tabasco' ~ 'MX_TAB',
           Region == 'Tamaulipas' ~ 'MX_TAM',
           Region == 'Tlaxcala' ~ 'MX_TLA',
           Region == 'Veracruz de Ignacio de la Llave' ~ 'MX_VER',
           Region == 'Yucat?n' ~ 'MX_YUC',
           Region == 'Zacatecas' ~ 'MX_ZAC',
           TRUE ~ "Other"
         ),
         Code = paste0(iso, Date),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

test <- db_final %>% 
  filter(Sex == "b",
         Age == "TOT")


# slicing database by regions for uploading it to drive ----

table(db2$Region) %>% sort()


unique(db_final$Region)

db_final_mx <- db_final %>% 
  filter(Region == "All")

gr1 <- c('Ciudad de M?xico', 
         'Aguascalientes', 
         'Baja California', 
         'Baja California Sur')

gr2 <- c('Campeche', 
         'Coahuila de Zaragoza', 
         'Colima', 
         'Chiapas')

gr3 <- c('Chihuahua', 
         'Durango',
         'Guanajuato', 
         'Guerrero') 

gr4 <- c(
  'Hidalgo', 
  'Jalisco', 
  'M?xico', 
  'Michoac?n de Ocampo'
)

gr5 <- c(
  'Morelos', 
  'Nayarit', 
  'Nuevo Le?n', 
  'Oaxaca'
)

gr6 <- c(
  'Puebla', 
  'Quer?taro', 
  'Quintana Roo', 
  'San Luis Potos?'
)

gr7 <- c(
  'Sinaloa', 
  'Sonora', 
  'Tabasco', 
  'Tamaulipas'
)

gr8 <- c(
  'Tlaxcala', 
  'Veracruz de Ignacio de la Llave', 
  'Yucat?n', 
  'Zacatecas'
)


db_final_1 <- db_final %>% 
  filter(Region %in% gr1)

db_final_2 <- db_final %>% 
  filter(Region %in% gr2)

db_final_3 <- db_final %>% 
  filter(Region %in% gr3)

db_final_4 <- db_final %>% 
  filter(Region %in% gr4)

db_final_5 <- db_final %>% 
  filter(Region %in% gr5)

db_final_6 <- db_final %>% 
  filter(Region %in% gr6)

db_final_7 <- db_final %>% 
  filter(Region %in% gr7)

db_final_8 <- db_final %>% 
  filter(Region %in% gr8)


#########################
# Push dataframe to Drive -------------------------------------------------
#########################


rubric <- get_input_rubric()
ss_0   <- rubric %>% filter(Short == "MX") %>% dplyr::pull(Sheet)
ss_1   <- rubric %>% filter(Short == "MX_1") %>% dplyr::pull(Sheet)
ss_2   <- rubric %>% filter(Short == "MX_2") %>% dplyr::pull(Sheet)
ss_3   <- rubric %>% filter(Short == "MX_3") %>% dplyr::pull(Sheet)
ss_4   <- rubric %>% filter(Short == "MX_4") %>% dplyr::pull(Sheet)
ss_5   <- rubric %>% filter(Short == "MX_5") %>% dplyr::pull(Sheet)
ss_6   <- rubric %>% filter(Short == "MX_6") %>% dplyr::pull(Sheet)
ss_7   <- rubric %>% filter(Short == "MX_7") %>% dplyr::pull(Sheet)
ss_8   <- rubric %>% filter(Short == "MX_8") %>% dplyr::pull(Sheet)

ss_db  <- rubric %>% filter(Short == "MX") %>% dplyr::pull(Source)



sheet_write(db_final_mx,
            ss = ss_0,
            sheet = "database")

sheet_write(db_final_1,
            ss = ss_1,
            sheet = "database")

sheet_write(db_final_2,
            ss = ss_2,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_3,
            ss = ss_3,
            sheet = "database")

sheet_write(db_final_4,
            ss = ss_4,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_5,
            ss = ss_5,
            sheet = "database")

sheet_write(db_final_6,
            ss = ss_6,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_7,
            ss = ss_7,
            sheet = "database")

sheet_write(db_final_8,
            ss = ss_8,
            sheet = "database")

Sys.sleep(105)
N <- nrow(db_final_mx) + nrow(db_final_1) + nrow(db_final_2) + nrow(db_final_3) +
  nrow(db_final_4) + nrow(db_final_5) + nrow(db_final_6) + nrow(db_final_7) + nrow(db_final_8) 
log_update(pp = "Mexico", N = N)
#########################
# Push zip file to Drive -------------------------------------------------
#########################

date_f <- db %>% 
  filter(!is.na(FECHA_ACTUALIZACION)) %>% 
  dplyr::pull(FECHA_ACTUALIZACION) %>% 
  max()

date <- paste(sprintf("%02d",day(date_f)),
              sprintf("%02d",month(date_f)),
              year(date_f),
              sep=".")

filename <- paste0("MX", date, "cases&deaths.zip")

drive_upload(
  temp,
  path = ss_db,
  name = filename,
  overwrite = T)

unlink(temp)

