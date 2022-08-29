#Isle of Man

library(here)
source(here("Automation/00_Functions_automation.R"))


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address

ctr          <- "Isle_of_Man" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#https://covid19.gov.im/about-coronavirus/open-data-downloads/

#Cases
#load input data 

In_cases= read.csv("https://covid19.gov.im/media/1466/age-gender-travelhistory-data.csv")

#reshape wide to long


Cases_out= In_cases%>%
  select(- gender.male, -gender.female, -travelhistory.no, -travelhistory.yes, Date=date) %>% 
  pivot_longer(!Date, names_to= "Age", values_to= "Value")%>%
  mutate(
    Age = case_when(
      is.na(Age) ~ "UNK",
      TRUE~ as.character(Age))) %>%
  mutate(Age=recode(Age, 
                    `age.from0to19`="0",
                    `age.from20to34`="20",
                    `age.from35to49`="35",
                    `age.from50to64`="50",
                    `age.from65to79`="65",
                    `age.over80`="80",
                    `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 20L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 15L))%>% 
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))



#Totals by sex 

In_cases_sex <- In_cases %>%
  select(gender.male, gender.female, Date=date) %>% 
  melt( id.vars = c("Date"),
        variable.name = "Sex",
        value.name = "Value")

Cases_out_sex= In_cases_sex%>%
  mutate(Sex = case_when(
    is.na(Sex)~ "UNK",
    Sex == "gender.male" ~ "m",
    Sex == "gender.female" ~ "f",
    Sex== "Unknown" ~ "UNK"))%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Age= "TOT", 
    AgeInt= "") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))


###Totals for Cases, Tests, Deaths 

In_total= read.csv("https://covid19.gov.im/media/1463/covid-test-data.csv")

#cases
cases_total= In_total %>%
  select(Date=date, Value=cases)%>%
mutate(
    Measure = "Cases",
    Metric = "Count",
    Age= "TOT", 
    Sex= "b",
    AgeInt= "") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))


#death
death_total= In_total %>%
  select(Date=date, Value=deaths.total)%>%
  mutate(
    Measure = "Deaths",
    Metric = "Count",
    Age= "TOT", 
    Sex= "b",
    AgeInt= "") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))

#tests
test_total= In_total %>%
  select(Date=date, Value=concludedtests)%>%
  mutate(
    Measure = "Tests",
    Metric = "Count",
    Age= "TOT", 
    Sex= "b",
    AgeInt= "") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))


#Vaccine 

url_vaccine <- "https://covid19.gov.im/about-coronavirus/open-data-downloads/"

links <- scraplinks(url_vaccine) %>% 
  filter(str_detect(url, "vaccination")) %>% 
  select(url) 

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

url_d = paste0("https://covid19.gov.im",url)

data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

#specify encoding
download.file(url_d, data_source3)

#Date vaccine 
#specify encoding
In_vaccine <- read_csv(data_source3, sep=",")
                       
#lapply(read.csv, fileEncoding="UCS-2LE", header = FALSE, sep = "\t")




#process vaccine data 
Out_vaccine = In_vaccine %>%
  filter(!str_detect(Date, 'Total'))%>%
  select(Date, Age= Age.Bands, Value= Vaccinated.sum, Measure= Dose.schedule) %>%
  mutate(
    Age = case_when(
      is.na(Age) ~ "UNK",
      TRUE~ as.character(Age))) %>%
  mutate(Age=recode(Age, 
                    `17-49 years`="17",
                    `50-64 years`="50",
                    `65-79 years`="65",
                    `80+ years`="80",
                    `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "17" ~ 33L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 15L))%>% 
  mutate(Measure= recode(Measure,
                         `First dose` ="Vaccination1",
                         `Second dose`= "Vaccination2"))%>%
  mutate(Measure = case_when(
      is.na(Measure) ~ "Vaccinations",
      TRUE~ as.character(Measure))) %>%
  mutate(Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = dmy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("IM"),
    Country = "Isle of Man",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))



#########put dataframes together#####

out <- bind_rows(Cases_out,
                Cases_out_sex,
                cases_total,
                death_total,
                test_total,
                Out_vaccine)

#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_sex_",today(), ".csv")
data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/totals_",today(), ".csv")



write_csv(In_cases, data_source1)
write_csv(In_total, data_source2)

data_source <- c(data_source1, data_source2,data_source3)

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




