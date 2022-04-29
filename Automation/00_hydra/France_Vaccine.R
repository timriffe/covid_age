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
drive_auth(email = email)
gs4_auth(email = email)

##France

###data on cases by region, sex and age
###total france
###arrounf twice as much positiv tests than cases
#cases_tot <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/dd0de5d9-b5a5-4503-930a-7b08dc0adc7c")
#https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-resultats-des-tests-virologiques-covid-19/

###data on death by age
#https://www.data.gouv.fr/fr/datasets/donnees-de-certification-electronique-des-deces-associes-au-covid-19-cepidc/
###data on death by sex

###vaccination in france by age
vacc <- read.csv2("https://www.data.gouv.fr/fr/datasets/r/54dd5f8d-1e2e-4ccb-8fb8-eac68245befd")
vacc_tot_out <- vacc %>% 
  select(Date = jour, Age = clage_vacsi, Vaccination1 = n_cum_dose1, Vaccination2 = n_cum_complet, Vaccination3 = n_cum_rappel)
vacc_tot_out <- melt(vacc_tot_out, id = c("Date", "Age"))
names(vacc_tot_out)[3] <- "Measure"
names(vacc_tot_out)[4] <- "Value"
vacc_tot_out <- vacc_tot_out %>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ NA_integer_,
    Age == "4" ~ 5L,
    Age == "9" ~ 5L,
    Age == "11" ~ 2L,
    Age == "17" ~ 6L,
    Age == "24" ~ 7L,
    Age == "29" ~ 5L,
    Age == "39" ~ 10L,
    Age == "49" ~ 10L,
    Age == "59" ~ 10L,
    Age == "64" ~ 5L,
    Age == "69" ~ 5L,
    Age == "74" ~ 5L,
    Age == "79" ~ 5L,
    Age == "80" ~ 25L),
    Age = case_when(
      Age == "0" ~ "TOT",
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
    Country = "France",
    Region = "All",
    Metric = "Count",
    Sex = "b"
  ) %>% 
  arrange(Date, Age) %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("FR")) %>% 
  sort_input_data()


#save output 

write_rds(vacc_tot_out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc_tot_out))


#Archive 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(vacc, data_source)

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

