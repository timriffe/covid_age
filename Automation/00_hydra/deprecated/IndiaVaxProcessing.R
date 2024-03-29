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


## Back to reality =D ===============


## Brief: India vaccination data are published in PDFs tables. 
## All PDFs have two tables, the first is over the country data, and the second is regional/ State level data. 
## All PDFs data are copied and pasted into excel file, on monthly basis and manipulated here.. 


## ARCHIVED DATA reading

dataarchived <- read_rds(paste0(dir_n, ctr, ".rds")) 


## READ & PROCESS THE COPIED NEW DATA 



vax.list.all <-list.files(
  path= data_source,
  pattern = ".csv",
  full.names = TRUE)

vax_list_national <- data.frame(file_name = vax.list.all) %>% 
  filter(str_detect(file_name, "/national_")) %>% 
  mutate(date = str_extract(file_name, "\\d+\\w+\\d+"),
         date = dmy(date)) 


vax_list_Subnational <- data.frame(file_name = vax.list.all) %>% 
  filter(str_detect(file_name, "/subnational_")) %>% 
  mutate(date = str_extract(file_name, "\\d+\\w+\\d+"),
         date = dmy(date)) 

## NATIONAL CSV FILES. 

vax_df_national_raw <- vax_list_national %>% 
  {map2_dfr(.$file_name, .$date, function(x,y) read_csv(x) %>% 
                     mutate(Date = y))} 

vax_df_national_processed <- vax_df_national_raw %>% 
  filter(!is.na(Country)) %>% 
  mutate(across(.cols = -c("Country", "Date"), ~parse_number(.x))) %>% 
  pivot_longer(cols = -c("Country", "Date"),
               names_to = "Dose_age",
               values_to = "Value") %>% 
  mutate(Measure = case_when(str_detect(Dose_age, "1st_") ~ "Vaccination1",
                             str_detect(Dose_age, "2nd_") ~ "Vaccination2",
                             str_detect(Dose_age, "Precaution_") ~ "Vaccination3",
                             str_detect(Dose_age, "Total_") ~ "Vaccinations"),
         Age = case_when(str_detect(Dose_age, "12") ~ "12",
                         str_detect(Dose_age, "15") ~ "15",
                         str_detect(Dose_age, "18") ~ "18",
                         str_detect(Dose_age, "60") ~ "60",
                         str_detect(Dose_age, "Total_") ~ "TOT"),
         AgeInt = case_when(Age == "12" ~ 3L,
                            Age == "15" ~ 3L,
                            Age == "18" & Measure == "Vaccination3" ~ 42L,
                            Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
                            Age == "60" ~ 45L,
                            Age == "TOT" ~ NA_integer_),
         Region = "All",
         Metric = "Count",
         Code = "IN",
         Sex = "b") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)



## SUB-NATIONAL CSV FILES. 

vax_df_Subnational_raw <- vax_list_Subnational %>% 
  {map2_dfr(.$file_name, .$date, function(x,y) read_csv(x) %>% 
              mutate(Date = y))} 

vax_df_Subnational_processed <- vax_df_Subnational_raw %>% 
  filter(!is.na(Region)) %>% 
  select(-Serial) %>% 
  pivot_longer(cols = -c("Region", "Date"),
               names_to = "Dose_age",
               values_to = "Value") %>% 
  mutate(Measure = case_when(str_detect(Dose_age, "1st_") ~ "Vaccination1",
                             str_detect(Dose_age, "2nd_") ~ "Vaccination2",
                             str_detect(Dose_age, "Precaution_") ~ "Vaccination3",
                             str_detect(Dose_age, "Total_") ~ "Vaccinations"),
         Age = case_when(str_detect(Dose_age, "12") ~ "12",
                         str_detect(Dose_age, "15") ~ "15",
                         str_detect(Dose_age, "18") ~ "18",
                         str_detect(Dose_age, "60") ~ "60",
                         str_detect(Dose_age, "Total_") ~ "TOT"),
         Country = "India",
         Sex = "b",
         Metric = "Count",
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
           Region == "Miscellaneous" ~ "IN-UNK"
         ),
         AgeInt = case_when(Age == "12" ~ 3L,
                            Age == "15" ~ 3L,
                            Age == "18" & Measure == "Vaccination3" ~ 42L,
                            Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
                            Age == "60" ~ 45L,
                            Age == "TOT" ~ NA_integer_)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)




