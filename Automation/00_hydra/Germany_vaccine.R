#Germany vaccine 
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



#read in archived data 

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))

########################################################
#read in population 31.12.2019 to get count from rate 
#source Destatis 

#total population by age 
data_source_age= paste0(dir_n, "Data_sources/", ctr,"/Population_Germany_age_31.12.2019.xlsx") 
Population= read_excel(data_source_age)

Population_age= Population%>%
  slice(6:91)%>%
  select(Age= `Bevölkerung: Deutschland, Stichtag, Altersjahre`, Value= ...2) 

Population_age$AgeGroup=NA
Population_age$AgeGroup[1:18]= "0-17"
Population_age$AgeGroup[19:60]= "18-59"
Population_age$AgeGroup[61:86]= "60"

Population_age_groups= Population_age%>%
  mutate(Value = as.numeric(Value))%>%
  group_by(AgeGroup)%>%
  summarize(Value = sum(Value), .groups="drop")%>%
  mutate(Region= "All")%>%
  separate(AgeGroup, c("Age", "C", "-"))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "18" ~ 42L,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 45L))%>%
  select(Value, Age, AgeInt, Region)

#population by region and age
data_source_age_reg=paste0(dir_n, "Data_sources/", ctr,"/Population_Germany_age_region_31.12.2019.xlsx") 
Population_reg= read_excel(data_source_age_reg, range = "A5:Q98")

Population_reg_age= Population_reg%>%
  subset(...1 != "31.12.2019")%>%
  pivot_longer(!...1, names_to= "Region", values_to= "Value" )%>%
  select(Age= ...1, Region, Value)

Population_reg_age$AgeGroup=NA
Population_reg_age$AgeGroup[1:288]= "0-17"
Population_reg_age$AgeGroup[289:960]= "18-59"
Population_reg_age$AgeGroup[961:1456]= "60"
Population_reg_age$AgeGroup[1457:1472]= "TOT"

Population_reg_age_groups= Population_reg_age%>%
  mutate(Value = as.numeric(Value))%>%
  group_by(AgeGroup,Region)%>%
  summarize(Value = sum(Value), .groups="drop")%>%
  separate(AgeGroup, c("Age", "C", "-"))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "18" ~ 42L,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 45L))%>%
  subset(Age != "TOT")%>%
  select(Value, Age, AgeInt, Region)

#put both together

Pop_Final= rbind(Population_reg_age_groups, Population_age_groups)
Pop_Final=Pop_Final%>%
  select(Pop=Value, Age, AgeInt, Region)
##########################################################################################

#read in new data vaccine

m_url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquoten-Tab.html;jsessionid=7CD5258893F719D9991A9BAEC2B971F0.internet081"


links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx")) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()


url_d = paste0("https://www.rki.de",url)

data_source <- paste0(dir_n, "Data_sources/", ctr, "/age_vaccine",today(), ".xlsx")

download.file(url_d, data_source, mode = "wb")

In_vaccine= read_excel(data_source, sheet = 2, range = "A1:M21")

#read in date 

date_df= read_excel(data_source, sheet = 1, range = "A3", col_names = FALSE)
date_text= date_df$...1
date= substr(date_text, 13, 21)%>%
  dmy()

#process vaccine data 

Out_vaccine= In_vaccine %>%
  select(Region= ...2, Vaccinations_TOT= `Gesamtzahl bisher verabreichter Impfungen`, 
         Vaccination1_TOT= `Gesamtzahl  mindestens einmal geimpft*`, Vaccination2_TOT= `Gesamtzahl vollständig geimpft*`,
         Vaccination1_0_17= ...7, Vaccination1_18_59=...8, Vaccination1_60= ...9, Vaccination2_0_17= ...11, Vaccination2_18_59=...12, Vaccination2_60= ...13)%>%
  slice(3:20)%>%
  subset(Region!= "Bundesressorts****")%>%
  mutate(Vaccinations_TOT = as.character(Vaccinations_TOT))%>%
  mutate(Vaccination1_TOT = as.character(Vaccination1_TOT))%>%
  mutate(Vaccination2_TOT = as.character(Vaccination2_TOT))%>%
  pivot_longer(!Region, names_to= "Measure", values_to= "Value")%>%
  separate(Measure, c("Measure", "Age", "C", "_"))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "18" ~ 42L,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 45L))%>%
  mutate(Date= date,
         Region= recode(Region, 
                        "Gesamt"= "All"))%>%
  mutate(Value = as.numeric(Value))%>%
  select(Date, Region, Measure, Age, AgeInt, Value)
  
#rate date

vaccine_rate= Out_vaccine%>%
  subset(Age != "TOT")

vaccine_total= Out_vaccine%>%
  subset(Age == "TOT")
  
#combine vaccine and population 
vaccine_count <- merge(vaccine_rate,Pop_Final,by=c("Age","Region")) 
#calculate count
vaccine_count<- transform(vaccine_count, Count = (Value/100)*Pop)
  
vaccine_count= vaccine_count%>%
  select(Value= Count, Age, AgeInt=AgeInt.x, Region, Date, Measure)


#final output dataset 

vaccine_final= rbind(vaccine_count, vaccine_total)
  
vaccine_final= vaccine_final%>%
mutate(Metric = "Count",
Sex= "b",
Country = "Germany",
Code1 = case_when(Region == 'Baden-Württemberg' ~ 'DE_BW_',
                  Region == 'Bayern' ~ 'DE_BY_',
                  Region == 'Berlin' ~ 'DE_BE_',
                  Region == 'Brandenburg' ~ 'DE_BB_',
                  Region == 'Bremen' ~ 'DE_HB_',
                  Region == 'Hamburg' ~ 'DE_HH_',
                  Region == 'Hessen' ~ 'DE_HE_',
                  Region == 'Mecklenburg-Vorpommern' ~ 'DE_MV_',
                  Region == 'Niedersachsen' ~ 'DE_NI_',
                  Region == 'Nordrhein-Westfalen' ~ 'DE_NW_',
                  Region == 'Rheinland-Pfalz' ~ 'DE_RP_',
                  Region == 'Saarland' ~ 'DE_SL_',
                  Region == 'Sachsen' ~ 'DE_SN_',
                  Region == 'Sachsen-Anhalt' ~ 'DE_ST_',
                  Region == 'Schleswig-Holstein' ~ 'DE_SH_',
                  Region == 'Thüringen' ~ 'DE_TH_',
                  Region== 'All' ~ 'DE_All_',
                  TRUE ~ "other")) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0(Code1,Date))%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#append data and save output 
Out_final= bind_rows(DataArchive,vaccine_final)%>% 
  distinct()

write_rds(Out_final, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Out_final))

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





















