
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

if (system("whoami",intern=TRUE) == "tim"){
  capture_path <- "Data"
} else {
  capture_path <- "N://COVerAGE-DB/Automation/Vietnam"
}

# We use OWiD totals to break up sequentially ordered cases & deaths
OWD <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv") %>% 
  filter(location == "Vietnam") %>% 
  select(date, total_cases, new_cases, total_deaths, new_deaths) 

# what's the most recent Vietnam capture we have?
VTcaptured <- list.files(capture_path) %>% grep(pattern = "Vietnam",value =TRUE)

whichVT <- VTcaptured %>% 
  gsub(pattern = "Vietnam", replacement = "") %>% 
  gsub(pattern = ".xlsx", replacement = "") %>% 
  lubridate::ymd() %>% 
  which.max()

thisVT <- VTcaptured[whichVT]

# Read in the microdata
IN <- readxl::read_xlsx(file.path(capture_path, thisVT))

colnames(IN) <- c("x","CaseID","Age","Place","Status","Nationality")

# Extract IDs from cases: 
# problem = there's one duplicate, but the ID right before it is missing,
# so we can create a new ID...
Cases <-
  IN %>% 
  select(CaseID, Age, Status) %>% 
  mutate(ID  = readr::parse_number(CaseID)) %>% 
  arrange(ID) %>% 
  mutate(ID_new = 1:n()) 

# Now we infer dates from the ordered cases and time series of new cases
dates_cases_infer <- rep(OWD$date, times = OWD$new_cases)
Dates_cases <- tibble(ID_new = 1:length(dates_cases_infer), date = dates_cases_infer)

# join dates to Cases, tabulate 
Cases2 <-
  Cases %>% 
  left_join(Dates_cases, by  = "ID_new") %>% 
  # This might throw away info, like if OWiD is behind a day.
  # But then we catch it on the next update.
  filter(!is.na(date)) %>% 
  mutate(
    Age = as.integer(Age),
    Age = ifelse(Age > 100,100,Age),
    Age = DemoTools::calcAgeAbr(Age)) %>% 
  group_by(date, Age) %>% 
  summarize(new = n(), .groups = "drop") 

# Need to split the pipeline to get max date
dates_cases_all <- seq(min(Cases2$date), max(Cases2$date), by = "days")
ages_all        <- c(0, 1, seq(5, 100, by = 5))

Cases_out <- 
  Cases2 %>% 
  tidyr::complete(date = dates_cases_all, 
                  Age = ages_all, 
                  fill = list(new = 0)) %>% 
  arrange(Age, date) %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases",
         Metric = "Count",
         Country = "Vietnam",
         Region = "All",
         Date = ddmmyyyy(date),
         Code = paste0("VT",Date),
         AgeInt = case_when(
           Age == 0 ~ 1L,
           Age == 1 ~ 4L,
           TRUE ~ 5L),
         Age = as.character(Age),
         Sex = "b") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)



# Repeat essentially the same steps for Deaths
Deaths <-
  Cases %>% 
  filter(grepl(Status,pattern = "vong")) %>% 
  mutate(ID_new = 1:n())

OWD <- 
  OWD %>% 
  filter(!is.na(new_deaths))
  # need to deal with one negative new_deaths
ind_neg <- which(OWD$new_deaths < 0)
  # most recent prior day with >0 new_deaths
for (i in 1:length(ind_neg)){
  ind_pos <- (OWD$new_deaths[1:ind_neg[i]] > 0) %>% which() %>% max()
  OWD$new_deaths[ind_neg[i]] <- 0
  OWD$new_deaths[ind_pos] <- 0
}


dates_deaths_infer <- rep(OWD$date, times = OWD$new_deaths)
Dates_deaths <- tibble(ID_new = 1:length(dates_cases_infer), date = dates_cases_infer)

Deaths2 <-
  Deaths %>% 
  left_join(Dates_deaths, by  = "ID_new") %>% 
  # This might throw away info, like if OWiD is behind a day.
  # But then we catch it on the next update.
  filter(!is.na(date)) %>% 
  mutate(
    Age = as.integer(Age),
    Age = ifelse(Age > 100,100,Age),
    Age = DemoTools::calcAgeAbr(Age)) %>% 
  group_by(date, Age) %>% 
  summarize(new = n(), .groups = "drop") 

dates_deaths_all <- seq(min(Deaths2$date), max(Deaths2$date), by = "days")
Deaths_out <- 
  Deaths2 %>% 
  tidyr::complete(date = dates_deaths_all, 
                  Age = ages_all, 
                  fill = list(new = 0)) %>% 
  arrange(Age, date) %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths",
         Metric = "Count",
         Country = "Vietnam",
         Region = "All",
         Date = ddmmyyyy(date),
         Code = paste0("VT",Date),
         AgeInt = case_when(
           Age == 0 ~ 1L,
           Age == 1 ~ 4L,
           TRUE ~ 5L),
         Age = as.character(Age),
         Sex = "b") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

# I think this is ready to go
out <- bind_rows(Deaths_out, Cases_out)




