library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr <- "CA_Manitoba"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



# Source page "https://www.gov.mb.ca/health/publichealth/surveillance/covid-19/index.html"

## Since week 11, year 2022 (2022-03-13), Manitoba published the weekly cases by age group and sex

## the below code is to automate the process and keep us updated. 

## However: we may need to get the historical data (manually) or from elsewhere if someone has collected it.

#deaths_pct <- read.csv("https://www.gov.mb.ca/health/publichealth/surveillance/covid-19/2022/week_27/downloads/age_distribution_severe_outcomes_week_27.csv")

#====================

## Create a dataframe with the dates, extract epi-week and epi-year

dates <- data.frame(date = seq(from = ymd('2022-03-13'), to = ymd(today() - 11), by='days')) %>% 
  mutate(week = epiweek(date),
         year = epiyear(date)) %>% 
  group_by(year, week, .drop = TRUE) %>% 
  filter(date == max(date)) 


## Loop over this dataframe to get the data

IN <- dates %>% 
  {map2_df(.$year, .$week, ~ read.csv(paste0("https://www.gov.mb.ca/health/publichealth/surveillance/covid-19/", 
                                             .x, "/week_", .y, "/downloads/age_sex_distribution_week_", .y, ".csv")) %>% 
             mutate(year = .x,
                    week = .y))} %>% 
  left_join(dates, by = c("year" = "year",
                          "week" = "week"))



## Processing

out <- IN %>% 
  dplyr::select(Date = date,
                Age = Age.Group,
                Sex = gender,
                Value = allcases) %>% 
  dplyr::mutate(Sex = case_when(Sex == "Female" ~ "f",
                                Sex == "Male" ~ "m",
                                Sex == "Unknown" ~ "UNK"),
                AgeInt = case_when(Age == "80+" ~ 25L,
                                   Age == "missing" ~ NA_integer_,
                                   TRUE ~ 10L),
                Age = case_when(Age == "<=9" ~ "0",
                                Age == "10-19" ~ "10",
                                Age == "20-29" ~ "20",
                                Age == "30-39" ~ "30",
                                Age == "40-49" ~ "40",
                                Age == "50-59" ~ "50",
                                Age == "60-69" ~ "60",
                                Age == "70-79" ~ "70",
                                Age == "80+" ~ "80",
                                Age == "missing" ~ "UNK",
                                TRUE ~ Age),
                Date = ddmmyyyy(Date),
                Country = "Canada",
                Region = "Manitoba",
                Code = "CA-MA",
                Metric = "Count",
                Measure = "Cases") %>% 
  dplyr::select(Country, Region, Code,
                Date, Age, AgeInt, 
                Sex, Measure, Metric, Value)



# saving data in N drive
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

## END
















