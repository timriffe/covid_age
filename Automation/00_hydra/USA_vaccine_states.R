<<<<<<< HEAD
source(here::here("Automation/00_Functions_automation.R"))
#install.packages("tidyverse")
#install.packages("reshape2")
library(tidyverse)
library(reshape2)

vacc <- read.csv("https://data.cdc.gov/api/views/unsk-b7fc/rows.csv?accessType=DOWNLOAD")
vacc2 <- vacc %>% 
  select(Date, Location, Administered_Dose1_Recip, Administered_Dose1_Recip_5Plus, Administered_Dose1_Recip_12Plus, Administered_Dose1_Recip_18Plus,
         Administered_Dose1_Recip_65Plus, Series_Complete_Yes ,Series_Complete_5Plus, Series_Complete_12Plus, Series_Complete_18Plus, Series_Complete_65Plus,
         Additional_Doses, Additional_Doses_12Plus, Additional_Doses_18Plus, Additional_Doses_50Plus, Additional_Doses_65Plus,
         Second_Booster_50Plus, Second_Booster_65Plus, Second_Booster)
vacc3 <- vacc2 %>% 
  mutate(Vaccination1_TOT = Administered_Dose1_Recip,
         Vaccination1_5 = Administered_Dose1_Recip_5Plus - Administered_Dose1_Recip_12Plus,
         Vaccination1_12 = Administered_Dose1_Recip_12Plus - Administered_Dose1_Recip_18Plus,
         Vaccination1_18 = Administered_Dose1_Recip_18Plus - Administered_Dose1_Recip_65Plus,
         Vaccination1_65 = Administered_Dose1_Recip_65Plus,
         Vaccination2_TOT = Series_Complete_Yes,
         Vaccination2_5 = Series_Complete_5Plus - Series_Complete_12Plus,
         Vaccination2_12 = Series_Complete_12Plus - Series_Complete_18Plus,
         Vaccination2_18 = Series_Complete_18Plus - Series_Complete_65Plus,
         Vaccination2_65 = Series_Complete_65Plus,
         Vaccination3_TOT = Additional_Doses,
         Vaccination3_12 = Additional_Doses_12Plus - Additional_Doses_18Plus,
         Vaccination3_18 = Additional_Doses_18Plus - Additional_Doses_50Plus,
         Vaccination3_50 = Additional_Doses_50Plus - Additional_Doses_65Plus,
         Vaccination3_65 = Additional_Doses_65Plus,
         Vaccination4_50 = Second_Booster_50Plus - Second_Booster_65Plus,
         Vaccination4_65 = Second_Booster_65Plus) %>% 
  select(-c(Administered_Dose1_Recip, Administered_Dose1_Recip_5Plus, Administered_Dose1_Recip_12Plus, Administered_Dose1_Recip_18Plus,
            Administered_Dose1_Recip_65Plus, Series_Complete_Yes ,Series_Complete_5Plus, Series_Complete_12Plus, Series_Complete_18Plus, Series_Complete_65Plus,
            Additional_Doses, Additional_Doses_12Plus, Additional_Doses_18Plus, Additional_Doses_50Plus, Additional_Doses_65Plus,
            Second_Booster_50Plus, Second_Booster_65Plus, Second_Booster)) %>% 
  mutate(Vaccination1_TOT = as.numeric(Vaccination1_TOT),
         Vaccination1_5 = as.numeric(Vaccination1_5),
         Vaccination1_12 = as.numeric(Vaccination1_12),
         Vaccination1_18 = as.numeric(Vaccination1_18),
         Vaccination1_65 = as.numeric(Vaccination1_65),
         Vaccination2_5 = as.numeric(Vaccination2_5),
         Vaccination2_12 = as.numeric(Vaccination2_12),
         Vaccination2_18 = as.numeric(Vaccination2_18),
         Vaccination2_65 = as.numeric(Vaccination2_65),
         Vaccination2_TOT = as.numeric(Vaccination2_TOT),
         Vaccination3_TOT = as.numeric(Vaccination3_TOT),
         Vaccination3_12 = as.numeric(Vaccination3_12),
         Vaccination3_18 = as.numeric(Vaccination3_18),
         Vaccination3_50 = as.numeric(Vaccination3_50),
         Vaccination3_65 = as.numeric(Vaccination3_65),
         Vaccination4_50 = as.numeric(Vaccination4_50),
         Vaccination4_65 = as.numeric(Vaccination4_65)) %>% 
  mutate(Vaccination1_5 = case_when(
    Vaccination1_5 <= 0 ~ 0,
    TRUE ~ Vaccination1_5
  ),
  Vaccination1_12 = case_when(
    Vaccination1_12 <= 0 ~ 0,
    TRUE ~ Vaccination1_12
  ),
  Vaccination2_12 = case_when(
    Vaccination2_12 <= 0 ~ 0,
    TRUE ~ Vaccination2_12),
  Vaccination2_5 = case_when(
    Vaccination2_5 <= 0 ~ 0,
    TRUE ~ Vaccination2_5)
  ) %>% 
  melt(id.vars=c("Date", "Location")) %>% 
  separate(variable, c("Measure", "Age"), "_")

