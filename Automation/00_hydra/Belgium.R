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
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# Loading data from the web
###########################

# vaccines
url_vcc <- "https://epistat.sciensano.be/Data/COVID19BE_VACC.csv"
data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vaccines_",today(), ".csv")
download.file(url_vcc, destfile = data_source_v, mode = "wb")

db_v <- read_csv(data_source_v)

# cases and deaths
url <- "https://epistat.sciensano.be/Data/COVID19BE.xlsx"
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/all_",today(), ".xlsx")
download.file(url, destfile = data_source_c, mode = "wb")

# cases and deaths database
db_c <- read_xlsx(data_source_c,
                  sheet = "CASES_AGESEX")

db_d <- read_xlsx(data_source_c,
                  sheet = "MORT")

db_t <- read_xlsx(data_source_c,
                  sheet = "TESTS")

data_source <- c(data_source_v, data_source_c)

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
  group_by(Date,Measure,Age,Sex,Region) %>% 
  summarize(new = sum(new)) %>% 
  ungroup() %>% 
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

db_v2 <- db_v %>% 
  select(Region = REGION,
         Date = DATE,
         Sex = SEX,
         Age = AGEGROUP,
         Measure = DOSE,
         new = COUNT) %>% 
  separate(Age, c("Age", "trash"), sep = "-") %>% 
  mutate(Date = ymd(Date),
         Measure = case_when(Measure == "A" ~ "Vaccination1", 
                             Measure == "B" ~ "Vaccination2",
                             Measure == "C" ~ "Vaccination2",
                             Measure == "E" ~ "Vaccination3",
                             Measure == "E2" ~ "Vaccination4"
                             ),
         Age = case_when(Age == "85+" ~ "85",
                         Age == "00" ~ "0",
                         Age == "05" ~ "5",
                         is.na(Age) ~ "UNK",
                         TRUE ~ Age),
         Sex = case_when(Sex == "M" ~ "m",
                         Sex == "F" ~ "f",
                         TRUE ~ "UNK"),
         Region = ifelse(is.na(Region), "UNK", Region),
         Region = ifelse(Region == "Ostbelgien", "Wallonia", Region)) %>% 
  select(-trash) %>% 
  group_by(Region, Date, Sex, Age, Measure) %>% 
  summarise(new = sum(new)) %>% 
  ungroup() %>% 
  tidyr::complete(Date, Region, Measure, Sex, Age, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region, Sex, Age, Measure) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new)


db_t2 <- db_t %>% 
  select(Region = REGION,
         Date = DATE,
         new = TESTS_ALL) %>% 
  mutate(Date = ymd(Date),
         Region = ifelse(is.na(Region), "UNK", Region)) %>% 
  group_by(Region, Date) %>% 
  summarize(new = sum(new), .groups = "drop") %>% 
  tidyr::complete(Date, Region, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Tests",
         Sex = "b",
         Age = "TOT") %>% 
  select(-new) 

db_nal <- bind_rows(db_cd2, db_t2, db_v2) %>% 
  group_by(Date, Measure, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Region = "All") %>% 
  ungroup()



#JD: Changed the AgeInt here, it was missing for the vaccine data 

