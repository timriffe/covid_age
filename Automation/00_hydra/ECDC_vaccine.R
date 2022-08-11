library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
library(ISOweek)


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address
ctr          <- "ECDC_vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#Read in data 

In= read.csv("https://opendata.ecdc.europa.eu/covid19/vaccine_tracker/csv/data.csv")

#process

Out= In %>%
  #select countries we need 
  subset(Region== "BG"| Region== "CY" | Region== "HR"| Region== "HU"|  Region== "IE"| 
          Region== "LU" | Region== "MT" | Region== "RO"| Region== "PL" | Region == "EL" | 
           Region == "PT" | Region == "NO")%>%
  select(YearWeekISO, 
         Vaccination1= FirstDose, 
         Vaccination2= SecondDose, 
         Vaccination3= DoseAdditional1, 
         Vaccination4 = DoseAdditional2, 
         Vaccinations = UnknownDose,
         Short=Region,TargetGroup)%>%
  #remove category medical personnel and long term care residents 
  subset(TargetGroup != "HCW") %>%
  subset(TargetGroup != "LTCF")%>%
  #remove age groups that only separate above and below 60
  subset(TargetGroup != "1_Age60+") %>%
  subset(TargetGroup != "1_Age<60")%>%
  subset(TargetGroup != "Age<18")%>%
  pivot_longer(!YearWeekISO & !Short & !TargetGroup, names_to= "Measure", values_to= "Value")%>%
  #data was given separate by vaccine brand, sum those together 
  group_by(YearWeekISO, Short,TargetGroup, Measure) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>% 
  distinct()%>%
  #accumulate data 
  arrange(YearWeekISO, Short,TargetGroup, Measure) %>% 
  group_by(Short,TargetGroup, Measure) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  mutate(Day= "7")%>%
  unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE)%>%
  mutate(Date= ISOweek::ISOweek2date(ISODate))%>%
  mutate(Age= recode(TargetGroup, 
                     `ALL`= "TOT",
                     `Age0_4`= "0",
                     `Age5_9`= "5",
                     `Age10_14`= "10",
                     `Age15_17`= "15",
                     `Age18_24`= "18",
                     `Age25_49`="25",
                     `Age50_59`="50",
                     `Age60_69`="60",
                     `Age70_79`="70",
                     `Age80+`="80",
                     `AgeUNK`="UNK"))%>% 
    mutate(Country= recode(Short, 
                     `BG`= "Bulgaria",
                     `CY`= "Cyprus",
                     `HR`= "Croatia",
                     `HU`= "Hungary",
                     `IE`= "Ireland",
                     `LU`= "Luxembourg",
                     `MT`="Malta",
                     `PL`="Poland",
                     `RO`="Romania",
                     `EL`="Greece",
                     `PT`="Portugal",
                     `NO`="Norway")) %>% 
  mutate(
    Metric = "Count",
    Sex= "b",
    Region="All")%>%
  tidyr::complete(Age, nesting(Date, Measure, Country, Metric, Sex, Region), fill=list(Value=0)) %>%  
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = case_when( 
      Country == "Bulgaria" ~  paste0("BG"),
      Country == "Croatia" ~  paste0("HR"),
      Country == "Cyprus" ~  paste0("CY"),
      Country == "Hungary" ~  paste0("HU"),
      Country == "Ireland" ~  paste0("IE"),
      Country == "Luxembourg" ~  paste0("LU"),
      Country == "Malta" ~  paste0("MT"),
      Country == "Poland" ~  paste0("PL"),
      Country == "Romania" ~  paste0("RO"),
      Country == "Greece" ~ "GR",
      Country == "Portugal" ~ "PT",
      Country == "Norway" ~ "NO"))%>% 
  mutate(AgeInt = case_when(
    Age == "15" ~ 3L,
    Age == "18" ~ 7L,
    Age == "25" ~ 25L,
    Age == "15" ~ 3L,
    Age == "50" ~ 10L,
    Age == "60" ~ 10L,
    Age == "70" ~ 10L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    Age == "TOT" ~ NA_integer_,
    TRUE ~ 5L))%>%
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

####we only need third vaccination for norway
Out <- Out %>% 
  filter(Country != "Norway" | Measure != "Vaccination1") %>% 
  filter(Country != "Norway" | Measure != "Vaccination2")



#save output data 
write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))

#zip input data

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





