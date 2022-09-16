library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}


# info country and N drive address

ctr          <- "France_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

##France

###data on cases by region, sex and age
###total France
###arrounf twice as much positiv tests than cases
#cases_tot <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/dd0de5d9-b5a5-4503-930a-7b08dc0adc7c")
#https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-resultats-des-tests-virologiques-covid-19/

###data on death by age
#https://www.data.gouv.fr/fr/datasets/donnees-de-certification-electronique-des-deces-associes-au-covid-19-cepidc/
###data on death by sex

###vaccination in France by age

##vacc <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/54dd5f8d-1e2e-4ccb-8fb8-eac68245befd")


## MK (05.07.2022) adding:

### Vaccination in France (total) by sex and age ===============

##Source: https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-personnes-vaccinees-contre-la-covid-19-1/#resources

vacc_total <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/e6fcd558-2ff6-487b-b624-e64a8c05bb07")

vacc_age_sex <- vacc_total %>% 
  select(Date = jour, 
         Age = clage_vacsi, 
         Vaccination1_Homme = n_cum_dose1_h, 
         Vaccination2_Homme = n_cum_complet_h, 
         Vaccination3_Homme = n_cum_rappel_h,
         Vaccination4_Homme = n_cum_2_rappel_h,
         Vaccination1_Femme = n_cum_dose1_f, 
         Vaccination2_Femme = n_cum_complet_f, 
         Vaccination3_Femme = n_cum_rappel_f,
         Vaccination4_Femme = n_cum_2_rappel_f,
         Vaccination1_Total = n_cum_dose1_e, 
         Vaccination2_Total = n_cum_complet_e, 
         Vaccination3_Total = n_cum_rappel_e,
         Vaccination4_Total = n_cum_2_rappel_e) %>% 
  pivot_longer(cols = -c("Date", "Age"),
               names_to = c("Measure", "Sex"),
               names_sep = "_",
               values_to = "Value")



vacc_tot_age_sex <- vacc_age_sex %>% 
  mutate(Sex = case_when(Sex == "Homme" ~ "m",
                         Sex == "Femme" ~ "f",
                         TRUE ~ "b"), # b (both) for totals
         Age = case_when(Age == "0" ~ "TOT",
                         Age == "4" ~ "0",
                         Age == "9" ~ "5",
                         Age == "11" ~ "10",
                         Age == "17" ~ "12",
                         Age == "24" ~ "18",
                         Age == "29" ~ "25",
                         Age == "39" ~ "30",
                         Age == "49" ~ "40",
                         Age == "59" ~ "50",
                         Age == "64" ~ "60",
                         Age == "69" ~ "65",
                         Age == "74" ~ "70",
                         Age == "79" ~ "75",
                         Age == "80" ~ "80"),
         AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                            Age == "0" ~ 5L,
                            Age == "5" ~ 5L,
                            Age == "10" ~ 2L,
                            Age == "12" ~ 6L,
                            Age == "18" ~ 7L,
                            Age == "25" ~ 5L,
                            Age == "80" ~ 25L,
                            TRUE ~ 10L),
         
         Country = "France",
         Metric = "Count",
         Region = "All") %>% 
  arrange(Date, Age) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("FR")) %>% 
  sort_input_data()




### Vaccination in France per region by sex and age ===============
vacc_reg <- fread("https://www.data.gouv.fr/fr/datasets/r/8e5e70fa-c082-45e3-a7b8-20862711b142")

## Notes on code-book as published in the source ## 
## we are interested in cumulative data ## so:
## (h is for homme/ males, f for females)
## n_cum_dose1_h : cumulative number of first dose 
## n_cum_complet_h: cumulative number of complete vaccinations (2 doses)
## n_cum_rappel_f: cumulative number of booster doses (3 doses)
## n_cum_2_rappel:  Nombre cumulé de personnes vaccinées avec 2 doses de rappel


vacc_reg_out <- vacc_reg %>% 
  select(Region = reg,
         Date = jour, 
         Age = clage_vacsi, 
         Vaccination1_Homme = n_cum_dose1_h, 
         Vaccination2_Homme = n_cum_complet_h, 
         Vaccination3_Homme = n_cum_rappel_h,
         Vaccination4_Homme = n_cum_2_rappel_h,
         Vaccination1_Femme = n_cum_dose1_f, 
         Vaccination2_Femme = n_cum_complet_f, 
         Vaccination3_Femme = n_cum_rappel_f,
         Vaccination4_Femme = n_cum_2_rappel_f,
         Vaccination1_Total = n_cum_dose1_e, 
         Vaccination2_Total = n_cum_complet_e, 
         Vaccination3_Total = n_cum_rappel_e,
         Vaccination4_Total = n_cum_2_rappel_e) %>% 
  pivot_longer(cols = -c("Region", "Date", "Age"),
               names_to = c("Measure", "Sex"),
               names_sep = "_",
               values_to = "Value")




vacc_reg_age_sex <- vacc_reg_out %>% 
  mutate(Sex = case_when(Sex == "Homme" ~ "m",
                         Sex == "Femme" ~ "f",
                         TRUE ~ "b"),
       #  Code = paste0("FR-",str_pad(Region, width = 2, side = "left", pad = "0")),
         Region = as.character(Region),
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
                          Region == "Saint Martin" ~	"FR-MF"),
         Age = case_when(Age == "0" ~ "TOT",
                         Age == "4" ~ "0",
                         Age == "9" ~ "5",
                         Age == "11" ~ "10",
                         Age == "17" ~ "12",
                         Age == "24" ~ "18",
                         Age == "29" ~ "25",
                         Age == "39" ~ "30",
                         Age == "49" ~ "40",
                         Age == "59" ~ "50",
                         Age == "64" ~ "60",
                         Age == "69" ~ "65",
                         Age == "74" ~ "70",
                         Age == "79" ~ "75",
                         Age == "80" ~ "80"),
         AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                            Age == "0" ~ 5L,
                            Age == "5" ~ 5L,
                            Age == "10" ~ 2L,
                            Age == "12" ~ 6L,
                            Age == "18" ~ 7L,
                            Age == "25" ~ 5L,
                            Age == "80" ~ 25L,
                            TRUE ~ 10L),
    Country = "France",
    Metric = "Count") %>% 
  arrange(Date, Age) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep=".")) %>% 
  sort_input_data()





vacc_tot_out <- bind_rows(vacc_tot_age_sex,vacc_reg_age_sex)




#save output 

write_rds(vacc_tot_out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc_tot_out))


#Archive the original source files for the day

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_sex_",today(), ".xlsx")

vacc <- list("vacc_total" = vacc_total,
             "vacc_reg" = vacc_reg)

writexl::write_xlsx(vacc, 
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
