# Michigan vaccine 


library(here)
source(here("Automation", "00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address

ctr <- "US_Michigan_vaccine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))


library(readxl)

#Read in data 

#m_url <- "https://www.michigan.gov/coronavirus/0,9753,7-406-98178_103214-547150--,00.html"
m_url <- "https://www.michigan.gov/coronavirus/resources/covid-19-vaccine/covid-19-dashboard"

#data until 29.05.2021
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "xlsx"))


links1 <- scraplinks(m_url) %>% 
  filter(str_detect(url, "Vaccine-Doses-Administered-Till-05292021")) %>% 
  select(url) 

url1 <- 
  links1 %>% 
  select(url) %>% 
  dplyr::pull()

url_d1 = paste0("https://www.michigan.gov",url1)

data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_until_05_2021",today(), ".xlsx")

download.file(url_d1, data_source1, mode = "wb")

IN1= read_xlsx(data_source1, sheet = 3)


# data between 30.05.2021 and 27.11.2021
links2 <- scraplinks(m_url) %>% 
  filter(str_detect(url, "Doses-Administered-Between-05302021-And-11272021")) %>% 
  select(url) 


url2 <- 
  links2 %>% 
  select(url) %>% 
  dplyr::pull()

url_d2 = paste0("https://www.michigan.gov",url1)

data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_between_06_2021_and_11_2021",today(), ".xlsx")

download.file(url_d2, data_source2, mode = "wb")

IN2= read_xlsx(data_source2, sheet = 3)


# data since 28.11.2021
links3 <- scraplinks(m_url) %>% 
  filter(str_detect(url, "Vaccine-Doses-Administered-Since-11282021")) %>% 
  select(url) 


url3 <- 
  links3 %>% 
  select(url) %>% 
  dplyr::pull()

url_d3 = paste0("https://www.michigan.gov",url3)

data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_since_11_2021",today(), ".xlsx")

download.file(url_d3, data_source3, mode = "wb")

IN3= read_xlsx(data_source3, sheet = 3)


#put dataframes togehter 

IN= rbind(IN1, IN2, IN3)



#Process 

unique(IN$`Sex`)


Out = IN %>%
  select(Sex, Age= `Age Group`, Measure= `Dose Number`,`Week Ending Date`, Value= `Doses Administered`)%>%
  mutate(Date=as.Date(`Week Ending Date`, "%m/%d/%Y"))%>%
  mutate(Sex = recode(Sex,
                      `F`= "f",
                      `M` = "m",
                      `U` = "UNK"))%>%
  mutate(Age=recode(Age, 
                    `12-15 years`="12",
                    `16-19 years`="16",
                    `20-29 years`="20",
                    `30-39 years`="30",
                    `40-49 years`="40",
                    `50-64 years`="50",
                    `65-74 years`="65",
                    `75+ years`="75",
                    `Missing`="UNK",
                    `missing`="UNK"))%>%
  mutate(AgeInt = case_when(
    Age == "16" ~ 4L,
    Age == "12" ~ 4L,
    Age == "50" ~ 15L,
    Age == "75" ~ 30L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>%
mutate(Measure = recode(Measure,
                    `First Dose`= "Vaccination1",
                    `Second Dose` = "Vaccination2"))%>%
  group_by(Sex, Age, Measure,Date) %>% # Data given by vaccine type and county, sum together 
  mutate(Value = sum(Value)) %>%
  #remove duplicates that where previously specified by vaccine type 
  distinct() %>%
  arrange(Measure,Sex, Age, Date) %>% 
  group_by(Measure,Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-MI"),
    Country = "USA",
    Region = "Michigan",
    Metric= "Count")%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#save output 

write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))

#archive data 


data_source <- c(data_source1, data_source2)

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

















