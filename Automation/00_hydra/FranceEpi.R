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
## Then stopped. SFP has collected data from all Laboratories in France from week 20, 2020. Despite losing the early epidemic data, 
## These data are systematically colelcted and updated. 
## Data are available in different formats; daily, rolling weeks, calender weeks by different age groups:
## ex. 1. school age groups (for lower ages; less than 18 yrs old and 18 and more -as one category)
## 2. more than 65 and less than 65 in 10-yrs interval
## 3. more than 90 and less than 90 in 10-yrs interval (which we will use here)
## since the data are available daily (by higher age groups), and weekly (by age group intervals), I prefer using weekly data since the start of the epidemic
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
## will take the last day (Friday) of the week 
                  YearWeek = paste0(YearWeek, "-5"),
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
  dplyr::mutate(
                #Code = paste0("FR-",str_pad(Region, width = 2, side = "left", pad = "0")),
                Region = case_when(Region == "1" ~ "Guadeloupe",
                                   Region == "2" ~ "Martinique",
                                   Region == "3" ~ "Guyane",
                                   Region == "4" ~ "La Reunion",
                                   Region == "5" ~ "Saint-Pierre-et-Miquelon",
                                   Region == "6" ~ "Mayotte",
                                   Region == "7" ~ "Saint Barthelemy",
                                   Region == "8" ~ "Saint-Martin",
                                   Region == "11" ~ "Ile-de-France",
                                   Region == "24" ~ "Centre-Val de Loire",
                                   Region == "27" ~ "Bourgogne-Franche-Comte",
                                   Region == "28" ~ "Normandie", 
                                   Region == "32" ~ "Hauts-de-France", 
                                   Region == "44" ~ "Grand Est",
                                   Region == "52" ~ "Pays de la Loire",
                                   Region == "53" ~ "Bretagne",
                                   Region == "75" ~ "Nouvelle-Aquitaine",
                                   Region == "76" ~ "Occitanie",
                                   Region == "84" ~ "Auvergne-Rhone-Alpes",
                                   Region == "93" ~ "Provence-Alpes-Cote d'Azur",
                                   Region == "94" ~ "Corse"),
                Code = case_when(Region == "Auvergne-Rhone-Alpes" ~	"FR-ARA",
                                 Region == "Bourgogne-Franche-Comte" ~	"FR-BFC",
                                 Region == "Bretagne" ~	"FR-BRE",
                                 Region == "Centre-Val de Loire" ~	"FR-CVL",
                                 Region == "Corse" ~	"FR-20R",
                                 Region == "Grand Est" ~	"FR-GES",
                                 Region == "Guadeloupe" ~ "FR-971",
                                 Region == "Guyane" ~	"FR-973",
                                 Region == "Hauts-de-France" ~	"FR-HDF",
                                 Region == "Ile-de-France" ~	"FR-IDF",
                                 Region == "La Reunion" ~	"FR-974",
                                 Region == "Martinique" ~	"FR-972",
                                 Region == "Mayotte" ~	"FR-976",
                                 Region == "Normandie" ~	"FR-NOR",
                                 Region == "Nouvelle-Aquitaine" ~"FR-NAQ",
                                 Region == "Occitanie" ~	"FR-OCC",
                                 Region == "Pays de la Loire" ~	"FR-PDL",
                                 Region == "Provence-Alpes-Cote d'Azur" ~	"FR-PAC",
                                 Region == "Saint Barthelemy" ~	"FR-BL",
                                 Region == "Saint Pierre et Miquelon" ~	"FR-PM",
                                 Region == "Saint Martin" ~	"FR-MF"))



## DEATHS DATASET ##
## Source Website: https://opendata.idf.inserm.fr/cepidc/covid-19/telechargements

## As per the data files in INED- France

## https://dc-covid.site.ined.fr/fr/donnees/France/

## The following dataset is CepiDC data which covers Cumulative deaths occurred in hospital and elsewhere (social institutions) in France, 
## for which the death certificate mentions an infection with the SARS-CoV-2 virus.

## Brief: deaths data are available till 22 April 2020, per week, per age & sex. 
## There is no data available by Region and data stopped publishing since late April 2022. 

deaths <- read.csv2("https://opendata.idf.inserm.fr/cepidc/covid-19/data/deces_hebdomadaires_avec_mention_de_covid_par_sexe_et_age.csv") 


deaths_processed <- deaths %>% 
  dplyr::select(semaine = semaine_de_deces,
                Age = classe_d_age,
                Sex = sexe,
                Deaths  = deces_covid) %>% 
  dplyr::mutate(YearWeek = str_replace_all(semaine, "-S", "-W"),
  ## will take the last day (Friday) of the week 
                YearWeek = paste0(YearWeek, "-5"),
                Date = ISOweek::ISOweek2date(YearWeek),
                Age = str_extract(Age, "\\d+"),
                Age = case_when(Age == "00" ~ "0",
                                TRUE ~ Age),
  ## Based on different files and datasets, 1 is for males, 2 for females ## 
                Sex = case_when(Sex == "1" ~ "m",
                                Sex == "2" ~ "f")) %>% 
  ## Since these are NEW weekly data, we will cumsum ACROSS columns before pivoting    
  dplyr::arrange(Date) %>% 
  dplyr::group_by(Age, Sex) %>% 
  dplyr::mutate(across(.cols = c("Deaths"), ~ cumsum(.x))) %>% 
  tidyr::pivot_longer(cols = c("Deaths"),
                      names_to = "Measure",
                      values_to = "Value") %>% 
  dplyr::mutate(AgeInt = case_when(Age == "0" ~ 25L,
                                   TRUE ~ 10L),
                Country = "France",
                Metric = "Count",
                ## we don't have the data by Region, so add the variable as 'All' ##
                Region = "All",
                Code = paste0("FR")) %>% 
  dplyr::select(Country, Region, Code, Date, 
                Age, AgeInt, Sex,
                Measure, Metric, Value)


## OUTPUTs ##

out <- dplyr::bind_rows(national, subnational, deaths_processed) %>% 
  dplyr::mutate(
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
             "SubNationalData" = region,
             "Deaths" = deaths)

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

