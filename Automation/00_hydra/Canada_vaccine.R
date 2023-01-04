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

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#Read in data 


## Website source: https://health-infobase.canada.ca/covid-19/vaccination-coverage/

#url <- "https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-byAgeAndSex.csv"
#IN<- read_csv("https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-byAgeAndSex.csv")

IN <- read_csv("https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-byAgeAndSex-overTimeDownload.csv")

#Process data 
raw_data <- IN %>%
  select(Region = prename, 
         Date = week_end, 
         Sex = sex, 
         Age = age, 
         Vaccination1 = numtotal_atleast1dose,
         Vaccinations = numtotal_partially, 
         Vaccination2 = numtotal_fully, 
         Vaccination3 = numtotal_additional,
         Vaccination4 = numtotal_2nd_additional) %>%
  mutate(Vaccination3 = as.character(Vaccination3),
         Vaccination4 = as.character(Vaccination4)) %>% 
  pivot_longer(!Age & !Sex & !Date & !Region, names_to= "Measure", values_to= "Value")%>%
  mutate(Sex = recode(Sex,
                      `Unknown`= "UNK",
                      `Not reported` = "UNK",
                      `Other` = "UNK",
                      `All sexes` = "b"),
         Value = as.numeric(Value)) %>% 
  filter(!is.na(Value))

processed_data <- raw_data %>% 
  mutate(AgeInt = case_when(
    Age == "0-4" ~ 5L,
    Age == "0-15" ~ 16L,
    Age == "0-17" ~ 18L,# The age groups vary by time and region, not sure if this is the best way to deal with that 
    Age == "05-11" ~ 7L,
    Age == "12-17" ~ 6L,
    Age == "16-69" ~ 54L,
    Age == "18-29" ~ 11L,
   # Age == "18-49" ~ 32L,
    Age == "18-69" ~ 52L,
    Age == "30-39" ~ 10L,
    Age == "40-49" ~ 10L,
    Age == "50-59" ~ 10L,
    Age == "60-69" ~ 10L,
    Age == "70-74" ~ 5L,
    Age == "70-79" ~ 10L,
    Age == "75-79" ~ 5L,
    Age == "80+" ~ 25L,
    Age == "Unknown" ~ NA_integer_,
    Age == "Not reported" ~ NA_integer_,
    Age == "All ages" ~ NA_integer_,
    TRUE ~ 5L),
  #  Age = case_when(Age == "Unknown" ~ "UNK",
  #                  Age == "Not reported" ~ "UNK",
  #                  Age == "All ages" ~ "TOT",
  #                  TRUE ~ Age)) %>% 
  # tidyr::separate(Age, into = c("Age", "nothing"), sep = "[+–]") %>% 
   Age = case_when(Age == "0–4" ~ "0",
                   Age == "0–15" ~ "0",
                   Age == "0–17" ~ "0",
                   Age == "05–11"  ~ "5",
                   Age == "12–17" ~ "12",
                   Age == "16–69"  ~ "16",
                   Age == "18–69" ~ "18",
                   Age == "18–29"  ~ "18",
                  #Age == "18–49" ~ "18",
                   Age == "30–39" ~ "30",
                   Age == "40–49"  ~"40",
                   Age == "50–59" ~ "50",
                   Age == "60–69"  ~ "60",
                   Age == "70–74" ~ "70",
                   Age == "70–79"  ~ "70",
                   Age == "75–79" ~ "75",
                   Age == "80+" ~ "80",
                   Age == "Unknown" ~ "UNK",
                   Age == "Not reported" ~ "UNK",
                  Age == "All ages" ~ "TOT")) %>%
  group_by(Region, Date, Sex, Age, Measure, AgeInt) %>% 
  summarise(Value = sum(Value)) 
  # mutate(Value=recode(Value, 
  #                   `<5`="2"))%>%
#   subset(!is.na(Value)) #Mostly in Quebec Vaccination2 had na. decided to remove them, because according to vaccine brands 
# #and time they started to vaccinate there should be a Vaccine2, so replacing with 0 seems like the wrong information



Out <- processed_data %>%  
  mutate(Code = case_when(Region == "Alberta" ~ "CA-AB",
                          Region == "British Columbia" ~ "CA-BC",
                          Region == "Canada" ~ "CA",
                          Region == "Manitoba" ~ "CA-MB",
                          Region == "New Brunswick" ~ "CA-NB",
                          Region == "Newfoundland and Labrador" ~ "CA-NL",
                          Region == "Northwest Territories" ~ "CA-NT",
                          Region == "Nova Scotia" ~ "CA-NS",
                          Region == "Nunavut" ~ "CA-NU",
                          Region == "Ontario" ~ "CA-ON",
                          Region == "Prince Edward Island" ~ "CA-PE",
                          Region == "Quebec" ~ "CA-QC", 
                          Region == "Saskatchewan" ~ "CA-SK",
                          Region == "Yukon" ~ "CA-YT"), 
       Region = recode(Region, 
                       `Canada`="All"),
       Date = ymd(Date),
       Date = ddmmyyyy(Date),
       Country ="Canada" ,
       Metric = "Count",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()
  


#save output data 
write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))

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

## history ============

#Contains all values with >, remove > and impute 2
# 
# Out1 <- 
#   Out %>% subset(substr(Value,1,1)== ">") %>%
#   separate(Value, c("col", "Value"), ">", fill = "left") %>%
#   mutate(Value = as.numeric(Value), 
#          Value = Value+2,
#          Value = as.character(Value)) %>%
#   select(-col) 
#   
# # Contains all data without <> 
# 
# Out2 <- 
#   Out %>% 
#   subset(substr(Value,1,1)!= ">")
# 
# #put both togehter again
# 
# outfinal <- bind_rows(Out1, Out2)


