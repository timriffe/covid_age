#Finland vaccine
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(lubridate)


# info country and N drive address
ctr          <- "Finland_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



#read in archived  data 

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Measure = case_when(
    Measure == "Third dose" ~ "Vaccination3",
    Measure == "Fourth dose" ~ "Vaccination4",
    TRUE ~ Measure
  ))

last_date_archive <- DataArchive %>% 
  mutate(date_max = dmy(Date)) %>% 
  dplyr::pull(date_max) %>% 
  max()

#read date last updated from website 
m_url <- "https://sampo.thl.fi/pivot/prod/fi/vaccreg/cov19cov/summary_cov19covagearea"

html      <- read_html(m_url)
date_text <-
  html_nodes(html, xpath = '/html/body/div[2]/div[1]/div[2]/div[2]/div[2]') %>%
  html_text()


date= substr(date_text, 92, 102) %>% 
  dmy()


if (date > last_date_archive){

#read in new data 

links <- scraplinks(m_url) %>% 
  filter(str_detect(url, ".csv")) %>% 
  select(url) %>%
  #link to csv file appears twice in website
  slice(1)

url <- 
  links %>% 
  select(url) %>% 
  dplyr::pull()

url_d = paste0("https://sampo.thl.fi/pivot/prod/en/vaccreg/cov19cov/",url)

data_source <- paste0(dir_n, "Data_sources/", ctr, "/Finland_vaccine",today(), ".csv")

download.file(url_d, data_source, mode = "wb")

In_vaccine= read.csv(data_source, sep = ";")



#process data 

In_vaccine= na.omit(In_vaccine)

Out_vaccine= In_vaccine%>%
  select(Value=val, Measure= Vaccination.dose, Age)%>%
  separate(Age, c("Age", "B"), "-")%>%
  mutate(Age=  recode(Age,
                      `80+`="80"),
         Measure=recode(Measure,
                        `First dose`="Vaccination1",
                        `Second dose`="Vaccination2",
                        `Third dose`="Vaccination3",
                        `Fourth dose`="Vaccination4"),
         Metric = "Count",
         Sex= "b")%>%
  mutate(AgeInt = case_when(
    Age == "5" ~ 7L,
    Age == "12" ~ 6L,
    Age == "18" ~ 7L,
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 5L))%>% 
  mutate(
    Date = date,
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("FI"),
    Country = "Finland",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

small_ages <- Out_vaccine %>% 
  filter(Age == "12") %>% 
  mutate(Age = 0,
         AgeInt = 5L,
         Value = 0)

Out_vaccine <- rbind(Out_vaccine, small_ages) %>% 
  sort_input_data()

#put together


Out= rbind(DataArchive,Out_vaccine) %>% 
  unique()



#save output 

write_rds(Out, paste0(dir_n, ctr, ".rds"))

log_update("Finland_vaccine", N = nrow(Out))

#save input 


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

} else if (date == last_date_archive) {
  log_update(pp = ctr, N = 0)
}






