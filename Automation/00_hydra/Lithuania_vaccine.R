#Lithuania vaccine data 

library(here)
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <-"jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Lithuania_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

######11.10.21 MK: code needs to be updated
######new source
######noise for age, 10% have added, removed one year
#Read in data

In= read.csv("https://opendata.arcgis.com/api/v3/datasets/ffb0a5bfa58847f79bf2bc544980f4b6_0/downloads/data?format=csv&spatialRefId=4326", sep = ",")

#Process
#Dose 1 
# Out_vaccine1= In %>%
#   select(Sex=sex, Age= age_group, Date= vacc_date_1)%>%
#   separate(Date, c("Date", "Time"), " ")%>%
#   mutate(Sex= recode(Sex, 
#                      `M`= "m",
#                      `V`= "f"))%>%
#   group_by(Date, Sex, Age) %>% 
#   summarize(Value = n(), .groups="drop")%>%
#   arrange(Date,Sex, Age) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>%
#   mutate(AgeInt= case_when(
#     Age == "80" ~ 25L,
#     TRUE~ 5L))%>%
#   mutate(
#     Measure = "Vaccination1",
#     Metric = "Count")%>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("LT_All",Date),
#     Country = "Lithuania",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)

Out_vaccine1= In %>%
  #remove missing age information 
  filter(!is.na(birth_year_noisy)) %>% 
select(Sex=sex, birth= birth_year_noisy, Date= vaccination_date, ID = pseudo_id, Drug = drug_manufacturer)%>%
  separate(Date, c("Date", "Time"), " ")%>%
  mutate(Sex= recode(Sex, 
                     `M`= "m",
                     `V`= "f")) %>% 
  mutate(Age= 2021- birth)%>%    
  filter(Drug != "Johnson & Johnson") %>% 
  group_by(ID) %>% 
  mutate(n = row_number()) %>% 
  filter(n == 1) %>% 
  group_by(Date, Sex, Age) %>%   
  summarize(Value = n()) %>% 
  ungroup() %>% 
 tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  arrange(Date,Sex, Age) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
   mutate(
    Measure = "Vaccination1",
    Metric = "Count", 
    AgeInt= "1")%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LT_All",Date),
    Country = "Lithuania",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#Dose2


# Out_vaccine2= In %>%
#   select(Sex=sex, Age= age_group, Date= vacc_date_2)
# 
# #remove everyone with a empty cell for data vaccine 2 (prob. have not received shot yet/single dose vaccine)
# 
# Out_vaccine2[Out_vaccine2==""]<-NA
#   
# Out_vaccine2= Out_vaccine2 %>%
#   filter(!is.na(Date))%>%
#   mutate(Sex= recode(Sex, 
#                      `M`= "m",
#                      `V`= "f"))%>%
#   group_by(Date, Sex, Age) %>% 
#   summarize(Value = n(), .groups="drop")%>%
#   arrange(Sex, Age, Date) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>%
#   separate(Date, c("Date", "Time"), " ")%>%
#   mutate(AgeInt= case_when(
#     Age == "80" ~ 25L,
#     TRUE~ 5L))%>%
#   mutate(
#     Measure = "Vaccination2",
#     Metric = "Count") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("LT_All",Date),
#     Country = "Lithuania",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)


Out_vaccine2= In %>%
  #remove missing age information 
  filter(!is.na(birth_year_noisy)) %>% 
  select(Sex=sex, birth= birth_year_noisy, Date= vaccination_date, ID = pseudo_id, Drug = drug_manufacturer)%>%
  separate(Date, c("Date", "Time"), " ")%>%
  mutate(Sex= recode(Sex, 
                     `M`= "m",
                     `V`= "f")) %>% 
  mutate(Age= 2021- birth)%>%
  group_by(ID) %>% 
  mutate(n = row_number()) %>% 
  filter(Drug == "Johnson & Johnson" | n == 2) %>% 
  group_by(Date, Sex, Age) %>%   
  summarize(Value = n())%>%
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  arrange(Date,Sex, Age) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  #age lets assume we just take current year 
  mutate(
    Measure = "Vaccination2",
    Metric = "Count", 
    AgeInt= "1")%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LT_All",Date),
    Country = "Lithuania",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

####just a test
test <- Out_vaccine2 %>% 
  group_by(Date) %>% 
  summarise(Vac = sum(Value))

#put them together 

out <- bind_rows(Out_vaccine1,
                 Out_vaccine2)


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(In, data_source)


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









