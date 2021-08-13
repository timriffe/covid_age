#Portugal Vaccine 


library(here)
source(here("Automation", "00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Portugal_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#Read data in 

m_url <- "https://covid19.min-saude.pt/relatorio-de-vacinacao/"


links <- scraplinks(m_url) %>% 
  filter(str_detect(url, ".csv")) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()


data_source <- paste0(dir_n, "Data_sources/", ctr, "/age_vaccine",today(), ".csv")

download.file(url, data_source, mode = "wb")

In= read.csv(data_source, sep = ";")


#Process 

Out <- In %>% 
  subset(TYPE== "AGES" | TYPE== "GENERAL")%>% # there are totals by some regions, but not in iso format, they use some regional health administration  
  select(Date= DATE, Region= REGION, Age= AGEGROUP, Vaccination1= CUMUL_VAC_1, Vaccination2= CUMUL_VAC_2, Vaccinations= CUMUL)%>%
  pivot_longer(!Age & !Date & !Region, names_to= "Measure", values_to= "Value")%>%
  mutate(Age=recode(Age, 
                    `0-17 anos`="0",
                    `18-24 anos`="18",
                    `25-49 anos`="25",
                    `50-64 anos`="50",
                    `65-79 anos`="65", 
                    `80 ou mais anos`="80",
                    `All`="TOT",
                    `Desconhecido`="UNK"))%>%
  mutate(Age = case_when(is.na(Age) ~ "UNK",
                         TRUE~ as.character(Age))) %>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 18L,
    Age == "18" ~ 7L,
    Age == "25" ~ 25L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 15L))%>%
  mutate(
    Metric = "Count", 
    Sex= "b") %>% 
  mutate(
    Date = dmy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("PT_All",Date),
    Country = "Portugal",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

  
#save output data 
write_rds(Out, paste0(dir_n, ctr, ".rds"))

# This command append new rows at the end of the sheet
log_update(pp = ctr, N = nrow(Out))

# now archive

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









