#US Minnesota vaccine 

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "US_Minnesota_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "US_MN")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

In_drive <-  read_sheet(ss = ss_i, sheet = "database")


#read in new data 

IN_vaccine=read.csv("https://raw.githubusercontent.com/coolbaby0208/MN-COVID19/master/People%20Vaccinated%2C%20By%20Age_tcm1148-467653.csv")

#process

Out= IN_vaccine%>%
  select(Age= Age.group, Date= reportedDate, Vaccination1= People.with.at.least.one.vaccine.dose,
         Vaccination2= People.with.completed.vaccine.series) %>%
  pivot_longer(!Date & !Age, names_to= "Measure", values_to= "Value")%>%
  mutate(Age=recode(Age, 
                    `12-15`="12",
                    `16-17`="16",
                    `18-49`="18",
                    `50-64`="50",
                    `65+`="65",
                    `Unknown/missing`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "12" ~ 4L,
    Age == "16" ~ 2L,
    Age == "18" ~ 32L,
    Age == "50" ~ 15L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 40L))%>% 
  mutate(
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = mdy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-MN"),
    Country = "USA",
    Region = "Minnesota",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  


#get previous data 

Out1 <- bind_rows(In_drive, Out)

# upload to Drive, overwrites

write_sheet(Out1, 
            ss = ss_i, 
            sheet = "database")

log_update("US_Minnesota_vaccine", N = nrow(Out))

# now archive


data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(IN_vaccine, data_source)

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

















