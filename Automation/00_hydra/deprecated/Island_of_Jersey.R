#Island of Jersey 

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

ctr          <- "Island_of_Jersey" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "JE")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)


## Source Website <- "https://www.gov.je/Health/Coronavirus/Pages/CoronavirusCases.aspx#tab_mortalityReporting"

#read in data 

vaccine= read.csv("https://www.gov.je/Datasets/ListOpenData?ListName=COVID19Weekly&clean=true")

#deaths= read.csv("https://www.gov.je/datasets/listopendata?listname=COVID19DeathsAge")[-216,] 

## MK: As announced on the website: 
## reporting of COVID data will move from a daily to a weekly reporting cycle from 1 May 2022
## Also, I would prefer to use this dataset rather than the previous one. 

deaths <- read.csv("https://www.gov.je/Datasets/ListOpenData?ListName=COVID19") 

#process deaths 
#Deaths_out[Deaths_out == ""] <- NA


Deaths_out <- deaths %>% 
  mutate(Date = ymd(Date)) %>% 
  filter(!is.na(Date)) %>%
  dplyr:: select(Date, starts_with("MortalityDeathsAge")) %>% 
  tidyr::pivot_longer(cols = -c("Date"),
                      names_to = "Age",
                      values_to = "Value") %>% 
  mutate(Value = replace_na(Value, 0),
         Age = str_remove_all(Age, "MortalityDeathsAge")) %>% 
  separate(Age, into = c("Age", "Nothing"), sep = "to") %>% 
  mutate(Age = str_remove_all(Age, "andover")) %>% 
  # mutate(Age=recode(Age, 
  #                   `X_0to9`="0",
  #                   `X_10to19`="10",
  #                   `X_20to29`="20",
  #                   `X_30to39`="30",
  #                   `X_40to49`="40",
  #                   `X_50to59`="50",
  #                   `X_60to69`="60",
  #                   `X_70to79`="70",
  #                   `X_80to89`="80",
  #                   `X_90andover`="90"))%>%
  mutate(AgeInt = case_when(
    Age == "90" ~ 15L,
    TRUE ~ 10L))%>% 
  mutate(
    Measure = "Deaths",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
  #  Date = lubridate::ymd(Date),
  #  Date = ddmmyyyy(Date),
    Code = paste0("JE"),
    Country = "Island of Jersey",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  

#Vaccine DATA; THESE ARE WEEKLY CUMULATIVE DATA 
## MK: In 05.08.2022 I added 3rd and 4th doses columns, and lower ages as published for all doses
## also, changed a bit the wrangling 

Vaccine_out <- vaccine %>% 
  mutate(Date = ymd(Date)) %>% 
  filter(!is.na(Date)) %>% 
 select(Vaccinations_TOT = VaccinationsTotalNumberDoses,                                       
         Vaccination1_TOT = VaccinationsTotalNumberFirstDoseVaccinations,                       
         Vaccination2_TOT = VaccinationsTotalNumberSecondDoseVaccinations,
         Vaccination3_TOT = VaccinationsTotalNumberThirdDoseVaccinations,
         Vaccination4_TOT = VaccinationsTotalNumberFourthDoseVaccinations,
         Vaccination5_TOT = VaccinationsTotalNumberAutumnBooster2022,
         ## FIRST DOSE BY AGE
         Vaccination1_80 = VaccinationsTotalVaccinationDosesFirstDose80yearsandover,          
         Vaccination1_75 = VaccinationsTotalVaccinationDosesFirstDose75to79years,              
         Vaccination1_70 = VaccinationsTotalVaccinationDosesFirstDose70to74years,             
         Vaccination1_65 = VaccinationsTotalVaccinationDosesFirstDose65to69years,             
         Vaccination1_60 = VaccinationsTotalVaccinationDosesFirstDose60to64years,              
         Vaccination1_55 = VaccinationsTotalVaccinationDosesFirstDose55to59years,             
         Vaccination1_50 = VaccinationsTotalVaccinationDosesFirstDose50to54years,             
         Vaccination1_40 = VaccinationsTotalVaccinationDosesFirstDose40to49years,              
         Vaccination1_30 = VaccinationsTotalVaccinationDosesFirstDose30to39years,             
         Vaccination1_18 = VaccinationsTotalVaccinationDosesFirstDose18to29years,              
         Vaccination1_16 = VaccinationsTotalVaccinationDosesFirstDose16to17years,
         Vaccination1_12 = VaccinationsTotalVaccinationDosesFirstDose12to15years,
         Vaccination1_5 = VaccinationsTotalVaccinationDosesFirstDose5to11years,
         # SECOND DOSE BY AGE
         Vaccination2_80 = VaccinationsTotalVaccinationDosesSecondDose80yearsandover,          
         Vaccination2_75 = VaccinationsTotalVaccinationDosesSecondDose75to79years,            
         Vaccination2_70 = VaccinationsTotalVaccinationDosesSecondDose70to74years,             
         Vaccination2_65 = VaccinationsTotalVaccinationDosesSecondDose65to69years,            
         Vaccination2_60 = VaccinationsTotalVaccinationDosesSecondDose60to64years,        
         Vaccination2_55 = VaccinationsTotalVaccinationDosesSecondDose55to59years,          
         Vaccination2_50 = VaccinationsTotalVaccinationDosesSecondDose50to54years,            
         Vaccination2_40 = VaccinationsTotalVaccinationDosesSecondDose40to49years,           
         Vaccination2_30 = VaccinationsTotalVaccinationDosesSecondDose30to39years,            
         Vaccination2_18 = VaccinationsTotalVaccinationDosesSecondDose18to29years,           
         Vaccination2_16 = VaccinationsTotalVaccinationDosesSecondDose16to17years,
         Vaccination2_12 = VaccinationsTotalVaccinationDosesSecondDose12to15years,
         Vaccination2_5 =  VaccinationsTotalVaccinationDosesSecondDose5to11years,
        # THIRD DOSE BY AGE
          Vaccination3_80 = VaccinationsTotalVaccinationDosesThirdDose80yearsandover, 
          Vaccination3_75 = VaccinationsTotalVaccinationDosesThirdDose75to79years,
          Vaccination3_70 =VaccinationsTotalVaccinationDosesThirdDose70to74years,
          Vaccination3_65 =VaccinationsTotalVaccinationDosesThirdDose65to69years,
          Vaccination3_60 =VaccinationsTotalVaccinationDosesThirdDose60to64years,
          Vaccination3_55 =VaccinationsTotalVaccinationDosesThirdDose55to59years,
          Vaccination3_50 =VaccinationsTotalVaccinationDosesThirdDose50to54years,
          Vaccination3_40 =VaccinationsTotalVaccinationDosesThirdDose40to49years,
          Vaccination3_30 =VaccinationsTotalVaccinationDosesThirdDose30to39years,
          Vaccination3_18 =VaccinationsTotalVaccinationDosesThirdDose18to29years,
          Vaccination3_16 =VaccinationsTotalVaccinationDosesThirdDose16to17years,
          Vaccination3_12 =VaccinationsTotalVaccinationDosesThirdDose12to15years,
          Vaccination3_5 = VaccinationsTotalVaccinationDosesThirdDose5to11years,           
       # FORTH DOSE BY AGE
         Vaccination4_80 = VaccinationsTotalVaccinationDosesFourthDose80yearsandover,          
         Vaccination4_75 = VaccinationsTotalVaccinationDosesFourthDose75to79years,             
         Vaccination4_70 = VaccinationsTotalVaccinationDosesFourthDose70to74years,             
         Vaccination4_65 = VaccinationsTotalVaccinationDosesFourthDose65to69years,             
         Vaccination4_60 = VaccinationsTotalVaccinationDosesFourthDose60to64years,             
         Vaccination4_55 = VaccinationsTotalVaccinationDosesFourthDose55to59years,             
         Vaccination4_50 = VaccinationsTotalVaccinationDosesFourthDose50to54years,             
         Vaccination4_40 = VaccinationsTotalVaccinationDosesFourthDose40to49years,             
         Vaccination4_30 = VaccinationsTotalVaccinationDosesFourthDose30to39years,             
         Vaccination4_18 = VaccinationsTotalVaccinationDosesFourthDose18to29years,             
         Vaccination4_16 = VaccinationsTotalVaccinationDosesFourthDose16to17years,             
         Vaccination4_12 = VaccinationsTotalVaccinationDosesFourthDose12to15years,             
         Vaccination4_5 = VaccinationsTotalVaccinationDosesFourthDose5to11years, 
       # AUTUMN 2022 DOSES 
       Vaccination5_80 = VaccinationsTotalVaccinationDosesAutumnBooster202280yearsandover,          
       Vaccination5_75 = VaccinationsTotalVaccinationDosesAutumnBooster202275to79years,              
       Vaccination5_70 = VaccinationsTotalVaccinationDosesAutumnBooster202270to74years,             
       Vaccination5_65 = VaccinationsTotalVaccinationDosesAutumnBooster202265to69years,             
       Vaccination5_60 = VaccinationsTotalVaccinationDosesAutumnBooster202260to64years,              
       Vaccination5_55 = VaccinationsTotalVaccinationDosesAutumnBooster202255to59years,             
       Vaccination5_50 = VaccinationsTotalVaccinationDosesAutumnBooster202250to54years,             
       Vaccination5_40 = VaccinationsTotalVaccinationDosesAutumnBooster202240to49years,              
       Vaccination5_30 = VaccinationsTotalVaccinationDosesAutumnBooster202230to39years,             
       Vaccination5_18 = VaccinationsTotalVaccinationDosesAutumnBooster202218to29years,              
       Vaccination5_16 = VaccinationsTotalVaccinationDosesAutumnBooster202216to17years,
       Vaccination5_12 = VaccinationsTotalVaccinationDosesAutumnBooster202212to15years,
       Vaccination5_5 = VaccinationsTotalVaccinationDosesAutumnBooster20225to11years,
        Date) %>% 
  pivot_longer(!Date, names_to= "Des", values_to= "Value") %>%
  separate(Des, c("Measure", "Age"), sep = "_") %>%
  mutate(AgeInt = case_when(
    Age == "5" ~ 7L,
    Age == "12" ~ 4L,
    Age == "16" ~ 1L,
    Age == "17" ~ 1L,
    Age == "80" ~ 25L,
    Age == "30" ~ 10L,
    Age == "40" ~ 10L,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 5L))%>% 
  mutate(
    Sex = "b",
    Metric = "Count",
    Code = "JE",
    Country = "Island of Jersey",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  #remove NAs at the beginning of vaccination process
  subset(Value!= is.na(Value))
  

# MK: I don't think this issue is still there. 

#Vaccine_out <- Vaccine_out %>% ##there is an issue in the data
#  mutate(Value = as.numeric(Value)) %>%  
#  mutate(Value = case_when(
#    Value == 52725 ~ 5725,
#    (Value == 8749 & Age == 0) ~ 70,
#    TRUE ~ Value
#  ))
  
#put togehter 

Out <- rbind(Deaths_out, Vaccine_out) %>% 
  mutate(Date = ddmmyyyy(Date)) %>% 
  sort_input_data() %>% 
  unique()

# save on N 

write_rds(Out, paste0(dir_n, ctr, ".rds"))

# write_sheet(Out, 
#             ss = ss_i, 
#             sheet = "database") 
                    
#log_update("Island of Jersey", N = nrow(Out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(deaths, data_source_1)
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

#END#

## history ==============

# mutate(Age=recode(Age, 
#                   `80yearsandover`="80",
#                   `75to79years`="75",
#                   `70to74years`="70",
#                   `65to69years`="65",
#                   `60to64years`="60",
#                   `55to59years`="55",
#                   `50to54years`="50",
#                   `40to49years`="40",
#                   `30to39years`="30",
#                   `18to29years`="18",
#                   `17yearsandunder`="17",
#                   `16to17years` = "16",
#                   `12to15years` = "12",
#                   `5to11years` = "5")) #%>%
# mutate(Age = case_when(is.na(Age) ~ "TOT",
#                        TRUE~ as.character(Age)))%>%
#  mutate(Measure=recode(Measure, 
#                    `s`="Vaccinations",
#                    `sFirst`="Vaccination1",
#                    `sSecond`="Vaccination2"))%>%
#  mutate(Measure = case_when(
#    Des == "VaccinationsTotalNumberFirst" ~ "Vaccination1",
#    Des == "VaccinationsTotalNumberSecond" ~ "Vaccination2",
#    TRUE ~ as.character(Measure)))%>% 
