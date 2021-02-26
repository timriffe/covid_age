source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
# This is just to get the Croatia script started.
# install.packages("rjson")
library(rjson)
library(tidyverse)
IN_json <- fromJSON(file="https://www.koronavirus.hr/json/?action=po_osobama")

Regions <- tibble(Zupanija = c("Bjelovarsko-bilogorska", "Brodsko-posavska"      ,
"Dubrovačko-neretvanska", "Grad Zagreb"           ,
"Istarska"              , "Karlovačka"            ,
"Koprivničko-križevačka", "Krapinsko-zagorska"    ,
"Ličko-senjska"         , "Međimurska"            ,
 "Osječko-baranjska"    ,  "Požeško-slavonska"     ,
 "Primorsko-goranska"   ,  "Šibensko-kninska"      ,
 "Sisačko-moslavačka"   ,  "Splitsko-dalmatinska"  ,
 "Varaždinska"          ,  "Virovitičko-podravska" ,
 "Vukovarsko-srijemska" ,  "Zadarska"              ,
 "Zagrebačka " ), 
Region = c("Bjelovarsko-bilogorska", 
           "Brodsko-posavska" ,
"Dubrovacko-neretvanska", "Grad Zagreb" ,
"Istarska" , "Karlovacka" ,
"Koprivnicko-krizevacka", "Krapinsko-zagorska" ,
"Licko-senjska" , "Medimurska" ,
"Osjecko-baranjska" , "Pozesko-slavonska" ,
"Primorsko-goranska","Sibensko-kninska" ,
"Sisacko-moslavacka","Splitsko-dalmatinska"  ,
"Varazdinska", "Viroviticko-podravska" ,
"Vukovarsko-srijemska" , "Zadarska" ,
"Zagrebacka" ),
RegionCode = c("_07_","_12_","_19_","_21_","_18_","_04_","_06_","_02_",
               "_09_","_20_","_14_","_11_","_08_","_15_","_03_","_17_",
               "_05_","_10_","_16_","_13_","_01_")) 

IN <- bind_rows(IN_json) 

IN2 <-
  IN %>% 
  left_join(Regions, by = "Zupanija") %>% 
  select(Sex = spol, dob, Date = Datum, Region) %>%  # Regions = Counties
  mutate( Date = lubridate::ymd(Date),
          Age = round(lubridate::decimal_date(Date) - (dob+.5)),
          Age = ifelse(Age > 100,100,Age),
          Age = as.integer(Age)) %>% 
  group_by(Sex, dob, Date, Region, Age) %>% 
  summarize(new = n(),.groups = "drop") %>% 
  mutate(Sex = ifelse(Sex == "M", "m", "f"))
date_range <- IN2$Date %>% range()
dates_all  <- seq(date_range[1], date_range[2], by = "days")

ages_all <- 0:100 %>% as.integer()

out1 <-
  IN2 %>% 
  tidyr::complete(Region, Date = dates_all, Sex, Age = ages_all, fill = list(new = 0))

out_all <-
  out1 %>% 
  group_by(Date, Sex, Age) %>% 
  summarize(new = sum(new),.groups = "drop") %>% 
  mutate(Region = "All",
         AgeInt = ifelse(Age == 100L, 5L, 1L))
out_abr <-
  out1 %>% 
  mutate(Age = DemoTools::calcAgeAbr(Age)) %>% 
  group_by(Region, Date, Sex, Age) %>% 
  summarize(new = sum(new), .groups = "drop") %>% 
  mutate(AgeInt = case_when(Age == 0 ~ 1L,
                            Age == 1 ~ 4L,
                            TRUE ~ 5L))
RegionCodes <- Regions %>% select(-Zupanija)

out <-
  bind_rows(out_all, out_abr) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Country = "Croatia",
         Measure = "Cases",
         Metric = "Count",
         Date = ddmmyyyy(Date)) %>% 
  left_join(RegionCodes, by = "Region") %>% 
  mutate(RegionCode = ifelse(is.na(RegionCode), "", RegionCode),
         Code = paste0("HR", RegionCode, Date)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  group_by(Region, Sex, Age, Date) %>% 
  mutate(n = sum(Value)) %>% 
  ungroup() %>% 
  filter(n > 0) %>% 
  select(-n)
