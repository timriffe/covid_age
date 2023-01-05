
source(here::here("Automation/00_Functions_automation.R"))

if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}


# info country and N drive address
ctr <- "Chile_vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#not use this anymore after Rafael sent new script
# obtaining cases and deaths data from Drive
#db_drive <- 
  #get_country_inputDB("CL") %>% 
 # select(-Short)


## Source: https://github.com/MinCiencia/Datos-COVID19/tree/master/output/producto78

#Vaccination 1

vacc1 <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_1eraDosis_std.csv")

#Vaccination 2

vacc2 <- read_csv ("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_2daDosis_std.csv")

#Vaccination 3

vacc3 <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_Refuerzo_std.csv")


#Vaccination 4

vacc4 <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_Cuarta_std.csv")


#Vaccination 

vacctot <- read_csv ("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto78/vacunados_edad_fecha_total_std.csv")

#process data
#vaccination 1 
all_ages <- 0:105 #

out1 <- vacc1 %>%
  select(Age=Edad, Date= Fecha, Vaccination1= `Primera Dosis`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  #age goes up to 221, but after 104 values are almost 0, remove ages above 105 
  dplyr::filter(Age < 106,
                Value != "NA")%>%
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= 1L,
    Measure = "Vaccination1") %>% 
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
    mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "CL",
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))


#Vaccination 2 

out2 <- vacc2 %>%
  select(Age=Edad, Date= Fecha, Vaccination2= `Segunda Dosis`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA")%>%# data for vaccine1 and 2 cover same time span, remove Na, 
  #especially during first 6 weeks when people where not to able to get second vaccine yet
  #age goes up to 221, but after 104 values are 0, remove ages above 105 
  subset(Age < 106)%>%
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= 1L,
    Measure = "Vaccination2")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "CL",
    Country = "Chile",
    Region = "All",)%>% 
select(Country, Region, Code, Date, Sex, 
Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))


#Vaccination 3 

out3 <- vacc3 %>%
  select(Age=Edad, Date= Fecha, Vaccination3= `Dosis Refuerzo`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA") %>%
  subset(Age < 106)%>%
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= 1L,
    Measure = "Vaccination3")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "CL",
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))


#Vaccination 4 

out4 <- vacc4 %>%
  select(Age=Edad, Date= Fecha, Vaccination4= `Cuarta Dosis`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA") %>%  
  subset(Age < 106)%>%
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= 1L,
    Measure = "Vaccination4")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "CL",
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))



#Vaccinations 

outtot <- vacctot %>%
  select(Age=Edad, Date= Fecha, Vaccinations= `Total vacunados`)%>%
  pivot_longer(!Age & !Date, names_to= "Measure", values_to= "Value")%>%
  subset(Value != "NA")%>%# data for vaccine1 and 2 cover same time span, remove Na, 
  #especially during first 6 weeks when people where not to able to get second vaccine yet
  #age goes up to 221, but after 104 values are 0, remove ages above 105 
  subset(Age < 106)%>%
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  mutate(
    Metric = "Count", 
    Sex= "b",
    AgeInt= 1L,
    Measure = "Vaccinations")  %>%
  arrange(Age, Date) %>%
  group_by(Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = ddmmyyyy(Date),
    Code = "CL",
    Country = "Chile",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Age = as.character(Age))


#put together 

out <- rbind(out1, out2, out3, out4, outtot) %>% 
  sort_input_data()

##adding ages 0 to 9
# small_ages<- out %>% 
#   filter(Age == "10") %>% 
#   mutate(Age = "0",
#          AgeInt = 2L,   # TR: AgeInt = 2 was off, and some ages missing
#          Value = "0")
# out <- rbind(out, small_ages) %>% 
#   sort_input_data()
#out <- sort_input_data(out)

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
data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine3_age_",today(), ".csv")
data_source_4 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine4_age_",today(), ".csv")
data_source_5 <- paste0(dir_n, "Data_sources/", ctr, "/vaccines_age_",today(), ".csv")

write_csv(vacc1, data_source_1)
write_csv(vacc2, data_source_2)
write_csv(vacc3, data_source_3)
write_csv(vacc4, data_source_4)
write_csv(vacctot, data_source_5)


data_source <- c(data_source_1, data_source_2,data_source_3, data_source_4, data_source_5)

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
