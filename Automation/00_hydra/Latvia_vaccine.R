# Latvia vaccine data 

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

ctr          <- "Latvia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#Read in data 


m_url_pre22 <- "https://data.gov.lv/dati/eng/dataset/covid19-vakcinacijas/resource/51725018-49f3-40d1-9280-2b13219e026f"


links_pre22 <- scraplinks(m_url_pre22) %>% 
  filter(str_detect(url, "adp_covid19_vakc")) %>% 
  select(url) 

links2_pre22 = head(links_pre22, 1)

url_pre22 <- 
  links2_pre22 %>% 
  select(url) %>% 
  dplyr::pull()


data_source_pre22 <- paste0(dir_n, "Data_sources/", ctr, "/Latvia_data_pre22", ".xlsx")
download.file(url_pre22, data_source_pre22, mode = "wb")

In_vaccine_pre22 = read_excel(data_source_pre22)



m_url_22 <- "https://data.gov.lv/dati/eng/dataset/covid19-vakcinacijas/resource/9320d913-a4a2-4172-b521-73e58c2cfe83"


links_22 <- scraplinks(m_url_22) %>% 
  filter(str_detect(url, "adp_covid19_vakc")) %>% 
  select(url) 

links2_22 = head(links_22, 1)

url_22 <- 
  links2_22 %>% 
  select(url) %>% 
  dplyr::pull()


data_source_22 <- paste0(dir_n, "Data_sources/", ctr, "/Latvia_data_22_",today(), ".xlsx")
download.file(url_22, data_source_22, mode = "wb")

In_vaccine_22 = read_excel(data_source_22)

## data source to zip aftewards 

data_source <- c(data_source_pre22, data_source_22)


In_vaccine <- bind_rows(In_vaccine_pre22, In_vaccine_22)

#Process data
All_ages <- seq(0,100,by=5)
Out_vaccine= In_vaccine %>%
  select(Date= `Vakcinācijas datums`, 
         Measure= `Vakcinācijas posms`,
         Age=`Vakcinētās personas vecums`, 
         Sex= `Vakcinētās personas dzimums`, 
         Value= `Vakcinēto personu skaits`) %>% 
  mutate(Measure = substr(Measure,1,6)) %>% 
  mutate(Measure= case_when(Measure == "1.pote" ~ "Vaccination1",
                            Measure == "2.pote"~ "Vaccination2",
                            Measure == "3.pote"~ "Vaccination3",
                            Measure == "1.bals" ~ "Vaccination3",
                            Measure == "2.bals" ~ "Vaccination4")) %>% 
  mutate(Sex = case_when(
                is.na(Sex)~ "UNK",
                Sex == "V" ~ "m",
                Sex == "S" ~ "f",
                Sex== "N" ~ "UNK"),
         Age = ifelse(Age > 100,100,Age),
         Age = Age - Age %% 5) %>% 
  # aggregate to daily sum 
  group_by(Date, Age, Measure, Sex) %>% 
  summarize(Value = sum(Value), .groups="drop") %>%
  tidyr::complete(Date, Sex, Age = All_ages, Measure, fill = list(Value = 0)) %>%
  #group_by(Date,Sex,Age,Measure)%>% 
  arrange(Sex,Age, Measure, Date)%>% 
  group_by(Sex, Age, Measure) %>%
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>%
    mutate(AgeInt = 5L,
           Metric = "Count") %>%
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = paste0("LV"),
    Country = "Latvia",
    Region = "All",
    Age = as.character(Age)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

## MK: Quality check for the merge and after-wrangling
# Out_vaccine %>% 
#   mutate(Date = dmy(Date)) %>% 
#   ggplot(aes(x = Date, y = Value)) + 
#   geom_point() +
#   facet_wrap(~ Measure)

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