vacc4 <- vacc3 %>% 
  mutate(Date = as.Date(Date, "%m/%d/%Y"))

vacc3_vac1 <- vacc4 %>% 
  filter(Measure == "Vaccination1",
         Location == "US")

ggplot(vacc3_vac1, aes(x = Date, y = value, group = Age, color=Age)) +
  geom_line() 

=======
#USA CDC vaccination data by Age and Sex, National and Jurisdictional 
# Data are cumulative and since 13.Dec.2020
library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
library(xlsx)
# assigning Drive credentials in the case the script is verified manually

if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# info country and N drive address

ctr          <- "USA_Vaccine_states" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


#make folder on hydra
if (!dir.exists(paste0(dir_n, "Data_sources/", ctr))){
  dir.create(paste0(dir_n, "Data_sources/", ctr))
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## read in Vaccination data ## =================

## Source Web: https://data.cdc.gov/Vaccinations/COVID-19-Vaccination-Age-and-Sex-Trends-in-the-Uni/5i5k-6cmh

us_vacc <- data.table::fread("https://data.cdc.gov/api/views/5i5k-6cmh/rows.csv?accessType=DOWNLOAD&bom=true&format=true")


## processing the data ================


vacc_processed <- us_vacc %>% 
  dplyr::mutate(Date = lubridate::mdy_hms(Date)) %>% 
  dplyr::select(Date, Location,
                Demographic_Category, 
                Administered_Dose1, Series_Complete_Yes,
                Booster_Doses) %>% 
  dplyr::filter(str_detect(Demographic_Category, pattern = c("Female_Ages_", "Male_Ages_"))) %>% 
  dplyr::mutate(
    Demographic_Category = str_remove_all(Demographic_Category, pattern = "Ages_"),
    Demographic_Category = str_remove_all(Demographic_Category, pattern = "_yrs"),
    Administered_Dose1 = str_replace_all(Administered_Dose1, ",", ""),
    Series_Complete_Yes = str_replace_all(Series_Complete_Yes, ",", ""),
    Booster_Doses = str_replace_all(Booster_Doses, ",", ""),
    Administered_Dose1 = as.integer(Administered_Dose1),
    Series_Complete_Yes = as.integer(Series_Complete_Yes),
    Booster_Doses = as.integer(Booster_Doses)
  ) %>% 
  tidyr::separate(Demographic_Category, sep = "_", 
                  into = c("Sex", "Age")) %>% 
  dplyr::mutate(
    Sex = case_when(Sex == "Male" ~ "m",
                    Sex == "Female" ~ "f",
                    TRUE ~ Sex),
    AgeInt = case_when(
      Age == "<5yrs" ~ 5L,
      Age == "5-11"  ~ 7L,
      Age == "12-17" ~ 6L,
      Age == "18-24" ~ 7L,
      Age == "25-39" ~ 15L,
      Age == "25-49" ~ 25L,
      Age == "40-49" ~ 10L,
      Age == "50-64" ~ 15L,
      Age == "65-74" ~ 10L,
      Age == "65+" ~ 40L,
      Age == "75+" ~ 30L
    ),
    Age = case_when(
      #  Age == "unknown" ~ "UNK",
      Age == "<5yrs" ~ "0",
      Age == "5-11" ~ "5",
      Age == "12-17" ~ "12",
      Age == "18-24" ~ "18",
      Age == "25-39" ~ "25",
      Age == "25-49" ~ "25",
      Age == "40-49" ~ "40",
      Age == "50-64" ~ "50",
      Age == "65-74" ~ "65",
      Age == "65+" ~ "65",
      Age == "75+" ~ "75"
    )
  ) %>% 
  pivot_longer(cols = -c("Date", "Location", "Age", "Sex", "AgeInt"),
               names_to = "Measure",
               values_to = "Value") %>% 
  mutate(Measure = case_when(
    Measure == "Administered_Dose1" ~ "Vaccination1",
    Measure == "Series_Complete_Yes" ~ "Vaccination2",
    Measure == "Booster_Doses" ~ "Vaccination3"
  ),
  Region= case_when( 
    Location == "AK" ~ "Alaska",
    Location == "AL" ~ "Alabama",
    Location == "AR" ~ "Arkansas",
    Location == "AS" ~ "American Samoa",
    Location == "AZ" ~ "Arizona",
    Location == "BP2"~ "Bureau of Prisons",
    Location == "CA" ~ "California",
    Location == "CA."~ "California",
    Location == "CO" ~ "Colorado",
    Location == "CT" ~ "Connecticut",
    Location == "DC" ~ "District of Columbia",
    Location == "DD2" ~ "Dept of Defense",
    Location == "DE" ~ "Delaware",
    Location == "FL" ~ "Florida",
    Location == "FM" ~ "Federated States of Micronesia",
    Location == "GA" ~ "Georgia",
    Location == "GU" ~ "Guam",
    Location == "HI" ~ "Hawaii",
    Location == "IA" ~ "Iowa",
    Location == "ID" ~ "Idaho",
    Location == "IH2" ~ "Indian Health Services",
    Location == "IL" ~ "Illinois",
    Location == "IN" ~ "Indiana",
    Location == "KS" ~ "Kansas",
    Location == "KY" ~ "Kentucky",
    Location == "LA" ~ "Louisiana",
    Location == "MA" ~ "Massachusetts",
    Location == "MD" ~ "Maryland",
    Location == "ME" ~ "Maine",
    Location == "MH" ~ "Marshall Islands",
    Location == "MI" ~ "Michigan",
    Location == "MN" ~ "Minnesota",
    Location == "MO" ~ "Missouri",
    Location == "MP" ~ "Northern Mariana Islands",
    Location == "MS" ~ "Mississippi",
    Location == "MT" ~ "Montana",
    Location == "NC" ~ "North Carolina",
    Location == "ND" ~ "North Dakota",
    Location == "NE" ~ "Nebraska",
    Location == "NH" ~ "New Hampshire",
    Location == "NJ" ~ "New Jersey",
    Location == "NM" ~ "New Mexico",
    Location == "NV" ~ "Nevada",
    Location == "NY" ~ "New York State",
    Location == "OH" ~ "Ohio",
    Location == "OK" ~ "Oklahoma",
    Location == "OR" ~ "Oregon",
    Location == "PA" ~ "Pennsylvania",
    Location == "PR" ~ "Puerto Rico",
    Location == "PW" ~ "Palau",
    Location == "RI" ~ "Rhode Island",
    Location == "SC" ~ "South Carolina",
    Location == "SD" ~ "South Dakota",
    Location == "TN" ~ "Tennessee",
    Location == "TX" ~ "Texas",
    Location == "US" ~ "United States",
    Location == "UT" ~ "Utah",
    Location == "VA" ~ "Virginia",
    Location == "VI" ~ "Virgin Islands",
    Location == "VT" ~ "Vermont",
    Location == "WA" ~ "Washington",
    Location == "WI" ~ "Wisconsin",
    Location == "WV" ~ "West Virginia",
    Location == "WY" ~ "Wyoming",
    Location == "NA" ~ "Unknown")) 



## Output Data

vacc_out <- vacc_processed %>% 
  mutate(Metric = "Count",
         Country = "USA",
         Date = as_date(Date),
         #Date = mdy(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US-", Location))%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#save output data

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))

# Update HYDRA 

log_update(pp = ctr, N = nrow(vacc_out))


# now archive new data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_states_",today(), ".csv")

write_csv(vacc_out, data_source)



zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "vaccine_states_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

# END. 
>>>>>>> 22a5bd4bcc150969e8de4249ad9722c990763aae
