##Italy regions 
library(readxl)
library(tidyverse)
library(ISOweek)
library(lubridate)
library(here)
library(httr)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  email <- "mumanal.k@gmail.com"
  #originally: "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Italy_reg"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- paste0("N:/COVerAGE-DB/Automation/", ctr, "/")


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#drive_auth(email = Sys.getenv("email"))
#gs4_auth(email = Sys.getenv("email"))

##female cases
m_url <- "https://github.com/InPhyT/COVID19-Italy-Integrated-Surveillance-Data/tree/main/3_output/data/"

links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "confirmed_female")) %>% 
  separate(url, c("trash", "url"), sep = "blob/") %>% 
    mutate(url = paste0("https://raw.githubusercontent.com/InPhyT/COVID19-Italy-Integrated-Surveillance-Data/", url)) %>% 
select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

destinations1 <- c(paste0(dir_n, "Data_sources/", ctr, "/Abruzzo_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Aosta Valley_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Apulia_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Basilicata_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Calabria_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Campania_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Emilia_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Friuli_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Lazio_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Liguria_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Lombardy_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Marches_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Molise_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Pa Bolzano_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Pa Trento_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Piedmont_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Sardinia_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Sicily_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Trentino Alto Adige_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Tuscany_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Umbria_Cases_f_",today(), ".csv"),
                 paste0(dir_n, "Data_sources/", ctr, "/Veneto_Cases_f_",today(), ".csv"))
                 


for(i in seq_along(url)){
  download.file(url[i], destinations1[i], mode="wb")
}

##male cases
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "confirmed_male")) %>% 
  separate(url, c("trash", "url"), sep = "blob/") %>% 
  mutate(url = paste0("https://raw.githubusercontent.com/InPhyT/COVID19-Italy-Integrated-Surveillance-Data/", url)) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

destinations2 <- c(paste0(dir_n, "Data_sources/", ctr, "/Abruzzo_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Aosta Valley_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Apulia_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Basilicata_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Calabria_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Campania_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Emilia_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Friuli_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lazio_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Liguria_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lombardy_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Marches_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Molise_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Bolzano_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Trento_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Piedmont_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sardinia_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sicily_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Trentino Alto Adige_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Tuscany_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Umbria_Cases_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Veneto_Cases_m_",today(), ".csv"))



for(i in seq_along(url)){
  download.file(url[i], destinations2[i], mode="wb")
}

###death females
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "deceased_female")) %>% 
  separate(url, c("trash", "url"), sep = "blob/") %>% 
  mutate(url = paste0("https://raw.githubusercontent.com/InPhyT/COVID19-Italy-Integrated-Surveillance-Data/", url)) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

destinations3 <- c(paste0(dir_n, "Data_sources/", ctr, "/Abruzzo_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Aosta Valley_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Apulia_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Basilicata_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Calabria_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Campania_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Emilia_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Friuli_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lazio_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Liguria_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lombardy_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Marches_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Molise_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Bolzano_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Trento_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Piedmont_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sardinia_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sicily_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Trentino Alto Adige_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Tuscany_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Umbria_Deaths_f_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Veneto_Deaths_f_",today(), ".csv"))



for(i in seq_along(url)){
  download.file(url[i], destinations3[i], mode="wb")
}



##deaths male
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "deceased_male")) %>% 
  separate(url, c("trash", "url"), sep = "blob/") %>% 
  mutate(url = paste0("https://raw.githubusercontent.com/InPhyT/COVID19-Italy-Integrated-Surveillance-Data/", url)) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

destinations4 <- c(paste0(dir_n, "Data_sources/", ctr, "/Abruzzo_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Aosta Valley_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Apulia_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Basilicata_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Calabria_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Campania_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Emilia_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Friuli_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lazio_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Liguria_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Lombardy_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Marches_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Molise_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Bolzano_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Pa Trento_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Piedmont_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sardinia_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Sicily_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Trentino Alto Adige_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Tuscany_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Umbria_Deaths_m_",today(), ".csv"),
                  paste0(dir_n, "Data_sources/", ctr, "/Veneto_Deaths_m_",today(), ".csv"))



for(i in seq_along(url)){
  download.file(url[i], destinations4[i], mode="wb")
}



######reading data in
##female cases
all_paths <-
  list.files(path = paste0(dir_n, "Data_sources/Italy_reg"),
             pattern = "Cases_f",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_csv)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