processed_data <- bind_rows(vax_df_national_processed, vax_df_Subnational_processed) %>% 
  mutate(Date = ddmmyyyy(Date))


out <- bind_rows(dataarchived, processed_data) %>% 
  unique() %>% 
  sort_input_data()


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(out)) 

## END ##




## CODE USED TO RUN AFTER MANUAL COPY ## =============================

# file_name <- "IndiaVaxDataFromPDFs.xlsx" ## the file_name  
#
# country_data <- read_excel(paste0(data_source, file_name), sheet = 1) %>% 
#   mutate(Value = parse_number(Value),
#          Measure = case_when(Dose == "1st Dose" ~ "Vaccination1",
#                              Dose == "2nd Dose" ~ "Vaccination2",
#                              Dose == "3rd Dose" ~ "Vaccination3",
#                              Age == "Total Doses" ~ "Vaccinations"),
#          Age = str_extract(Age, "\\d+"),
#          Age = replace_na(Age, "TOT"),
#          AgeInt = case_when(Age == "12" ~ 3L,
#                             Age == "15" ~ 3L,
#                             Age == "18" & Measure == "Vaccination3" ~ 42L,
#                             Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
#                             Age == "60" ~ 45L,
#                             Age == "TOT" ~ NA_integer_),
#          Region = "All",
#          Metric = "Count",
#          Code = "IN",
#          Sex = "b") %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# regional_data <- read_excel(paste0(data_source, file_name), sheet = 2) %>% 
#   filter(!is.na(Region)) %>% 
#   pivot_longer(cols = -c(Region, Date),
#                names_to = c("Measure", "Age"),
#                names_sep = "_",
#                values_to = "Value") %>% 
#   mutate(Value = parse_number(Value),
#          Country = "India",
#          Sex = "b",
#          Metric = "Count",
#          Age = case_when(Measure == "Vaccinations" ~ "TOT",
#                          TRUE ~ Age),
#          Code = case_when(
#            Region == "A & N Islands" ~ "IN-AN",
#            Region == "Andhra Pradesh" ~ "IN-AP",
#            Region == "Arunachal Pradesh" ~ "IN-AR",
#            Region == "Assam" ~ "IN-AS",
#            Region == "Bihar" ~ "IN-BR",
#            Region == "Chandigarh" ~ "IN-CH",
#            Region == "Chhattisgarh" ~ "IN-CT",
#            Region == "Delhi" ~ "IN-DL",
#            Region == "Daman & Diu" ~ "IN-DD",
#            Region == "Dadra & Nagar Haveli" ~ "IN-DN",
#            Region == "Goa" ~ "IN-GA",
#            Region == "Gujarat" ~ "IN-GJ",
#            Region == "Haryana" ~ "IN-HR",
#            Region == "Himachal Pradesh" ~ "IN-HP",
#            Region == "Jammu & Kashmir" ~ "IN-JK",
#            Region == "Jharkhand" ~ "IN-JH",
#            Region == "Karnataka" ~ "IN-KA",
#            Region == "Kerala" ~ "IN-KL",
#            Region == "Ladakh" ~ "IN-LA",
#            Region == "Lakshadweep" ~ "IN-LD",
#            Region == "Madhya Pradesh" ~ "IN-MP",
#            Region == "Maharashtra" ~ "IN-MH",
#            Region == "Manipur" ~ "IN-MN",
#            Region == "Meghalaya" ~ "IN-ML",
#            Region == "Mizoram" ~ "IN-MZ",
#            Region == "Nagaland" ~ "IN-NL",
#            Region == "Odisha" ~ "IN-OR",
#            Region == "Puducherry" ~ "IN-PY",
#            Region == "Punjab" ~ "IN-PB",
#            Region == "Rajasthan" ~ "IN-RJ",
#            Region == "Sikkim" ~ "IN-SK",
#            Region == "Tamil Nadu" ~ "IN-TN",
#            Region == "Telangana" ~ "IN-TG",
#            Region == "Tripura" ~ "IN-TR",
#            Region == "Uttar Pradesh" ~ "IN-UP",
#            Region == "Uttarakhand" ~ "IN-UT",
#            Region == "West Bengal" ~ "IN-WB",
#            Region == "Miscellaneous" ~ "IN-UNK"
#          ),
#          AgeInt = case_when(Age == "12" ~ 3L,
#                             Age == "15" ~ 3L,
#                             Age == "18" & Measure == "Vaccination3" ~ 42L,
#                             Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
#                             Age == "60" ~ 45L,
#                             Age == "TOT" ~ NA_integer_)) %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


