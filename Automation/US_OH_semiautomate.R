### OHIO STATE CASES AND DEATHS ###

# Libraries ---------------------------------------------------------------

library(readr)
library(tidyverse)
library(lubridate)
library(here)
library(googlesheets4)

# Load data ----------------------------------- ----------------------------

oh_cases_deaths <- read_csv(file = "Data/COVIDSummaryData.csv", 
                            col_types = "ccccccccc") %>% 
  # This is ugly, but solves the commas seperator in thousands in last row
  mutate(`Case Count` = gsub(pattern = ",",
                             replacement = "", 
                             `Case Count`),
         `Death Count` = gsub(pattern = ",",
                             replacement = "", 
                             `Death Count`),
         `Hospitalized Count` = gsub(pattern = ",",
                                replacement = "", 
                               `Hospitalized Count`),
         `Case Count` = as.double(`Case Count`),
         `Death Count` = as.double(`Death Count`), 
         `Hospitalized Count` = as.double(`Hospitalized Count`)) 

# Slice off Total as a check for later
TOT <- oh_cases_deaths %>% filter(`Age Range` == "Total")

# Remove total to eliminate parsing issues
oh_cases_deaths <- oh_cases_deaths %>% 
  filter(`Age Range` != "Total")
# Manage cases ------------------------------------------------------------
#oh_cases_deaths %>% pull(`Onset Date`) %>% unique() %>% sort()
oh_cases_deaths %>% pull(`Age Range`) %>% unique()
ohio_cases <- 
  oh_cases_deaths %>% 
  select(County, Sex, `Age Range`, `Onset Date`, `Case Count`) %>% 
  mutate(County = as.factor(County),
         # no need for factors here
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex == "Total" ~ "b",
                         Sex == "Unknown" ~ "UNK",
                         TRUE ~ "NA" # leave a "catch" at the end
                         ),
         Age = case_when(`Age Range` == "0-19" ~ "0",
                         `Age Range` == "20-29" ~ "20",
                         `Age Range` == "30-39" ~ "30",
                         `Age Range` == "40-49" ~ "40",
                         `Age Range` == "50-59" ~ "50",
                         `Age Range` == "60-69" ~ "60",
                         `Age Range` == "70-79" ~ "70",
                         `Age Range` == "80+" ~ "80",
                         `Age Range` == "Unknown" ~ "UNK",
                         TRUE ~ "NA" # leave a "catch" at the end
                         ),
         Day = mdy(`Onset Date`), # TR lubridate is cool
         Metric = "Count",
         Measure = "Cases",
         Value2 = `Case Count`) %>% 
  select(County, Sex, Age, Day, Metric, Measure, Value2) 

#calculate new cases by age_group and sex per day
# (sum over counties)
ohio_cases_final <- 
  ohio_cases %>% 
  group_by(Day, Age, Sex) %>% 
  # mutate(cases_cum = cumsum(Value2)) %>% 
  # summarise(Value = max(cases_cum)) %>% 
  # the max of a cumsum is the sum
  summarise(Value = sum(Value2)) %>% 
  ungroup() %>% 
  arrange(Sex, Age, Day) # TR changed order

#complete cases df
ohio_cases_complete <- 
  ohio_cases_final %>% 
  # TR: neat trick, super useful!
  complete(Day, Age, Sex, fill = list(Value = 0)) %>% 
  # Can go straight to integer
  mutate( AgeInt = case_when(
    Age == "0" ~ 20,
    Age %in% c("20","30","40","50","60","70") ~ 10,
    Age == "80" ~ 25,
    TRUE ~ NA_real_ 
  ) )%>% 
  arrange(Sex, Age, Day) %>% 
  # TR add cumusm Value. This is a big change
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()
  
#finalize data: google spreadsheet
ohio_cases_spreadsheet <- 
  ohio_cases_complete %>%
  mutate(Day2 = Day) %>% 
  separate(Day, into = c("Y","M","D"), sep = "-") %>% 
  mutate(Country = "USA",
         Region = "Ohio",
         Date = paste(D, ".", M, ".", Y, sep = ""),
         Code = paste("US_OH", Date, sep = ""),
         Metric = "Count",
         Measure = "Cases") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value, Day2)

ohio_cases_spreadsheet %>% filter(Date == "01.05.2020") %>% pull(Value) %>% sum()
TOT %>% pull(`Case Count`)
# Manage deaths -----------------------------------------------------------

##################################
# Need to assign date of death to one person where it's unknown.
# However, we know the onset date :-), and it's a Male aged 30-39.
# Sooooo, let's add the mean time from onset to death?

