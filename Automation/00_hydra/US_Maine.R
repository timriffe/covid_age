
library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr <- "US_Maine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_ME")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

# read in current 
ME_in <-  read_sheet(ss = ss_i, sheet = "database") %>% 
  #select(-Short) %>% 
  mutate(Code = "US-ME") %>% 
  distinct()

date_max <-
  ME_in %>% 
  dplyr::pull(Date) %>% 
  dmy() %>% 
  max()

## SOURCE WEBSITE <- https://www.maine.gov/dhhs/mecdc/infectious-disease/epi/airborne/coronavirus/data.shtml

#JD 22.02.2021: Changed reporting. Sheets are now separate Excel files

#ME_data <- "https://gateway.maine.gov/dhhs-apps/mecdc_covid/Maine_COVID19_Summary.xlsx"
#ME_age <- rio::import(ME_data, sheet = "cases_by_age")
#ME_sex <- rio::import(ME_data, sheet = "cases_by_sex")

ME_age_url <- "https://gateway.maine.gov/dhhs-apps/mecdc_covid/cases_by_age.csv"
ME_age<- read_csv(ME_age_url)

ME_sex_url <- "https://gateway.maine.gov/dhhs-apps/mecdc_covid/cases_by_sex.csv"
ME_sex <- read_csv(ME_sex_url)

Age <-
  ME_age %>% 
  mutate(Date = as_date(DATA_AS_OF_DT),
         Age = recode(PATIENT_AGE,
                      "<20" = "0",
                      "20s" = "20",
                      "30s" = "30",
                      "40s" = "40",
                      "50s" = "50",
                      "60s" = "60",
                      "70s" = "70",
                      "80+" = "80"),
         Sex = "b",
         AgeInt = case_when(
           Age == "0" ~ 20L,
           Age == "20" ~ 10L,
           Age == "30" ~ 10L,
           Age == "40" ~ 10L,
           Age == "50" ~ 10L,
           Age == "60" ~ 10L,
           Age == "70" ~ 10L,
           Age == "80" ~ 25L
         )
         ) %>% 
  select(Date, Sex, Age, AgeInt, Cases = CASES)


Sex <-
  ME_sex %>% 
  mutate(Date = as_date(DATA_AS_OF_DT),
         Sex = ifelse(PATIENT_CURRENT_SEX == 'Female',"f","m"),
         Age = "TOT",
         AgeInt = NA_integer_) %>% 
  select(Date, Sex, Age, AgeInt, Cases = CASES)

MEout <-
  bind_rows(Age,Sex)  %>% 
  pivot_longer(Cases, names_to = "Measure", values_to = "Value") %>% 
  mutate(Value = as.double(Value))

date_new <- MEout$Date %>% unique()

if (date_new > date_max){
  MEout <-
    MEout %>% 
    mutate(Metric = "Count",
           Country = "USA",
           Region = "Maine",
           Date = paste(sprintf("%02d",day(Date)),    
                        sprintf("%02d",month(Date)),  
                        year(Date),sep="."),
           Code = paste0("US-ME")
           ) %>% 
    select(Country, Region, Code, Date, 
           Sex, Age, AgeInt,
           Metric, Measure, Value)
  
  # send to Drive
  sheet_append(MEout, ss = ss_i, sheet = "database")
  
  log_update("US_Maine", N = nrow(MEout))
  
  # archive on N
  data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/age_",today(), ".csv")
  data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/sex_",today(), ".csv")

  
  write_csv(ME_age, path = data_source_1)
  write_csv(ME_sex, path = data_source_2)

  data_source <- c(data_source_1, data_source_2)
  
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
  
} else {
  # Otherwise, show that the script ran but didn't update.
  log_update("US_Maine", N = 0)
}
