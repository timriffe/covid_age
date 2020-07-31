rm(list=ls())
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

db <- read_csv("https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv")

unique(db$Geschlecht)

db2 <- db %>% 
  mutate(Sex = case_when(Geschlecht == "M" ~ "m",
                         Geschlecht == "W" ~ "f",
                         Geschlecht == "unbekannt" ~ "UNK"),
         Age = case_when(Altersgruppe == "A00-A04" ~ "0",
                         Altersgruppe == "A05-A14" ~ "5",
                         Altersgruppe == "A15-A34" ~ "15",
                         Altersgruppe == "A35-A59" ~ "35",
                         Altersgruppe == "A60-A79" ~ "60",
                         Altersgruppe == "A80+" ~ "80",
                         Altersgruppe == "unbekannt" ~ "UNK"),
         date_f = ymd(str_sub(Meldedatum, 1, 10)),
         Cases = ifelse(AnzahlFall < 0, 0, AnzahlFall),
         Deaths = ifelse(AnzahlTodesfall < 0, 0, AnzahlTodesfall),
         Region = Bundesland) %>% 
  select(date_f, Sex, Age, Cases, Deaths, Region) %>% 
  gather('Cases', 'Deaths', key = 'Measure', value = 'Value')
  

unique(db2$Region)
unique(db2$date_f)

ages <- unique(db2$Age)
sexes <- unique(db2$Sex)
regions <- unique(db2$Region)

empty_db <- expand_grid(Region = regions, Measure = c("Cases", "Deaths"), Sex = c("m", "f", "b"), Age = c("0", "5", "15", "35", "60", "80")) %>%
  bind_rows(expand_grid(Region = regions, Measure = c("Cases", "Deaths"), Sex = "b", Age = "TOT"))

db_all <- NULL

min(db2$date_f)
max(db2$date_f)
date_start <- dmy("01/03/2020")
date_end <- max(db2$date_f)
ref <- date_start

while (ref <= date_end){
  print(ref)
  
  db3 <- db2 %>% 
    filter(date_f <= ref)

  db4 <- db3 %>% 
    group_by(Age, Sex, Region, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup()
  
  db5 <- db3 %>% 
    group_by(Age, Region, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    mutate(Sex = "b") %>% 
    ungroup()

  db6 <- db3 %>% 
    group_by(Sex, Region, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    mutate(Age = "TOT") %>% 
    ungroup()
  
  db7 <- db3 %>% group_by(Measure, Region) %>% 
    group_by(Region, Measure) %>% 
    summarise(Value = sum(Value))%>% 
    mutate(Sex = "b",
           Age = "TOT") %>% 
    ungroup()
  
  db8 <- bind_rows(db4, db5, db6, db7)
  
  db9 <- empty_db %>% 
    left_join(db8) %>% 
    mutate(date_f = ref)

  db_all <- bind_rows(db_all, db9)
  
  ref = ref + 1
}  

db_region <- db_all %>% 
  mutate(Value = replace_na(Value, 0),
         Country = "Germany",
         Code1 = case_when(Region == 'Baden-Württemberg' ~ 'DE_BW_',
                            Region == 'Bayern' ~ 'DE_BY_',
                            Region ==  'Berlin' ~ 'DE_BE_',
                            Region == 'Brandenburg' ~ 'DE_BB_',
                            Region == 'Bremen' ~ 'DE_HB_',
                            Region == 'Hamburg' ~ 'DE_HH_',
                            Region ==  'Hessen' ~ 'DE_HE_',
                            Region ==  'Mecklenburg-Vorpommern' ~ 'DE_MV_',
                            Region == 'Niedersachsen' ~ 'DE_NI_',
                            Region == 'Nordrhein-Westfalen' ~ 'DE_NW_',
                            Region == 'Rheinland-Pfalz' ~ 'DE_RP_',
                            Region == 'Saarland' ~ 'DE_SL_',
                            Region == 'Sachsen' ~ 'DE_SN_',
                            Region == 'Sachsen-Anhalt' ~ 'DE_ST_',
                            Region == 'Schleswig-Holstein' ~ 'DE_SH_',
                            Region == 'Thüringen' ~ 'DE_TH_',
                            TRUE ~ "other"),
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0(Code1, Date),
         AgeInt = case_when(Age == "0" ~ "5",
                            Age == "5" ~ "10",
                            Age == "15" ~ "20",
                            Age == "35" ~ "25",
                            Age == "60" ~ "20",
                            Age == "80" ~ "25",
                            Age == "UNK" ~ ""),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

db_germany <- db_all %>% 
  mutate(Value = replace_na(Value, 0)) %>% 
  group_by(date_f, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Country = "Germany",
         Region = "All",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("DE_", Date),
         AgeInt = case_when(Age == "0" ~ "5",
                            Age == "5" ~ "10",
                            Age == "15" ~ "20",
                            Age == "35" ~ "25",
                            Age == "60" ~ "20",
                            Age == "80" ~ "25",
                            Age == "UNK" ~ ""),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

unique(db_all$Region)

db_full <- bind_rows(db_germany, db_region)

############################################
#### comparison with reported aggregate data
############################################

# comparison with aggregate data reported online in 
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html

db_full %>%
  filter(dmy(Date) == max(db2$date_f),
         Sex == "b",
         Age == "TOT") %>%
  select(Region, Measure, Value) %>% 
  spread(Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db_full,
            ss = "https://docs.google.com/spreadsheets/d/12OavEjjo6I4FdLfqZv0g1iTXy9R8bCK0RD82fuqJpc0/edit#gid=1548224005",
            sheet = "database")

############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("DE", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1vx35ThBgKkPxHt6K8ZCOtFXyQhJfOFDe?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "cases&deaths_age_sex")

sheet_delete(meta$id, "Sheet1")