# manual_data <- bind_rows(country_data, regional_data)
# 
# 
# out <- bind_rows(dataarchived, manual_data) %>% 
#   unique() %>% 
#   sort_input_data()



## PDFs data ## ==========================

## copy till the writing out to .rds & paste into RStuido cloud 
## you need to zip the PDF files to upload it into the cloud. 

# install.packages("rJava")
# library(rJava) # load and attach 'rJava' now
# install.packages("devtools")
# devtools::install_github("ropensci/tabulizer", args="--no-multiarch")
# 
# library(tabulizer)
# library(here)
# library(lubridate)
# library(tidyverse)
# 
# list.pdfs <- list.files(
#   path = here::here("IndiaPDFs"),
#   pattern = ".pdf",
#   full.names = TRUE
# )
# 
# pdfs_df <- data.frame(pdf_path = list.pdfs) %>% 
#   mutate(date = str_remove(pdf_path, "/cloud/project/IndiaPDFs/CummulativeCovidVaccinationReport"),
#          Date = str_remove(date, ".pdf"),
#          Date = dmy(Date))
# 
# 
# 
# # ALL table ## ======================
# 
# ## FUNCTION: Extraction ##
# 
# extract_table1 <- function(pdf_path){
#   extract_tables(pdf_path, output = "data.frame") %>% .[[1]] %>% 
#     janitor::clean_names()
# }
# 
# ## EXAMPLE ##
# 
# tab1_data <- pdfs_df %>% 
#   filter(str_detect(pdf_path, "Sep")) %>% #tried May, Jun, Jul- okay!, but Aug & Sep have some issues
#   {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} 
# 
# ## FUNCTION: Collection and little cleaning ##
# 
# collect_data <- function(tbl, name_month){
#   tbl %>% 
#     filter(str_detect(pdf_path, name_month)) %>% 
#     {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} %>% 
#     filter(country == "India") %>% 
#     rename('Vaccination1_18' = beneficiaries_vaccinated,
#            'Vaccination2_18' = total_doses,
#            'Vaccination1_15' = x,
#            'Vaccination2_15' = x_1,
#            'Vaccination1_12' = x_2,
#            'Vaccination2_12' = x_3,
#            'Vaccination3_18' = x_4,
#            'Vaccination3_60' = x_5,
#            'Vaccinations' = x_6)
# }
# 
# tab1_May <- pdfs_df %>% collect_data("May")
# tab1_Jun <- pdfs_df %>% collect_data("Jun")
# tab1_Jul <- pdfs_df %>% collect_data("Jul")
# tab1_Aug25 <- pdfs_df %>% collect_data("Aug")
# tab1_Sep7 <- pdfs_df %>% collect_data("Sep")
# 
# ## Different wrangling is required for the period > 25.08.2022 - < 07.09.2022 & some sporadic dates 
# tab1_aug_sep <- pdfs_df %>% filter(Date > "2022-08-25", Date < "2022-09-07") %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-05-11")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-08-01")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-08-06")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-08-07")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-08-11")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-08-18")) %>% 
#   bind_rows(pdfs_df %>% filter(Date == "2022-09-20"))
# 
# tab1_AS <- tab1_aug_sep %>% 
#   {map2_dfr(.$pdf_path, .$Date, function(x,y) extract_table1(x) %>% mutate(Date=y))} %>% 
#   filter(str_detect(x_3, ","),
#          x != "India") %>% 
#   select(-x) %>% 
#   rename('Vaccination1_Vaccination2_18' = x_1,
#          'Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12' = beneficiaries_vaccinated,
#          'Vaccination3_1859-Vaccination3_60' = x_2,
#          'Vaccinations' = x_3) %>% 
#   separate('Vaccination1_Vaccination2_18',
#            into = c("Vaccination1_18", "Vaccination2_18"),
#            sep = " ") %>% 
#   separate('Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12',
#            into = c("Vaccination1_15", "Vaccination2_15", 
#                     "Vaccination1_12", "Vaccination2_12"),
#            sep = " ") %>% 
#   separate('Vaccination3_1859-Vaccination3_60',
#            into = c("Vaccination3_18", "Vaccination3_60"),
#            sep = " ") %>% 
#   mutate(country = "India")
# 
# ## BIND all tables 1
# 
# tab1_all <- bind_rows(tab1_May,
#                       tab1_Jun,
#                       tab1_Jul,
#                       tab1_Aug25,
#                       tab1_Sep7,
#                       tab1_AS)
# 
# 
# tab1_out <- tab1_all %>% 
#   pivot_longer(cols = -c("country", "Date"),
#                names_to = c("Measure", "Age"),
#                names_sep = "_",
#                values_to = "Value") %>% 
#   rename(Country = country) %>% 
#   mutate(Value = parse_number(Value),
#          Region = "All",
#          Sex = "b",
#          Code = "IN",
#          Metric = "Count",
#          Age = case_when(Measure == "Vaccinations" ~ "TOT",
#                          TRUE ~ Age),
#          AgeInt = case_when(Age == "12" ~ 3L,
#                             Age == "15" ~ 3L,
#                             Age == "18" & Measure == "Vaccination3" ~ 42L,
#                             Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
#                             Age == "60" ~ 45L,
#                             Age == "TOT" ~ NA_integer_)) %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# # REGIONAL TABLE ========================
# 
# ## FUNCTION: Extraction ##
# 
# extract_table2 <- function(pdf_path){
#   extract_tables(pdf_path, output = "data.frame") %>% .[[2]] %>% 
#     janitor::clean_names()
# }
# 
# 
# all_pdfs <- list.pdfs %>% 
#   set_names() %>% 
#   map(~extract_tables(., output = "data.frame"))
# 
# regional_pdfs <- all_pdfs %>% 
#   map_dfr(~length(.)) %>% 
#   pivot_longer(cols = everything(),
#                names_to = "File_name",
#                values_to = "number_tables") %>% 
#   filter(number_tables == 2)  ## only 19 files (so far) that have the second table read by tabulizer
# 
# regional_files <- regional_pdfs %>% 
#   inner_join(pdfs_df, by = c("File_name" = "pdf_path")) %>% 
#   {map2_dfr(.$File_name, .$Date, function(x,y) extract_table2(x) %>% mutate(Date=y))} 
# 
# regional_files_processing <- regional_files %>% 
#   select(-x) %>% 
#   rename(Region = x_1,
#          'Vaccination1_Vaccination2_18' = x_2,
#          'Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12' = beneficiaries_vaccinated,
#          'Vaccination3_1859-Vaccination3_60' = x_3,
#          'Vaccinations' = x_4) %>% 
#   filter(str_detect(Vaccinations, ",")) %>% 
#   mutate(Region = case_when(Region == "" ~ "Dadra & Nagar Haveli",
#                             TRUE ~ Region)) %>% 
#   separate('Vaccination1_Vaccination2_18',
#            into = c("Vaccination1_18", "Vaccination2_18"),
#            sep = " ") %>% 
#   separate('Vaccination1_Vaccination2_15-Vaccination1_Vaccination2_12',
#            into = c("Vaccination1_15", "Vaccination2_15", 
#                     "Vaccination1_12", "Vaccination2_12"),
#            sep = " ") %>% 
#   separate('Vaccination3_1859-Vaccination3_60',
#            into = c("Vaccination3_18", "Vaccination3_60"),
#            sep = " ") %>% 
#   pivot_longer(cols = -c(Region, Date),
#                names_to = c("Measure", "Age"),
#                names_sep = "_",
#                values_to = "Value") %>% 
#   mutate(Value = parse_number(Value),
#          Country = "India",
#          Sex = "b",
#          Metric = "Count",
#          Age = case_when(Measure == "Vaccinations" ~ "TOT",
#                          TRUE ~ Age),
#          Code = case_when(
#            Region == "A & N Islands" ~ "IN-AN",
#            Region == "Andhra Pradesh" ~ "IN-AP",
#            Region == "Arunachal Pradesh" ~ "IN-AR",
#            Region == "Assam" ~ "IN-AS",
#            Region == "Bihar" ~ "IN-BR",
#            Region == "Chandigarh" ~ "IN-CH",
#            Region == "Chhattisgarh" ~ "IN-CT",
#            Region == "Delhi" ~ "IN-DL",
#            Region == "Daman & Diu" ~ "IN-DD",
#            Region == "Dadra & Nagar Haveli" ~ "IN-DN",
#            Region == "Goa" ~ "IN-GA",
#            Region == "Gujarat" ~ "IN-GJ",
#            Region == "Haryana" ~ "IN-HR",
#            Region == "Himachal Pradesh" ~ "IN-HP",
#            Region == "Jammu & Kashmir" ~ "IN-JK",
#            Region == "Jharkhand" ~ "IN-JH",
#            Region == "Karnataka" ~ "IN-KA",
#            Region == "Kerala" ~ "IN-KL",
#            Region == "Ladakh" ~ "IN-LA",
#            Region == "Lakshadweep" ~ "IN-LD",
#            Region == "Madhya Pradesh" ~ "IN-MP",
#            Region == "Maharashtra" ~ "IN-MH",
#            Region == "Manipur" ~ "IN-MN",
#            Region == "Meghalaya" ~ "IN-ML",
#            Region == "Mizoram" ~ "IN-MZ",
#            Region == "Nagaland" ~ "IN-NL",
#            Region == "Odisha" ~ "IN-OR",
#            Region == "Puducherry" ~ "IN-PY",
#            Region == "Punjab" ~ "IN-PB",
#            Region == "Rajasthan" ~ "IN-RJ",
#            Region == "Sikkim" ~ "IN-SK",
#            Region == "Tamil Nadu" ~ "IN-TN",
#            Region == "Telangana" ~ "IN-TG",
#            Region == "Tripura" ~ "IN-TR",
#            Region == "Uttar Pradesh" ~ "IN-UP",
#            Region == "Uttarakhand" ~ "IN-UT",
#            Region == "West Bengal" ~ "IN-WB",
#            Region == "Miscellaneous" ~ "IN-UNK"
#          ),
#          AgeInt = case_when(Age == "12" ~ 3L,
#                             Age == "15" ~ 3L,
#                             Age == "18" & Measure == "Vaccination3" ~ 42L,
#                             Age == "18" & Measure %in% c("Vaccination1", "Vaccination2") ~ 87L,
#                             Age == "60" ~ 45L,
#                             Age == "TOT" ~ NA_integer_)) %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# pdf_tables_out <- bind_rows(tab1_out, regional_files_processing) %>% 
#   mutate(Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep="."))
# 
# 
# write_rds(pdf_tables_out, "IndiaVax.rds")

## download/ export to local computer and move to N
## End of work on the cloud. 


