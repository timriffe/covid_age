library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Belgium"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
# dir_n <- "Data/Belgium/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Loading data from the web
###########################
url <- "https://epistat.sciensano.be/Data/COVID19BE.xlsx"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/all_",today(), ".xlsx")

download.file(url, destfile = data_source, mode = "wb")

# cases and deaths database
db_c <- read_xlsx(data_source,
                  sheet = "CASES_AGESEX")

db_d <- read_xlsx(data_source,
                  sheet = "MORT")

db_t <- read_xlsx(data_source,
                  sheet = "TESTS")

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

# Building database
################### 
# mortality data only at regional level, not provincial, so all data in Regional...
last_date <- db_c %>%
  mutate(last_d = max(ymd(DATE), na.rm = T)) %>% 
  dplyr::pull(last_d) %>% 
  max()

db_c2 <- db_c %>% 
  select(Region = REGION,
         Date = DATE,
         Sex = SEX,
         Age = AGEGROUP,
         new = CASES) %>% 
  separate(Age, c("Age", "trash"), sep = "-") %>% 
  mutate(Date = ymd(Date),
         Measure = "Cases",
         Age = case_when(Age == "90+" ~ "90",
                         is.na(Age) ~ "UNK",
                         TRUE ~ Age),
         Sex = case_when(Sex == "M" ~ "m",
                         Sex == "F" ~ "f",
                         TRUE ~ "UNK"),
         Region = ifelse(is.na(Region), "UNK", Region)) %>% 
  select(-trash) %>% 
  replace_na(list(Date = last_date)) %>% 
  tidyr::complete(Date, Region, Measure, Sex, Age, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region, Sex, Age, Measure) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new) 

db_d2 <- db_d %>% 
  select(Region = REGION,
         Date = DATE,
         Sex = SEX,
         Age = AGEGROUP,
         new = DEATHS) %>% 
  separate(Age, c("Age", "trash"), sep = "-") %>% 
  mutate(Date = ymd(Date),
         Measure = "Deaths",
         Age = case_when(Age == "85+" ~ "90",
                         is.na(Age) ~ "UNK",
                         TRUE ~ Age),
         Sex = case_when(Sex == "M" ~ "m",
                         Sex == "F" ~ "f",
                         TRUE ~ "UNK"),
         Region = ifelse(is.na(Region), "UNK", Region)) %>% 
  select(-trash) %>% 
  replace_na(list(Date = last_date)) %>% 
  tidyr::complete(Date, Region, Measure, Sex, Age, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region, Sex, Age, Measure) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new) 

db_cd <- bind_rows(db_c2, db_d2)

db_cd_sex <- db_cd %>% 
  group_by(Date, Region, Measure, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b") %>% 
  filter(Age != "UNK")

db_cd_age <- db_cd %>% 
  group_by(Date, Region, Measure, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT") %>% 
  filter(Sex != "UNK")

db_cd2 <- db_cd %>% 
  filter(Age != "UNK" & Sex != "UNK") %>% 
  bind_rows(db_cd_sex, db_cd_age) 

db_t2 <- db_t %>% 
  select(Region = REGION,
         Date = DATE,
         new = TESTS_ALL) %>% 
  mutate(Date = ymd(Date),
         Region = ifelse(is.na(Region), "UNK", Region)) %>% 
  tidyr::complete(Date, Region, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Tests",
         Sex = "b",
         Age = "TOT") %>% 
  select(-new) 

db_nal <- bind_rows(db_cd2, db_t2) %>% 
  group_by(Date, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Region = "All") %>% 
  ungroup()

unique(db_c2$Age)
unique(db_d2$Age)

out <- bind_rows(db_nal,
                 db_cd2 %>% 
                   filter(Region != "UNK"),
                 db_t2 %>% 
                   filter(Region != "UNK")) %>% 
  mutate(Country = "Belgium",
         AgeInt = case_when(Measure == "Cases" & Age != "90" ~ 10,
                            Measure == "Cases" & Age == "90" ~ 15,
                            Measure == "Deaths" & Age == "0" ~ 25,
                            Measure == "Deaths" & Age %in% c("25", "45") ~ 20,
                            Measure == "Deaths" & Age == "65" ~ 10,
                            Measure == "Deaths" & Age == "75" ~ 15,
                            Measure == "Deaths" & Age == "90" ~ 15),
         date_f = Date,
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         Code = case_when(
           Region == "All" ~ paste0("BE", Date),
           Region == "Flanders" ~ paste0("BE_VLG", Date),
           Region == "Wallonia" ~ paste0("BE_WAL", Date),
           Region == "Brussels" ~ paste0("BE_BRU", Date)),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

unique(out$Region)
unique(out$Age)
unique(out$Sex)
unique(out$Date)

############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

