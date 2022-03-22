

library(here)
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <-"jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Puerto_Rico" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")
data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/tests_age_",today(), ".csv")
data_source4 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")


###death
download.file("https://covid19datos.salud.gov.pr/estadisticas_v2/download/data/defunciones/completo",
              data_source1)

death = read.csv(data_source1)

death2= death %>%
  #remove missing age information 
  select(Sex=CO_SEXO, Age= TX_GRUPO_EDAD, Date= FE_MUERTE)
death2$Date = substr(death2$Date,1,nchar(death2$Date)-9)
death3 <- death2 %>% 
  mutate(Sex= recode(Sex, 
                     `M`= "m",
                     `F`= "f")) %>% 
  group_by(Date,Sex, Age) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths",
    Metric = "Count") %>% 
arrange(Date, Sex, Age) %>% 
  mutate(Date= ddmmyyyy(Date),
         Code = paste0("PR"),
         Age = case_when(Age == "0 a 9" ~ "0",
                         Age == "10 a 19" ~ "10",
                         Age == "20 a 29" ~ "20",
                         Age == "30 a 39" ~ "30",
                         Age == "40 a 49" ~ "40",
                         Age == "50 a 59" ~ "50",
                         Age == "60 a 69" ~ "60",
                         Age == "70 a 79" ~ "70",
                         Age == "80 +" ~ "80"),
         AgeInt = case_when(Age == "80" ~ "25",
                            TRUE ~ "10")) %>% 
  mutate(Region = "All",
         Country = "Puerto Rico",
         Region = "All")

###cases
download.file("https://covid19datos.salud.gov.pr/estadisticas_v2/download/data/casos/completo", 
              data_source2)

cases = read.csv(data_source2)



cases2= cases %>%
  #remove missing age information 
  select(Sex=Sex, Age= Age, Date= Sample.Date)
cases2$Date = substr(cases2$Date,1,nchar(cases2$Date)-9)
cases3 <- cases2 %>% 
  mutate(Sex= recode(Sex, 
                     `M`= "m",
                     `F`= "f",
                    `O` = "UNK")) %>% 
  group_by(Date,Sex, Age) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases",
         Metric = "Count") %>% 
  arrange(Date, Sex, Age) %>% 
  mutate(Date= ddmmyyyy(Date),
         Code = paste0("PR"),
         Age = as.character(Age),
         Age = case_when(is.na(Age) ~ "UNK",
           TRUE ~ Age),
         AgeInt = "1",
         Region = "All",
         Country = "Puerto Rico",
         Region = "All")



###tests
download.file("https://covid19datos.salud.gov.pr/estadisticas_v2/download/data/pruebas/completo",
              data_source3)

tests = read.csv(data_source3)

tests2= tests %>%
  #remove missing age information 
  select(Sex=CO_SEXO, Age= TX_GRUPO_EDAD, Date= FE_PRUEBA)
tests2$Date = substr(tests2$Date,1,nchar(tests2$Date)-9)
tests3 <- tests2 %>% 
  mutate(Sex= recode(Sex, 
                     `M`= "m",
                     `F`= "f",
                     `O` = "UNK",
                     `U` = "UNK")) %>% 
  group_by(Date,Sex, Age) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Measure = "Tests",
         Metric = "Count") %>% 
  arrange(Date, Sex, Age) %>%  
  mutate(Date= ddmmyyyy(Date),
         Code = paste0("PR"),
         Age = case_when(Age == "0 a 9" ~ "0",
                         Age == "10 a 19" ~ "10",
                         Age == "20 a 29" ~ "20",
                         Age == "30 a 39" ~ "30",
                         Age == "40 a 49" ~ "40",
                         Age == "50 a 59" ~ "50",
                         Age == "60 a 69" ~ "60",
                         Age == "70 a 79" ~ "70",
                         Age == "80 +" ~ "80",
                         Age == "" ~ "UNK"),
         AgeInt = case_when(Age == "80" ~ "25",
                            TRUE ~ "10")) %>% 
  mutate(Region = "All",
         Country = "Puerto Rico",
         Region = "All")

