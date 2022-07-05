#Germany vaccine 
#JD 22.09.2021: Rewrote script with more detailed data provided by RKI
#Data is now given with absolute numbers and whole time series

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

ctr          <- "Germany_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#read in data vaccine

url_v="https://raw.githubusercontent.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland/master/Aktuell_Deutschland_Landkreise_COVID-19-Impfungen.csv"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/age_vaccine",today(), ".csv")

download.file(url_v, data_source, mode = "wb")

Vaccine_in= read.csv(data_source)


#process vaccine data 

#remove Bundesressort here, vaccines from federal ressource where state is not documented
Vaccine_out_reg= Vaccine_in%>%
  mutate(Number= nchar(LandkreisId_Impfort)) %>% 
  mutate(RegID = case_when(
    Number == "4" ~ substr(LandkreisId_Impfort,1,1),
    TRUE ~ substr(LandkreisId_Impfort,1,2)))%>%
  mutate(Region= recode(RegID,
                        "01"="Schleswig-Holstein",
                        "02"="Hamburg",
                        "03"="Niedersachsen",
                        "04"="Bremen",
                        "05"="Nordrhein-Westfalen",
                        "06"="Hessen",
                        "07"="Rheinland-Pfalz",
                        "08"="Baden-Württemberg",
                        "09"="Bayern",
                        "10"="Saarland",
                        "11"="Berlin",
                        "12"="Brandenburg",
                        "13"="Mecklenburg-Vorpommern",
                        "14"="Sachsen",
                        "15"="Sachsen-Anhalt",
                        "16"="Thüringen"))%>%
  filter(Region!= "17",
         Region != "u")%>%
  select(Date=Impfdatum, Age= Altersgruppe, Measure= Impfschutz, Value=Anzahl, Region)%>%
  #sum subregional level to regional level
  group_by(Date, Age, Region, Measure)%>%
  mutate(Value=sum(Value))%>%
  unique()%>%
  ungroup()%>%
  arrange(Age,Date,Region,Measure)%>% 
  group_by(Age,Region,Measure) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Code1 = case_when(Region == 'Baden-Württemberg' ~ 'DE-BW',
                           Region == 'Bayern' ~ 'DE-BY',
                           Region == 'Berlin' ~ 'DE-BE',
                           Region == 'Brandenburg' ~ 'DE-BB',
                           Region == 'Bremen' ~ 'DE-HB',
                           Region == 'Hamburg' ~ 'DE-HH',
                           Region == 'Hessen' ~ 'DE-HE',
                           Region == 'Mecklenburg-Vorpommern' ~ 'DE-MV',
                           Region == 'Niedersachsen' ~ 'DE-NI',
                           Region == 'Nordrhein-Westfalen' ~ 'DE-NW',
                           Region == 'Rheinland-Pfalz' ~ 'DE-RP',
                           Region == 'Saarland' ~ 'DE-SL',
                           Region == 'Sachsen' ~ 'DE-SN',
                           Region == 'Sachsen-Anhalt' ~ 'DE-ST',
                           Region == 'Schleswig-Holstein' ~ 'DE-SH',
                           Region == 'Thüringen' ~ 'DE-TH'),
         Measure= case_when(Measure== "1"~ "Vaccination1",
                            Measure=="2"~"Vaccination2",
                            Measure=="3"~"Vaccination3",
                            Measure=="4"~"Vaccination4"),
         Age=recode(Age, 
                    "05-11"="5",
                    "12-17"="12",
                    "18-59"="18",
                    "60+"="60",
                    "u"="UNK")) %>% 
  tidyr::complete(Age, nesting(Date, Measure, Region, Code1), fill=list(Value=0)) %>% 
        mutate(AgeInt = case_when(
           Age == "5" ~ 7L,
           Age == "12" ~ 6L,
           Age == "18" ~ 42L,
           Age == "60" ~ 45L),
         Sex="b",
         Country= "Germany",
         Metric="Count")%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0(Code1))%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)



#National Level(include data from Bundesressorts) 

Vaccine_out_all= Vaccine_in%>%
  select(Date=Impfdatum, Age= Altersgruppe, Measure= Impfschutz, Value=Anzahl)%>%
  #sum subregional level to national level 
  group_by(Date, Age, Measure)%>%
  mutate(Value=sum(Value))%>%
  unique()%>%
  ungroup()%>%
  arrange(Age,Date,Measure)%>% 
  group_by(Age,Measure) %>% 
  mutate(Value = cumsum(Value))%>% 
  ungroup()%>%
  mutate(Measure= recode(Measure,
                         "1"= "Vaccination1",
                         "2"="Vaccination2",
                         "3"="Vaccination3",
                         "4"="Vaccination4"),
         Age=recode(Age, 
                    "05-11"="5",
                    "12-17"="12",
                    "18-59"="18",
                    "60+"="60",
                    "u"="UNK")) %>% 
  tidyr::complete(Age, nesting(Date, Measure), fill=list(Value=0)) %>%   
  mutate(AgeInt = case_when(
           Age == "5" ~ 7L,
           Age == "12" ~ 6L,
           Age == "18" ~ 42L,
           Age == "60" ~ 45L),
         Sex="b",
         Country= "Germany",
         Metric="Count",
         Region="All")%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("DE"))%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#final output dataset
