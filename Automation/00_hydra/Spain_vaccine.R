#Spain vaccine 

library(here)
source(here("Automation", "00_Functions_automation.R"))
# install.packages("readODS")
library(readODS)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address

ctr <- "Spain_vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"


####################################################################################
#Read data in 

m_url <- "https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/vacunaCovid19.htm"

links <- scraplinks(m_url) %>% 
  filter(str_detect(url, ".ods")) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

url_d = paste0("https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/",url)

#local try 
#data_source <- paste0("U:/COVerAgeDB/Spain/data_vaccine", today(), ".ods")

data_source <- paste0(dir_n, "Data_sources/", ctr, "/Spain_vaccine",today(), ".ods")

download.file(url_d, data_source, mode = "wb")

###########################################################################################
DataArchive <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(AgeInt = as.integer(AgeInt)) 
  # mutate(Region = case_when(
  #   Region == "Totales" ~ "All",
  #   TRUE ~ Region
  # ),
  # Code = case_when(
  #   Region == "Madrid" ~ "ES-M",
  #   Region == "All" ~ "ES",
  #   Region == "Asturias" ~ "ES-O",
  #   Region == "Cantabria" ~ "ES-S",
  #   Region == "La Rioja" ~ "ES-LO"))


# fixing age intervals for 18
# DataArchive <- 
#   DataArchive %>% 
#   mutate(AgeInt = ifelse(Age == "18", 7, AgeInt))


#Read in sheets 

In_vaccine_total= read_ods(data_source, sheet = 1)
In_vaccine1_age= read_ods(data_source, sheet = 3)
In_vaccine2_age= read_ods(data_source, sheet = 4)
In_vaccine3_age= read_ods(data_source, sheet = 5, range = "A2:K24")

################################
#Process 
#Total 

colnames(In_vaccine_total)[1] <- "Region" 
names(In_vaccine_total)[10] <- "one" 
names(In_vaccine_total)[11] <- "two" 
names(In_vaccine_total)[12] <- "three" 

total <-
  In_vaccine_total %>%
  select(Vaccinations= `Dosis administradas (2)`, 
         Date= `Fecha de la última vacuna registrada (2)`, 
         Region, 
         Vaccination1 = `one`, 
         Vaccination2 = `two`,
         Vaccination3 = `three`) %>%
  pivot_longer(c(Vaccinations,Vaccination1, Vaccination2,Vaccination3), names_to= "Measure", values_to= "Value") %>% 
  mutate(Date = suppressWarnings(dmy(Date)),
         MD = max(Date, na.rm = TRUE),
         Date = coalesce(Date, MD)) %>% 
  select(-MD) %>%
  dplyr::filter(!Region %in% c("Fuerzas Armadas","Sanidad Exterior" )) %>%# delete armed forces from region  
  mutate(Short = recode(Region,
                        "Andalucía" = "AN",
                        "Aragón" = "AR",
                        "Asturias"= "AS", 
                        "Baleares" ="IB",
                        "Canarias" ="CN",
                        "Cantabria"= "CB",
                        "Castilla y Leon"= "CL",
                        "Castilla La Mancha"= "CM",
                        "Cataluña" ="CT",
                        "C. Valenciana" ="VC",
                        "Extremadura"= "EX",
                        "Galicia"= "GA",
                        "La Rioja" ="RI",
                        "Madrid"= "M",
                        "Murcia"= "MU",
                        "Navarra"= "NA",
                        "País Vasco" ="PV",
                        "Ceuta"= "CE",
                        "Melilla" ="ML",
                        "Totales"= "All"), 
         Region = case_when(
           Region == "Totales" ~ "All",
           TRUE ~ Region
         ),
         Metric= "Count",
         Sex = "b",
         Age = "TOT", 
         AgeInt = NA_integer_, 
         Date = ddmmyyyy(Date),
         Country = "Spain")

#Vaccination1 
MD <- total$Date %>% dmy() %>% max() %>% ddmmyyyy()

colnames(In_vaccine1_age)[1] <- "Region" 

