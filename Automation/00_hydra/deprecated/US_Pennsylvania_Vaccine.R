#Pennsylvenia Vaccine 
library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "US_Pennsylvania_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



# reading in archive data  

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Value = as.numeric(Value)) 

last_date_archive <- DataArchive %>% 
  mutate(date_max = dmy(Date)) %>% 
  dplyr::pull(date_max) %>% 
  max()


#read date from website 

### source
m_url <- "https://data.pa.gov/browse?q=covid%20vaccine&sortBy=relevance"

# reading date of last update
html      <- read_html(m_url)

date_text <-
  html_nodes(html, xpath = '/html/body/div[2]/div/div[6]/div/div[4]/div[2]/div[2]/div[3]/div/div[4]/div[1]/div[2]') %>%
  html_text()

date_f  <- str_sub(date_text) %>% 
  str_trim() %>% 
  str_replace("\\.", "") %>% 
  mdy()


if (date_f > last_date_archive){

#read in data 
#vaccine age 
Vaccine_age= read.csv("https://data.pa.gov/api/views/xy2e-dqvt/rows.csv?accessType=DOWNLOAD")

#vaccine sex
Vaccine_sex=read.csv("https://data.pa.gov/api/views/id8t-dnk6/rows.csv?accessType=DOWNLOAD") 

#Process
#Age 


Out_vaccine_age= Vaccine_age %>%
  select(Age= Age.Group, Partially.Covered,Fully.Covered,
         #First Booster Doses (Administered Since August 13, 2021)
         # Second Booster Doses (Administered Since March 29, 2022)
         Additional.Dose.1, Additional.Dose.2, Bivalent.Booster.1)%>%
  pivot_longer(!Age, names_to= "Measure", values_to= "Value")%>%
  mutate(Measure= recode(Measure, 
                         `Partially.Covered` = "Vaccination1",
                         `Fully.Covered`= "Vaccination2",
                         `Additional.Dose.1` = "Vaccination3", 
                         `Additional.Dose.2` = "Vaccination4", 
                         `Bivalent.Booster.1` = "Vaccination5"))%>%
  mutate(Age=recode(Age, 
                    `0-4` = "0",
                    `5-9` = "5",
                    `10-14`="10",
                    `15-19`="15",
                    `20-24`="20",
                    `25-29`="25",
                    `30-34`="30",
                    `35-39`="35",
                    `40-44`="40",
                    `45-49`="45",
                    `50-54`="50",
                    `55-59`="55",
                    `60-64`="60",
                    `65-69`="65",
                    `70-74`="70",
                    `75-79`="75",
                    `80-84`="80",
                    `85-89`="85",
                    `90-94`="90",
                    `95-99`="95",
                    `100-104`="100",
                    `105+`="105"))%>%
  mutate(AgeInt = case_when(
    Age == "105" ~ 1L,
    TRUE ~ 5L))%>% 
  mutate(Metric = "Count",
         Sex="b") %>%
  mutate(
    Date= date_f,
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-PA"),
    Country = "USA",
    Region = "Pennsylvania",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(AgeInt= as.character(AgeInt))



#Sex

Out_vaccine_sex = Vaccine_sex %>%
  select(Sex= Gender, Partially.Covered,Fully.Covered,
         Additional.Dose.1, Additional.Dose.2, Bivalent.Booster.1)%>%
  pivot_longer(!Sex, names_to= "Measure", values_to= "Value")%>%
  mutate(Measure= recode(Measure, 
                         `Partially.Covered` = "Vaccination1",
                         `Fully.Covered`= "Vaccination2",
                         `Additional.Dose.1` = "Vaccination3", 
                         `Additional.Dose.2` = "Vaccination4", 
                         `Bivalent.Booster.1` = "Vaccination5"),
         Sex= recode(Sex, 
                     `Female`= "f",
                     `Male`= "m",
                     `Unknown`= "UNK"), 
         Metric = "Count",
         Age="TOT",
         Date= date_f,
         Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US-PA"),
         Country = "USA",
         Region = "Pennsylvania",
         AgeInt= NA_character_)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

#put together 

Out <- bind_rows(DataArchive,
                Out_vaccine_age,
                Out_vaccine_sex) %>% 
  sort_input_data()

# ##adding age group 0 to 9
# small_ages <- Out %>% 
#   filter(Age == "10") %>% 
#   mutate(Age = "0",
#          AgeInt = 10L,
#          Value = 0)

# Out <- rbind(Out, small_ages) %>% 
#   sort_input_data()
#save output 

#write_rds(Out, paste0(dir_n, ctr, ".rds"))

#log_update("US_Pennsylvania_Vaccine", N = nrow(Out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",date_f, ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_sex_",date_f, ".csv")

write_csv(Vaccine_age, data_source_1)
write_csv(Vaccine_sex, data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  date_f, 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

} else if (date_f == last_date_archive) {
  log_update(pp = ctr, N = 0)
}

