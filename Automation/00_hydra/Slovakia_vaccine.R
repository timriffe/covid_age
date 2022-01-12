
#Slovakia vaccine 

library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address
ctr          <- "Slovakia_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#read in data 

In=read.csv("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/Vaccination/OpenData_Slovakia_Vaccination_AgeGroup_District.csv", sep = ";")

regions= read.csv("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/Vaccination/OpenData_Slovakia_Vaccination_Regions.csv", sep=";")
#process 

Out= In %>%
  #transform week number to last day of the week
  mutate(Date= lubridate::ymd( "2021-01-03" ) + lubridate::weeks(week))%>%
  mutate(Region= recode(region,"TrenÄ\u008diansky" = "Trencin",
                          "Å½ilinskÃ½"="Zilina",
                          "BratislavskÃ½"="Bratislava",
                          "BanskobystrickÃ½"="Banksa Bystrica",
                          "TrnavskÃ½"="Trnava",
                          "KoÅ¡ickÃ½"="Kosice",
                          "PreÅ¡ovskÃ½"="Presov",
                          "Nitriansky"= "Nitra"),
         Sex= recode(gender, "F"="f",
                          "M"="m",
                          "X"="UNK",
                          "U"="UNK")) %>%
  separate(AgeGroup, c("Age", "Age2"), "-")%>%
  mutate(Age= case_when(Age =="80+" ~ "80",
                     is.na(Age) ~ "UNK",
                     TRUE ~ Age),
         Measure= case_when(
           dose=="1"~ "Vaccination1",
           dose=="2"~ "Vaccination2",
           dose=="3"~ "Vaccination3")) %>% 
        mutate( Measure = case_when(
           (vaccine == "JANSSEN" & dose == "fully") ~ "Vaccination2",
           TRUE ~ Measure)) %>%  
  group_by(Date, Age, Sex, Region,Measure) %>% 
  summarize(Value = sum(doses_administered), .groups="drop")%>% 
  arrange(Sex, Date,Measure, Age, Region) %>%
  ungroup() %>% 
  tidyr::complete(Age, nesting(Sex, Date, Measure, Region), fill=list(Value=0)) %>%  
  group_by(Sex,Measure, Age, Region) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>%
  mutate(Short= case_when(
    Region=="Trencin" ~ "TC",
    Region== "Zilina"~ "ZI",
    Region== "Bratislava"~ "BL",
    Region== "Banksa Bystrica"~ "BC",
    Region== "Trnava"~ "TA",
    Region== "Kosice"~"KI",
    Region== "Presov"~"PV",
    Region=="Nitra"~"NI"),
    AgeInt= case_when(
      Age== "80" ~ 25L,
      Age=="15"~3L,
      Age== "18" ~ 2L,
      TRUE ~ 5L))%>%
  mutate(
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("SK_",Short,Date),
    Country = "Slovakia")%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

##adding ages o to 9
small_ages <- Out %>% 
  filter(Age == "5") %>% 
  mutate(Age = "0",
         AgeInt = 5L,
         Value = "0")

Out <- rbind(Out, small_ages) %>% 
  sort_input_data()

##adding total countrie data
all <- Out %>% 
  mutate(Value = as.numeric(Value)) %>% 
group_by(Date, Country, Age, Measure, AgeInt, Metric, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Region = "All",
         Code = paste0("SK_", Date))

Out <- rbind(Out, all) %>% 
  sort_input_data()

#save output 

write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))


#archive


data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(In, data_source)


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

#sk <- read_rds(paste0(dir_n, ctr, ".rds"))
##test
#test <- Out %>% 
#  group_by(Date, Measure) %>% 
#  summarise(Value = sum(Value)) %>% 
#  mutate(Date = dmy(Date)) %>% 
#  arrange(Date)
 