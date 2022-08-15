## FRANCE EPI-DATA; CASES, DEATHS AND TESTS
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "France" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## SourceWebsite <- "https://www.data.gouv.fr/fr/datasets/donnees-de-laboratoires-pour-le-depistage-a-compter-du-18-05-2022-si-dep/"
## CodeBook <- "https://www.data.gouv.fr/fr/datasets/r/2f8fd565-2691-4c83-8a5f-376e9da09ae5"

## Description of the following:
## Data from France have been collected manually per day for a while in Google Drive input templates (National & Regional),
## Then stopped. Data are available in different formats; daily, rolling weeks, calender weeks by different age groups:
## ex. 1. school age groups (for lower ages; less than 18 yrs old and 18 and more -as one category)
## 2. more than 65 and less than 65 in 10-yrs interval
## 3. more than 90 and less than 90 in 10-yrs interval (which we will use here)
## since the data are available daily (by higher age groups), and weekly (by ag egroup intervals), I prefer using weekly data since the start of the epidmeic
## though mentioned in the website that data by sex is available, I could not find it in the datasets :(

## CASES AND TESTS DATA

## From the CODEBOOK 

# P = patients testés positifs === (Confirmed Cases)
# T= nombre de patients testés === (Tests)

## France National Data, weekly, new cases and tests, % and counts, by age group.  

france <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/cb18e336-49ac-4dca-8c74-881ae0f344c8") %>% 
  rename(Region = 'fra')

## France Regional Data, weekly, new cases and tests, % and counts, by age group.  

region <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/64a05585-1e38-4d31-a94d-f6726cce4749") %>% 
  rename(Region = 'reg') %>% 
  mutate(Region = as.character(Region))

## FUNCTION TO PROCESS THE DATA 

process_dataset <- function(tbl){
  tbl %>% 
    dplyr::select(Region, semaine,
                  Age = cage10,
                  Cases  = `P`,
                  Tests = `T`) %>% 
    dplyr::mutate(YearWeek = str_replace_all(semaine, "-S", "-W"),
                  YearWeek = paste0(YearWeek, "-1"),
                  Date = ISOweek::ISOweek2date(YearWeek),
                  Age = str_extract(Age, "\\d+"),
                  Age = case_when(Age == "00" ~ "0",
                                  TRUE ~ Age)) %>% 
## Since these are NEW weekly data, we will cumsum ACROSS columns before pivoting    
    dplyr::arrange(Date) %>% 
    dplyr::group_by(Region, Age) %>% 
    dplyr::mutate(across(.cols = c("Cases", "Tests"), ~ cumsum(.x))) %>% 
    tidyr::pivot_longer(cols = c("Cases", "Tests"),
                        names_to = "Measure",
                        values_to = "Value") %>% 
    dplyr::mutate(AgeInt = case_when(Age == "90" ~ 15L,
                                     TRUE ~ 10L),
                  Country = "France",
                  Metric = "Count",
## we don't have the data by Sex, so add the variable as 'both' ##
                  Sex = "b") %>% 
    dplyr::select(Country, Region, Date, 
                  Age, AgeInt, Sex,
                  Measure, Metric, Value)
}

## MERGE & PROCESSING THE DATASETs ##

national <- france %>% 
  process_dataset() %>% 
  dplyr::mutate(Region = "All",
                Code = paste0("FR"))

subnational <- region %>% 
  process_dataset() %>% 
  dplyr::mutate(Code = paste0("FR-", 
                              str_pad(Region, width = 2, side = "left", pad = "0")),
                Region = case_when(Region == "1" ~ "Guadeloupe",
                                   Region == "2" ~ "Martinique",
                                   Region == "3" ~ "Guyane",
                                   Region == "4" ~ "La Réunion",
                                   Region == "5" ~ "Saint-Pierre-et-Miquelon",
                                   Region == "6" ~ "Mayotte",
                                   Region == "7" ~ "Saint-Barthélemy",
                                   Region == "8" ~ "Saint-Martin",
                                   Region == "11" ~ "Ile-de-France",
                                   Region == "24" ~ "Centre-Val de Loire",
                                   Region == "27" ~ "Bourgogne-Franche-Comté",
                                   Region == "28" ~ "Normandie", 
                                   Region == "32" ~ "Hauts-de-France", 
                                   Region == "44" ~ "Grand Est",
                                   Region == "52" ~ "Pays de la Loire",
                                   Region == "53" ~ "Bretagne",
                                   Region == "75" ~ "Nouvelle-Aquitaine",
                                   Region == "76" ~ "Occitanie",
                                   Region == "84" ~ "Auvergne-Rhône-Alpes",
                                   Region == "93" ~ "Provence-Alpes-Côte d’Azur",
                                   Region == "94" ~ "Corse")) 



## DEATHS DATASET == In Progress ## 

deaths <- read.csv2("https://opendata.idf.inserm.fr/cepidc/covid-19/data/deces_hebdomadaires_avec_mention_de_covid_par_sexe_et_age.csv")


## OUTPUTs ##

out <- national %>% 
  dplyr::bind_rows(subnational) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep=".")) %>% 
  sort_input_data()


#save output 

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out))


#Archive the original source files for the day

data_source <- paste0(dir_n, "Data_sources/", ctr, "/National_SubNational_Data_",today(), ".xlsx")

datasets <- list("NationalData" = france,
             "SubNationalData" = region)

writexl::write_xlsx(datasets, 
                    path = data_source)

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

