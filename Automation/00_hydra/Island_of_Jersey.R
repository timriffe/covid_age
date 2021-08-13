#Island of Jersey 

library(here)
source('U:/GitHub/Covid/Automation/00_Functions_automation.R')

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Island_of_Jersey" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "JE")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)


#read in data 

vaccine= read.csv("https://www.gov.je/Datasets/ListOpenData?ListName=COVID19Weekly&clean=true")

death= read.csv("https://www.gov.je/datasets/listopendata?listname=COVID19DeathsAge")


#process deaths 

Deaths_out= death %>%
  select(!DateTime)%>% 
  pivot_longer(!Date, names_to= "Age", values_to= "Value")
                    
Deaths_out[Deaths_out == ""] <- NA


Deaths_out= Deaths_out%>%
  filter(!is.na(Date))%>%
  mutate(Age=recode(Age, 
                    `X_0to9`="0",
                    `X_10to19`="10",
                    `X_20to29`="20",
                    `X_30to39`="30",
                    `X_40to49`="40",
                    `X_50to59`="50",
                    `X_60to69`="60",
                    `X_70to79`="70",
                    `X_80to89`="80",
                    `X_90andover`="80"))%>%
  mutate(AgeInt = case_when(
    Age == "90" ~ 15L,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Deaths",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("JE",Date),
    Country = "Island of Jersey",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  

#vaccine 

Vaccine_out= vaccine%>% 
  select(VaccinationsTotalNumberDoses,                                       
         VaccinationsTotalNumberFirstDoseVaccinations,                       
         VaccinationsTotalNumberSecondDoseVaccinations,                      
         VaccinationsTotalVaccinationDosesFirstDose80yearsandover,          
         VaccinationsTotalVaccinationDosesFirstDose75to79years,              
         VaccinationsTotalVaccinationDosesFirstDose70to74years,             
         VaccinationsTotalVaccinationDosesFirstDose65to69years,             
         VaccinationsTotalVaccinationDosesFirstDose60to64years,              
         VaccinationsTotalVaccinationDosesFirstDose55to59years,             
         VaccinationsTotalVaccinationDosesFirstDose50to54years,             
         VaccinationsTotalVaccinationDosesFirstDose40to49years,              
         VaccinationsTotalVaccinationDosesFirstDose30to39years,             
         VaccinationsTotalVaccinationDosesFirstDose18to29years,              
         VaccinationsTotalVaccinationDosesFirstDose17yearsandunder,
         VaccinationsTotalVaccinationDosesSecondDose80yearsandover,          
        VaccinationsTotalVaccinationDosesSecondDose75to79years,            
VaccinationsTotalVaccinationDosesSecondDose70to74years,             
VaccinationsTotalVaccinationDosesSecondDose65to69years,            
VaccinationsTotalVaccinationDosesSecondDose60to64years,        
VaccinationsTotalVaccinationDosesSecondDose55to59years,          
VaccinationsTotalVaccinationDosesSecondDose50to54years,            
VaccinationsTotalVaccinationDosesSecondDose40to49years,           
VaccinationsTotalVaccinationDosesSecondDose30to39years,            
VaccinationsTotalVaccinationDosesSecondDose18to29years,           
VaccinationsTotalVaccinationDosesSecondDose17yearsandunder,
Date)%>% 
  pivot_longer(!Date, names_to= "Des", values_to= "Value")%>%
  separate(Des, c("Des", "Measure", "Age"), "Dose")%>%
  mutate(Age=recode(Age, 
                    `80yearsandover`="80",
                    `75to79years`="75",
                    `70to74years`="70",
                    `65to69years`="65",
                    `60to64years`="60",
                    `55to59years`="55",
                    `50to54years`="50",
                    `40to49years`="40",
                    `30to39years`="30",
                    `18to29years`="18",
                    `17yearsandunder`="0"))%>%
  mutate(Age = case_when(is.na(Age) ~ "TOT",
                         TRUE~ as.character(Age)))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "80" ~ 25L,
    Age == "30" ~ 10L,
    Age == "40" ~ 10L,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 5L))%>% 
  mutate(Measure=recode(Measure, 
                    `s`="Vaccinations",
                    `sFirst`="Vaccination1",
                    `sSecond`="Vaccination2"))%>%
  mutate(Measure = case_when(
    Des == "VaccinationsTotalNumberFirst" ~ "Vaccination1",
    Des == "VaccinationsTotalNumberSecond" ~ "Vaccination2",
    TRUE ~ as.character(Measure)))%>% 
  mutate(
    Sex = "b",
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("JE",Date),
    Country = "Island of Jersey",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  #remove NAs at the beginning of vaccination process
  subset(Value!= is.na(Value))
  
  
#put togehter 

Out= rbind(Deaths_out, Vaccine_out)

# upload to Drive, overwrites

write_sheet(Out, 
            ss = ss_i, 
            sheet = "database") 
                    
log_update("Island of Jersey", N = nrow(Out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(death, data_source_1)
write_csv(vaccine, data_source_2)

data_source <- c(data_source_1, data_source_2)

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


















