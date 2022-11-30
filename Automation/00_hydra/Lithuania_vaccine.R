#Lithuania vaccine data 

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <-"jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Lithuania_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

######11.10.21 
######new source
######noise for age, 10% have added, removed one year
#Read in data

## Source website: https://hub.arcgis.com/datasets/ffb0a5bfa58847f79bf2bc544980f4b6_0/about

In= data.table::fread("https://opendata.arcgis.com/api/v3/datasets/ffb0a5bfa58847f79bf2bc544980f4b6_0/downloads/data?format=csv&spatialRefId=4326")


## MK 08.08.2022

## Well, it seems that at some point the authorities added 'dose_number'
## so I adapted the code accordingly

## Some anatomy of the dataset:
## This dataset is a linelist, identified by unique ID, and birth year with noise (for privacy concerns)
## so our job here is to identify the columns of interest, 
## mutate the necessary 
## sum value of the unique/ grouped ID and measure, by getting row numbers. 
## fill in the dates gap based on grouped data by: Age, sex, Measure 
## then cumsum the values. 
## add the usual stuff: country ISO code, region, etc.


## MK 26.08.2020
## I am adapting the code so that 105 is the oldest age group

processed_data <- In %>%
  #remove missing age information if any 
  filter(!is.na(birth_year_noisy)) %>% 
  select(Date = vaccination_date,
         ID = pseudo_id, 
         birth = birth_year_noisy, 
         Sex = sex, 
         Measure = dose_number) %>%
  separate(Date, c("Date", "Time"), " ") %>% 
  # as per the codebook: V-vyras, M-moteris:
  # V for males, M for females 
  mutate(Date = ymd(Date),
         Sex = recode(Sex, 
                     `M`= "f",
                     `V`= "m"),
         ## here I would calculate the Age from the vaccination_date: vaccination_date - birth_date 
         Age = lubridate::year(Date)- birth,
         Measure = recode(Measure, 
                          `1` = "Vaccination1",
                          `2` = "Vaccination2",
                          `3` = "Vaccination3",
                          `4` = "Vaccination4",
                          `5` = "Vaccination5")) %>% 
  group_by(ID, Measure) %>% 
  mutate(n = row_number()) %>% 
  ungroup() %>%  
         mutate(Age = case_when(
           Age == 106 ~ 105,
           Age == 107 ~ 105,
           TRUE ~ Age
           )) %>% 
  group_by(Date, Sex, Age, Measure) %>%   
  summarize(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age, Measure), fill=list(Value=0)) %>% 
  arrange(Date, Sex, Age, Measure) %>% 
  group_by(Sex, Age, Measure) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() 


out <- processed_data %>% 
  mutate(
    Metric = "Count", 
    AgeInt = 1L)%>% 
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = paste0("LT"),
    Country = "Lithuania",
    Region = "All") %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()



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



### END ###



## PREVIOUS CODE ## ################################################


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

# Out_vaccine1= In %>%
#   #remove missing age information 
#   filter(!is.na(birth_year_noisy)) %>% 
# select(Sex=sex, birth= birth_year_noisy, 
#        Date= vaccination_date, ID = pseudo_id, Drug = drug_manufacturer)%>%
#   separate(Date, c("Date", "Time"), " ")%>%
#   mutate(Sex= recode(Sex, 
#                      `M`= "m",
#                      `V`= "f",
#                      `CenzÅ«ruota` = "b")) %>% 
#   mutate(Age= 2021- birth)%>%    
# #  filter(Drug != "Johnson & Johnson") %>% 
#   group_by(ID) %>% 
#   mutate(n = row_number()) %>% 
#   filter(n == 1) %>% 
#   group_by(Date, Sex, Age) %>%   
#   summarize(Value = n()) %>% 
#   ungroup() %>% 
#   tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
#   arrange(Date,Sex, Age) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#    mutate(
#     Measure = "Vaccination1",
#     Metric = "Count", 
#     AgeInt= "1")%>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("LT"),
#     Country = "Lithuania",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 

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


# Out_vaccine2= In %>%
#   #remove missing age information 
#   filter(!is.na(birth_year_noisy)) %>% 
#   select(Sex=sex, birth= birth_year_noisy, Date= vaccination_date, ID = pseudo_id, Drug = drug_manufacturer)%>%
#   separate(Date, c("Date", "Time"), " ")%>%
#   mutate(Sex= recode(Sex, 
#                      `M`= "m",
#                      `V`= "f",
#                      `CenzÅ«ruota` = "b")) %>% 
#   mutate(Age= 2021- birth)%>%
#   group_by(ID) %>% 
#   mutate(n = row_number()) %>% 
#   filter(Drug == "Johnson & Johnson" | n == 2) %>% 
#   group_by(Date, Sex, Age) %>%   
#   summarize(Value = n())%>%
#   ungroup() %>% 
#   tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
#   arrange(Date,Sex, Age) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#   #age lets assume we just take current year 
#   mutate(
#     Measure = "Vaccination2",
#     Metric = "Count", 
#     AgeInt= "1")%>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("LT"),
#     Country = "Lithuania",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)


# Out_vaccine3= In %>%
#   #remove missing age information 
#   filter(!is.na(birth_year_noisy)) %>% 
#   select(Sex=sex, birth= birth_year_noisy, Date= vaccination_date, ID = pseudo_id, Drug = drug_manufacturer)%>%
#   separate(Date, c("Date", "Time"), " ")%>%
#   mutate(Sex= recode(Sex, 
#                      `M`= "m",
#                      `V`= "f",
#                      `CenzÅ«ruota` = "b")) %>% 
#   mutate(Age= 2021- birth)%>%
#   group_by(ID) %>% 
#   mutate(n = row_number()) %>% 
#   filter(n == 3) %>% 
#   group_by(Date, Sex, Age) %>%   
#   summarize(Value = n())%>%
#   ungroup() %>% 
#   tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
#   arrange(Date,Sex, Age) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() %>% 
#   #age lets assume we just take current year 
#   mutate(
#     Measure = "Vaccination3",
#     Metric = "Count", 
#     AgeInt= "1")%>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("LT"),
#     Country = "Lithuania",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# #put them together 
# 
# out <- bind_rows(Out_vaccine1,
#                  Out_vaccine2,
#                  Out_vaccine3)

##calculating both sexes
# sexes <- out %>% 
#   filter(Sex != "b") %>% 
#   group_by(Country, Region, Code, Date, Age, AgeInt, Metric, Measure) %>% 
#   summarise(Value = sum(Value)) %>% 
#   mutate(Sex = "b")
# 
# 
# out <- rbind(out, sexes) %>% 
#   sort_input_data() %>% 
#   filter(Age != "-1")









