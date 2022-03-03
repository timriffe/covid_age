library(readxl)
library(tidyverse)
library(ISOweek)
library(lubridate)
library(here)
source(here("Automation/00_Functions_automation.R"))

#install.packages("ISOweek")

if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address

ctr          <- "Switzerland_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


m_url <- "https://opendata.swiss/en/dataset/covid-19-schweiz"
links_age <- scraplinks(m_url) %>% 
  filter(str_detect(url, "COVID19VaccPersons_AKL10_w_v2.csv")) %>% 
  select(url) 

url_age <- 
  links_age %>% 
  select(url) %>% 
  dplyr::pull()


links_sex <- scraplinks(m_url) %>% 
  dplyr::filter(str_detect(url, "COVID19VaccPersons_sex_w_v2.csv")) %>% 
  select(url) 

url_sex <- 
  links_sex %>% 
  select(url) %>% 
  dplyr::pull()

#####vaccination by age
vacc <- read.csv(url_age)
vacc2 <- vacc %>% 
  dplyr::filter(type != "COVID19PartiallyVaccPersons") %>% 
  dplyr::filter(age_group_type == "age_group_AKL10") %>% 
  select(YearWeekISO = date, Region = geoRegion, Age = altersklasse_covid19, Measure = type, Value = sumTotal)
vacc2$YearWeekISO <- gsub("^(.{4})(.*)$",         # Apply gsub
                  "\\1-W\\2",
                  vacc2$YearWeekISO)
vacc2 <- vacc2 %>% 
  mutate(Day= "7")%>%
  unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE)%>%
  mutate(Date= ISOweek::ISOweek2date(ISODate))
vacc2 <- vacc2[-c(1,2,7)]
vacc2 <- vacc2 %>% 
  mutate(Age = case_when(
    Age == "0 - 9" ~ "0",
    Age == "10 - 19" ~ "10",
    Age == "20 - 29" ~ "20",
    Age == "30 - 39" ~ "30",
    Age == "40 - 49" ~ "40",
    Age == "50 - 59" ~ "50",
    Age == "60 - 69" ~ "60",
    Age == "70 - 79" ~ "70",
    Age == "80+" ~ "80")) 
vacc2 <- vacc2 %>% 
    mutate(AgeInt = case_when(
      Age == "80" ~ 25L,
      TRUE ~ 10L))
vacc3 <- vacc2 %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep=".")) %>% 
  mutate(Code = case_when(
    Region == "CH" ~ paste0("CH"),
    Region == "FL" ~ paste0("LI"),
    Region == "unknown" ~ "CH-UNK+",
  TRUE ~ paste0("CH-",Region)
    )) %>% 
  filter(Region != "CHFL") %>% 
  filter(Region != "all") %>% 
  mutate(Country = case_when(
    Region == "FL" ~ "Liechtenstein",
    TRUE ~ "Switzerland"
  )) %>% 
  mutate(Region = case_when(
    Region == "unknown" ~ "UNK",
    Region == "CH" ~ "All",
    Region == "FL" ~ "All",
    TRUE ~ Region
  )) %>% 
  mutate(Measure = case_when(
    Measure == "COVID19AtLeastOneDosePersons" ~ "Vaccination1",
    Measure == "COVID19FullyVaccPersons" ~ "Vaccination2",
    Measure == "COVID19FirstBoosterPersons" ~ "Vaccination3"
  )) %>% 
mutate(Sex = "b",
  Metric = "Count") %>% 
  filter(Region != "neighboring_chfl")






###vaccinations by sex
vaccsex <- read.csv(url_sex)
vaccsex2 <- vaccsex %>% 
  filter(type != "COVID19PartiallyVaccPersons") %>% 
  select(YearWeekISO = date, Region = geoRegion, Sex = sex, Measure = type, Value = sumTotal)
vaccsex2$YearWeekISO <- gsub("^(.{4})(.*)$",         # Apply gsub
                          "\\1-W\\2",
                          vaccsex2$YearWeekISO)
vaccsex2 <- vaccsex2 %>% 
  mutate(Day= "7")%>%
  unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE)%>%
  mutate(Date= ISOweek::ISOweek2date(ISODate))
vaccsex2 <- vaccsex2[-c(1,2,7)]
vaccsex2 <- vaccsex2 %>% 
  mutate(Sex = case_when(
    Sex == "female" ~ "f",
    Sex == "male" ~ "m",
    Sex == "unknown" ~ "UNK")) 
vaccsex2 <- vaccsex2 %>% 
  mutate(AgeInt = NA)
vaccsex3 <- vaccsex2 %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep=".")) %>% 
  mutate(Code = case_when(
    Region == "CH" ~ paste0("CH"),
    Region == "FL" ~ paste0("LI"),
    Region == "unknown" ~ "CH-UNK+",
    TRUE ~ paste0("CH-",Region)
  )) %>% 
  filter(Region != "CHFL") %>% 
  filter(Region != "all") %>% 
  mutate(Country = case_when(
    Region == "FL" ~ "Liechtenstein",
    TRUE ~ "Switzerland"
  )) %>% 
  mutate(Region = case_when(
    Region == "unknown" ~ "UNK",
    Region == "CH" ~ "All",
    Region == "FL" ~ "All",
    TRUE ~ Region
  )) %>% 
  mutate(Measure = case_when(
    Measure == "COVID19AtLeastOneDosePersons" ~ "Vaccination1",
    Measure == "COVID19FullyVaccPersons" ~ "Vaccination2",
    Measure == "COVID19FirstBoosterPersons" ~ "Vaccination3"
  )) %>% 
  mutate(Metric = "Count",
         Age = "TOT")%>% 
  filter(Region != "neighboring_chfl")


