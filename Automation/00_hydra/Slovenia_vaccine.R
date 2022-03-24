#Slovenia vaccine 

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(lubridate)

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Slovenia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#move script to N
# # Drive urls
# rubric <- get_input_rubric() %>% 
#   filter(Short == "SI")
# 
# ss_i <- rubric %>% 
#   dplyr::pull(Sheet)
# 
# ss_db <- rubric %>% 
#   dplyr::pull(Source)
# 
# # Get current data (to keep deaths and cases 2020)
# #only read in cases and deaths, vaccine get refreshed 
# In_drive <-
#   get_country_inputDB("SI") %>% 
#   filter(Measure == "Cases" | Measure == "Deaths") %>%
#   select(-Short)


#get vaccine data 

In_vaccine=read.csv("https://raw.githubusercontent.com/sledilnik/data/master/csv/vaccination.csv")


#process

Out_vaccine= In_vaccine%>%
  select(-vaccination.administered, -vaccination.administered.todate, -vaccination.administered2nd, -vaccination.administered2nd.todate,
         -vaccination.administered3rd, -vaccination.administered3rd.todate,
         -vaccination.used.todate, -vaccination.pfizer.used.todate, -vaccination.moderna.used.todate, -vaccination.az.used.todate,
         -vaccination.janssen.used.todate, -vaccination.delivered.todate, -vaccination.pfizer.delivered, -vaccination.pfizer.delivered.todate,
         -vaccination.moderna.delivered, -vaccination.moderna.delivered.todate, -vaccination.az.delivered, -vaccination.az.delivered.todate,
         -vaccination.janssen.delivered, -vaccination.janssen.delivered.todate)%>%
  pivot_longer(!date, names_to = "x", values_to = "Value")%>%
  separate(x, c("1", "2", "3", "4", "5", "6"), "\\.") %>% 
  select(Date= date, Age=`3`, `4`, Measure= `5`, Value) %>% 
  filter(Age != "delivered",
         Age != "used") %>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 12L,
    Age == "12" ~ 7L,
    Age == "18" ~ 7L,
    Age == "90" ~ 15L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 5L)) %>% 
  mutate(Measure=recode(Measure, 
                    `1st`="Vaccination1",
                    `2nd`="Vaccination2",
                    `3rd`="Vaccination3"))%>%
  mutate(
    Metric = "Count",
    Sex="b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("SI"),
    Country = "Slovenia",
    Region = "All") %>% 
  mutate(Value = as.numeric(Value)) %>% 
mutate(Value = case_when(
  is.na(Value) ~ 0,
  TRUE ~ Value
)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


# #put together with data from drive 
# 
# out= rbind(In_drive, Out_vaccine)


#upload 

# upload to Drive, overwrites

write_rds(Out_vaccine, paste0(dir_n, ctr, ".rds"))

# write_sheet(out, 
#             ss = ss_i, 
#             sheet = "database")


log_update("Slovenia_vaccine", N = nrow(Out_vaccine))


# ------------------------------------------
# now archive

data_source<- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")


write_csv(In_vaccine, data_source)

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





















