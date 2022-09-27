## India Vax Data- Processing- Monthly & Manually revisiting 
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address
ctr          <- "IndiaVax" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
data_source <- paste0(dir_n, "Data_sources/India/")

## These data I am not sure about; not sure if 'doses administered' are 'Vaccination1' and 'fully vaccinated' are 'Vaccination2'.
## Given the context and the time frame, it seems so, but I could not find definitions. 

vax <- read_csv("http://data.covid19india.org/csv/latest/cowin_vaccine_data_statewise.csv")


## PDFs data ## 

## copy till the writing out to .rds & paste into RStuido cloud 
## you need to zip the PDF files to upload it into the cloud. 

# install.packages("rJava")
# library(rJava) # load and attach 'rJava' now
# install.packages("devtools")
# devtools::install_github("ropensci/tabulizer", args="--no-multiarch")

library(tabulizer)
library(here)
library(lubridate)
library(tidyverse)

list.pdfs <- list.files(
  path = here::here("IndiaPDFs"),
  pattern = ".pdf",
  full.names = TRUE
)

pdfs_df <- data.frame(pdf_path = list.pdfs) %>% 
  mutate(date = str_remove(pdf_path, "/cloud/project/IndiaPDFs/CummulativeCovidVaccinationReport"),
         Date = str_remove(date, ".pdf"),
         Date = dmy(Date))



# ALL table ## ======================

## FUNCTION: Extraction ##

extract_table1 <- function(pdf_path){
  extract_tables(pdf_path, output = "data.frame") %>% .[[1]] %>% 
    janitor::clean_names()
}

## EXAMPLE ##

tab1_data <- pdfs_df %>% 
  filter(str_detect(pdf_path, "Sep")) %>% #tried May, Jun, Jul- okay!, but Aug & Sep have some issues
  {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} 

## FUNCTION: Collection and little cleaning ##

collect_data <- function(tbl, name_month){
  tbl %>% 
    filter(str_detect(pdf_path, name_month)) %>% 
    {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} %>% 
    filter(country == "India") %>% 
    rename('Vaccination1_18' = beneficiaries_vaccinated,
           'Vaccination2_18' = total_doses,
           'Vaccination1_15' = x,
           'Vaccination2_15' = x_1,
           'Vaccination1_12' = x_2,
           'Vaccination2_12' = x_3,
           'Vaccination3_18' = x_4,
           'Vaccination3_60' = x_5,
           'Vaccinations' = x_6)
}

tab1_May <- pdfs_df %>% collect_data("May")
tab1_Jun <- pdfs_df %>% collect_data("Jun")
tab1_Jul <- pdfs_df %>% collect_data("Jul")
tab1_Aug25 <- pdfs_df %>% collect_data("Aug")
tab1_Sep7 <- pdfs_df %>% collect_data("Sep")

## Different wrangling is required for the period > 25.08.2022 - < 07.09.2022 & some sporadic dates 
tab1_aug_sep <- pdfs_df %>% filter(Date > "2022-08-25", Date < "2022-09-07") %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-05-11")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-08-01")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-08-06")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-08-07")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-08-11")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-08-18")) %>% 
  bind_rows(pdfs_df %>% filter(Date == "2022-09-20"))

tab1_AS <- tab1_aug_sep %>% 
  {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} %>% 
  filter(str_detect(x_3, ","),
         x != "India") %>% 
  select(-x) %>% 
  rename('Vaccination1_Vaccination2_18' = x_1,
         'Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12' = beneficiaries_vaccinated,
         'Vaccination3_1859-Vaccination3_60' = x_2,
         'Vaccinations' = x_3) %>% 
  separate('Vaccination1_Vaccination2_18',
           into = c("Vaccination1_18", "Vaccination2_18"),
           sep = " ") %>% 
  separate('Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12',
           into = c("Vaccination1_15", "Vaccination2_15", 
                    "Vaccination1_12", "Vaccination2_12"),
           sep = " ") %>% 
  separate('Vaccination3_1859-Vaccination3_60',
           into = c("Vaccination3_18", "Vaccination3_60"),
           sep = " ") %>% 
  mutate(country = "India")

## BIND all tables 1

tab1_all <- bind_rows(tab1_May,
                      tab1_Jun,
                      tab1_Jul,
                      tab1_Aug25,
                      tab1_Sep7,
                      tab1_AS)


