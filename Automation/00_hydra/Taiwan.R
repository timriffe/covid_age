## Taiwan EPI-DATA (CASES ONLY)
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Taiwan" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## Cases data source: https://data.cdc.gov.tw/en/dataset/aagstable-weekly-19cov

## format of the data: ## ====
## New weekly data per county
## so for processing:
## First: need to sum the cases by Date/ WEEK (summarize)
## Second: need to complete the 0-weeks data
## then: sum again the cases by Date (summarize)
## Last: cumsum Cases (mutate)

cases_raw <- read_csv("https://od.cdc.gov.tw/eic/Weekly_Age_County_Gender_19CoV.csv")

casescol_names <- c("Disease", "Year_Onset", "Week_Onset", "County_living", 
                  "Town_living", "Sex", 
                  "Imported", "Age_Group", "Number_of_confirmed_cases")


names(cases_raw) <- casescol_names

processed_cases <- cases_raw %>% 
  dplyr::select(Year_Onset, Week_Onset,
                Sex, Age = Age_Group, 
                Value = Number_of_confirmed_cases) %>% 
  dplyr::mutate(Week_Onset = str_pad(Week_Onset, 2, "left", 0),
                YearWeek = paste0(Year_Onset,"-W" , Week_Onset, "-5"),
                Date = ISOweek::ISOweek2date(YearWeek),
                Sex = case_when(Sex == "F" ~ "f",
                                Sex == "M" ~ "m",
                                TRUE ~ "UNK"),
                Age = case_when(Age %in% c("0", "1", 
                                           "2", "3", 
                                           "4") ~ "0",
                                Age == "5-9" ~ "5",
                                Age == "10-14" ~ "10",
                                Age == "15-19" ~ "15",
                                Age == "20-24" ~ "20",
                                Age == "25-29" ~ "25",
                                Age == "30-34" ~ "30",
                                Age == "35-39" ~ "35",
                                Age == "40-44" ~ "40",
                                Age == "45-49" ~ "45",
                                Age == "50-54" ~ "50",
                                Age == "55-59" ~ "55",
                                Age == "60-64" ~ "60",
                                Age == "65-69" ~ "65",
                                Age == "70+" ~ "70")) %>% 
  dplyr::group_by(Date, Age, Sex) %>% 
  dplyr::summarise(Value = sum(Value), .groups = "drop") %>% 
  ## complete the 0-weeks data
  tidyr::complete(Age, Sex, Date = seq(min(.$Date), 
                                       max(.$Date), by = "7 days"), 
                  fill = list(Value = 0)) %>% 
  dplyr::group_by(Date, Age, Sex) %>% 
  dplyr::summarise(Value = sum(Value)) %>% 
  dplyr::mutate(AgeInt = case_when(Age == "70" ~ 35L,
                                   TRUE ~ 5L)) %>% 
  dplyr::arrange(Date) %>% 
  dplyr::group_by(Sex, Age) %>% 
  dplyr::mutate(Value = cumsum(Value)) %>% 
  dplyr::ungroup() %>% 
  dplyr::select(Date, Age, AgeInt, Sex, Value)


## Since we have data on Tests in inputDB till 05/2021, though not by age / by sex, 
## So I will output cases data as .rds and deprecate the GoogleSheet file for our records


## Deaths data source: https://data.cdc.gov.tw/en/dataset/death-date-statistics-cases-19cov


deaths_raw <- read_csv("https://od.cdc.gov.tw/eic/open_data_death_date_statistics_19CoV_2.csv")

deathscol_names <- c("Disease", "DeathDate", "County", "township", 
                    "gender", "Immigrant", "Age_Group", "number_of_deaths")


names(deaths_raw) <- deathscol_names

processed_deaths <- deaths_raw %>% 
  dplyr::select(Date = DeathDate,
                Sex = gender, 
                Age = Age_Group, 
                Value = number_of_deaths) %>% 
  dplyr::mutate(Date = ymd(Date),
                Sex = case_when(Sex == "F" ~ "f",
                                Sex == "M" ~ "m",
                                TRUE ~ "UNK"),
                Age = case_when(Age == "0~4" ~ "0",
                                Age == "5~9" ~ "5",
                                Age == "10~14" ~ "10",
                                Age == "15~19" ~ "15",
                                Age == "20~24" ~ "20",
                                Age == "25~29" ~ "25",
                                Age == "30~34" ~ "30",
                                Age == "35~39" ~ "35",
                                Age == "40~44" ~ "40",
                                Age == "45~49" ~ "45",
                                Age == "50~54" ~ "50",
                                Age == "55~59" ~ "55",
                                Age == "60~64" ~ "60",
                                Age == "65~69" ~ "65",
                                Age == "70+" ~ "70")) %>% 
  dplyr::group_by(Date, Age, Sex) %>% 
  dplyr::summarise(Value = sum(Value), .groups = "drop") %>% 
  ## complete the 0-Dates data
  tidyr::complete(Age, Sex, Date = seq(min(.$Date), 
                                       max(.$Date), by = "1 days"), 
                  fill = list(Value = 0)) %>% 
  dplyr::group_by(Date, Age, Sex) %>% 
  dplyr::summarise(Value = sum(Value)) %>% 
  dplyr::mutate(AgeInt = case_when(Age == "70" ~ 35L,
                                   TRUE ~ 5L)) %>% 
  dplyr::arrange(Date) %>% 
  dplyr::group_by(Sex, Age) %>% 
  dplyr::mutate(Value = cumsum(Value)) %>% 
  dplyr::ungroup() %>% 
  dplyr::select(Date, Age, AgeInt, Sex, Value)




# MERGE datasets 

processed_data <- bind_rows("Cases" = processed_cases, 
                            "Deaths" = processed_deaths,
                            .id = "Measure") 


## Output data as .rds file

out <- processed_data %>% 
  dplyr::mutate(
    Metric = "Count", # add type of metric: Fraction, Count, etc
    Date = ddmmyyyy(Date),
    Code = paste0("TW"), # add 2-ISO country code 
    Country = "Taiwan", # add country name
    Region = "All",
    Age = as.character(Age)) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, 
                Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 


#zip input data file 

cases_source <- paste0(dir_n, "Data_sources/", ctr, "/Cases_", today(), ".csv")

deaths_source <- paste0(dir_n, "Data_sources/", ctr, "/Deaths_", today(), ".csv")

write.csv(cases_raw, cases_source)
write.csv(deaths_raw, deaths_source)

data_source_zip <-  c(cases_source, deaths_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source_zip, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(cases_source, deaths_source)

#END
