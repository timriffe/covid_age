#Pennsylvenia Vaccine 


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

ctr          <- "US_Pennsylvania_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "US_PA")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

In_drive <- get_country_inputDB("US_PA")%>% 
  select(-Short)%>%
  mutate(AgeInt= as.character(AgeInt))



#vaccine age 
Vaccine_age= read.csv("https://data.pa.gov/api/views/xy2e-dqvt/rows.csv?accessType=DOWNLOAD")

#vaccine sex
Vaccine_sex=read.csv("https://data.pa.gov/api/views/id8t-dnk6/rows.csv?accessType=DOWNLOAD") 

#Process
#using yesterday because of difference to US time zone 
yesterday <- format(Sys.Date()-1,"%Y/%m/%d")

#Age 

Out_vaccine_age= Vaccine_age %>%
  select(Age= Age.Group, Partially.Covered,Fully.Covered )%>%
  pivot_longer(!Age, names_to= "Measure", values_to= "Value")%>%
  mutate(Measure= recode(Measure, 
                         `Partially.Covered` = "Vaccination1",
                         `Fully.Covered`= "Vaccination2"))%>%
  mutate(Age=recode(Age, 
                    `15-19`="15",
                    `20-24`="20",
                    `25-29`="25",
                    `30-34`="30",
                    `35-39`="35",
                    `40-44`="40",
                    `45-49`="45",
                    `50-54`="50",
                    `55-59`="55",
                    `60-64`="60",
                    `65-69`="65",
                    `70-74`="70",
                    `75-79`="75",
                    `80-84`="80",
                    `85-89`="85",
                    `90-94`="90",
                    `95-99`="95",
                    `100-104`="100",
                    `105+`="105"))%>%
  mutate(AgeInt = case_when(
    Age == "105" ~ 1L,
    TRUE ~ 5L))%>% 
  mutate(Metric = "Count",
         Sex="b") %>%
  mutate(
    Date= yesterday,
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_PA",Date),
    Country = "USA",
    Region = "Pennsylvania",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))



#Sex

Out_vaccine_sex = Vaccine_sex %>%
  select(Sex= Gender, Partially.Covered,Fully.Covered )%>%
  pivot_longer(!Sex, names_to= "Measure", values_to= "Value")%>%
  mutate(Measure= recode(Measure, 
                         `Partially.Covered` = "Vaccination1",
                         `Fully.Covered`= "Vaccination2"))%>%
  mutate(Sex= recode(Sex, 
                     `female`= "f",
                     `male`= "m",
                     `Unknown`= "UNK"))%>%
  mutate(Metric = "Count",
         Age="TOT",
         AgeInt="",) %>%
  mutate(
    Date= yesterday,
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_PA",Date),
    Country = "USA",
    Region = "Pennsylvania",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))

#put together 

Out <- bind_rows(In_drive,
                Out_vaccine_age,
                Out_vaccine_sex)

#upload 

write_sheet(Out, 
            ss = ss_i, 
            sheet = "database")



#log_update("US_Pennsylvania", N = nrow(Out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",yesterday, ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_sex_",yesterday, ".csv")

write_csv(Vaccine_age, data_source_1)
write_csv(Vaccine_sex, data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  yesterday, 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