###vaccine
download.file("https://covid19datos.salud.gov.pr/estadisticas_v2/download/data/vacunacion/completo", 
              data_source4)

vacc = read.csv(data_source4)

vaccine2= vacc %>%
  #remove missing age information 
  select(Sex=CO_SEXO, Age= TX_GRUPO_EDAD, Date= FE_VACUNA, Dosis = NU_DOSIS, Drug = CO_MANUFACTURERO)
vaccine2$Date = substr(vaccine2$Date,1,nchar(vaccine2$Date)-9)
vaccine3 <- vaccine2 %>% 
 # filter(Drug != "JSN") %>% 
  filter(Dosis != 2) %>% 
  mutate(Sex= case_when(Sex == "M" ~ "m",
                        Sex == "F" ~ "f",
                        Sex == "O" ~ "UNK",
                        Sex == "U" ~ "UNK",
                        Sex == "" ~ "UNK")) %>% 
  group_by(Date,Sex, Age) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Measure = "Vaccination1",
         Metric = "Count") %>% 
  arrange(Date, Sex, Age) %>%  
  mutate(Date= ddmmyyyy(Date),
         Code = paste0("PR"),
         Age = case_when(Age == "12 a 15" ~ "12",
                         Age == "16 a 19" ~ "16",
                         Age == "20 a 29" ~ "20",
                         Age == "30 a 39" ~ "30",
                         Age == "40 a 49" ~ "40",
                         Age == "50 a 59" ~ "50",
                         Age == "60 a 69" ~ "60",
                         Age == "70 a 79" ~ "70",
                         Age == "80 +" ~ "80",
                         Age == "No Definido" ~ "UNK"),
         AgeInt = case_when(Age == "80" ~ "25",
                            Age == "12" ~ "4",
                            Age == "16" ~ "4",
                            TRUE ~ "10")) %>% 
  mutate(Region = "All",
         Country = "Puerto Rico",
         Region = "All")


vaccine4= vacc %>%
  #remove missing age information 
  select(Sex=CO_SEXO, Age= TX_GRUPO_EDAD, Date= FE_VACUNA, Dosis = NU_DOSIS, Drug = CO_MANUFACTURERO)
vaccine4$Date = substr(vaccine4$Date,1,nchar(vaccine4$Date)-9)
vaccine5 <- vaccine4 %>% 
  filter(Drug == "JSN" | Dosis == 2) %>% 
  mutate(Sex= case_when(Sex == "M" ~ "m",
                        Sex == "F" ~ "f",
                        Sex == "O" ~ "UNK",
                        Sex == "U" ~ "UNK",
                        Sex == "" ~ "UNK")) %>% 
  group_by(Date,Sex, Age) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date, nesting(Sex, Age), fill=list(Value=0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  mutate(Measure = "Vaccination2",
         Metric = "Count") %>% 
  arrange(Date, Sex, Age) %>%  
  mutate(Date= ddmmyyyy(Date),
         Code = paste0("PR"),
         Age = case_when(Age == "12 a 15" ~ "12",
                         Age == "16 a 19" ~ "16",
                         Age == "20 a 29" ~ "20",
                         Age == "30 a 39" ~ "30",
                         Age == "40 a 49" ~ "40",
                         Age == "50 a 59" ~ "50",
                         Age == "60 a 69" ~ "60",
                         Age == "70 a 79" ~ "70",
                         Age == "80 +" ~ "80",
                         Age == "No Definido" ~ "UNK"),
         AgeInt = case_when(Age == "80" ~ "25",
                            Age == "12" ~ "4",
                            Age == "16" ~ "4",
                            TRUE ~ "10")) %>% 
  mutate(Region = "All",
         Country = "Puerto Rico",
         Region = "All")


out <- rbind(death3, cases3, tests3, vaccine3, vaccine5)
out <- out %>% 
  sort_input_data()

#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

# write_csv(death, data_source1)
# write_csv(cases, data_source2)
# write_csv(tests, data_source3)
# write_csv(vacc, data_source4)

data_source <- c(data_source1, data_source2, data_source3, data_source4)

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