Out_vaccine1_age = In_vaccine1_age%>%
  select(Region, 
         `80`= `Personas con al menos 1 dosis ≥80 años` ,
         `70`= `Personas con al menos 1 dosis 70-79 años`, 
         `60`= `Personas con al menos 1 dosis 60-69 años`,
         `50`= `Personas con al menos 1 dosis 50-59 años`, 
         `40`= `Personas con al menos 1 dosis 40-49 años`, 
         `30`=`Personas con al menos 1 dosis 30-39 años`,
         `20`=`Personas con al menos 1 dosis 20-29 años`,
         `12`=`Personas con al menos 1 dosis 12-19 años`) %>%
  pivot_longer(!Region, names_to= "Age", values_to= "Value") %>%
  mutate(AgeInt= case_when(
    Age == "80" ~ 25L,
    Age == "12" ~ 8L,
    TRUE ~ 10L)) %>%
  dplyr::filter(!Region %in% c("Fuerzas Armadas","Sanidad Exterior" )) %>%# delete armed forces from region  
  mutate(Region = recode(Region,
                         "Totales" = "All",
                         "Total España"= "All",
                         "Castilla - La Mancha"= "Castilla La Mancha"),
         Short = recode(Region,
                        "Andalucía" = "AN",
                        "Aragón" = "AR",
                        "Asturias"= "AS", 
                        "Baleares" ="IB",
                        "Canarias" ="CN",
                        "Cantabria"= "CB",
                        "Castilla y Leon"= "CL",
                        "Castilla La Mancha"= "CM",
                        "Cataluña" ="CT",
                        "C. Valenciana" ="VC",
                        "Extremadura"= "EX",
                        "Galicia"= "GA",
                        "La Rioja" ="RI",
                        "Madrid"= "M",
                        "Murcia"= "MU",
                        "Navarra"= "NA",
                        "País Vasco" ="PV",
                        "Ceuta"= "CE",
                        "Melilla" ="ML",
                        "All"= "All"),
         Measure = "Vaccination1",
         Metric = "Count",
         Sex = "b",
         Date = MD,
         Country = "Spain") 



#Vaccination2

colnames(In_vaccine2_age)[1] <- "Region" 

Out_vaccine2_age= In_vaccine2_age %>%
  select(Region, `80`= `Personas pauta completa ≥80 años` , 
         `70`= `Personas pauta completa 70-79 años`, 
         `60`= `Personas pauta completa 60-69 años`,
         `50`= `Personas pauta completa 50-59 años`, 
         `40`= `Personas pauta completa 40-49 años`, 
         `30`= `Personas pauta completa 30-39 años`,
         `20`= `Personas pauta completa 20-29 años`,
         `12`= `Personas pauta completa 12-19 años`)%>%
  pivot_longer(!Region, names_to= "Age", values_to= "Value") %>%
  mutate(AgeInt= case_when(
    Age == "80" ~ 25L,
    Age == "12" ~ 8L,
    TRUE~ 10L))%>%
  dplyr::filter(!Region %in% c("Fuerzas Armadas","Sanidad Exterior" )) %>%# delete armed forces from region  
  mutate(Region= recode(Region,
                        "Totales" = "All",
                        "Total España"= "All",
                        "Castilla - La Mancha"= "Castilla La Mancha"),
         Short = recode(Region,
                        "Andalucía" = "AN",
                        "Aragón" = "AR",
                        "Asturias"= "O", 
                        "Baleares" ="IB",
                        "Canarias" ="CN",
                        "Cantabria"= "S",
                        "Castilla y Leon"= "CL",
                        "Castilla La Mancha"= "CM",
                        "Cataluña" ="CT",
                        "C. Valenciana" ="VC",
                        "Extremadura"= "EX",
                        "Galicia"= "GA",
                        "La Rioja" ="LO",
                        "Madrid"= "M",
                        "Murcia"= "MU",
                        "Navarra"= "NA",
                        "País Vasco" ="PV",
                        "Ceuta"= "CE",
                        "Melilla" ="ML",
                        "All"= "All"),
         Measure = "Vaccination2",
         Metric = "Count",
         Sex = "b",
         Date = MD,
         Country = "Spain")



