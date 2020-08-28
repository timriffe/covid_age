# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "tim.riffe@gmail.com"
setwd("C:/Users/riffe/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(lubridate)
library(rvest)
library(zip)

drive_auth(email = email)
gs4_auth(email = email)

rubric <- get_input_rubric()
ss_0   <- rubric %>% filter(Short == "PE") %>% dplyr::pull(Sheet)
ss_1   <- rubric %>% filter(Short == "PE_1") %>% dplyr::pull(Sheet)
ss_2   <- rubric %>% filter(Short == "PE_2") %>% dplyr::pull(Sheet)
ss_3   <- rubric %>% filter(Short == "PE_3") %>% dplyr::pull(Sheet)
ss_4   <- rubric %>% filter(Short == "PE_4") %>% dplyr::pull(Sheet)
ss_5   <- rubric %>% filter(Short == "PE_5") %>% dplyr::pull(Sheet)
ss_6   <- rubric %>% filter(Short == "PE_6") %>% dplyr::pull(Sheet)

ss_db  <- rubric %>% filter(Short == "PE") %>% dplyr::pull(Source)

# ---------


m_url1 <- "https://www.datosabiertos.gob.pe/dataset/casos-positivos-por-covid-19-ministerio-de-salud-minsa"
m_url2 <- "https://www.datosabiertos.gob.pe/dataset/fallecidos-por-covid-19-ministerio-de-salud-minsa"

html1 <- read_html(m_url1)
html2 <- read_html(m_url2)

# locating the links for Excel files
url1 <- html_nodes(html1, xpath = '//*[@id="data-and-resources"]/div/div/ul/li/div/span/a') %>%
  html_attr("href")

url2 <- html_nodes(html2, xpath = '//*[@id="data-and-resources"]/div/div/ul/li/div/span/a') %>%
  html_attr("href")

db_c <- read_csv(url1) %>% 
  as_tibble()

db_d <- read_csv(url2) %>% 
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
  complete(Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
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

dates_f <- seq(min(db_c2$date_f),max(db_c2$date_f), by = '1 day')

db_c3 <- db_c2 %>% 
  complete(Region, Sex, Age = ages, date_f = dates_f, fill = list(new = 0)) %>% 
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

db_final <- db_all2 %>% 
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


# slicing database by regions to uploading it to drive

table(db_final$Region) %>% sort()

unique(db_final$Region)

regions <- db_final %>% pull(Region) %>% unique()

db_final_pe <- db_final %>% 
  filter(Region == "All")

db_final_1 <- db_final %>% 
  filter(Region %in% regions[2:4])

db_final_2 <- db_final %>% 
  filter(Region %in% regions[5:7])

db_final_3 <- db_final %>% 
  filter(Region %in% regions[8:10])

db_final_4 <- db_final %>% 
  filter(Region %in% regions[11:13])

db_final_5 <- db_final %>% 
  filter(Region %in% regions[14:18])

db_final_6 <- db_final %>% 
  filter(Region %in% regions[19:length(regions)])

#########################
# Push dataframe to Drive -------------------------------------------------
#########################

sheet_write(db_final_pe,
            ss = ss_0,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_1,
            ss = ss_1,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_2,
            ss = ss_2,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_3,
            ss = ss_3,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_4,
            ss = ss_4,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_5,
            ss = ss_5,
            sheet = "database")

Sys.sleep(105)

sheet_write(db_final_6,
            ss = ss_6,
            sheet = "database")

Sys.sleep(105)

#########################
# Push zip file to Drive -------------------------------------------------
#########################

date_f <- db_d2 %>% 
  filter(!is.na(date_f)) %>% 
  pull(date_f) %>% 
  max()

date <- paste(sprintf("%02d",day(date_f)),
              sprintf("%02d",month(date_f)),
              year(date_f),
              sep=".")

filename_c <- file.path("Data",paste0("PE", date, "cases.csv"))
filename_d <- file.path("Data",paste0("PE", date, "deaths.csv"))



write_csv(db_c, filename_c)
write_csv(db_d, filename_d)

filename <- file.path("Data",paste0("PE", date, "cases&deaths.zip"))

files <- c(filename_c, filename_d)
zip(filename, files, compression_level = 9)

drive_upload(
  filename,
  path = ss_db,
  name = filename,
  overwrite = T)


file.remove(filename)
file.remove(filename_c)
file.remove(filename_d)