cases_female <- rbindlist(all_lists, fill = T) 

cases_female <- melt(cases_female, id=c("date", "V1"))
names(cases_female)[1] <- "Date"
names(cases_female)[3] <- "Age"
names(cases_female)[4] <- "Value"

cases_female_out <- cases_female %>% 
  separate(V1, c("Region", "Measure", "Sex"), sep = "_")

##male cases
all_paths <-
  list.files(path = paste0(dir_n, "Data_sources/Italy_reg"),
             pattern = "Cases_m",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_csv)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

cases_male <- rbindlist(all_lists, fill = T) 

cases_male <- melt(cases_male, id=c("date", "V1"))
names(cases_male)[1] <- "Date"
names(cases_male)[3] <- "Age"
names(cases_male)[4] <- "Value"

cases_male_out <- cases_male %>% 
  separate(V1, c("Region", "Measure", "Sex"), sep = "_")

##female death
all_paths <-
  list.files(path = paste0(dir_n, "Data_sources/Italy_reg"),
             pattern = "Deaths_f",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_csv)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

deaths_female <- rbindlist(all_lists, fill = T) 

deaths_female <- melt(deaths_female, id=c("date", "V1"))
names(deaths_female)[1] <- "Date"
names(deaths_female)[3] <- "Age"
names(deaths_female)[4] <- "Value"

deaths_female_out <- deaths_female %>% 
  separate(V1, c("Region", "Measure", "Sex"), sep = "_")


##male death
all_paths <-
  list.files(path = paste0(dir_n, "Data_sources/Italy_reg"),
             pattern = "Deaths_m",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_csv)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

deaths_male <- rbindlist(all_lists, fill = T) 

deaths_male <- melt(deaths_male, id=c("date", "V1"))
names(deaths_male)[1] <- "Date"
names(deaths_male)[3] <- "Age"
names(deaths_male)[4] <- "Value"

deaths_male_out <- deaths_male %>% 
  separate(V1, c("Region", "Measure", "Sex"), sep = "_")
  
out <- rbind(cases_female_out, cases_male_out, deaths_female_out, deaths_male_out) %>% 
  arrange(Date, Measure, Sex, Age) %>% 
  group_by(Measure,Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
    mutate (Country = "Italy",
          Age = case_when(
            Age == "0_9" ~ "0",
            Age == "10_19" ~ "10",
            Age == "20_29" ~ "20",
            Age == "30_39" ~ "30",
            Age == "40_49" ~ "40",
            Age == "50_59" ~ "50",
            Age == "60_69" ~ "60",
            Age == "70_79" ~ "70",
            Age == "80_89" ~ "80",
            Age == "90_+" ~ "90"
          ),
          AgeInt = case_when(
            Age == "90" ~ 15L,
            TRUE ~ 10L
          ),
          Metric = "Count",
        Code = case_when(
          Region == "Abruzzo" ~ "IT-65",     
          Region == "Aosta Valley" ~ "IT-23",              
          Region == "Apulia" ~ "IT-75",          
          Region == "Basilicata" ~ "IT-77",            
          Region == "Calabria" ~ "IT-78",            
          Region == "Campania" ~ "IT-72",              
          Region == "Emilia" ~ "IT-45",              
          Region == "Friuli" ~ "IT-36", 
          Region == "Lazio" ~ "IT-62",             
          Region == "Liguria" ~ "IT-42",            
          Region == "Lombardy" ~ "IT-25",             
          Region == "Marches" ~ "IT-57",              
          Region == "Molise" ~ "IT-67",          
          Region == "Pa Bolzano" ~ "IT-BZ",           
          Region == "Pa Trento" ~ "IT-TN",            
          Region == "Piedmont" ~ "IT-21", 
          Region == "Sardinia" ~ "IT-88",              
          Region == "Sicily" ~ "IT-82", 
          Region == "Trentino Alto Adige" ~ "IT-32",             
          Region == "Tuscany" ~ "IT-52",              
          Region == "Umbria" ~ "IT-55",              
          Region == "Veneto" ~ "IT-34" 
        )) %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),
                      sprintf("%02d",month(Date)),
                      year(Date),
                      sep=".")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source <- rbind(destinations1, destinations2, destinations3, destinations4)


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











