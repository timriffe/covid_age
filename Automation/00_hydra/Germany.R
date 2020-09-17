# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")


library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = email)
gs4_auth(email = email)

# TR: pull urls from rubric instead 
de_rubric <- get_input_rubric() %>% filter(Short == "DE")
ss_i   <- de_rubric %>% dplyr::pull(Sheet)
ss_db  <- de_rubric %>% dplyr::pull(Source)



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
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to ="Value") %>% 
  group_by(Region, Sex, Measure, date_f, Age) %>% 
  summarize(Value = sum(Value)) %>% 
  ungroup()
  

# unique(db2$Region)
# unique(db2$date_f)

ages    <- unique(db2$Age)
sexes   <- unique(db2$Sex)
regions <- unique(db2$Region)
date_range <- range(db2$date_f)

# we can expand on days too
dates   <- seq(date_range[1],date_range[2],by="days")

# TR: This replaces a big manual loop
db_all <- db2 %>% 
  group_by(Region, Measure) %>% 
  expand(Sex = sexes, Age = ages, date_f = dates) %>% 
  left_join(., db2) %>% 
  replace_na(list(Value = 0)) %>% 
  ungroup() %>% 
  arrange(Region, Sex, Measure, Age, date_f) %>% 
  group_by(Region, Sex, Measure, Age) %>% 
  mutate(Value = cumsum(Value))
  

db_region <- db_all %>% 
  mutate(Country = "Germany",
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
         AgeInt = case_when(Age == "0" ~ 5,
                            Age == "5" ~ 10,
                            Age == "15" ~ 20,
                            Age == "35" ~ 25,
                            Age == "60" ~ 20,
                            Age == "80" ~ 25,
                            Age == "UNK" ~ NA_real_),
         Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

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
         AgeInt = case_when(Age == "0" ~ 5,
                            Age == "5" ~ 10,
                            Age == "15" ~ 20,
                            Age == "35" ~ 25,
                            Age == "60" ~ 20,
                            Age == "80" ~ 25,
                            Age == "UNK" ~ NA_real_),
         Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()



db_full <- bind_rows(db_germany, db_region) 
  
# Remove days where cumulative sum is 0.
db_full <-
  db_full %>% 
  group_by(Region, Measure, date_f = dmy(Date)) %>% 
  mutate(N = sum(Value)) %>% 
  filter(N > 0) %>% 
  filter(!(Sex == "UNK" & Value == 0),
         !(Age == "UNK" & Value == 0)) %>% 
  select(-date_f, -N) %>% 
  sort_input_data()
  
  

############################################
#### comparison with reported aggregate data
############################################

# comparison with aggregate data reported online in 
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html


db_full %>% 
  filter(Date == "28.08.2020") %>% 
  group_by(Region, Measure) %>% 
  summarize(N = sum(Value)) %>% 
  select(Region, Measure, N) %>% 
  pivot_wider(names_from = Measure, values_from = N)
  

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(db_full,
            ss = ss_i,
            sheet = "database")

log_update(pp = "Germany", N = nrow(db_full))

############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("DE", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = ss_db, 
                     type = "spreadsheet",
                     overwrite = TRUE)

write_sheet(db, 
            ss = meta$id,
            sheet = "cases&deaths_age_sex")



sheet_delete(meta$id, "Sheet1")

