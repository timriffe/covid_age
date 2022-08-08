#Texas Vaccine

library(here)
source(here("Automation", "00_Functions_automation.R"))

# install.packages("readODS")
library(readODS)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address
ctr          <- "US_Texas_Vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#get previous age data by sex and save it  
#data by sex and dose is appended
#data for both sexes and doses combined is refreshed, need that time series to get date  

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds")) 


#save data by sex and totals  

Append= DataArchive%>%
  # MK 07.07.2022: Not sure why these steps are here ##
  filter(Sex== "f"| Sex== "m"| Sex== "UNK"| Age == "TOT") %>%
  mutate(Sex = case_when(
    Sex == "Texas" ~ "b",
    TRUE ~ Sex)) %>%
  mutate(Age = case_when(
    Age == "6mo-4yr" ~ "0",
    Age == "44327" ~ "5",
    Age == "44545" ~ "12",
    Age == "16-49" ~ "16",
    Age == "44692" ~ "5",
    Age == "44910" ~ "12",
    Age == "50-64" ~ "50",
    Age == "65-79" ~ "65",
    Age == "80+" ~ "80",
    Age == "Total" ~ "TOT",
    Age == "Unknown" ~ "UNK",
    TRUE  ~ Age
  ),
  AgeInt = case_when(
    Age == "0" ~ 5L,
    Age == "5" ~ 7L,
    Age == "12" ~ 5L,
    Age == "16" ~ 34L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 15L)) %>% 
  unique()


#Download data 

url <- "https://www.dshs.texas.gov/immunize/covid19/COVID-19-Vaccine-Data-by-County.xls"


data_source <- paste0(dir_n, "Data_sources/", ctr, "/data_vaccine",today(), ".xlsx")

download.file(url, data_source, mode = "wb")

#Read in data

In_vaccine <- read_xlsx(data_source, sheet = 4)

##MK: Texas changed the age groups by adding "6mo-4yr", recoded 

In_vaccine_age<- In_vaccine %>%
  select(Age = `Agegrp_v2`, Date=`Vaccination Date`, Doses= `Doses Administered`)%>%
  filter(!is.na(Date))

#Date is transformed to time passed since 01.01.1900 when Excel file is read in
# Reshape to date format 

#date_vector <- In_vaccine_age$Date_numeric
#x <- factor(date_vector)
#y <- as.numeric(as.character(x))
#Date <- as.Date(y- 2, origin = "1900-01-01")
#Date<-data.frame(Date)
#In_vaccine_age$Date <- (Date$Date)


# Process data for both sexes and doses, whole series refreshed every time  

Out_Vaccine_Age = In_vaccine_age %>% 
  select(Age ,Date, Doses)%>%
  mutate(Age = as.character(Age),
         Date = as.character(Date)) %>% 
  arrange(Date) %>% 
  group_by(Age) %>% 
  mutate(Value= cumsum(Doses)) %>% 
  ungroup() %>%
  mutate(Age=recode(Age, 
                    `6mo-4yr` = "0",
                    `16-49`="16",
                    `50-64`="50",
                    `65-79`="65",
                    `80+`="80",
                    `44692`="5",
                    `44910`="12",
                    `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 5L,
    Age == "5" ~ 7L,
    Age == "12" ~ 5L,
    Age == "16" ~ 34L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 15L))%>% 
  mutate(
    Measure = "Vaccinations",
    Metric = "Count", 
    Sex= "b" ) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-TX"),
    Country = "USA",
    Region = "Texas",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#find most recent date to assign to vaccine data by sex and dose, tab is uploaded without date column  

datesmax = Out_Vaccine_Age%>% 
  mutate(Date = dmy(Date)) %>%
  summarise(max = max(Date))

# Read in age date by dose and sex, only given per day 

In_vaccine_dose <- read_xlsx(data_source, sheet = 3)


Out_Vaccine_dose <- In_vaccine_dose %>% 
  select(Race = `Race/Ethnicity` , Sex = Gender, Age = `Agegrp_v2`,  
         Vaccinations= `Doses Administered`, 
         Vaccination1= `People Vaccinated with at least One Dose` , 
         Vaccination2= `People Fully Vaccinated`)%>%
  pivot_longer(!Age & !Sex & !Race, names_to= "Measure", values_to= "Value")%>%
   mutate(Age=recode(Age, 
                     `6mo-4yr`= "0",
                     `44692`="5",
                     `44910`="12",
                    `16-49`="16",
                    `50-64`="50",
                    `65-79`="65",
                    `80+`="80",
                    `Unknown`="UNK",
                    `Total`="TOT"), 
          AgeInt = case_when(
            Age == "0" ~ 5L,
            Age == "5" ~ 7L,
            Age == "12" ~ 5L,
            Age == "16" ~ 34L,
            Age == "80" ~ 25L,
            Age == "UNK" ~ NA_integer_,
            Age == "TOT" ~ NA_integer_,
            TRUE ~ 15L), 
          Sex = recode(Sex,
                       `Male` = "m",
                       `Female` = "f",
                       `Unknown`= "UNK",
                       `Grand Total` = "b",
                       `Texas` = "UNK")) %>%
  group_by(Sex, Age, Measure) %>% # Data given by race, sum those together 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  subset(Race== "Asian" | Age == "TOT" )%>% # Remove duplicates by race
  mutate(Metric = "Count",
         Date= datesmax$max, 
         Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US-TX"),
         Country = "USA",
         Region = "Texas",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)



#put both together 

out <- bind_rows(Out_Vaccine_Age,
                 Out_Vaccine_dose,
                 Append)

#save output data 
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

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




