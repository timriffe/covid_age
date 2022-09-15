## Guatemala EPI-DATA AND VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Guatemala" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## Web source: https://tablerocovid.mspas.gob.gt/

# # Historical DATA LIST THE DIRECTORIES IN THE GUATEMALA FOLDER #

dir_main <- list.dirs(path = paste0(dir_n_source, ctr, "/GuatemalaHistoricalData/"),
                      full.names = TRUE, recursive = FALSE)

# FUNCTION TO EXTRACT THE DATA OF ALL THERE CSV IN A FOLDER

extract_data <- function(directory){
  list.files(path = directory,
             pattern = ".csv",
             full.names = TRUE) %>%
    set_names() %>%
    map_dfr(read.csv, .id = "file_name") %>%
    mutate(file_name = basename(file_name))
}

## FUNCTION TO READ DATA FROM CSV FILES

read_csv_files <- function(tbl, string_selection){
  
  tbl %>% 
    filter(str_detect(files_name, string_selection)) %>% 
    mutate(Date = str_extract(files_name, "\\d+"),
           Date = ymd(Date)) %>% 
    {map2_dfr(.$files_name, .$Date, function(x,y) read.csv(x) %>% mutate(Date=y))}
}

# DATAFRAMES CASES, DEATHS reading & processing #=============

cases_history <- extract_data(dir_main[1]) %>%
  dplyr::select(file_name, Age = Edad,
                Sex = Sexo, Value = n) %>% 
  mutate(Date = str_extract(file_name, "\\d+"),
         Date = dmy(Date))

deaths_history <- extract_data(dir_main[2]) %>%
  dplyr::select(file_name, Age = edad,
                Sex = sexo, Value = n) %>% 
  mutate(Date = str_extract(file_name, "\\d+"),
         Date = dmy(Date))


# DataArchived <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
#   mutate(Age = if_else(Age > 105, "105", Age))

directory <- paste0(dir_n_source, ctr)

files_all <- list.files(path = directory,
           pattern = ".csv",
           full.names = TRUE) 
files_csv <- data.frame(files_name = files_all)


cases_python <- files_csv %>% 
  read_csv_files("confirmedcases_") %>% 
  dplyr::select(Date, Age = Edad,
                Sex = Sexo, Value = n)

deaths_python <- files_csv %>% 
  read_csv_files("deceasedcases_") %>% 
  dplyr::select(Date, Age = edad,
                Sex = sexo, Value = n)

## BIND HISTORICAL AND PYTHON_DATA INTO ONE DATAFRAME 

epi_data <- bind_rows("Cases" = cases_python,
                     "Cases" = cases_history,
                     "Deaths" = deaths_history, 
                     "Deaths" = deaths_python, 
                     .id = "Measure") %>% 
  dplyr::mutate(
    Sex = case_when(Sex == "Femenino" ~ "f",
                    Sex == "Masculino" ~ "m",
                    Sex == "Sin Dato" ~ "UNK",
                    TRUE ~ "b"),
    Age = case_when(Age == "SIN DATO" ~ "UNK",
                    Age == "Total" ~ "TOT",
                    TRUE ~ Age),
    AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                       Age == "TOT" ~ NA_integer_,
                       TRUE ~ 1L))


## FUNCTION TO PROCESS CASES AND DEATHS DATA ## 

# process_epi <- function(tbl){
#   
#   tbl %>% 
#     dplyr::mutate(
#       Sex = case_when(Sex == "Femenino" ~ "f",
#                       Sex == "Masculino" ~ "m",
#                       Sex == "Sin Dato" ~ "UNK",
#                       TRUE ~ "b"),
#       Age = case_when(Age == "SIN DATO" ~ "UNK",
#                       Age == "Total" ~ "TOT",
#                       TRUE ~ Age),
#       AgeInt = case_when(Age == "UNK" ~ NA_integer_,
#                          Age == "TOT" ~ NA_integer_,
#                          TRUE ~ 1L))
#   
# }
# 
# Cases <- cases_python %>% 
#   process_epi()
# 
# Deaths <- deaths_python %>% 
#   process_epi()
# 
# #%>% arrange(Date) %>% distinct(Date)
# 
# 
# ## MERGE CASES AND DEATHS DATASETS 
# 
# epi_data <- bind_rows("Cases" = Cases, 
#                       "Deaths" = Deaths, .id = "Measure")


# VACCINATION DATA- reading & processing # =====================

