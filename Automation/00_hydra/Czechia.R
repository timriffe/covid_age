library(here)
source(here("Automation/00_Functions_automation.R"))

library(tidyverse)
library(googlesheets4)
library(dplyr)
library(xml2)
library(rvest)
library(lubridate)
library(googledrive)


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "e.delfava@gmail.com"
}

# info country and N drive address
ctr <- "Czechia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

###########################################
################ CASES ####################
###########################################

CZNUTS3 <- tibble(
  code = c("CZ010", "CZ020", "CZ031", "CZ032", 
           "CZ041", "CZ042", "CZ051", "CZ052", 
           "CZ053", "CZ063", "CZ064", "CZ071", 
           "CZ072", "CZ080"), 
  name = c("Prague", "Central Bohemia", "South Bohemia", "Plzen", 
           "Karlovy Vary", "Usti nad Labe", "Liberec", "Hradec Kralove", 
           "Pardubice", "Vysocina", "South Moravia", "Olomouc", 
           "Zlin", "Moravian-Silesian")
)
Lookup <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1gbP_TTqc96PxeZCpwKuZJB1sxxlfbBjlQj-oxXD2zAs/edit#gid=0") %>% 
  dplyr::filter(Country == "Czechia") %>% 
  select(Region, Code = `ISO 3166-2`, `Natural Region Names` ) %>% 
  rename(name = Region)

CZNUTS3 <-
  CZNUTS3 %>% 
  left_join(Lookup, by = c("name"))

# Getting the data from the Health Ministry website
cases_url <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/osoby.csv" 


cz_cases <- read_csv(cases_url) # note id col is now in front, and other
# column order should be checked. read_csv() gives us these names:
 # "id","datum","vek","pohlavi","kraj_nuts_kod",
 # "okres_lau_kod","nakaza_v_zahranici" , "nakaza_zeme_csu_kod", "reportovano_khs"
cz_cases2 <-
  cz_cases %>% 
  select(Date = datum, Age = vek, Sex2 = pohlavi, code = kraj_nuts_kod, LAU1 = okres_lau_kod) %>% 
  mutate(Sex = ifelse(Sex2 == "M","m","f")) %>% 
  select(-Sex2) %>% 
  # extracting NUTS3 from LAU1 when NUTS3 is empty
  mutate(code = ifelse(code == "", str_sub(LAU1, 1, 5), code))

# cz_cases2 %>%  dplyr::pull("Age") %>%  unique()

Ages_All <- c(0,1,seq(5,100,by=5))
DateRange <- range(cz_cases2$Date)
Dates_All <- seq(DateRange[1],DateRange[2],by="days")




