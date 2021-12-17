library(here)
source(here("Automation/00_Functions_automation.R"))

if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}


# info country and N drive address
ctr <- "Chile_vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "CL")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)


#not use this anymore after Rafael sent new script
# obtaining cases and deaths data from Drive
#db_drive <- 
  #get_country_inputDB("CL") %>% 
 # select(-Short)



#Vaccination 1

vacc1 <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_1eraDosis_std.csv")

#Vaccination 2

vacc2 <- read_csv ("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_2daDosis_std.csv")

#Vaccination 

vacctot <- read_csv ("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_total_std.csv")

#process data
#vaccination 1 


out1 <- vacc1 %>%
  select(Age=Edad, Date= Fecha, Vaccination1= `Primera Dosis`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  #age goes up to 221, but after 104 values are almost 0, remove ages above 105 
  subset(Age < 106)%>%
  subset(Value != "NA")%>%
  tidyr::complete(Date, Age, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= "1",
    Measure = "Vaccination1") %>% 
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
    mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("CL_All",Date),
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))%>% 
  mutate(AgeInt = as.character(AgeInt))


#Vaccination 2 

out2 <- vacc2 %>%
  select(Age=Edad, Date= Fecha, Vaccination2= `Segunda Dosis`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA")%>%# data for vaccine1 and 2 cover same time span, remove Na, 
  #especially during first 6 weeks when people where not to able to get second vaccine yet
  #age goes up to 221, but after 104 values are 0, remove ages above 105 
  subset(Age < 106)%>%
  tidyr::complete(Date, Age, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= "1",
    Measure = "Vaccination2")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("CL_All",Date),
    Country = "Chile",
    Region = "All",)%>% 
select(Country, Region, Code, Date, Sex, 
Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))%>% 
  mutate(AgeInt = as.character(AgeInt))


#Vaccinations 

outtot <- vacctot %>%
  select(Age=Edad, Date= Fecha, Vaccinations= `Total vacunados`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA")%>%# data for vaccine1 and 2 cover same time span, remove Na, 
  #especially during first 6 weeks when people where not to able to get second vaccine yet
  #age goes up to 221, but after 104 values are 0, remove ages above 105 
  subset(Age < 106)%>%
  tidyr::complete(Date, Age, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= "1",
    Measure = "Vaccinations")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("CL_All",Date),
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))%>% 
  mutate(AgeInt = as.character(AgeInt))


#put together 

out <- rbind(out1, out2, outtot)

#converting to character, because combining did not work otherwise 
#db_drive <- db_drive %>% 
 # mutate(AgeInt = as.character(AgeInt))

#out <- db_drive %>% 
  #filter(!Measure %in% c("Vaccination1", "Vaccination2","Vaccinations")) %>% 
  #bind_rows(vaccine) %>% 
  #sort_input_data()


################################
#### Saving data in N drive ####
################################
write_rds(out, paste0(dir_n, ctr, ".rds"))
# This command append new rows at the end of the sheet
log_update(pp = "Chile_vaccine", N = nrow(out))


############################################
#### uploading metadata to N Drive ####
############################################

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine1_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine2_age_",today(), ".csv")
data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccines_age_",today(), ".csv")

write_csv(vacc1, data_source_1)
write_csv(vacc2, data_source_2)
write_csv(vacctot, data_source_3)


data_source <- c(data_source_1, data_source_2,data_source_3 )

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