do.this <- FALSE
if (do.this){
dlag <- 
  oh_cases_deaths %>% 
  filter(!is.na(`Date Of Death`),
         !is.na(`Onset Date`),
         `Age Range` == "30-39") %>% 
  mutate(onset = mdy(`Onset Date`),
         deathdate = mdy(`Date Of Death`),
         meandur = deathdate - onset) %>% 
  pull(meandur) %>% 
  mean(na.rm = TRUE) %>% 
  round()

# So for this one unk death date just add 12 to onset...
UNKddate <-
  oh_cases_deaths %>% 
  filter(`Date Of Death` == "Unknown") %>% 
  mutate(`Date Of Death` = "5/9/2020")

oh_cases_deaths <-
oh_cases_deaths %>% 
  filter(`Date Of Death` != "Unknown") %>% 
  rbind(UNKddate)
}
##################################33

ohio_deaths <- 
  oh_cases_deaths %>% 
  filter(!is.na(`Date Of Death`)) %>% 
  select(County, Sex, `Age Range`, `Date Of Death`, `Death Count`) %>% 
  mutate(
    # no need for factors here
    Sex = case_when(Sex == "Female" ~ "f",
                    Sex == "Male" ~ "m",
                    Sex == "Total" ~ "b",
                    Sex == "Unknown" ~ "UNK",
                    TRUE ~ "NA" # leave a "catch" at the end
    ),
    Age = case_when(`Age Range` == "0-19" ~ "0",
                    `Age Range` == "20-29" ~ "20",
                    `Age Range` == "30-39" ~ "30",
                    `Age Range` == "40-49" ~ "40",
                    `Age Range` == "50-59" ~ "50",
                    `Age Range` == "60-69" ~ "60",
                    `Age Range` == "70-79" ~ "70",
                    `Age Range` == "80+" ~ "80",
                    `Age Range` == "Unknown" ~ "UNK",
                    TRUE ~ "NA" ), # leave a "catch" at the end
    Day = mdy(`Date Of Death`),
    Metric = "Count",
    Measure = "Deaths",
    Value2 = `Death Count`) %>% 
  select(County, Sex, Age, Day, Metric, Measure, Value2)

#calculate new deaths by age_group and sex per day
ohio_deaths_final <- 
  ohio_deaths %>% 
  group_by(Day, Age, Sex) %>% 
  # mutate(cases_cum = cumsum(Value2)) %>% 
  # summarise(Value = max(cases_cum)) %>% 
  # the max of a cumsum is the sum
  summarise(Value = sum(Value2)) %>% 
  ungroup() %>% 
  arrange(Sex, Age, Day) # TR changed order

#complete deaths df
ohio_deaths_complete <- 
  ohio_deaths_final %>% 
  # TR: neat trick, super useful!
  complete(Day, Age, Sex, fill = list(Value = 0)) %>% 
  # Can go straight to integer
  mutate( AgeInt = case_when(
    Age == "0" ~ 20,
    Age %in% c("20","30","40","50","60","70") ~ 10,
    Age == "80" ~ 25,
    TRUE ~ NA_real_ 
  ) )%>% 
  arrange(Sex, Age, Day) %>% 
  # TR add cumusm Value. This is a big change
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()

#finalize data: google spreadsheet
ohio_deaths_spreadsheet <- 
  ohio_deaths_complete %>%
  mutate(Day2 = Day) %>% 
  separate(Day, into = c("Y","M","D"), sep = "-") %>% 
  mutate(Country = "USA",
         Region = "Ohio",
         Date = paste(D, ".", M, ".", Y, sep = ""),
         Code = paste("US_OH", Date, sep = ""),
         Metric = "Count",
         Measure = "Deaths") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value, Day2)

  
# Merge cases and deaths --------------------------------------------------

ohio_spreadsheet <- 
  rbind(ohio_cases_spreadsheet, ohio_deaths_spreadsheet) %>% 
  arrange(Day2, Measure, Sex, Age) %>% 
  select(-Day2) %>% #it was useful to arrange the dataset
  filter(!(Sex == "UNK" & Value == 0))

# Push dataframe ----------------------------------------------------------

sheet_write(ohio_spreadsheet, 
            ss = "https://docs.google.com/spreadsheets/d/1VUKJ9pugRNKPtwCqqmvUPyAi7VKzkSiPKUOFzsNbDZI/edit?ts=5e9e07d1#gid=937073600", 
            sheet = "database")
