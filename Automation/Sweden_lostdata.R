

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "Sweden"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/Data_sources/Sweden/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## =====================================================


## Date: 04.07.2022
## By: Manal
## Problem: Sweden download data each day, but the data are not appended to inputDB since 13.01.2022

## Investigating the data a bit, I found there are multiple gaps though file names say that data are downloaded each day

## to check on this whole country data: 

## read in the final .rds file 

Sweden <- readRDS("N:/COVerAGE-DB/Automation/Hydra/Sweden.rds")

## some check ups on this dataset

Sweden %>% 
  mutate(Date = lubridate::dmy(Date)) %>% 
  ggplot(aes(x = Date, y = Value)) + 
  geom_point() + 
  facet_wrap(facets = "Measure")


Sweden <- Sweden %>% 
  mutate(Date = as.Date(Date, format = "%d.%m.%Y"))

Sweden %>% 
  arrange(desc(Date)) ## last data date in .rds file is 13-01-2022 :O


## ======================================

## Assumption is that if there is no epi-data for a specific date, 
## there is no vaccination data as well (starting 2021),
## however, better to separate this step, just in case. 


## 1. Epi-data 

## load the xlsx files after unzipping and do some checks... 

epi.list <-list.files(path= paste0(dir_n, "Epi-data/"), 
                       pattern = ".xlsx",
                       full.names = TRUE)


epi.list <- setNames(epi.list, epi.list) # only needed when you need an id-column with the file-names


## 1. this is to get the maximum date for each file "from the first sheet- default read_excel"

sourcedata_epi <- map_dfr(epi.list, read_excel, .id = "file_name")

## 2. check if the file name date is longer than one day difference with maximum date, if so, consider it duplicate

## condition in 2. is not necessarily valid, we have May 2021 data but the difference is so high that it is considered duplicates!

source_lastdate <- sourcedata_epi %>% 
  select(file_name, date = 2) %>% 
  mutate(date = lubridate::ymd(date)) %>% 
  group_by(file_name) %>% 
  summarise(max_date = max(date)) # %>% 
  # mutate(file_name = str_replace_all(file_name, "N:/COVerAGE-DB/Automation/Hydra/Data_sources/Sweden/2021/",
  #                             ""),
  #        file_date = lubridate::ymd(stringr::str_extract_all(file_name, '\\d+')),
  #        how_long = file_date - max_date,
  #        duplicate = if_else(how_long == 1, "No", "Yes")) 

# df_lastdate %>% 
#   filter(duplicate == "No") %>% 
#   View()



## so the better is to check the opposite way:

## 3. check whether the max_date is included in the .rds file or not. 


unique_dates <- Sweden %>% 
  filter(Measure %in% c("Cases", "Deaths")) %>% 
  distinct(Date)



to_retrieve <- source_lastdate %>% 
  anti_join(unique_dates, by = c("max_date" = "Date")) %>% 
  distinct(max_date, .keep_all = TRUE) 


epi_files <- to_retrieve %>% 
  dplyr::pull(file_name)

### ======================

## function to go over the missing data files and append first separately from the main dataset ##

# create empty df to add rows to
lost_epidates <- data.frame()

epi_gaps <- function(file_path){
  
  date <- read_excel(file_path,
                     sheet = 1) %>% 
    dplyr::pull(Statistikdatum) %>% 
    max() %>% 
    ymd()
  
  db_sex <- read_excel(file_path,
           sheet = 5) %>% 
  dplyr::rename(
    Sex = starts_with("K"),
    Cases = Totalt_antal_fall,
    Deaths = Totalt_antal_avlidna
  ) %>% 
    dplyr::mutate(
    Sex = case_when(Sex == "Man" ~ "m",
                    Sex == "Kvinna" ~ "f",
                    Sex == "Uppgift saknas" ~ "UNK"),
    Age = "TOT"
  ) %>% 
  dplyr::select(Sex, Age, Cases, Deaths)



  db_age <- read_excel(file_path,
                     sheet = 6) %>%
  dplyr::rename(
    Cases = Totalt_antal_fall,
    Deaths = Totalt_antal_avlidna
    , Age = ends_with("ldersgrupp")
  ) %>% 
  dplyr::mutate(
    Age = str_sub(Age, 7, 8),
    Age = case_when(Age == "0_" ~ "0",
                    Age == "t " ~ "UNK",
                    TRUE ~ Age),
    Sex = "b"
  ) %>% 
  dplyr::select(Sex, Age, Cases, Deaths)


  out_cases <- bind_rows(db_sex, db_age) %>% 
  gather(Cases, Deaths, key = Measure, value = Value) %>% 
  mutate(Country = "Sweden",
         Region = "All",
         Code = paste0("SE"),
         Date = date,
         AgeInt = case_when(
           Age == "TOT" | Age == "UNK" ~ NA_integer_
           , Age == "90" ~ 15L
           , TRUE ~ 10L
         ), Metric = "Count"
  ) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

  .GlobalEnv$out_cases <- out_cases

}