Vaccine_out=rbind(Vaccine_out_all,Vaccine_out_reg)



##adding age group 0 to 4
small_ages <- Vaccine_out %>% 
  filter(Age == "5") %>% 
  mutate(Age = "0",
         AgeInt = 5L,
         Value = 0)
Vaccine_out <- rbind(Vaccine_out, small_ages) %>% 
  sort_input_data()
# Vaccine_out2 <- Vaccine_out %>% 
#   tidyr::complete(Date, Age, Country, Region, Code, AgeInt, Sex, Metric, Measure, fill = list(Value = 0))


write_rds(Vaccine_out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Vaccine_out))

#zip input data
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





#####outdated script##############

# #Germany vaccine 
# library(here)
# source(here("Automation/00_Functions_automation.R"))
# library(lubridate)
# library(dplyr)
# library(tidyverse)
# 
# # assigning Drive credentials in the case the script is verified manually  
# if (!"email" %in% ls()){
#   email <- "jessica_d.1994@yahoo.de"
# }
# 
# 
# # info country and N drive address
# 
# ctr          <- "Germany_vaccine" # it's a placeholder
# dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
# 
# 
# 
# #read in archived data 
# 
# DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))
# 
# ########################################################
# #read in population 31.12.2019 to get count from rate 
# #source Destatis 
# 
# #total population by age 
# data_source_age= paste0(dir_n, "Data_sources/", ctr,"/Population_Germany_age_31.12.2019.xlsx") 
# Population= read_excel(data_source_age)
# 
# Population_age= Population%>%
#   slice(6:91)%>%
#   select(Age= `Bevölkerung: Deutschland, Stichtag, Altersjahre`, Value= ...2) 
# 
# Population_age$AgeGroup=NA
# Population_age$AgeGroup[1:18]= "0-17"
# Population_age$AgeGroup[19:60]= "18-59"
# Population_age$AgeGroup[61:86]= "60"
# 
# Population_age_groups= Population_age%>%
#   mutate(Value = as.numeric(Value))%>%
#   group_by(AgeGroup)%>%
#   summarize(Value = sum(Value), .groups="drop")%>%
#   mutate(Region= "All")%>%
#   separate(AgeGroup, c("Age", "C", "-"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 18L,
#     Age == "18" ~ 42L,
#     Age == "TOT" ~ NA_integer_,
#     TRUE ~ 45L))%>%
#   select(Value, Age, AgeInt, Region)
# 
# #population by region and age
# data_source_age_reg=paste0(dir_n, "Data_sources/", ctr,"/Population_Germany_age_region_31.12.2019.xlsx") 
# Population_reg= read_excel(data_source_age_reg, range = "A5:Q98")
# 
# Population_reg_age= Population_reg%>%
#   subset(...1 != "31.12.2019")%>%
#   pivot_longer(!...1, names_to= "Region", values_to= "Value" )%>%
#   select(Age= ...1, Region, Value)
# 
# Population_reg_age$AgeGroup=NA
# Population_reg_age$AgeGroup[1:288]= "0-17"
# Population_reg_age$AgeGroup[289:960]= "18-59"
# Population_reg_age$AgeGroup[961:1456]= "60"
# Population_reg_age$AgeGroup[1457:1472]= "TOT"
# 
# Population_reg_age_groups= Population_reg_age%>%
#   mutate(Value = as.numeric(Value))%>%
#   group_by(AgeGroup,Region)%>%
#   summarize(Value = sum(Value), .groups="drop")%>%
#   separate(AgeGroup, c("Age", "C", "-"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 18L,
#     Age == "18" ~ 42L,
#     Age == "TOT" ~ NA_integer_,
#     TRUE ~ 45L))%>%
#   subset(Age != "TOT")%>%
#   select(Value, Age, AgeInt, Region)
# 
# #put both together
# 
# Pop_Final= rbind(Population_reg_age_groups, Population_age_groups)
# Pop_Final=Pop_Final%>%
#   select(Pop=Value, Age, AgeInt, Region)
# ##########################################################################################
# 
# #read in new data vaccine
# 
# m_url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquoten-Tab.html;jsessionid=7CD5258893F719D9991A9BAEC2B971F0.internet081"
# 
# 
# links <- scraplinks(m_url) %>% 
#   filter(str_detect(url, "Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx")) %>% 
#   select(url) 
# 
# url <- 
#   links %>% 
#   select(url) %>% 
#   dplyr::pull()
# 
# 
# url_d = paste0("https://www.rki.de",url)
# 
# data_source <- paste0(dir_n, "Data_sources/", ctr, "/age_vaccine",today(), ".xlsx")
# 
# download.file(url_d, data_source, mode = "wb")
# 
# In_vaccine= read_excel(data_source, sheet = 2, range = "A1:M21")
# 
# #read in date 
# 
# date_df= read_excel(data_source, sheet = 1, range = "A3", col_names = FALSE)
# date_text= date_df$...1
# date= substr(date_text, 13, 21)%>%
#   dmy()
# 
# #process vaccine data 
# 
# Out_vaccine= In_vaccine %>%
#   select(Region= ...2, Vaccinations_TOT= `Gesamtzahl bisher verabreichter Impfungen`, 
#          Vaccination1_TOT= `Gesamtzahl  mindestens einmal geimpft*`, Vaccination2_TOT= `Gesamtzahl vollständig geimpft*`,
#          Vaccination1_0_17= ...7, Vaccination1_18_59=...8, Vaccination1_60= ...9, Vaccination2_0_17= ...11, Vaccination2_18_59=...12, Vaccination2_60= ...13)%>%
#   slice(3:20)%>%
#   subset(Region!= "Bundesressorts****")%>%
#   mutate(Vaccinations_TOT = as.character(Vaccinations_TOT))%>%
#   mutate(Vaccination1_TOT = as.character(Vaccination1_TOT))%>%
#   mutate(Vaccination2_TOT = as.character(Vaccination2_TOT))%>%
#   pivot_longer(!Region, names_to= "Measure", values_to= "Value")%>%
#   separate(Measure, c("Measure", "Age", "C", "_"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 18L,
#     Age == "18" ~ 42L,
#     Age == "TOT" ~ NA_integer_,
#     TRUE ~ 45L))%>%
#   mutate(Date= date,
#          Region= recode(Region, 
#                         "Gesamt"= "All"))%>%
#   mutate(Value = as.numeric(Value))%>%
#   select(Date, Region, Measure, Age, AgeInt, Value)
#   
# #rate date
# 
# vaccine_rate= Out_vaccine%>%
#   subset(Age != "TOT")
# 
# vaccine_total= Out_vaccine%>%
#   subset(Age == "TOT")
#   
# #combine vaccine and population 
# vaccine_count <- merge(vaccine_rate,Pop_Final,by=c("Age","Region")) 
# #calculate count
# vaccine_count<- transform(vaccine_count, Count = (Value/100)*Pop)
#   
# vaccine_count= vaccine_count%>%
#   select(Value= Count, Age, AgeInt=AgeInt.x, Region, Date, Measure)
# 
# 
# #final output dataset 
# 
# vaccine_final= rbind(vaccine_count, vaccine_total)
#   
# vaccine_final= vaccine_final%>%
# mutate(Metric = "Count",
# Sex= "b",
# Country = "Germany",
# Code1 = case_when(Region == 'Baden-Württemberg' ~ 'DE_BW_',
#                   Region == 'Bayern' ~ 'DE_BY_',
#                   Region == 'Berlin' ~ 'DE_BE_',
#                   Region == 'Brandenburg' ~ 'DE_BB_',
#                   Region == 'Bremen' ~ 'DE_HB_',
#                   Region == 'Hamburg' ~ 'DE_HH_',
#                   Region == 'Hessen' ~ 'DE_HE_',
#                   Region == 'Mecklenburg-Vorpommern' ~ 'DE_MV_',
#                   Region == 'Niedersachsen' ~ 'DE_NI_',
#                   Region == 'Nordrhein-Westfalen' ~ 'DE_NW_',
#                   Region == 'Rheinland-Pfalz' ~ 'DE_RP_',
#                   Region == 'Saarland' ~ 'DE_SL_',
#                   Region == 'Sachsen' ~ 'DE_SN_',
#                   Region == 'Sachsen-Anhalt' ~ 'DE_ST_',
#                   Region == 'Schleswig-Holstein' ~ 'DE_SH_',
#                   Region == 'Thüringen' ~ 'DE_TH_',
#                   Region== 'All' ~ 'DE_All_',
#                   TRUE ~ "other")) %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0(Code1,Date))%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# 
# #append data and save output 
# Out_final= bind_rows(DataArchive,vaccine_final)%>% 
#   distinct()
# 
# write_rds(Out_final, paste0(dir_n, ctr, ".rds"))
# 
# # updating hydra dashboard
# log_update(pp = ctr, N = nrow(Out_final))
# 
# #zip input data
# zipname <- paste0(dir_n,
#                   "Data_sources/", 
#                   ctr,
#                   "/", 
#                   ctr,
#                   "_data_",
#                   today(), 
#                   ".zip")
# 
# 
# 
# zip::zipr(zipname, 
#           data_source, 
#           recurse = TRUE, 
#           compression_level = 9,
#           include_directories = TRUE)
# 
# file.remove(data_source)            
# 
# 
# 