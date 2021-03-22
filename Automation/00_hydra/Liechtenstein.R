#Liechtenstein 

library(here)
source('U:/GitHub/Covid/Automation/00_Functions_automation.R')
library(ISOweek)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

########################################################################################
ctr          <- "Liechtenstein" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


##################Read in new data#############


url= "https://www.covid19.admin.ch/api/data/20210316-ggilst65/downloads/sources-csv.zip"
data_source <- paste0(dir_n, "Data_sources/", ctr, "/Liechtenstein_data",today(), ".zip")
download.file(url, data_source, mode = "wb")


In_cases= read.csv(unz(data_source, "data/COVID19Cases_geoRegion_AKL10_w.csv"))
In_death= read.csv(unz(data_source,"data/COVID19Death_geoRegion_AKL10_w.csv"))
In_test= read.csv(unz(data_source,"data/COVID19Test_geoRegion_AKL10_w.csv"))
In_dose= read.csv(unz(data_source,"data/COVID19VaccDosesAdministered_AKL10_w.csv"))
In_vaccine= read.csv(unz(data_source,"data/COVID19FullyVaccPersons_AKL10_w.csv"))
In_cases_sex= read.csv(unz(data_source,"data/COVID19Cases_geoRegion_sex_w.csv"))
In_death_sex= read.csv(unz(data_source,"data/COVID19Death_geoRegion_sex_w.csv"))
In_test_sex= read.csv(unz(data_source,"data/COVID19Test_geoRegion_sex_w.csv"))
In_dose_sex= read.csv(unz(data_source,"data/COVID19VaccDosesAdministered_sex_w.csv"))
In_vaccine_sex= read.csv(unz(data_source,"data/COVID19FullyVaccPersons_sex_w.csv"))


#Process################################################################################## 

Out_cases= In_cases %>%
  select(Age = altersklasse_covid19, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Age=recode(Age, 
                    `0 - 9`="0",
                    `10 - 19`="10",
                    `20 - 29`="20",
                    `30 - 39`="30",
                    `40 - 49`="40",
                    `50 - 59`="50",
                    `60 - 69`="60",
                    `70 - 79`="70",
                    `80+`="80",
                    `Unbekannt`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex= "b",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))

  
  

#Deaths


Out_death= In_death %>%
  select(Age = altersklasse_covid19, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Age=recode(Age, 
                    `0 - 9`="0",
                    `10 - 19`="10",
                    `20 - 29`="20",
                    `30 - 39`="30",
                    `40 - 49`="40",
                    `50 - 59`="50",
                    `60 - 69`="60",
                    `70 - 79`="70",
                    `80+`="80",
                    `Unbekannt`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Deaths",
    Metric = "Count",
    Sex= "b",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))





#Test

Out_test= In_test %>%
  select(Age = altersklasse_covid19, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Age=recode(Age, 
                    `0 - 9`="0",
                    `10 - 19`="10",
                    `20 - 29`="20",
                    `30 - 39`="30",
                    `40 - 49`="40",
                    `50 - 59`="50",
                    `60 - 69`="60",
                    `70 - 79`="70",
                    `80+`="80",
                    `Unbekannt`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Tests",
    Metric = "Count",
    Sex= "b",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))


#Vaccine 
#Vaccination1

Out_dose= In_dose %>%
  select(Age = altersklasse_covid19, Date=date, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Age=recode(Age, 
                    `0 - 9`="0",
                    `10 - 19`="10",
                    `20 - 29`="20",
                    `30 - 39`="30",
                    `40 - 49`="40",
                    `50 - 59`="50",
                    `60 - 69`="60",
                    `70 - 79`="70",
                    `80+`="80",
                    `Unbekannt`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Vaccination1",
    Metric = "Count",
    Sex= "b",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))



#Vaccination2 

Out_vaccine= In_vaccine %>%
  select(Age = altersklasse_covid19, Date=date, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Age=recode(Age, 
                    `0 - 9`="0",
                    `10 - 19`="10",
                    `20 - 29`="20",
                    `30 - 39`="30",
                    `40 - 49`="40",
                    `50 - 59`="50",
                    `60 - 69`="60",
                    `70 - 79`="70",
                    `80+`="80",
                    `Unbekannt`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Vaccination2",
    Metric = "Count",
    Sex= "b",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))



#Totals by sex 

#Cases

Out_cases_sex= In_cases_sex %>%
  select(Sex=sex, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Sex=recode(Sex, 
                    `male`="m",
                    `female`="f",
                    `unknown`="UNK"))%>% 
    mutate(
    Measure = "Cases",
    Metric = "Count",
    Age= "TOT",
    AgeInt= "",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))


#Deaths 



Out_death_sex= In_death_sex %>%
  select(Sex=sex, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Sex=recode(Sex, 
                    `male`="m",
                    `female`="f",
                    `unknown`="UNK"))%>% 
    mutate(
    Measure = "Deaths",
    Metric = "Count",
    Age= "TOT",
    AgeInt= "",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))


#Tests

Out_test_sex= In_test_sex %>%
  select(Sex=sex, Date=datum, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Sex=recode(Sex, 
                    `male`="m",
                    `female`="f",
                    `unknown`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
    mutate(
    Measure = "Tests",
    Metric = "Count",
    Age= "TOT",
    AgeInt= "",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))



#vaccination1 

Out_dose_sex= In_dose_sex %>%
  select(Sex=sex, Date=date, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Sex=recode(Sex, 
                    `male`="m",
                    `female`="f",
                    `unknown`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
    mutate(
    Measure = "Vaccination1",
    Metric = "Count",
    Age= "TOT",
    AgeInt= "",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))




#vaccination2 

Out_vaccine_sex= In_vaccine_sex %>%
  select(Sex=sex, Date=date, Value= sumTotal, Region= geoRegion) %>% 
  mutate(Sex=recode(Sex, 
                    `male`="m",
                    `female`="f",
                    `unknown`="UNK"),
         Value = case_when(
           is.na(Value) ~ "UNK",
           TRUE~ as.character(Value)))%>% 
    mutate(
    Measure = "Vaccination2",
    Metric = "Count",
    Age= "TOT",
    AgeInt= "",
    Country= "Liechtenstein")%>%
  separate(Date, c("D1", "D2", "D3","D4","D5", "D6", "D7"), "")%>%
  mutate(Date = paste0(D2, D3, D4, D5,"-W", D6, D7, "-7"))%>%
  mutate(Date=ISOweek::ISOweek2date(Date))%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI_", Region, Date),)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  mutate(Value= as.character(Value))


######combine to one dataframe########## 

Out <- bind_rows(Out_cases,
                    Out_cases_sex,
                    Out_death,
                    Out_death_sex, 
                    Out_dose,
                    Out_dose_sex,
                    Out_test,
                    Out_test_sex,
                    Out_vaccine,
                    Out_vaccine_sex)
                    

#save output data

write_rds(Out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) ###Is that for the automation sheet?TR: Yes


#####input data already archived at beginning 
