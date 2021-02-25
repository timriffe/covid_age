
library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}


# info country and N drive address

ctr          <- "Hungary" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


#Downloading deaths from the website 

pg <- xml2::read_html("https://koronavirus.gov.hu/elhunytak")

# How many pages do we have?
lastpg <- strsplit(rvest::html_attr(rvest::html_node(pg, xpath = "//li[@class='pager-last']/a"), "href"), "=")[[1]][2]

# iterate over pages, rbind individual results
res <- do.call(rbind, lapply(0:lastpg, function(i)
  rvest::html_table(xml2::read_html(paste0("https://koronavirus.gov.hu/elhunytak?page=", i)))[[1]]))


names(res) <- c("ID", "Sex", "Age", "Comorbidities")

# unique(res$Sex)
res$Sex <- ifelse(res$Sex%in%c("férfi", "Férfi"), "m", "f")


# Get time series for Hungary.

OWD <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv") %>% 
  filter(location == "Hungary") %>% 
  select(date, total_deaths, new_deaths) %>% 
  filter(!is.na(total_deaths),
         new_deaths > 0)

# A <- readRDS("Data/HU/HU_2021-02-21.rds")
# B <- readRDS("Data/HU/HU_2021-02-22.rds")
# C <- readRDS("Data/HU/HU_2021-02-23.rds")
# nrow(A);nrow(B);nrow(C)
# tail(A)
# tail(B)
# tail(C)
# a silly date assignment operation.


dates_infer <- rep(OWD$date, times = OWD$new_deaths)

Dates <- tibble(ID_new = 1:length(dates_infer), date = dates_infer)

# we want all combos of age and date:
dates_all <- seq(min(Dates$date),max(Dates$date),by="days")
ages_all  <- 0:104

# we expect this many rows:
#length(dates_all) *length(ages_all) * 2 


out <-
  res %>% 
  select(-Comorbidities) %>% 
  mutate(ID_new = n():1) %>% 
  left_join(Dates, by  = "ID_new") %>% 
  # This might throw away info, like if OWiD is behind a day.
  # But then we catch it on the next update.
  filter(!is.na(date)) %>% 
  arrange(date, Sex, Age) %>% 
  mutate(Age = ifelse(Age > 104,104,Age)) %>% 
  group_by(date,Sex, Age) %>% 
  summarize(Value = n(), .groups = "drop") %>% 
  arrange(Sex, Age, date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  tidyr::complete(date = dates_all, Sex, Age = ages_all, fill = list(Value = 0)) %>% 
  mutate(Measure = "Deaths",
         Metric = "Count",
         Country = "Hungary",
         Region = "All",
         Date = ddmmyyyy(date),
         Code = paste0("HU",Date),
         AgeInt = 1L,
         Age = as.character(Age)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) ###Is that for the automation sheet?TR: Yes

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")

write_csv(res, data_source)


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