# TR:7 Dec 2021: the results here contain duplicates of (Sex, Age, Date, Measure, Metric), needs checking
### DATA ON NUTS3 level
cz_cases_region_ss <- 
  cz_cases2 %>% 
  left_join(CZNUTS3, by = "code") %>% 
  select(Code, Date, Sex, Age) %>% 
  mutate(Age = case_when(between(Age,1,4) ~ 1,
                         Age >= 100 ~ 100,
                         TRUE ~ Age - Age %% 5),
         Code = ifelse(is.na(Code),"UNK",Code)) %>% 
  mutate(Age = as.character(Age),
         Age = case_when(is.na(Age) ~ "UNK",
                         TRUE ~ Age)) %>% 
  ### select
  select(Code, Date, Sex, Age) %>% 
  group_by(Code, Date, Age, Sex) %>% 
  summarise(Value = n(), .groups = "drop") %>% 
  ### complete = Turns implicit missing values into explicit 0s 
  tidyr::complete(
    Code = CZNUTS3$Code, 
    Date = Dates_All, 
    Age, 
    Sex, 
    fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>%  
  arrange(Code, Date, Sex, Age) %>% 
  mutate(Country = "Czechia",
         AgeInt = case_when(Age == 0 ~ 1,
                            Age == 1 ~ 4,
                            TRUE ~ 5), # what about the 100+? 
         Metric = "Count", 
         Measure = "Cases",
         Date = ddmmyyyy(Date)) %>% 
  left_join(CZNUTS3, by = "Code") %>% 
  select(Country, 
         Region = `Natural Region Names`,
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)

# cz_cases_region_ss %>% 
#   group_by(Region,Sex,Age,Date,Measure,Metric) %>% 
#   mutate(n = n(),
#          i = 1:n()) %>% 
#   ungroup() %>% 
#   filter(n>1)


###########################################
################ DEATHS ###################
###########################################

# Getting the data from the Health Ministery website
deaths_url <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/umrti.csv"

# TR: 7 Dec, 2021: this should be read in using read_csv() and colnames matched using select(),
# as in the above for cases.
cz_deaths_in <- read_csv(deaths_url)

cz_deaths2 <-
  cz_deaths_in %>% 
  select(Date = datum, Age = vek, Sex = pohlavi, code = kraj_nuts_kod, LAU1 = okres_lau_kod) %>% 

  mutate(Sex = case_when(Sex == "M" ~ "m",
                         TRUE ~ "f"), 
         code = ifelse(code == "", str_sub(LAU1, 1, 5), code)) %>% 
  left_join(CZNUTS3, by = "code") %>% 
  select(Code, Date, Sex, Age) 

# cz_deaths2 %>%  dplyr::pull(Age) %>%  unique()


# we'll use the same Ages_All

DateRangeD <- range(cz_deaths2$Date)
Dates_AllD <- seq(DateRange[1],DateRange[2],by="days")

### DATA ON NUTS3 level
cz_deaths_region_ss <- 
  cz_deaths2 %>% 
  mutate(Age5 = Age - Age %% 5,
         Age = case_when(between(Age,1,4) ~ 1,
                        Age >= 100 ~ 100,
                        TRUE ~  Age - Age %% 5)
  ) %>% 
  select(Code, Date, Sex, Age) %>% 
  group_by(Code, Date, Age, Sex) %>% 
  summarise(Value = n(),
            .groups = "drop") %>% 
  ungroup() %>% 
  tidyr::complete(Code = CZNUTS3$Code, 
           Date = Dates_AllD, 
           Age = Ages_All, 
           Sex, 
           fill = list(Value = 0)) %>% 
  arrange(Code, Sex, Age, Date) %>% 
  group_by(Code, Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Code, Date, Sex,Age) %>% 
  mutate(AgeInt = 5, # what about the 100+? 
         Metric = "Count", 
         Measure = "Deaths",
         Date = ddmmyyyy(Date),
         Country = "Czechia") %>% 
  left_join(CZNUTS3, by = "Code") %>% 
  select(Country, 
         Region = `Natural Region Names`, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)%>%
  mutate(Age= as.character(Age))

###########################################
################ VACCINATION ##############
###########################################

vaccine_url <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani.csv"

vacc_in    <- read_csv(vaccine_url)

DateRangeV <- range(vacc_in$datum)
Dates_AllV <- seq(DateRangeV[1],DateRangeV[2],by="days")
all_ages_V <- vacc_in$vekova_skupina %>% unique()


# vacc_in cont
cz_vaccines <- 
  vacc_in %>% 
  select(Date = datum,
         Age = vekova_skupina,
         code = kraj_nuts_kod,
         first_dose = prvnich_davek,
         second_dose = druhych_davek,
         n_dose = celkem_davek ) %>% 
  left_join(CZNUTS3, by="code") %>% 
  select(Date, Age, Code, first_dose, second_dose, n_dose) %>% 
  group_by(Date, Age, Code) %>% 
  summarize(first_dose = sum(first_dose),
            second_dose = sum(second_dose),
            n_dose = sum(n_dose),
            .groups = "drop") %>% 
  tidyr::complete(Code = CZNUTS3$Code, 
                  Date = Dates_AllV, 
                  Age = all_ages_V, 
                  fill = list(first_dose = 0, 
                              second_dose = 0, 
                              n_dose = 0)) %>% 
  arrange(Code, Age, Date) %>%
  group_by(Code, Age) %>% 
  mutate(Vaccination1 = cumsum(first_dose), 
         Vaccination2 = cumsum(second_dose), 
         Vaccinations = cumsum(n_dose)) %>% 
  ungroup() %>% 
  select(Date, Code, Age, 
         Vaccination1, Vaccination2, Vaccinations) %>% 
  pivot_longer(-c(Date, Code, Age), names_to = "Measure", values_to = "Value") %>% 
  mutate(Age= case_when ( 
                  Age ==  "0-17"~"0",
                  Age ==  "18-24"~"18",
                  Age ==  "25-29"~"25",
                  Age ==  "30-34"~"30",
                  Age ==  "35-39"~"35",
                  Age ==  "40-44"~"40",
                  Age ==  "45-49"~"45",
                  Age ==  "50-54"~"50",
                  Age ==  "55-59"~"55",
                  Age ==  "60-64"~"60",
                  Age ==  "65-69"~"65",
                  Age ==  "70-74"~"70",
                  Age ==  "75-79"~"75",
                  Age ==  "80+"~"80",
                  TRUE ~ "UNK"),
         AgeInt = case_when(
                  Age == "0" ~ 18L,
                  Age == "18" ~ 7L,
                  Age == "80" ~ 25L,
                  Age == "UNK" ~ NA_integer_,
                  TRUE ~ 5L),
    Country = "Czechia",
    Sex= "b",
    Date = ddmmyyyy(Date),
    Metric= "Count") %>% 
  left_join(CZNUTS3, by  ="Code") %>% 
  select(Country, Region = `Natural Region Names`, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

cz_vaccines_all <- 
  cz_vaccines %>% 
  group_by(Country, Date, Sex, Age, AgeInt, Metric, Measure) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  mutate(Code = "CZ", Region = "All", Age = as.character(Age)) %>% 
  relocate(Region, .after = "Country") %>% 
  relocate(Code, .after = "Code")
#Anna Altova:
# comments: As of today (15 Feb 2021) only selected population groups 
# are allowed to get the vaccine. These are people over 80 y.o., medical 
# professionals (with the priority of those working with the COVID-19+ patients etc), 
# members of the army helping to handle the pandemic, members of the emergency services, 
# other workers in the critical infrastructure for the pandemic.
# Kids <18 should not be vaccinated (although there are some according to the data)


#JD:
#could not combine them because of different class types for Age 
#Did not want to mess with numeric class types for case and death
#Maybe upload/store vaccine cases/ death separately? 


# final spreadsheet 

cz_spreadsheet_region <-
  bind_rows(cz_cases_region_ss, 
            cz_deaths_region_ss,
            cz_vaccines) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#############################################3
# CZ All should be in single ages

Ages_all_single <- 0:100

cz_cases_all_ss <- 
  cz_cases2 %>% 
  select(Date, Sex, Age) %>% 
  mutate(Age = ifelse(Age >= 100, 100, Age)) %>% 
  ### select
  select(Date, Sex, Age) %>% 
  group_by(Date, Age, Sex) %>% 
  summarise(Value = n(), .groups = "drop") %>% 
  tidyr::complete(
    Date = Dates_All, 
    Age = Ages_all_single, 
    Sex, 
    fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Date, Sex, Age) %>% 
  mutate(Country = "Czechia",
         Region = "All",
         AgeInt = ifelse(Age == 100,5,1), 
         Metric = "Count", 
         Measure = "Cases",
         Date = ddmmyyyy(Date),
         Code = "CZ",
         Age = as.character(Age)) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)

cz_deaths_all_ss <- 
  cz_deaths2 %>% 
  select(Date, Sex, Age) %>% 
  mutate(Age = ifelse(Age >= 100, 100, Age)) %>% 
  select(Date, Sex, Age) %>% 
  group_by(Date, Age, Sex) %>% 
  summarise(Value = n(),
            .groups = "drop") %>% 
  ungroup() %>% 
  tidyr::complete(
    Date = Dates_AllD, 
    Age = Ages_all_single, 
    Sex, 
    fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Date, Sex, Age) %>% 
  mutate(AgeInt = ifelse(Age == 100,5,1), 
         Metric = "Count", 
         Measure = "Deaths",
         Date = ddmmyyyy(Date),
         Code = "CZ",
         Country = "Czechia",
         Region = "All",
         Age = as.character(Age)) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)


cz_spreadsheet_all <-
   bind_rows(cz_cases_all_ss,
             cz_deaths_all_ss,
             cz_vaccines_all) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value) %>% 
  arrange(dmy(Date), Sex, Measure, Age) %>% 
  mutate(Age = as.character(Age))

out <- bind_rows(cz_spreadsheet_all, cz_spreadsheet_region) %>% 
  dplyr::filter(Region != "UNK")



# out %>% 
#   group_by(Region, Sex, Date, Age, Measure, Metric) %>% 
#   mutate(i = 1:n()) %>% 
#   ungroup() %>% 
#   dplyr::filter(i > 1)
###########################
#### Saving data in N: ####
###########################

write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

#### uploading metadata to N Drive ####

data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_source_v <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_",today(), ".csv")

download.file(cases_url, destfile = data_source_c)
download.file(deaths_url, destfile = data_source_d)
download.file(vaccine_url, destfile = data_source_v)


data_source <- c(data_source_c, data_source_d,data_source_v )

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