for (i in epi_files) {
  print(paste("Adding lost epi-data for:", i))
  epi_gaps(file_path = i)
  lost_epidates <- rbind(lost_epidates, out_cases)
}


## Append to main dataset (.rds file) ## ==========================


Sweden <- lost_epidates %>% 
  bind_rows(Sweden) #%>% 
 # arrange(desc(Date))



## =====================================

## 2. Vax-data 

## load the xlsx files after unzipping and do some checks... 

vax.list <-list.files(path= paste0(dir_n, "Vaccinations/"), 
                      pattern = ".xlsx",
                      full.names = TRUE)


vax.list <- setNames(vax.list, vax.list) # only needed when you need an id-column with the file-names

## read the excel sheet that has the date, to extract the date of the data:
## function to do so

extract_date <- function(file_path){
  date_f_vac_temp <- excel_sheets("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Sweden/Vaccinations/vaccination_2022-07-04.xlsx")
  date_f_vac_temp <- date_f_vac_temp[grepl("[0-9]{4}$", date_f_vac_temp)]
  date_f_vac_temp <- trimws(gsub("FOHM", "", date_f_vac_temp))
}



vax_Sourcedates <- map_dfr(vax.list, extract_date) %>% 
  pivot_longer(cols = everything(),
               names_to = "file_name",
               values_to = "date")




vax_lastdate <- vax_Sourcedates %>% 
  mutate(date = str_replace_all(date, "MAJ", "May"),
         date = str_replace_all(date, "OKT", "Oct"),
         date = str_replace_all(date, "211028", "28 Oct 2021"),
         date = parse_date_time(date,
                                orders = "d m y")) 



unique_dates_vax <- Sweden %>% 
  filter(!Measure %in% c("Cases", "Deaths")) %>% 
  distinct(Date)



to_retrieve_vax <- vax_lastdate %>% 
  anti_join(unique_dates_vax, by = c("date" = "Date")) %>% 
  distinct(date, .keep_all = TRUE) 

vax_files <- to_retrieve_vax %>% 
  dplyr::pull(file_name)

### ======================

## functions to go over the missing data files and append first separately from the main dataset ##

## After reviewing the sheets manually:
## from 02-02-2021, sex was in sheet 4, age in sheet 3

before_25Mar <- to_retrieve_vax %>% 
  filter(date < "2022-03-24") %>% 
  dplyr::pull(file_name)

## from 25.03.2022, sex was in sheet 7, age in sheet 4, 5, 6 depending on the # of doses

After_25Mar <- to_retrieve_vax %>% 
  filter(date > "2022-03-24", date < "2022-03-30") %>% 
  dplyr::pull(file_name)

## from 01.04.2022, sex was in sheet 8, age in sheet 5,6,7 depending on the # of doses

After_Apr <- to_retrieve_vax %>% 
  filter(date > "2022-03-30", date < "2022-06-23") %>% 
  dplyr::pull(file_name)

## from 24.06.2022, sex was in sheet 7, age in sheet 5,6 depending on the # of doses

After_lateJune <- to_retrieve_vax %>% 
  filter(date > "2022-06-23") %>% 
  dplyr::pull(file_name)


vax_sex_data <- data.frame()

#file_path = "N:/COVerAGE-DB/Automation/Hydra/Data_sources/Sweden/Vaccinations/vaccination_2021-02-02.xlsx"