# ##death by sex
# 
# deathsex <- read.csv("https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Death_geoRegion_sex_w.csv")
# deathsex2 <- deathsex %>% 
#   select(YearWeekISO = datum, Region = geoRegion, Sex = sex, Measure = type, Value = sumTotal)
# deathsex2$YearWeekISO <- gsub("^(.{4})(.*)$",         # Apply gsub
#                              "\\1-W\\2",
#                              deathsex2$YearWeekISO)
# deathsex2 <- deathsex2 %>% 
#   mutate(Day= "7")%>%
#   unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE)%>%
#   mutate(Date= ISOweek::ISOweek2date(ISODate))
# deathsex2 <- deathsex2[-c(1,2,7)]
# deathsex2 <- deathsex2 %>% 
#   mutate(Sex = case_when(
#     Sex == "female" ~ "f",
#     Sex == "male" ~ "m",
#     Sex == "unknown" ~ "UNK")) 
# deathsex2 <- deathsex2 %>% 
#   mutate(AgeInt = NA)
# deathsex3 <- deathsex2 %>% 
#   mutate(Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep=".")) %>% 
#   mutate(Code = case_when(
#     Region == "CH" ~ paste0("CH_",Date),
#     Region == "FL" ~ paste0("FL_",Date),
#     TRUE ~ paste0("CH_",Region,"_",Date)
#   )) %>% 
#   filter(Region != "CHFL") %>% 
#   filter(Region != "all") %>% 
#   mutate(Country = case_when(
#     Region == "FL" ~ "Liechtenstein",
#     TRUE ~ "Switzerland"
#   )) %>% 
#   mutate(Region = case_when(
#     Region == "unknown" ~ "UNK",
#     Region == "CH" ~ "All",
#     Region == "FL" ~ "All",
#     TRUE ~ Region
#   )) %>% 
#   mutate(Measure = case_when(
#     Measure == "COVID19Death" ~ "Deaths"
#   )) %>% 
#   mutate(Metric = "Count",
#          Age = "TOT")
# 
# ##death by age
# death <- read.csv("https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Death_geoRegion_AKL10_w.csv")
# death2 <- death %>% 
#   select(YearWeekISO = datum, Region = geoRegion, Age = altersklasse_covid19, Measure = type, Value = sumTotal)
# death2$YearWeekISO <- gsub("^(.{4})(.*)$",         # Apply gsub
#                           "\\1-W\\2",
#                           death2$YearWeekISO)
# death2 <- death2 %>% 
#   mutate(Day= "7")%>%
#   unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE)%>%
#   mutate(Date= ISOweek::ISOweek2date(ISODate))
# death2 <- death2[-c(1,2,7)]
# death2 <- death2 %>% 
#   mutate(Age = case_when(
#     Age == "0 - 9" ~ "0",
#     Age == "10 - 19" ~ "10",
#     Age == "20 - 29" ~ "20",
#     Age == "30 - 39" ~ "30",
#     Age == "40 - 49" ~ "40",
#     Age == "50 - 59" ~ "50",
#     Age == "60 - 69" ~ "60",
#     Age == "70 - 79" ~ "70",
#     Age == "80+" ~ "80",
#     Age == "Unbekannt" ~ "UNK")) 
# death2 <- death2 %>% 
#   mutate(AgeInt = case_when(
#     Age == "80" ~ 25L,
#     TRUE ~ 10L))
# death3 <- death2 %>% 
#   mutate(Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep=".")) %>% 
#   mutate(Code = case_when(
#     Region == "CH" ~ paste0("CH_",Date),
#     Region == "FL" ~ paste0("FL_",Date),
#     TRUE ~ paste0("CH_",Region,"_",Date)
#   )) %>% 
#   filter(Region != "CHFL") %>% 
#   filter(Region != "all") %>% 
#   mutate(Country = case_when(
#     Region == "FL" ~ "Liechtenstein",
#     TRUE ~ "Switzerland"
#   )) %>% 
#   mutate(Region = case_when(
#     Region == "unknown" ~ "UNK",
#     Region == "CH" ~ "All",
#     Region == "FL" ~ "All",
#     TRUE ~ Region
#   )) %>% 
#   mutate(Measure = case_when(
#     Measure == "COVID19Death" ~ "Deaths"
#   )) %>% 
#   mutate(Sex = "b",
#          Metric = "Count")
# 
# 
# 
# ##cases sex
# https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Cases_geoRegion_sex_w.csv
# ##cases age
# https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Cases_geoRegion_AKL10_w.csv
# 
# ##test sex
# https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Test_geoRegion_sex_w.csv
# 
# ##test age
# https://www.covid19.admin.ch/api/data/20211116-0ahpfn1y/sources/COVID19Test_geoRegion_AKL10_w.csv
# 
# 
# 
# 
# 
# 
# 




out <- rbind(vacc3, vaccsex3) %>%   
 sort_input_data()
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

#zip input data
cases_url1 <- url_age
data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccination_age",today(), ".csv")
cases_url2 <- url_sex
data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccination_sex",today(), ".csv")
download.file(cases_url1, destfile = data_source1, mode = "wb")
download.file(cases_url2, destfile = data_source2, mode = "wb")


data_source <- c(data_source1, data_source2)

zipname <- paste0(dir_n,
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)
