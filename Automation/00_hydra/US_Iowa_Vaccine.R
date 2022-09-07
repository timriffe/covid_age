###Iowa vaccines
library(here)
source(here("Automation/00_Functions_automation.R"))
library(readxl)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr <- "Iowa_Vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

test <- read_excel("https://onedrive.live.com/view.aspx?cid=26d8c5e551e13bad&page=view&resid=26D8C5E551E13BAD!3356&parId=26D8C5E551E13BAD!3353&authkey=!AIYtrGG0YPKvF1o&app=Excel")
url <- read_excel("https://excel.officeapps.live.com/x/_layouts/XlFileHandler.aspx?WacUserType=WOPI&usid=9eac966e-f795-4754-969c-d27f3147a17f&NoAuth=1&waccluster=PNL1")
#download.file(url, destfile = data_source_c)
# loading data
#destfile <- "COVID-19 Vaccination Report.xlsx"
#curl::curl_download(url)
#Iowa_vacc <- read_excel(destfile)
#head(Richard_Sprague_Tracking)

setwd("U:/Backup/Iowa")
vacc <- read_excel("COVID-19 Vaccination Report.xlsx", sheet = 5)
Out_vaccine= vacc%>%
  select(Date= Date, Age=Group, Vaccinations ="# of Doses", Vaccination1= "# of Series Initiated", Vaccination2= "# of Series Completed") %>% 
  filter(Age != "American Indian or Alaska Native") %>% 
  filter(Age != "Asian") %>% 
  filter(Age != "Black") %>% 
  filter(Age != "Latinx") %>% 
  filter(Age != "Native Hawaiian or Pacific Islander") %>% 
  filter(Age != "Not Latinx") %>% 
  filter(Age != "Other Race") %>% 
  filter(Age != "Unknown Ethnicity") %>% 
  filter(Age != "Unknown Race") %>% 
  filter(Age != "White") %>% 
  #filter(Date != NA ) %>% 
  mutate(Sex = case_when(
    Age == "Female" ~ "f",
    Age == "Male" ~ "m",
    TRUE ~ "b"),
    AgeInt = case_when(
      Age == "0 to 11 Year Olds" ~ "12",  
      Age == "0 to 17 Year Olds" ~ "18",   
      Age == "12 to 15 Year Olds" ~ "4",   
      Age == "16 to 17 Year Olds" ~ "2",   
      Age == "18 to 19 Year Olds" ~ "2",   
      Age == "18 to 29 Year Olds" ~ "12",   
      Age == "20 to 29 Year Olds" ~ "10",   
      Age == "30 to 39 Year Olds" ~ "10",   
      Age == "40 to 49 Year Olds" ~ "10",   
      Age == "50 to 59 Year Olds" ~ "10",   
      Age == "60 to 64 Year Olds" ~ "5",   
      Age == "60 to 69 Year Olds" ~ "10",     
      Age == "65+ Year Olds" ~ "40",   
      Age == "70 to 79 Year Olds" ~ "10",   
      Age == "80+ Year Olds" ~ "25",               
      Age == "Female" ~ "",                 
      Age == "Male" ~ "",    
      Age == "Unknown Age Group" ~ ""  
    ),
    Age = case_when(
      Age == "0 to 11 Year Olds" ~ "0",  
      Age == "0 to 17 Year Olds" ~ "0",   
      Age == "12 to 15 Year Olds" ~ "12",   
      Age == "16 to 17 Year Olds" ~ "16",   
      Age == "18 to 19 Year Olds" ~ "18",   
      Age == "18 to 29 Year Olds" ~ "18",   
      Age == "20 to 29 Year Olds" ~ "20",   
      Age == "30 to 39 Year Olds" ~ "30",   
      Age == "40 to 49 Year Olds" ~ "40",   
      Age == "50 to 59 Year Olds" ~ "50",   
      Age == "60 to 64 Year Olds" ~ "60",   
      Age == "60 to 69 Year Olds" ~ "60",     
      Age == "65+ Year Olds" ~ "65",   
      Age == "70 to 79 Year Olds" ~ "70",   
      Age == "80+ Year Olds" ~ "80",               
      Age == "Female" ~ "TOT",                 
      Age == "Male" ~ "TOT",    
      Age == "Unknown Age Group" ~ "UNK" 
    )) 
Out_vaccine <- as.data.table(Out_vaccine)
Out_vaccine <- melt(Out_vaccine, id = c("Date", "Age", "Sex", "AgeInt"))  
names(Out_vaccine)[6] <- "Value"
names(Out_vaccine)[5] <- "Measure"
Out_vaccine$Measure <- as.character(Out_vaccine$Measure)
Out_vaccine <- Out_vaccine %>% 
  arrange(Date, Measure, Age) %>% 
  mutate(Date= ddmmyyyy(Date)) %>% 
  mutate(Country = "USA",
           Region = "Iowa",
           Code = paste0("US-IA"),
           Metric = "Count") %>% 
  mutate(Measure = case_when(
    Measure == "Vaccination" ~ "Vaccinations",
    TRUE ~ Measure)) %>% 
  sort_input_data()
write_rds(Out_vaccine, paste0(dir_n, ctr, ".rds"))
  