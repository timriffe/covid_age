library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Italy"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# links to spreadsheet in Drive
# rubric_i <- get_input_rubric() %>% filter(Short == "IT")
# ss_i     <- rubric_i %>% dplyr::pull(Sheet)
# 
# db_drive <- get_country_inputDB("IT")
# 
# last_date_drive <- db_drive %>% 
#   mutate(date_f = dmy(Date)) %>% 
#   dplyr::pull(date_f) %>% 
#   max()

###get the last update from drive and select deaths and cases
it <- read_rds(paste0(dir_n, ctr, ".rds"))

it <- it %>% 
  filter(Measure == "Cases" | Measure == "Deaths")
  
  last_date_n <- it %>%
  mutate(date_f = dmy(Date)) %>%
  dplyr::pull(date_f) %>%
  max()
# loading Excel file from the website 
# "https://www.epicentro.iss.it/coronavirus/sars-cov-2-sorveglianza-dati"
data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", today(), ".xlsx")
link <- "https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx"
download.file(link, data_source, mode = "wb")

db_age <- read_xlsx(data_source, sheet = "sesso_eta")
# db_tot <- read_xlsx(data_source, sheet = "casi_regioni")

date_f <- db_age %>% dplyr::pull(iss_date) %>% unique() %>% dmy

if (date_f > last_date_n){
  
  db_age2 <- db_age %>% 
    rename(Sex = SESSO,
           Age = AGE_GROUP,
           Deaths = DECEDUTI, 
           Cases = CASI_CUMULATIVI) %>% 
    mutate(Sex = recode(Sex,
                        "M" = "m",
                        "F" = "f",
                        "Non noto" = "UNK"),
           Age = str_sub(Age, 1, 2),
           Age = recode(Age,
                        "0-" = "0",
                        ">9" = "90",
                        "No" = "UNK"),
           Cases = recode(Cases,
                          "<5" = "2"),
           Deaths = recode(Deaths,
                          "<5" = "2")) %>% 
    gather(Cases, Deaths, key = Measure, value = Value) %>% 
    mutate(Value = as.integer(Value)) %>% 
    select(-iss_date)

  

  db_sex_t <- db_age2 %>% 
    group_by(Age, Measure) %>% 
    summarize(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Sex = "b")
  
  db_tot <- db_sex_t %>% 
    group_by(Measure, Sex) %>% 
    summarize(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT")
  
  db_age_t <- db_age2 %>% 
    group_by(Sex, Measure) %>% 
    summarize(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT")
  
  out_drive <- bind_rows(db_age2, db_sex_t, db_tot, db_age_t) %>% 
    filter(!(Age == "UNK" | Sex == "UNK")) %>% 
    mutate(Country = "Italy",
           Region = "All",
           Date = ddmmyyyy(date_f),
           Code = "IT",
           AgeInt = case_when(Age == "90" ~ 15,
                              TRUE ~ 10),
           Metric = "Count") %>% 
    sort_input_data()
    
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  # sheet_append(out_drive,
  #              ss = ss_i,
  #              sheet = "database")

} 

# Vaccination data

## Source Website: https://github.com/italia/covid19-opendata-vaccini/

vacc <- read_csv("https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/master/dati/somministrazioni-vaccini-latest.csv")
# write_rds(vacc, "")

vacc2 <- vacc %>% 
  rename(Date = data,
         Age = eta, 
         Vaccination1 = d1,
         Vaccination2 = d2,
         Vaccination3 = db1,
         Vaccination4 = db2) %>% 
  select(Date, Age, Vaccination1, Vaccination2, 
         Vaccination3, Vaccination4) %>% 
  gather(Vaccination1, Vaccination2, Vaccination3, 
         Vaccination4, key = "Measure", value = new) %>% 
  mutate(Age = as.integer(str_sub(Age, 1, 2))) %>% 
  group_by(Date, Measure, Age) %>% 
  summarise(new = sum(new)) %>% 
  ungroup()
ages <- c(0, unique(vacc2$Age)) %>% sort()

vacc3 <- vacc2 %>% 
  tidyr::complete(Measure, Age = ages, Date, fill = list(new = 0))  %>% 
  group_by(Measure, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  arrange(Date, Measure, Age) %>% 
  ungroup() %>% 
  mutate(Country = "Italy",
       Region = "All",
       Date = ddmmyyyy(Date),
       Code = "IT",
       Sex = "b",
       Age = as.character(Age),
       AgeInt = case_when(Age == "90" ~ 15,
                          Age == "0" ~ 16,
                          Age == "16" ~ 4,
                          TRUE ~ 10),
       Metric = "Count") %>% 
  sort_input_data()

##get totals from a different source
library(reshape2)
totals <- read.csv("https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv")
totals <- totals %>% 
  select(Date = data, Cases = totale_casi, Deaths = deceduti)
totals <- melt(totals, id = "Date")
names(totals)[2] <- "Measure"
names(totals)[3] <- "Value"
totals$Date = substr(totals$Date,1,nchar(totals$Date)-9)

totals <- totals %>% 
  mutate(Sex = "b",
         Country = "Italy",
         Region = "All",
         Age = "TOT",
         AgeInt = NA,
         Metric = "Count",
         Date = ymd(Date),
         Date = ddmmyyyy(Date),
         Code = "IT")%>% 
  sort_input_data()


out <- 
  bind_rows(out_drive, 
            vacc3, it)%>%
  filter(Age != "TOT") %>% 
  sort_input_data()

out <- bind_rows(out, totals) %>% 
  unique() %>% 
  # group_by(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure) %>% #this was a one time fix 
  # summarise(Value = sum(Value)) %>% 
  # ungroup() %>% 
  sort_input_data()
nrow(out_drive)
nrow(vacc3)
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out_drive) + nrow(vacc3))

# Italy adjustment of Bolletino and Infographic sources in one sheet
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# (Only Once!!!!)

#  db_bol <- get_country_inputDB("ITbol")
#  db_inf <- get_country_inputDB("ITinfo")
# # 
#  db_inf2 <- db_inf %>% 
#    filter(Measure != "ASCFR") %>% 
#    mutate(Date = dmy(Date))
# # 
#  info_dates <- db_inf2 %>% 
#    select(Date) %>% 
#    dplyr::pull()
# # 
#  clean_bol <- db_bol %>% 
#    mutate(Date = dmy(Date)) %>% 
#    filter(!(Measure == "Deaths" & Sex == "b" & Date %in% info_dates)) %>% 
#    arrange(Date, Measure, Sex, Age)
# # 
#  out <- bind_rows(db_inf2, 
#                   clean_bol) %>% 
#    arrange(Date, Measure, Sex, Age) %>% 
#    mutate(Date = ddmmyyyy(Date),
#           Code = paste0("IT", Date)) %>% 
#    select(-Short)
# # 
#  test <- 
#  out %>% 
#    filter(Age == 0) %>% 
#    group_by(Date, Measure, Sex) %>% 
#    summarise(n())
# 
# sheet_append(out,
#              ss = ss_i,
#              sheet = "database")



#ita <- read_rds(paste0(dir_n, ctr, ".rds"))

