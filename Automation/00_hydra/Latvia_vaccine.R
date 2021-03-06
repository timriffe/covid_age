# Latvia vaccine data 

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

ctr          <- "Latvia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


#Read in data 


m_url <- "https://data.gov.lv/dati/eng/dataset/covid19-vakcinacijas/resource/51725018-49f3-40d1-9280-2b13219e026f"


links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "adp_covid19_vakc")) %>% 
  select(url) 

links2= head(links, 1)

url <- 
  links2 %>% 
  select(url) %>% 
  dplyr::pull()


data_source <- paste0(dir_n, "Data_sources/", ctr, "/Latvia_data",today(), ".xlsx")
download.file(url, data_source, mode = "wb")

In_vaccine= read_excel(data_source)

#Process data

Out_vaccine= In_vaccine %>%
  select(Date= `Vakcinācijas datums`, Measure= `Vakcīnas kārtas numurs`, Age=`Vakcinētās personas vecums`, Sex= `Vakcinētās personas dzimums`, Value= `Vakcinēto personu skaits`)%>%
  mutate(Measure= recode(Measure, 
                       `1` = "Vaccination1",
                       `2`= "Vaccination2"))%>%
  mutate(Sex = case_when(
  is.na(Sex)~ "UNK",
  Sex == "V" ~ "m",
  Sex == "S" ~ "f",
  Sex== "NULL" ~ "UNK")) %>%
  group_by(Date,Sex, Age, Measure)%>% 
  arrange(Date,Sex, Age, Measure)%>% 
  group_by(Sex, Age, Measure) %>%
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>%
    mutate(AgeInt = "1",
           Metric = "Count") %>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LV_All",Date),
    Country = "Latvia",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#save output data

write_rds(Out_vaccine, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(Out_vaccine)) 


#zip input data file 

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