vaxAge_history <- extract_data(dir_main[3]) %>% 
  mutate(Date = str_extract(file_name, "\\d+"),
         Date = dmy(Date))

vaxSex_history <- extract_data(dir_main[4]) %>% 
  mutate(Date = str_extract(file_name, "\\d+"),
         Date = dmy(Date))


vaxAge_python <- files_csv %>% 
  read_csv_files("vaccination_age_")

vaxSex_python <- files_csv %>% 
  read_csv_files("vaccination_gender_")

## MERGE datasets & process

vaxAge_raw <- bind_rows(vaxAge_history, vaxAge_python)

vaxSex_raw <- bind_rows(vaxSex_history, vaxSex_python)


VaccAge_processed <- vaxAge_python %>% 
  select(Date,
         Age = contains("Grupo"), 
         Vaccination1 = Dosis.administradas..primera.dosis.,
         Vaccination2 = Dosis.administradas..esquema.completo.,
         Vaccination3 = Dosis.administradas..dosis.de.refuerzo.,
         Vaccination4 = Dosis.administradas..segunda.dosis.de.refuerzo.) %>% 
  dplyr::mutate(
    Age = case_when(Age == "Total" ~ "TOT",
                    str_detect(Age, "06") ~ "6",
                    TRUE ~ str_extract(Age, "\\d+")),
    AgeInt = case_when(Age == "Total" ~ NA_integer_,
                       Age == "6" ~ 6L,
                       Age == "12" ~ 6L,
                       Age == "18" ~ 12L,
                       Age == "70" ~ 35L,
                       TRUE ~ 10L),
    Sex = "b") %>% 
  tidyr::pivot_longer(cols = contains("Vaccin"),
                      names_to = "Measure",
                      values_to = "Value") 
  


VaccSex_processed <- vaxSex_python %>% 
  select(Date,
         Sex = sexo, 
         Vaccination1 = Dosis.administradas..primera.dosis.,
         Vaccination2 = Dosis.administradas..esquema.completo.,
         Vaccination3 = Dosis.administradas..dosis.de.refuerzo.,
         Vaccination4 = Dosis.administradas..segunda.dosis.de.refuerzo.) %>% 
  dplyr::mutate(
    Sex = case_when(Sex == "Femenino" ~ "f",
                    Sex == "Masculino" ~ "m",
                    Sex == "Sin Dato" ~ "UNK",
                    TRUE ~ "b"),
    Age = "UNK",
    AgeInt = NA_integer_) %>% 
  tidyr::pivot_longer(cols = contains("Vaccin"),
                      names_to = "Measure",
                      values_to = "Value") 



## MERGE ALL DATA AND PREPARE THE FINAL OUTPUT ## ======


out <- bind_rows(epi_data,
                 VaccAge_processed,
                 VaccSex_processed) %>% 
  dplyr::mutate(
  Metric = "Count",
  Date = ddmmyyyy(Date),
  Code = paste0("GT"),
  Country = "Guatemala",
  Region = "All",
  Age = as.character(Age)) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, 
                Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()
  
## MERGE WITH HISTORICAL ARCHIVED DATA (if required) 

#out <- bind_rows(out_week, DataArchived)


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

## NO NEED for this as the csv files are already downloaded and stored. 
# #zip input data file 
# 
# data_source <- paste0(dir_n, "Data_sources/", ctr, "/data_", today(), ".csv")
# 
# write.csv(raw_data, data_source)
# 
# 
# zipname <- paste0(dir_n, 
#                   "Data_sources/", 
#                   ctr,
#                   "/", 
#                   ctr,
#                   "_data_",
#                   today(), 
#                   ".zip")
# 
# zip::zipr(zipname, 
#           data_source, 
#           recurse = TRUE, 
#           compression_level = 9,
#           include_directories = TRUE)
# 
# file.remove(data_source)

#END



## some quality check for reference ##

# epi_data %>%
#   filter(Sex != "TOT") %>%
#  # group_by(Date, Measure) %>%
#  # summarise(Value = sum(Value)) %>%
#   ggplot(aes(x = Date, y = Value)) +
#   geom_point() +
#   facet_wrap(~ Measure)
# 
# 
# 
# VaccAge_processed %>%
#   filter(Age != "Total") %>%
# #  group_by(Date, Measure) %>%
#  # summarise(Value = sum(Value)) %>%
#   ggplot(aes(x = Date, y = Value)) +
#   geom_point() +
#   facet_wrap(~ Measure)
# 