fill_dates_sex <- function(file_path, sex_sheet) {
  
  date <- to_retrieve_vax %>% 
    dplyr::filter(stringr::str_detect(file_name, pattern = file_path)) %>% 
    dplyr::pull(date)
  
  
  db_sex <- read_excel(file_path,
                       sheet = sex_sheet) %>% 
    select(
      Sex = starts_with("K")
      , Value = contains("antal")
      # Changed on 20210423 by Diego after codes changed
       , Measure = Dosnummer
      #, Measure = ends_with("status")
    ) %>%
    # filter(!grepl("^t", Sex, ignore.case = T)) %>%
    mutate(
      Sex = case_when(
        grepl("^m", Sex, ignore.case = T) ~ "m",
        grepl("^k", Sex, ignore.case = T) ~ "f"
        # grepl("^t", Sex, ignore.case = T) ~ "UNK"
      )
      , Measure = case_when(
        # Changed on 20210423 by Diego after codes changed
      #  grepl("Minst 1 dos", Measure, ignore.case = T) ~ "Vaccination1"
      #  , grepl("Minst 2 doser", Measure, ignore.case = T) ~ "Vaccination2"
         grepl("1", Measure, ignore.case = T) ~ "Vaccination1"
         , grepl("2", Measure, ignore.case = T) ~ "Vaccination2"
      )
      , Age = "TOT"
      , AgeInt = ""
      # Add empty row for UNK
      , Sex = ifelse(is.na(Sex), "UNK", Sex)
      , AgeInt = ifelse(Sex == "UNK", "", AgeInt)
      , Value = ifelse(Sex == "UNK", 0, Value)
      , Date = date
    ) %>%
    select(Sex, Date, Age, AgeInt, Measure, Value) %>%
    arrange(Sex)
  
  .GlobalEnv$db_sex <- db_sex
}


for (file in before_25Mar) {
  print(paste("Adding lost Vax sex for:", file))
  fill_dates_sex(file_path = file, sex_sheet = 4)
  vax_sex_data <- rbind(vax_sex_data, db_sex)
  
}






















# create empty df to add rows to
lost_vaxdates <- data.frame()

vax_gaps <- function(file_path){
  
  db_age <- read_excel(file_path,
                       sheet = age_sheet) %>%
    filter(grepl("| Sverige |", Region)) %>% 
    select(
      Value = contains("antal")
      # , Measure = Dosnummer
      , Measure = ends_with("status")
      , Age = ends_with("ldersgrupp")
    ) %>% 
    # filter(!grepl("^Total", Age)) %>% 
    mutate(
      Measure = case_when(
        # grepl("1", Measure, ignore.case = T) ~ "Vaccination1"
        # , grepl("2", Measure, ignore.case = T) ~ "Vaccination2"
        grepl("1 dos", Measure, ignore.case = T) ~ "Vaccination1"
        , grepl("2 doser", Measure, ignore.case = T) ~ "Vaccination2"
        , grepl("Minst 3 doser", Measure, ignore.case = T) ~ "Vaccination3"
      )
      , Age_low = as.numeric(str_extract(Age, "^[0-9]{2}"))
      , Age_high = as.numeric(str_extract(Age, "[0-9]{2}$"))
      , Age = as.character(Age_low)
      , AgeInt = as.character(ifelse(!is.na(Age_high), Age_high-Age_low+1, 15))
      , Sex = "b"
      # Add empty row for UNK
      , Age = ifelse(is.na(Age), "UNK", Age)
      , AgeInt = ifelse(Age == "UNK", "", AgeInt)
      , Value = ifelse(Age == "UNK", 0, Value)
    ) %>%  
    select(Sex, Age, AgeInt, Measure, Value)
  
  
  small_ages <- vac_a2 %>% 
    filter(Age == "12") %>% 
    mutate(Age = "0",
           AgeInt = 12L,
           Value = 0)
  vac_a2 <- rbind(vac_a2, small_ages)
  
  
  out_cases <- bind_rows(db_sex, db_age) %>% 
    gather(Cases, Deaths, key = Measure, value = Value) %>% 
    mutate(Country = "Sweden",
           Region = "All",
           Code = paste0("SE"),
           Date = date,
           AgeInt = case_when(
             Age == "TOT" | Age == "UNK" ~ NA_integer_
             , Age == "90" ~ 15L
             , TRUE ~ 10L
           ), Metric = "Count"
    ) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  .GlobalEnv$out_cases <- out_cases
  
}


for (i in epi_files) {
  print(paste("Adding lost epi-data for:", i))
  epi_gaps(file_path = i)
  lost_vaxdates <- rbind(lost_vaxdates, out_cases)
}


## Append to main dataset (.rds file) ## ==========================


Sweden <- lost_epidates %>% 
  bind_rows(Sweden) #%>% 
# arrange(desc(Date))




