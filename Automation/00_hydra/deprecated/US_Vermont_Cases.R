## USA- Vermont CASES DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "US_Vermont_Cases" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



# Source website: https://geodata.vermont.gov/datasets/VCGI::vt-covid-19-weekly-cases-by-race-and-age/about
## as per the codebook in the website:
# FIELD DESCRIPTIONS-----
# w_end_date: Date representing end of weekly period
# w_a_0-9 Total: Total cases this week in age group 0-9 years old
# w_a_10-19: Total cases this week in age group 10-19 years old
# w_a_20-29: Total cases this week in age group 20-29 years old
# w_a_30-39: Total cases this week in age group 30-39 years old
# w_a_40-49: Total cases this week in age group 40-49 years old
# w_a_50-59: Total cases this week in age group 50-59 years old
# w_a_60-69: Total cases this week in age group 60-69 years old
# w_a_70-79: Total cases this week in age group 70-79 years old
# w_a_80plus: Total cases this week in age group 80 plus years old
# w_a_Unknown: Total cases this week, unknown age group

IN <- read.csv("https://docs.google.com/spreadsheets/d/1Ep63rVfEILV442ZN9cIH6hkOOGTCnJ8loyC25AHIgOE/export?format=csv") 

cases <- IN %>% 
  dplyr::select(Date = w_end_date,
                `w_a_0_9`,
                `w_a_10_19`,
                `w_a_20_29`,
                `w_a_30_39`,
                `w_a_40_49`,
                `w_a_50_59`,
                `w_a_60_69`,
                `w_a_70_79`,
                `w_a_80plus`, 
                `w_a_Unknown`) %>% 
  dplyr::mutate(Date = as.Date(Date),
                across(.cols = -c("Date"), ~ cumsum(.x))) %>% 
  tidyr::pivot_longer(cols = -("Date"),
                      names_to = "Age",
                      values_to = "Value") %>% 
  dplyr::mutate(Age = str_remove_all(Age, "w_a_"),
                Age = case_when(Age == "Unknown" ~ "UNK",
                                TRUE ~ Age),
                AgeInt = case_when(Age == "80plus" ~ 25L,
                                   Age == "UNK" ~ NA_integer_,
                                   TRUE ~ 10L),
                Age = case_when(Age == "UNK" ~ "UNK",
                                TRUE ~ str_extract(Age, "\\d+"))) 

out <- cases %>% 
  dplyr::mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex = "b",
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-VT"),
    Country = "USA",
    Region = "Vermont",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#save output data

#write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/WeeklyCases",today(), ".csv")

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

## END ##