tab1_out <- tab1_all %>% 
  pivot_longer(cols = -c("country", "Date"),
               names_to = c("Measure", "Age"),
               names_sep = "_",
               values_to = "Value") %>% 
  rename(Country = country) %>% 
  mutate(Value = parse_number(Value),
         Region = "All",
         Sex = "b",
         Code = "IN",
         Metric = "Count",
         Age = case_when(Measure == "Vaccinations" ~ "TOT",
                         TRUE ~ Age),
         AgeInt = case_when(Age == "12" ~ 3L,
                            Age == "15" ~ 3L,
                            Age == "18" & Measure == "Vaccination3" ~ 42L,
                            Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
                            Age == "60" ~ 45L,
                            Age == "TOT" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

# REGIONAL TABLE ========================

## FUNCTION: Extraction ##

extract_table2 <- function(pdf_path){
  extract_tables(pdf_path, output = "data.frame") %>% .[[2]] %>% 
    janitor::clean_names()
}


all_pdfs <- list.pdfs %>% 
  set_names() %>% 
  map(~extract_tables(., output = "data.frame"))

regional_pdfs <- all_pdfs %>% 
  map_dfr(~length(.)) %>% 
  pivot_longer(cols = everything(),
               names_to = "File_name",
               values_to = "number_tables") %>% 
  filter(number_tables == 2)  ## only 19 files (so far) that have the second table read by tabulizer

regional_files <- regional_pdfs %>% 
  inner_join(pdfs_df, by = c("File_name" = "pdf_path")) %>% 
  {map2_dfr(.$File_name, .$Date, function(x,y) extract_table2(x) %>% mutate(Date=y))} 

regional_files_processing <- regional_files %>% 
  select(-x) %>% 
  rename(Region = x_1,
         'Vaccination1_Vaccination2_18' = x_2,
         'Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12' = beneficiaries_vaccinated,
         'Vaccination3_1859-Vaccination3_60' = x_3,
         'Vaccinations' = x_4) %>% 
  filter(str_detect(Vaccinations, ",")) %>% 
  mutate(Region = case_when(Region == "" ~ "Dadra & Nagar Haveli",
                            TRUE ~ Region)) %>% 
  separate('Vaccination1_Vaccination2_18',
           into = c("Vaccination1_18", "Vaccination2_18"),
           sep = " ") %>% 
  separate('Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12',
           into = c("Vaccination1_15", "Vaccination2_15", 
                    "Vaccination1_12", "Vaccination2_12"),
           sep = " ") %>% 
  separate('Vaccination3_1859-Vaccination3_60',
           into = c("Vaccination3_18", "Vaccination3_60"),
           sep = " ") %>% 
  pivot_longer(cols = -c(Region, Date),
               names_to = c("Measure", "Age"),
               names_sep = "_",
               values_to = "Value") %>% 
  mutate(Value = parse_number(Value),
         Country = "India",
         Sex = "b",
         Metric = "Count",
         Age = case_when(Measure == "Vaccinations" ~ "TOT",
                         TRUE ~ Age),
         Code = case_when(
           Region == "A & N Islands" ~ "IN-AN",
           Region == "Andhra Pradesh" ~ "IN-AP",
           Region == "Arunachal Pradesh" ~ "IN-AR",
           Region == "Assam" ~ "IN-AS",
           Region == "Bihar" ~ "IN-BR",
           Region == "Chandigarh" ~ "IN-CH",
           Region == "Chhattisgarh" ~ "IN-CT",
           Region == "Delhi" ~ "IN-DL",
           Region == "Daman & Diu" ~ "IN-DD",
           Region == "Dadra & Nagar Haveli" ~ "IN-DN",
           Region == "Goa" ~ "IN-GA",
           Region == "Gujarat" ~ "IN-GJ",
           Region == "Haryana" ~ "IN-HR",
           Region == "Himachal Pradesh" ~ "IN-HP",
           Region == "Jammu & Kashmir" ~ "IN-JK",
           Region == "Jharkhand" ~ "IN-JH",
           Region == "Karnataka" ~ "IN-KA",
           Region == "Kerala" ~ "IN-KL",
           Region == "Ladakh" ~ "IN-LA",
           Region == "Lakshadweep" ~ "IN-LD",
           Region == "Madhya Pradesh" ~ "IN-MP",
           Region == "Maharashtra" ~ "IN-MH",
           Region == "Manipur" ~ "IN-MN",
           Region == "Meghalaya" ~ "IN-ML",
           Region == "Mizoram" ~ "IN-MZ",
           Region == "Nagaland" ~ "IN-NL",
           Region == "Odisha" ~ "IN-OR",
           Region == "Puducherry" ~ "IN-PY",
           Region == "Punjab" ~ "IN-PB",
           Region == "Rajasthan" ~ "IN-RJ",
           Region == "Sikkim" ~ "IN-SK",
           Region == "Tamil Nadu" ~ "IN-TN",
           Region == "Telangana" ~ "IN-TG",
           Region == "Tripura" ~ "IN-TR",
           Region == "Uttar Pradesh" ~ "IN-UP",
           Region == "Uttarakhand" ~ "IN-UT",
           Region == "West Bengal" ~ "IN-WB",
           TRUE ~ NA_character_
         ),
         AgeInt = case_when(Age == "12" ~ 3L,
                            Age == "15" ~ 3L,
                            Age == "18" & Measure == "Vaccination3" ~ 42L,
                            Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
                            Age == "60" ~ 45L,
                            Age == "TOT" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

pdf_tables_out <- bind_rows(tab1_out, regional_files_processing) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."))


write_rds(pdf_tables_out, "IndiaVax.rds")

## download/ export to local computer and move to N
## End of work on the cloud. 

## Back to reality =D ===============


## Brief: India vaccination data are published in PDFs tables. 
## All PDFs have two tables, the first is over the country data, and the second is regional/ State level data. 
## All PDFs first tables are extracted by tabulizer (as above) via RStudio Cloud, 
## and some of these files table 2 is also extracted 

## Yet, for other files {tabulizer} does not read the second table, so I copied and pasted these 'manually' after opening the PDFs as word documents 


dataarchived <- read_rds(paste0(dir_n, ctr, ".rds"))

manual_data <- read_excel(paste0(data_source, "IndiaRegional-Table2.xlsx")) %>% 
  filter(!is.na(Region)) %>% 
  pivot_longer(cols = -c(Region, Date),
               names_to = c("Measure", "Age"),
               names_sep = "_",
               values_to = "Value") %>% 
  mutate(Value = parse_number(Value),
         Country = "India",
         Sex = "b",
         Metric = "Count",
         Age = case_when(Measure == "Vaccinations" ~ "TOT",
                         TRUE ~ Age),
         Code = case_when(
           Region == "A & N Islands" ~ "IN-AN",
           Region == "Andhra Pradesh" ~ "IN-AP",
           Region == "Arunachal Pradesh" ~ "IN-AR",
           Region == "Assam" ~ "IN-AS",
           Region == "Bihar" ~ "IN-BR",
           Region == "Chandigarh" ~ "IN-CH",
           Region == "Chhattisgarh" ~ "IN-CT",
           Region == "Delhi" ~ "IN-DL",
           Region == "Daman & Diu" ~ "IN-DD",
           Region == "Dadra & Nagar Haveli" ~ "IN-DN",
           Region == "Goa" ~ "IN-GA",
           Region == "Gujarat" ~ "IN-GJ",
           Region == "Haryana" ~ "IN-HR",
           Region == "Himachal Pradesh" ~ "IN-HP",
           Region == "Jammu & Kashmir" ~ "IN-JK",
           Region == "Jharkhand" ~ "IN-JH",
           Region == "Karnataka" ~ "IN-KA",
           Region == "Kerala" ~ "IN-KL",
           Region == "Ladakh" ~ "IN-LA",
           Region == "Lakshadweep" ~ "IN-LD",
           Region == "Madhya Pradesh" ~ "IN-MP",
           Region == "Maharashtra" ~ "IN-MH",
           Region == "Manipur" ~ "IN-MN",
           Region == "Meghalaya" ~ "IN-ML",
           Region == "Mizoram" ~ "IN-MZ",
           Region == "Nagaland" ~ "IN-NL",
           Region == "Odisha" ~ "IN-OR",
           Region == "Puducherry" ~ "IN-PY",
           Region == "Punjab" ~ "IN-PB",
           Region == "Rajasthan" ~ "IN-RJ",
           Region == "Sikkim" ~ "IN-SK",
           Region == "Tamil Nadu" ~ "IN-TN",
           Region == "Telangana" ~ "IN-TG",
           Region == "Tripura" ~ "IN-TR",
           Region == "Uttar Pradesh" ~ "IN-UP",
           Region == "Uttarakhand" ~ "IN-UT",
           Region == "West Bengal" ~ "IN-WB",
           TRUE ~ NA_character_
         ),
         AgeInt = case_when(Age == "12" ~ 3L,
                            Age == "15" ~ 3L,
                            Age == "18" & Measure == "Vaccination3" ~ 42L,
                            Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
                            Age == "60" ~ 45L,
                            Age == "TOT" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


out <- bind_rows(dataarchived, manual_data)


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

## END ##



