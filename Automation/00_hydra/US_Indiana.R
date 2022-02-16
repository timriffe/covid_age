# Indiana 

library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}
 

# info country and N drive address

ctr          <- "US_Indiana" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
 


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#Save append vaccine data 

vaccine_archive <- read_rds(paste0(dir_n, ctr, ".rds"))%>% 
filter(Measure== "Vaccination1"| Measure== "Vaccination2"| Measure== "Vaccinations")

#Read in files 

#Cases

cases_url <- "https://hub.mph.in.gov/dataset/6b57a4f2-b754-4f79-a46b-cff93e37d851/resource/46b310b9-2f29-4a51-90dc-3886d9cf4ac1/download/covid_report.xlsx"

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".xlsx")

download.file(cases_url, data_source_1, mode = "wb")

IN_cases<- read_excel(data_source_1)


##Death

# Read it in 
death_url <- "https://hub.mph.in.gov/datastore/dump/7661f008-81b5-4ff2-8e46-f59ad5aad456?bom=True"
IN_death<- read_csv(death_url)

################cases###############

#update for new age groups

Out_cases= IN_cases%>%
  select(Age = AGEGRP,Date=DATE, Value= COVID_COUNT, Sex=GENDER)%>% 
  mutate(Age=recode(Age, 
                    `0 to <1`= "0",
                    `1-4`= "1",
                    `5-11`= "5",
                    `12-17`= "12",
                    `18-19`= "18",
                    `20-29`="20",
                    `30-39`="30",
                    `40-49`="40",
                    `50-59`="50",
                    `60-69`="60",
                    `70-79`="70",
                    `80+`="80",
                    `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 2L,
    Age == "1" ~ 4L,
    Age == "5" ~ 7L,
    Age == "12" ~ 6L,
    Age == "18" ~ 2L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
    mutate(
      Age = case_when(
        is.na(Age) ~ "UNK",
        TRUE~ as.character(Age))) %>%
  mutate(Sex = case_when(
    is.na(Sex)~ "UNK",
    Sex == "M" ~ "m",
    Sex == "F" ~ "f",
    Sex== "Unknown" ~ "UNK"))%>%
    group_by(Date, Age,Sex) %>% 
  #sum together by county 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%
    arrange(Age, Date,Sex) %>% 
    group_by(Age,Sex) %>% 
    mutate(Value = cumsum(Value)) %>% 
    ungroup()%>%
  mutate(
    Measure = "Cases",
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-IN"),
    Country = "USA",
    Region = "Indiana",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(AgeInt = as.character(AgeInt))
  

#####################################Deaths#######################################################
# 
# Out_death= IN_death%>%
#   select(Age = agegrp,Date=date, covid_deaths) %>% 
#   mutate(
#     Age = case_when(
#       is.na(Age) ~ "UNK",
#       TRUE~ as.character(Age))) %>%
#   group_by(Date, Age) %>% 
#   arrange(Age, Date) %>% 
#   group_by(Age) %>% 
#   mutate(Value = cumsum(covid_deaths)) %>% 
#   ungroup() %>%
#   mutate(Age=recode(Age, 
#                     `0-19`="0",
#                     `20-29`="20",
#                     `30-39`="30",
#                     `40-49`="40",
#                     `50-59`="50",
#                     `60-69`="60",
#                     `70-79`="70",
#                     `80+`="80",
#                     `Unknown`="UNK"))%>% 
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 20L,
#     Age == "80" ~ 25L,
#     Age == "UNK" ~ NA_integer_,
#     TRUE ~ 10L))%>% 
#   mutate(
#     Measure = "Deaths",
#     Metric = "Count",
#     Sex= "b") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US-IN"),
#     Country = "USA",
#     Region = "Indiana",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)%>% 
#   mutate(AgeInt = as.character(AgeInt))
# 
# 


#automated vaccine data append 

vaccine_url <- "https://hub.mph.in.gov/dataset/145a43b2-28e5-4bf1-ad86-123d07fddb55/resource/82d99020-093f-41ac-95c7-d3c335b8c2ba/download/county-vaccination-demographics.xlsx"

data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".xlsx")

download.file(vaccine_url, data_source_3, mode = "wb")

IN_vaccine_age<- read_excel(data_source_3, sheet = 4)

# vaccine by age


Out_vaccine_age = IN_vaccine_age%>%
  select(Age= age_group, fully_vaccinated, first_dose_administered, Date= current_as_of)%>%
  pivot_longer(!Date & !Age, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "Suppressed")%>%
  mutate(Value = as.numeric(Value))%>%
  #sum together by county 
  group_by(Age, Measure) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%
  separate(Date, c("Date", "Time"), " ")%>%
  separate(Age, c("Age", "Age2"), "-")%>% 
  mutate(Age=recode(Age, 
                    `Unknown`="UNK"))%>%
  mutate(AgeInt = case_when(
    Age == "12" ~ 4L,
    Age == "16" ~ 4L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 5L)) %>% 
  mutate(Measure=recode(Measure, 
                    `fully_vaccinated`="Vaccination2",
                    `first_dose_administered`="Vaccination1"),
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = mdy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-IN"),
    Country = "USA",
    Region = "Indiana",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(AgeInt = as.character(AgeInt))




#vaccine by sex

IN_vaccine_sex<- read_excel(data_source_3, sheet = 3)

Out_vaccine_sex= IN_vaccine_sex%>%
select(Sex= gender, fully_vaccinated, first_dose_administered, Date= current_as_of)%>%
  pivot_longer(!Date & !Sex, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "Suppressed")%>%
  mutate(Value = as.numeric(Value))%>%
  #sum together by county 
  group_by(Sex, Measure) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%
  separate(Date, c("Date", "Time"), " ")%>%
  mutate(Measure=recode(Measure, 
                        `fully_vaccinated`="Vaccination2",
                        `first_dose_administered`="Vaccination1"),
         Sex= recode(Sex, 
                     `Female`="f",
                     `Male`="m",
                     `Unknown`="UNK"),
         Metric = "Count",
         Age= "TOT",
         AgeInt= NA) %>% 
  mutate(
    Date = mdy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-IN"),
    Country = "USA",
    Region = "Indiana",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(AgeInt = as.character(AgeInt))



######combine to one dataframe########## 

out <- bind_rows(Out_cases,
                #Out_death,
                Out_vaccine_age,
                Out_vaccine_sex,
                vaccine_archive)%>%
  distinct()


# save on N 
write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update("US_Indiana", N = nrow(out))


# ------------------------------------------
# now archive


data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")

write_csv(IN_death, data_source_2)

data_source <- c(data_source_1, data_source_2, data_source_3)

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

##############################################################################

#move script to N 
# # # Drive urls
# rubric <- get_input_rubric() %>% filter(Short == "US_IN")
# 
# ss_i <- rubric %>%
#   dplyr::pull(Sheet)
# 
# ss_db <- rubric %>%
#   dplyr::pull(Source)
# 
# # reading data from Drive and last date entered 
# In_drive <- get_country_inputDB("US_IN")%>% 
#   select(-Short)
# 
# 
# # #Save vaccine data that was manually entered 
# 
# vaccine_archive= In_drive%>%
#   filter(Measure== "Vaccination1"| Measure== "Vaccination2"| Measure== "Vaccinations")%>%
#   mutate(AgeInt = as.character(AgeInt))































