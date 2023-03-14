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

## Function to prepare the output 

prepare_output <- function(df){
  df |> 
    filter(!Age %in% c("75+", "50+")) %>% 
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
      Sex = "b",
      Date = ymd(Date),
      Date = ddmmyyyy(Date))
  
}


#Website <- https://coronavirus.data.gov.uk/details/vaccinations?areaType=nation&areaName=England
#api-page <- https://coronavirus.data.gov.uk/details/download

## National-level England

raw_data_national <- read.csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=vaccinationsAgeDemographics&format=csv")
national_prepared <- raw_data_national %>% 
  select(Date = date, Age = age, 
         Vaccination1 = cumPeopleVaccinatedFirstDoseByVaccinationDate, 
         Vaccination2 = cumPeopleVaccinatedSecondDoseByVaccinationDate,
         Vaccination3 = cumPeopleVaccinatedThirdInjectionByVaccinationDate,
         ## This dose is administered to Aged groups, so NA in the rest of Age groups is valid. 
         Vaccination4 = cumPeopleVaccinatedSpring22ByVaccinationDate,
         ## This dose is administered to Aged groups, so NA in the rest of Age groups is valid. 
         Vaccination5 = cumPeopleVaccinatedAutumn22ByVaccinationDate) |> 
  pivot_longer(cols = -c("Date", "Age"), names_to = "Measure", values_to = "Value")


vacc_out_national <- national_prepared |> 
  prepare_output() |> 
  mutate(Region = "All",
         Code = paste0("GB-ENG")) %>% 
  sort_input_data()


## Regional-level England 

##work on getting regional data
raw_data_regional <- read.csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=vaccinationsAgeDemographics&format=csv")

regional_prepared <- raw_data_regional %>% 
  select(Date = date,
         Age = age, 
         Region = areaName,
         Vaccination1 = cumPeopleVaccinatedFirstDoseByVaccinationDate, 
         Vaccination2 = cumPeopleVaccinatedSecondDoseByVaccinationDate,
         Vaccination3 = cumPeopleVaccinatedThirdInjectionByVaccinationDate,
         ## This dose is administered to Aged groups, so NA in the rest of Age groups is valid. 
         Vaccination4 = cumPeopleVaccinatedSpring22ByVaccinationDate,
         ## This dose is administered to Aged groups, so NA in the rest of Age groups is valid. 
         Vaccination5 = cumPeopleVaccinatedAutumn22ByVaccinationDate,
         ) |> 
  pivot_longer(cols = -c("Date", "Age", "Region"), names_to = "Measure", values_to = "Value")


vacc_out_regional <- regional_prepared |> 
  prepare_output() |> 
  mutate(Code = case_when(Region == "East Midlands" ~ "GB-EEM+",
                          Region == "East of England" ~ "GB-EEOE+",
                          Region == "London" ~ "GB-EL+",
                          Region == "North East" ~ "GB-ENE+",
                          Region == "North West" ~ "GB-ENW+",
                          Region == "South East" ~ "GB-ESE+",
                          Region == "South West" ~ "GB-ESW+",
                          Region == "West Midlands" ~ "GB-EWM+",
                          Region == "Yorkshire and The Humber" ~ "GB-EYATH+")) %>% 
  sort_input_data()


vacc_out <- bind_rows(vacc_out_national, vacc_out_regional)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# uploading database to Google Drive and N
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))

log_update(pp = "England_Vaccine", N = nrow(vacc_out))


## Keep copy of raw data ## 

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/England_national_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/England_regional_",today(), ".csv")

write_csv(raw_data_national, data_source_1)
write_csv(raw_data_regional, data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_Vaxdata_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

#End# 