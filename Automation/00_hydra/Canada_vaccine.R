# Canada Vaccine 

library(here)
source(here("Automation", "00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Canada_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

#Read in data 

url <- "https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-byAgeAndSex.csv"
IN<- read_csv(url)


#Process data 
Out <- IN %>%
  select(Region = prename, 
         Date = week_end, 
         Sex = sex, 
         Age = age, 
         Vaccination1 = numtotal_partially, 
         Vaccination2 = numtotal_fully, 
         Vaccinations = numtotal_atleast1dose) %>%
  pivot_longer(!Age & !Sex & !Date & !Region, names_to= "Measure", values_to= "Value")%>%
  mutate(Sex = recode(Sex,
                      `Unknown`= "UNK",
                      `Not reported` = "UNK",
                      `Other` = "UNK"))%>%
  mutate(AgeInt = case_when(
    Age == "0-11" ~ 12L,
    Age == "0-15" ~ 16L,
    Age == "0-17" ~ 18L,# The age groups vary by time and region, not sure if this is the best way to deal with that 
    Age == "12-17" ~ 6L,
    Age == "16-69" ~ 54L,
    Age == "18-29" ~ 11L,
    Age == "18-49" ~ 32L,
    Age == "18-69" ~ 52L,
    Age == "30-39" ~ 10L,
    Age == "40-49" ~ 10L,
    Age == "50-59" ~ 10L,
    Age == "60-69" ~ 10L,
    Age == "70-79" ~ 10L,
    Age == "80+" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    Age == "All ages" ~ NA_integer_,
    TRUE ~ 5L))%>%
  mutate(Age=recode(Age, 
                    `0-15`="0",
                    `0-17`="0",
                    `0-11`="0",
                    `12-17`="12",
                    `16-69`="16",
                    `18-69`="18",
                    `18-29`="18",
                    `18-49`="18",
                    `30-39`="30",
                    `40-49`="40",
                    `50-59`="50",
                    `60-69`="60",
                    `70-74`="70",
                    `70-79`="70",
                    `75-79`="75",
                    `80+`="80",
                    `Unknown`="UNK",
                    `Not reported`="UNK",
                    `All ages`="TOT" ))%>%
  mutate(Value=recode(Value, 
                    `<5`="2"))%>%
  subset(Value != ("na"))%>% #Mostly in Quebec Vaccination2 had na. decided to remove them, because according to vaccine brands 
                              #and time they started to vaccinate there should be a Vaccine2, so replacing with 0 seems like the wrong information
  mutate(Short = recode(Region,
                      "Newfoundland and Labrador" = "NL",
                      "Nova Scotia" = "NS",
                      "Quebec"= "AS", 
                      "Manitoba" ="MB",
                      "Saskatchewan" ="SK",
                      "Yukon"= "YT",
                      "Northwest Territories"= "NT",
                      "Nunavut"= "NU",
                      "Prince Edward Island" ="PE",
                      "New Brunswick" ="NB",
                      "Alberta"= "AB",
                      "British Columbia"= "BC",
                      "Ontario" ="ON",
                      "Canada"= "All"), 
       Region = recode(Region, 
                       `Canada`="All"))%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste("CA",Short,Date,sep="_"),
    Country ="Canada" ,
    Metric = "Count",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) 
  

#Contains all values with >, remove > and impute 2

Out1 <- 
  Out %>% subset(substr(Value,1,1)== ">") %>%
  separate(Value, c("col", "Value"), ">", fill = "left") %>%
  mutate(Value = as.numeric(Value), 
         Value = Value+2,
         Value = as.character(Value)) %>%
  select(-col) 
  
# Contains all data without <> 

Out2 <- 
  Out %>% 
  subset(substr(Value,1,1)!= ">")

#put both togehter again

outfinal <- bind_rows(Out1, Out2)

#save output data 
write_rds(outfinal, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(outfinal))

# now archive

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")


write_csv(IN, data_source)

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