out <- bind_rows(db_nal,
                 db_cd2 %>% 
                   filter(Region != "UNK"),
                 db_t2 %>% 
                   filter(Region != "UNK"),
                 db_v2 %>% 
                   filter(Region != "UNK")) %>% 
  mutate(Country = "Belgium",
         AgeInt = case_when(Measure == "Cases" & Age != "90" ~ 10L,
                            Measure == "Cases" & Age == "90" ~ 15L,
                            Measure == "Deaths" & Age == "0" ~ 25L,
                            Measure == "Deaths" & Age %in% c("25", "45") ~ 20L,
                            Measure == "Deaths" & Age == "65" ~ 10L,
                            Measure == "Deaths" & Age == "75" ~ 15L,
                            Measure == "Deaths" & Age == "90" ~ 15L,
                            #JD: The AgeInt information for vaccines was missing
                            Measure == "Vaccination1" & Age == "0" ~ 5L,
                            Measure == "Vaccination2" & Age == "0" ~ 5L,
                            Measure == "Vaccination3" & Age == "0" ~ 5L,
                            Measure == "Vaccination4" & Age == "0" ~ 5L,
                            
                            
                            Measure == "Vaccination1" & Age == "5" ~ 7L,
                            Measure == "Vaccination2" & Age == "5" ~ 7L,
                            Measure == "Vaccination3" & Age == "5" ~ 7L,
                            Measure == "Vaccination4" & Age == "5" ~ 7L,
                            
                            
                            Measure == "Vaccination1" & Age == "12" ~ 4L,
                            Measure == "Vaccination2" & Age == "12" ~ 4L,
                            Measure == "Vaccination3" & Age == "12" ~ 4L,
                            Measure == "Vaccination4" & Age == "12" ~ 4L,
                            
                            
                            Measure == "Vaccination1" & Age == "16" ~ 2L,
                            Measure == "Vaccination2" & Age == "16" ~ 2L,
                            Measure == "Vaccination3" & Age == "16" ~ 2L,
                            Measure == "Vaccination4" & Age == "16" ~ 2L,
                            
 
                            Measure == "Vaccination1" & Age == "18" ~ 7L,
                            Measure == "Vaccination2" & Age == "18" ~ 7L,
                            Measure == "Vaccination3" & Age == "18" ~ 7L,
                            Measure == "Vaccination4" & Age == "18" ~ 7L,
                            

                            Measure == "Vaccination1" & Age == "85" ~ 20L,
                            Measure == "Vaccination2" & Age == "85" ~ 20L,
                            Measure == "Vaccination3" & Age == "85" ~ 20L,
                            Measure == "Vaccination4" & Age == "85" ~ 20L,
                            
                            
                            Measure == "Vaccination1" & Age %in% c("25", "35", "45", "55","65","75") ~ 10L,
                            Measure == "Vaccination3" & Age %in% c("25", "35", "45", "55","65","75") ~ 10L,
                            Measure == "Vaccination2" & Age %in% c("25", "35", "45", "55","65","75") ~ 10L,
                            Measure == "Vaccination4" & Age %in% c("25", "35", "45", "55","65","75") ~ 10L),

         date_f = Date,
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         Code = case_when(
           Region == "All" ~ paste0("BE"),
           Region == "Flanders" ~ paste0("BE-VLG"),
           Region == "Wallonia" ~ paste0("BE-WAL"),
           Region == "Brussels" ~ paste0("BE-BRU")),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

#original final processing
# out <- bind_rows(db_nal,
#                  db_cd2 %>% 
#                    filter(Region != "UNK"),
#                  db_t2 %>% 
#                    filter(Region != "UNK"),
#                  db_v2 %>% 
#                    filter(Region != "UNK")) %>% 
#   mutate(Country = "Belgium",
#          AgeInt = case_when(Measure == "Cases" & Age != "90" ~ 10,
#                             Measure == "Cases" & Age == "90" ~ 15,
#                             Measure == "Deaths" & Age == "0" ~ 25,
#                             Measure == "Deaths" & Age %in% c("25", "45") ~ 20,
#                             Measure == "Deaths" & Age == "65" ~ 10,
#                             Measure == "Deaths" & Age == "75" ~ 15,
#                             Measure == "Deaths" & Age == "90" ~ 15),
#          date_f = Date,
#          Date = paste(sprintf("%02d",day(date_f)),
#                       sprintf("%02d",month(date_f)),
#                       year(date_f),
#                       sep="."),
#          Code = case_when(
#            Region == "All" ~ paste0("BE", Date),
#            Region == "Flanders" ~ paste0("BE_VLG", Date),
#            Region == "Wallonia" ~ paste0("BE_WAL", Date),
#            Region == "Brussels" ~ paste0("BE_BRU", Date)),
#          Metric = "Count") %>% 
#   arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
#   select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)

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