# #Vaccination2
# 
# colnames(In_vaccine3_age)[1] <- "Region" 
# 
# Out_vaccine3_age= In_vaccine3_age %>%
#   select(Region, `70`= `% Dosis de recuerdo en > 70 años` , 
#          `70`= `Nº Personas > 70 años con dosis de recuerdo`, 
#          `60`= `Nº Personas > 70 años con dosis de recuerdo`,
#          `50`= `Nº Personas > 70 años con dosis de recuerdo`, 
#          `40`= `Nº Personas > 70 años con dosis de recuerdo`, 
#          `30`= `Nº Personas > 70 años con dosis de recuerdo`,
#          `20`= `Personas pauta completa 20-29 años`,
#          `12`= `Personas pauta completa 12-19 años`)%>%
#   pivot_longer(!Region, names_to= "Age", values_to= "Value") %>%
#   mutate(AgeInt= case_when(
#     Age == "80" ~ 25L,
#     Age == "12" ~ 8L,
#     TRUE~ 10L))%>%
#   dplyr::filter(!Region %in% c("Fuerzas Armadas","Sanidad Exterior" )) %>%# delete armed forces from region  
#   mutate(Region= recode(Region,
#                         "Total España"= "All",
#                         "Castilla - La Mancha"= "Castilla La Mancha"),
#          Short = recode(Region,
#                         "Andalucía" = "AN",
#                         "Aragón" = "AR",
#                         "Asturias"= "AS", 
#                         "Baleares" ="IB",
#                         "Canarias" ="CN",
#                         "Cantabria"= "CB",
#                         "Castilla y Leon"= "CL",
#                         "Castilla La Mancha"= "CM",
#                         "Cataluña" ="CT",
#                         "C. Valenciana" ="VC",
#                         "Extremadura"= "EX",
#                         "Galicia"= "GA",
#                         "La Rioja" ="RI",
#                         "Madrid"= "MD",
#                         "Murcia"= "MU",
#                         "Navarra"= "NA",
#                         "País Vasco" ="PV",
#                         "Ceuta"= "CE",
#                         "Melilla" ="ML",
#                         "All"= "All"),
#          Measure = "Vaccination2",
#          Metric = "Count",
#          Sex = "b",
#          Date = MD,
#          Country = "Spain")



#put together

Out <-
  bind_rows(total, 
            Out_vaccine1_age, 
            Out_vaccine2_age) %>%
  mutate(Code = paste("ES",Short, sep="-"),
         Code = case_when(Region == "All"~"ES",
                          TRUE ~ Code)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

#fix for smaller age groups
small_ages <- Out %>% 
  filter(Age == "12") %>% 
  mutate(AgeInt = case_when(
    Age == "12" ~ 12L
  ),
  Age = "0",
  Value = 0)

Out <- rbind(Out, small_ages) %>% 
  sort_input_data()

#include previous data, think issue with wrong codes was because 
#previous data was appended and after that "Short" was used, 
#which is not included anymore in the data archive
Out_final1 = bind_rows(DataArchive,Out)%>% 
  group_by(Region, Sex, Date, Measure, Metric, Age) %>% 
  mutate(keep = Value == max(Value)) %>% 
  ungroup() %>% 
  dplyr::filter(keep) %>% 
  select(-keep) %>% 
  unique()



#Out_final2= Out_final1 %>%
#subset(Code!= "ES_Datos del 13/05_NA")%>%# delete armed forces from region 
#subset(Code!= "ES_Sanidad Exterior_NA")%>%
#subset(Region!= "*Datos de Comunidad Valenciana pendientes de consolidar")

#save output data 
#write_rds(Out_final1, paste0("U:/COVerAgeDB/Datenquellen/Vaccination/Spain/Spain_Vaccine.rsd"))

write_rds(Out_final1, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Out_final1))

#zip input data
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
####################################################