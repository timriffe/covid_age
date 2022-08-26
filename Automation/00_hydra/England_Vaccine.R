##england vaccines

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr <- "England_Vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

vacc <- read.csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=vaccinationsAgeDemographics&format=csv")
vacc <- vacc %>% 
  select(Date = date, Age = age, 
         Vaccination1 = cumPeopleVaccinatedFirstDoseByVaccinationDate, 
         Vaccination2 = cumPeopleVaccinatedCompleteByVaccinationDate,
         Vaccination3 = cumPeopleVaccinatedThirdInjectionByVaccinationDate)
vacc_out <- melt(vacc, id = c("Date", "Age"))
names(vacc_out)[3] <- "Measure"
names(vacc_out)[4] <- "Value"
vacc_out <- vacc_out %>% 
  filter(Age != "75+") %>% 
  mutate(Age = case_when(
    Age == "05_11" ~ "5",
    Age == "12_15" ~ "12",
    Age == "16_17" ~ "16",
    Age == "18_24" ~ "18",
    Age == "25_29" ~ "25",
    Age == "30_34" ~ "30",
    Age == "35_39" ~ "35",
    Age == "40_44" ~ "40",
    Age == "45_49" ~ "45",
    Age == "50_54" ~ "50",
    Age == "55_59" ~ "55",
    Age == "60_64" ~ "60",
    Age == "65_69" ~ "65",
    Age == "70_74" ~ "70",
    Age == "75_79" ~ "75",
    Age == "80_84" ~ "80",
    Age == "85_89" ~ "85",
    Age == "90+" ~ "90"),
    AgeInt = case_when(
      Age == "5" ~ 7L,
      Age == "12" ~ 4L,
      Age == "16" ~ 2L,
      Age == "18" ~ 7L,
      Age == "90" ~ 15L,
      TRUE ~ 5L
    ),
    Country = "England",
    Metric = "Count",
    Region = "All",
    Sex = "b",
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),
                 sprintf("%02d",month(Date)),
                 year(Date),
                 sep="."),
    Code = paste0("GB-ENG")) %>% 
  sort_input_data()

##work on getting regional data
#https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=vaccinationsAgeDemographics&format=csv
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# uploading database to Google Drive and N
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))

log_update(pp = "England_Vaccine", N = nrow(vacc_out))

data_source <- paste0(dir_n, 
                      "Data_sources/", 
                      ctr,
                      "/", 
                      ctr,
                      "_england_vaccine_",
                      today(), 
                      ".csv")

write_csv(vacc_out, data_source)

