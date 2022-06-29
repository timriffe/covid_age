#Maldives 


#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here::here("Automation/00_Functions_automation.R"))
library(here)
library(readxl)
library(lubridate)
library(dplyr)
library(tidyverse)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address

ctr          <- "Maldives" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


dir_n_source <- "N:/COVerAGE-DB/Automation/Maldives" # <- that one is if 
                                                       # Muhammad is gathering raw data

######################################### 

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "MV")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

#In_drive <- get_country_inputDB("MV")%>% 
#  select(-Short)


#Download from website with python 
#https://covid19.health.gov.mv/dashboard/list/?c=0
#read excel file in 

#Each day complete timeseries is downloaded.Read in most recent file.  

#get a vector of all filenames
files <- list.files(path = dir_n_source, 
                    pattern = ".xlsx",
                    full.names = TRUE,
                    recursive = TRUE)

#get the directory names of these (for grouping)
dirs <- dirname(files)

#find the last file in each directory (i.e. latest modified time)
lastfiles <- tapply(files,dirs,function(v) v[which.max(file.mtime(v))])

Maldives<- read_excel(lastfiles)


#####Cases#########


MV_cases= Maldives%>%
  select(Sex= GENDER, Age = AGE,Date= `CONFIRMED ON`) %>% 
  mutate(Sex = case_when(
    is.na(Sex)~ "UNK",
    Sex == "Male" ~ "m",
    Sex == "Female" ~ "f"),
    Age = case_when(
      is.na(Age) ~ "UNK",
      TRUE~ as.character(Age)),
    Date = dmy(Date)) %>% 
  na.omit()


# TR:
# see if you can take care of Age
# with case_when() in the above mutate()

# JD:  I cant get this sub function in there 


#MV= Maldives%>%
# select(Sex= GENDER, Age = AGE,Date= `CONFIRMED ON`) %>% 
# mutate(Sex = case_when(
# is.na(Sex)~ "UNK",
# Sex == "Male" ~ "m",
# Sex == "Female" ~ "f"),
# Age = case_when(
# is.na(Age) ~ "UNK",
#TRUE~ as.character(Age)),
# Age= case_when(sub(".*M" ,"0", Age),
#sub(".*D", "0", Age)),
# Date = dmy(Date))


# Dont count Age in months or days, below 1 year of Age becomes 0 
#Months
MV_cases$Age <- (sub(".*M", "0", MV_cases$Age))

#Days
MV_cases$Age <- (sub(".*D", "0", MV_cases$Age))

#categories <- unique(MV$Age) 
#categories
  
#changed aggregation to summarize 

MV_cases_out= MV_cases %>%
group_by(Date, Sex, Age) %>% 
  summarize(Value = n(), .groups="drop")%>%
  arrange(Sex, Age, Date) %>% 
  ungroup() %>% 
  tidyr::complete(Date, Sex, Age, fill = list(Value = 0))%>%
  filter(Age != 2020) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("MV"),
    Country = "Maldives",
    Region = "All",
    Measure= "Cases",
    Metric= "Count", 
    AgeInt = case_when(
      Age == "UNK" ~ NA_integer_,
      TRUE ~ 1L))%>%
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


######Deaths######### 


MV_death= Maldives%>%
  select(Sex= GENDER, Age = AGE,Date= `DECEASED ON`) %>% 
  mutate(Sex = case_when(
    is.na(Sex)~ "UNK",
    Sex == "Male" ~ "m",
    Sex == "Female" ~ "f"),
    Age = case_when(
      is.na(Age) ~ "UNK",
      TRUE~ as.character(Age)),
    Date = dmy(Date)) %>% 
  na.omit()

#only take those that died 

MV_death= MV_death[complete.cases(MV_death), ]

#In case someday someone with age counted in days or month dies 
#Months
MV_death$Age <- (sub(".*M", "0", MV_death$Age))
#Days
MV_death$Age <- (sub(".*D", "0", MV_death$Age))

MV_death_out= MV_death %>%
  group_by(Date, Sex, Age) %>% 
  summarize(Value = n(), .groups="drop")%>%
  arrange(Sex, Age, Date) %>% 
  ungroup() %>% 
  tidyr::complete(Date, Sex, Age, fill = list(Value = 0))%>%
  filter(Age != 2020) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("MV"),
    Country = "Maldives",
    Region = "All",
    Measure= "Deaths",
    Metric= "Count", 
    AgeInt = case_when(
      Age == "UNK" ~ NA_integer_,
      TRUE ~ 1L))%>%
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

######combine both to one dataframe########## 
MV_out <- bind_rows(MV_cases_out,
                    MV_death_out) %>% 
  sort_input_data()



# In case we had earlier data, we keep it.
###########################################Dont think we need that here, new download always has complete time series 
#MV_out <- 
  #In_drive %>% 
  #filter(dmy(Date) < min(dmy(MV_out$Date))) %>% 
  #bind_rows(MV_out) %>% 
  #sort_input_data()

# upload to Drive, overwrites

#write_sheet(MV_out, 
#            ss = ss_i, 
#            sheet = "database")

write_rds(MV_out, paste0(dir_n, ctr, ".rds"))

###########################################Still not sure how to set this up with the automation sheet 
log_update("Maldives", N = nrow(MV_out))


#archive: input files already saved on N 

########################################################

































#############First draft 
#cases
#sum by day  
#MV_cases= transform(MV_cases,Count = as.numeric(Count))
#MV_cases_sum= aggregate(Count~Date+Age+Sex, data=MV_cases, FUN=sum) 
#cumulative sum
#MV_cases_csum= MV_cases_sum %>%
#group_by(Sex,Age) %>%
#mutate(Value = cumsum(Count))



#death 
#sum by day  
#MV_death= transform(MV_death,Count = as.numeric(Count))
#cumulative sum
#MV_death_csum= MV_death %>%
#group_by(Sex,Age) %>%
#mutate(Value = cumsum(Count))
























