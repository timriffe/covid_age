# Michigan vaccine 
library(readxl)
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

#DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))

#Read in data 

#m_url <- "https://www.michigan.gov/coronavirus/0,9753,7-406-98178_103214-547150--,00.html"
#m_url <- "https://www.michigan.gov/coronavirus/resources/covid-19-vaccine/covid-19-dashboard"

#data until 29.05.2021
# links <- scraplinks(m_url) %>% 
#   filter(str_detect(url, "xlsx"))
# 
# 
# links1 <- scraplinks(m_url) %>% 
#   filter(str_detect(url, "20201215-20210529")) %>% 
#   select(url) 
# 
# 
# url1 <- 
#   links1 %>% 
#   select(url) %>% 
#   dplyr::pull()
# 
# url_d1 = paste0("https://www.michigan.gov",url1)
############################

## MK; 25.07.2022: this link stopped working ; will review after a while ## 
## to mitigate: read from the .rds historical, filter less than or equal 29.05.2021 
## add at the end of this script. 

data_rds <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Date <= "2021-05-29") %>% 
  mutate(Age=recode(Age, 
                    `under 5 years` = "0",
                    `5-11 years` = "5"),
         AgeInt = case_when(
           Age == "0" ~ 5L,
           Age == "5" ~ 7L,
           TRUE ~ AgeInt),
         Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."))


# url_d1 <- "https://www.michigan.gov/coronavirus/resources/covid-19-vaccine/-/media/550395D34E9440C79090E6E38A016908.ashx"
# 
# data_source1 <- paste0(dir_n, "Data_sources/", ctr, 
#                        "/vaccine_age_until_05_2021",today(), ".xlsx")
# 
# download.file(url_d1, data_source1, mode = "wb")
# 
# IN1= read_xlsx(data_source1, sheet = 3)
########################

# data between 30.05.2021 and 27.11.2021
# links2 <- scraplinks(m_url) %>% 
#   filter(str_detect(link, "05302021 And 11272021")) %>% 
#   select(url) 
# 
# 
# url2 <- 
#   links2 %>% 
#   select(url) %>% 
#   dplyr::pull()

#url_d2 = paste0("https://www.michigan.gov",url1)

url_d2 <- "https://www.michigan.gov/coronavirus/-/media/Project/Websites/coronavirus/Vaccine-Dashboard/07-20-2022/COVID-Vaccines-Administered-20210530-20211127-updated-20220720.xlsx?rev=debec13a73874084a4735f727a366bb6&hash=0E3A313A6847E342980D15A0F25C7A1D"

data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_between_06_2021_and_11_2021",today(), ".xlsx")

download.file(url_d2, data_source2, mode = "wb")

IN2= read_xlsx(data_source2, sheet = 3)


# data since 28.11.2021
# links3 <- scraplinks(m_url) %>% 
#   filter(str_detect(url, "20211128")) %>% 
#   select(url) 
# 
# 
# url3 <- 
#   links3 %>% 
#   select(url) %>% 
#   dplyr::pull()
# 
# url_d3 = paste0("https://www.michigan.gov",url3)

url_d3 <- "https://www.michigan.gov/coronavirus/-/media/Project/Websites/coronavirus/Vaccine-Dashboard/07-20-2022/COVID-Vaccines-Administered-20211128-updated-20220720.xlsx?rev=c7e71a4d21c644e5a8e5ff932c7386fb&hash=C436C447A6F5807347861AE3E33532B6"

data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_since_11_2021",today(), ".xlsx")

download.file(url_d3, data_source3, mode = "wb")

IN3= read_xlsx(data_source3, sheet = 3)


#put dataframes togehter 

IN= rbind(
         #IN1, 
          IN2, IN3)



#Process 

unique(IN$`Sex`)


Out_1 = IN %>%
  select(Sex, Age= `Age Group`, 
         Measure= `Dose Number`,
         `Week Ending Date`, Value= `Doses Administered`)%>%
  mutate(Date=as.Date(`Week Ending Date`, "%m/%d/%Y"))%>%
  mutate(Sex = recode(Sex,
                      `F`= "f",
                      `M` = "m",
                      `U` = "UNK"))%>%
  mutate(Age=recode(Age, 
                    `under 5 years` = "0",
                    `5-11 years` = "5",
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
    Age == "0" ~ 5L,
    Age == "5" ~ 7L,
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
  ungroup() %>% 
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


Out <- bind_rows(data_rds, Out_1)


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

















