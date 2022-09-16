library(here)
source(here("Automation/00_Functions_automation.R"))

#install.packages("ISOweek")

if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address

ctr          <- "Scotland_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


###get vaccine data for scotland

## Source Website: https://www.opendata.nhs.scot/dataset/covid-19-vaccination-in-scotland

vacc <- read.csv("https://www.opendata.nhs.scot/dataset/6dbdd466-45e3-4348-9ee3-1eac72b5a592/resource/9b99e278-b8d8-47df-8d7a-a8cf98519ac1/download/daily_vacc_age_sex_20211103.csv")
vacc2 <- vacc %>% 
  select(Date = Date, Sex = Sex, 
         Age = AgeGroup, 
         Measure = Dose, 
         Value = CumulativeNumberVaccinated) %>% 
  ## MK : I may need to ask Maxi why she filtered out here? these does not seem to be duplicates.
  # quoting Maxi: we used to filter out when for example age group 18 is given; so that we avoid duplicates. 
  # if not, keep and code age group 18+.  
  filter(Age != "40 years and over",
         Age != "18 years and over",
         Age != "12 years and over") %>%
  mutate(Sex = case_when(
    Sex == "Female" ~ "f",
    Sex == "Male" ~ "m",
    Sex == "Total" ~ "b"),
    Age = case_when(
## MK: 05.08.2022: added small age and vaccination5 as published      
      Age == "5 to 11" ~ "5",
      Age == "12 to 15" ~ "12",
    #  Age == "12 years and over" ~ "12",
      Age == "16 to 17" ~ "16",   
      Age == "18 to 29" ~ "18",  
   #   Age == "18 years and over" ~ "18",
      Age == "30 to 39" ~ "30",   
      Age == "40 to 49" ~ "40",   
    #  Age == "40 years and over" ~ "40",
      Age == "50 to 54" ~ "50",            
      Age == "55 to 59" ~ "55",            
      Age == "60 to 64" ~ "60",            
      Age == "65 to 69" ~ "65",   
      Age == "70 to 74" ~ "70",            
      Age == "75 to 79" ~ "75",   
      Age == "80 years and over" ~ "80",   
      Age == "All vaccinations" ~ "TOT",
      Age == "Total" ~ "TOT",
      Age == "" ~ "UNK"),
    Measure = case_when(
      Measure == "Dose 1" ~ "Vaccination1",
      Measure == "Dose 2" ~ "Vaccination2",
      Measure == "Dose 3" ~ "Vaccination3",
      Measure == "Dose 4" ~ "Vaccination4",
      Measure == "Dose 5" ~ "Vaccination5"),
    Date = as.Date(ymd(Date))) %>% 
  arrange(Date, Sex, Measure, Age) %>% 
  group_by(Date, Sex, Measure, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Date = ddmmyyyy(Date),
         AgeInt = case_when(
           Age == "5" ~ 7L,
           Age == "12" ~ 4L,
           Age == "16" ~ 2L,
           Age == "18" ~ 12L,
           Age == "30" ~ 10L,
           Age == "40" ~ 10L,
           Age == "50" ~ 5L,
           Age == "55" ~ 5L,
           Age == "60" ~ 5L,
           Age == "65" ~ 5L,
           Age == "70" ~ 5L,
           Age == "75" ~ 5L,
           Age == "80" ~ 25L,
           Age %in% c("TOT", "UNK") ~ NA_integer_)) %>% 
  mutate(Country = "Scotland",
         Region = "All",
         Metric = "Count",
         Code = paste0("GB-SCT")) %>% 
  sort_input_data()


write_rds(vacc2, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc2)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(vacc, data_source)


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
