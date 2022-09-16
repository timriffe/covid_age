#Liechtenstein 

library(here)
source(here("Automation", "00_Functions_automation.R"))

#install.packages("zoo")
library(zoo)
library(openxlsx)


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Liechtenstein" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))




# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "LI")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)


#data download 
#https://www.statistikportal.li/de/uebersichten-indikatoren/schwerpunkt-corona

url <- "https://www.llv.li/files/as/grafik_covid19_alter_geschlecht_wohnort.xlsx"

data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age",today(), ".xlsx")

download.file(url, data_source, mode = "wb")

#Age

age2021= read_excel(data_source, sheet = 1, range = "A38:I48")

age2020= read_excel(data_source, sheet = 4, range = "A35:J45")

#Sex

sex2021=read_excel(data_source, sheet = 2, range = "A35:J38")

sex2020= read_excel(data_source, sheet = 5, range = "A31:J34")


#Process age

#2020

#Tests

colnames(age2020)[1] <- "Age"
colnames(age2020)[6] <- "Oktober"
colnames(age2020)[8] <- "November"
colnames(age2020)[10] <- "Dezember"

out_age2020_tests= age2020 %>%
  pivot_longer(!Age, names_to= "Date", values_to= "Value")%>%
  subset(Age != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Age=recode(Age, 
                    `0 bis 9 Jahre`="0",
                    `10 bis 19 Jahre`="10",
                    `20 bis 29 Jahre`="20",
                    `30 bis 39 Jahre`="30",
                    `40 bis 49 Jahre`="40",
                    `50 bis 59 Jahre`="50",
                    `60 bis 69 Jahre`="60",
                    `70 bis 79 Jahre`="70",
                    `80 Jahre und älter`="80"))%>%
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  group_by(Age, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                    `Januar`="Jan",
                    `Februar`="Feb",
                    `März`="Mar",
                    `April`="Apr",
                    `Mai`="May",
                    `Juni`="Jun",
                    `Juli`="Jul",
                    `August`="Aug",
                    `September`="Sep",
                    `Oktober`="Oct",
                    `November`="Nov",
                    `Dezember`="Dec"))%>%
  mutate(Year= "2020")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>% 
  mutate(
    Measure = "Tests",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

#Cases 2020 

out_age2020_cases= age2020 %>%
select(1, 6,8,10) %>%
  pivot_longer(!Age, names_to= "Date", values_to= "Value")%>%
  subset(Age != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Age=recode(Age, 
                    `0 bis 9 Jahre`="0",
                    `10 bis 19 Jahre`="10",
                    `20 bis 29 Jahre`="20",
                    `30 bis 39 Jahre`="30",
                    `40 bis 49 Jahre`="40",
                    `50 bis 59 Jahre`="50",
                    `60 bis 69 Jahre`="60",
                    `70 bis 79 Jahre`="70",
                    `80 Jahre und älter`="80"))%>%
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  group_by(Age, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2020")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#tests by sex 


colnames(sex2020)[1] <- "Sex"
colnames(sex2020)[6] <- "Oktober"
colnames(sex2020)[8] <- "November"
colnames(sex2020)[10] <- "Dezember"

out_sex_2020_tests= sex2020 %>% 
  pivot_longer(!Sex, names_to= "Date", values_to= "Value")%>%
  subset(Sex != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Sex=recode(Sex, 
                    `Männer`="m",
                    `Frauen`="f")) %>%
  group_by(Sex, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2020")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Tests",
    Metric = "Count",
    AgeInt= "",
    Age= "TOT") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#cases 2020 by sex 

out_sex2020_cases= sex2020 %>% 
  select(1, 6,8,10) %>%
  pivot_longer(!Sex, names_to= "Date", values_to= "Value")%>%
  subset(Sex != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Sex=recode(Sex, 
                    `Männer`="m",
                    `Frauen`="f")) %>%
  group_by(Sex, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2020")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    AgeInt= "",
    Age= "TOT") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#2021

#tests 2021

colnames(age2021)[1] <- "Age"
colnames(age2021)[3] <- "Januar"
colnames(age2021)[6] <- "März"
colnames(age2021)[8] <- "April"


out_age2021_test= age2021%>%
  pivot_longer(!Age, names_to= "Date", values_to= "Value")%>%
  subset(Age != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Age=recode(Age, 
                    `0 bis 9 Jahre`="0",
                    `10 bis 19 Jahre`="10",
                    `20 bis 29 Jahre`="20",
                    `30 bis 39 Jahre`="30",
                    `40 bis 49 Jahre`="40",
                    `50 bis 59 Jahre`="50",
                    `60 bis 69 Jahre`="60",
                    `70 bis 79 Jahre`="70",
                    `80 Jahre und älter`="80"))%>%
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  group_by(Age, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2021")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>% 
  mutate(
    Measure = "Tests",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

#cases 2021


out_age2021_cases= age2021%>%
  select(1, 3,6,8) %>%
  pivot_longer(!Age, names_to= "Date", values_to= "Value")%>%
  subset(Age != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Age=recode(Age, 
                    `0 bis 9 Jahre`="0",
                    `10 bis 19 Jahre`="10",
                    `20 bis 29 Jahre`="20",
                    `30 bis 39 Jahre`="30",
                    `40 bis 49 Jahre`="40",
                    `50 bis 59 Jahre`="50",
                    `60 bis 69 Jahre`="60",
                    `70 bis 79 Jahre`="70",
                    `80 Jahre und älter`="80"))%>%
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  group_by(Age, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2021")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#sex 2021 tests 

colnames(sex2021)[1] <- "Sex"
colnames(sex2021)[3] <- "Januar"
colnames(sex2021)[5] <- "Februar"
colnames(sex2021)[7] <- "März"
colnames(sex2021)[9] <- "April"


out_sex_2021_tests= sex2021 %>% 
  pivot_longer(!Sex, names_to= "Date", values_to= "Value")%>%
  subset(Sex != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Sex=recode(Sex, 
                    `Männer`="m",
                    `Frauen`="f")) %>%
  group_by(Sex, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2021")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Tests",
    Metric = "Count",
    AgeInt= "",
    Age= "TOT") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

#cases by sex 2021 


out_sex2021_cases= sex2021%>%
  select(1, 3,6,8) %>%
  pivot_longer(!Sex, names_to= "Date", values_to= "Value")%>%
  subset(Sex != "NA") %>% 
  mutate(Value = as.numeric(Value))%>%
  mutate(Sex=recode(Sex, 
                    `Männer`="m",
                    `Frauen`="f")) %>%
  group_by(Sex, Date) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup()%>%
  distinct()%>%# reshape month names to last day of month 
  mutate(Date=recode(Date, 
                     `Januar`="Jan",
                     `Februar`="Feb",
                     `März`="Mar",
                     `April`="Apr",
                     `Mai`="May",
                     `Juni`="Jun",
                     `Juli`="Jul",
                     `August`="Aug",
                     `September`="Sep",
                     `Oktober`="Oct",
                     `November`="Nov",
                     `Dezember`="Dec"))%>%
  mutate(Year= "2021")%>%
  mutate(Date=paste(Date, Year, sep = "/"),
         Date= as.yearmon(Date, format = "%b/%Y"),
         Date=as.Date(Date, frac=1))%>%
  arrange(Date)%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    AgeInt= "",
    Age= "TOT") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LI"),
    Country = "Liechtenstein",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#sum together tests by age 2020 and 2021 
#Tests

Test_age= rbind(out_age2020_tests, out_age2021_test)

Out_test_age= Test_age %>%
  group_by (Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()


#Cases

Case_age= rbind(out_age2020_cases,out_age2021_cases)

Out_cases_age= Case_age%>%
  group_by (Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()


#Tests by sex 

Test_sex= rbind(out_sex_2020_tests,out_sex_2021_tests)


Out_tests_sex= Test_sex%>%
  group_by (Sex) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()


#cases by sex 

cases_sex= rbind(out_sex2020_cases, out_sex2021_cases)

out_cases_sex= cases_sex%>%
  group_by (Sex) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()

#put everything together 

out_final= rbind(out_cases_sex,Out_cases_age,Out_test_age, Out_tests_sex)


# upload to Drive, overwrites


write_sheet(out_final, 
            ss = ss_i, 
            sheet = "database")



########archive##############


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














