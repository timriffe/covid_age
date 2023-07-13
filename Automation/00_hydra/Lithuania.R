# Created on: 02.06.2023

## README: Lithuania MOH is publishing the linelist of Epi-data; 

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr <- "Lithuania"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# main source: https://open-data-ls-osp-sdg.hub.arcgis.com/search?collection=Dataset&q=covid

## Definitions: https://open-data-ls-osp-sdg.hub.arcgis.com/datasets/ba35de03e111430f88a86f7d1f351de6_0/about
# municipality_name - the municipality of the person's likely place of residence (60 Lithuanian municipalities), does not necessarily coincide with the municipality declared by the person
# date - the day on which the described events took place, date
# sex - the gender of the person
# age_gr - the age group of the person (in ten-year wide sections) calculated for today
# incidence - that the number of primary or repeated infections with the SARS-CoV-2 virus detected in that group of individuals on the day (that is, the sum of the four further columns) 
# infection_1 - the number of primary infections with the SARS-CoV-2 virus
# infection_2  - the number of secondary infections with the SARS-CoV-2 virus
# infection_3  - tertiary infections number of SARS-CoV-2 viruses
# infection_4  - number of quarterly infections with the SARS-CoV-2 virus
# deaths_all - all deaths in Lithuania according to digital death certificates (<1% of death certificates are paper, they are not available here or in eHealth)
# deaths_cov1 - COVID deaths according to  the first definition  ("from COVID") . This is the narrowest/conservative definition of a COVID death, assuming that all death certificates and causes of death were completed correctly and without errors. Number of deaths with COVID as the main cause of death.
# deaths_cov2 - COVID deaths according to  the second definition; this definition includes the death of the first definition, but is broader, searching the death certificate for keywords related to COVID. Number of deaths with any cause of death listed as COVID-19.
# deaths_cov3 - COVID deaths according to  the third definition  ("with COVID"). This is the broadest/most liberal definition of a COVID death, incorporating the previous two definitions, and is the most consistent with estimates of excess mortality during the pandemic. The number of people who have died from any cause, or who were infected and died from other than external causes of death in a 28-day period.


raw_data <- read_csv("https://opendata.arcgis.com/api/v3/datasets/ba35de03e111430f88a86f7d1f351de6_0/downloads/data?format=csv&spatialRefId=4326")

processed_data <- raw_data |> 
  select(date, Sex = sex, age_gr, Cases = incidence, Deaths = deaths_all) |> 
  mutate(date = as.Date(date, format = "%Y/%m/%d"),
         Sex = case_when(Sex == "Moteris" ~ "f",
                         Sex == "Nenustatyta" ~ "UNK",
                         Sex == "Vyras" ~ "m"),
         age_gr = case_when(age_gr %in% c("100-109", "110-119") ~ "100-120",
                            TRUE ~ age_gr)) |> 
  group_by(date, Sex, age_gr) |> 
  summarise(Cases = sum(Cases),
            Deaths = sum(Deaths)) |> 
  ungroup() |> 
  arrange(date) |> 
  group_by(Sex, age_gr) |> 
  mutate(Cases = cumsum(Cases),
         Deaths = cumsum(Deaths),
         Age = case_when(age_gr == "Nenustatyta" ~ "UNK",
                         TRUE ~ str_remove(age_gr, "-\\d+")),
         AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                            Age == "100" ~ 5L,
                            TRUE ~ 10L),
         Date = ddmmyyyy(date)) |> 
  ungroup() |> 
  pivot_longer(cols = c("Cases", "Deaths"),
               names_to = "Measure",
               values_to = "Value") 


Out <- processed_data |> 
  mutate(Metric = "Count",
         Code = "LT",
         Country = "Lithuania",
         Region = "All") |> 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) |> 
  unique() |> 
  sort_input_data()


#save output data

write_rds(Out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(Out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/Lithuania_Epi",today(), ".csv")

write_csv(raw_data, data_source)


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















