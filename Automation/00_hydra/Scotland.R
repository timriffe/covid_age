library(readr)
library(tidyverse)
library(lubridate)
library(rvest)
library(googlesheets4)
library(googledrive)

source(here::here("Automation/00_Functions_automation.R"))

if (! "email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
ctr          <- "Scotland" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/CDC"
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# handle authentications
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# Get upload urls:
ss_list <- get_input_rubric() %>% 
  filter(Country == "Scotland")

ss_i  <- ss_list %>% dplyr::pull(Sheet)
ss_db <- ss_list %>% dplyr::pull(Source)

# derive data

## Cases data ====================


cases_url <- read_html('https://www.opendata.nhs.scot/dataset/b318bddf-a4dc-4262-971f-0ba329e09b87/resource/19646dce-d830-4ee0-a0a9-fcec79b5ac71') %>% 
  html_nodes('#content > div.row.wrapper.no-nav > section > div > p > a') %>% 
  html_attr('href')

## Extract daily cases (cumulative values), with 0 to 14 age groups ##
sccases <- read_csv(cases_url)

# Pipeline for *today's* data:
sc <- 
  sccases %>% 
  select(Date, 
         Sex, 
         Age = AgeGroup, 
         Cases = TotalPositive) %>% 
  filter(Age != 'Total')%>%
  mutate(
    Date = ymd(Date),
    Age = recode(Age,
                 '0 to 14' = "0",
                 '15 to 19' = "15",
                 '20 to 24' = "20",
                 '25 to 44' = "25",
                 '45 to 64' = "45",
                 '65 to 74' = "65",
                 '75 to 84' = "75",
                 '85plus' = "85"),
    Sex = recode(Sex,'Female' = 'f',
                 'Male' = 'm'),
    AgeInt = case_when(
      Age == "0" ~ 15,
      Age == "15" ~ 5,
      Age == "20" ~ 5,
      Age == "25" ~ 20,
      Age == "45" ~ 20,
      Age == "65" ~ 10,
      Age == "75" ~ 10,
      Age == "85" ~ 20)) %>% 
  filter(Age != "60+") %>% 
  filter(Age != "0 to 59") %>% 
  pivot_longer(Cases, 
               names_to = "Measure",
               values_to = "Value") %>% 
  mutate(Country = "Scotland",
         Region = "All",
         Metric = "Count",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date), 
                      sep = "."),
         Code = paste0('GB-SCT')) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


## Deaths data ===================

#deaths <- read.csv("https://pmd3-production-grafter-sg.publishmydata.com/v1/pipelines/download/job/548ae341-1e34-46c6-ada0-d09d4bcf3a6d")
# MK- 29 June 2022 #
# Since June 2022, Scotland publishing data has changed: 
# National Records of Scotland (NRS) weekly publication on Deaths involving 
# coronavirus (COVID-19) in Scotland provides data on: 
# deaths where COVID-19 was mentioned on the death certificate.
# this weekly series is available for 2020, 2021, and 2022 
# However, we use the trend data as always in the input_dataset
# Note: Scotland.rds for data till 02.06.2022 is deprecated in the folder. 

#Source: https://www.nrscotland.gov.uk/covid19stats

## Function to edit the table 

edit_table <- function(dataset){
  dataset %>% 
    dplyr::filter(!is.na(`Registration year`),
                  `Registration year` != "Total") %>% 
    dplyr::mutate(Sex = case_when(str_detect(`Registration year`, "females") ~ "f",
                                  str_detect(`Registration year`, "males") ~ "m",
                                  TRUE ~ NA_character_)) %>% 
    tidyr::fill(Sex, .direction = "down") %>% 
    dplyr::filter(!str_detect(`Registration year`, "Table"),
                  !str_detect(`Registration year`, "Registration year")) %>% 
    dplyr::mutate(Sex = replace_na(Sex, "b")) %>% 
    dplyr::rename("Year" = `Registration year`,
                  "Week_number" = `Week number`,
                  "date_prep" = `Week beginning`)
  
}


## 2020 WEEKLY DEATHS DATA ##

deaths_source2020 <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-deaths_2020", ".xlsx")

deaths_url_2020 <- "https://www.nrscotland.gov.uk/files//statistics/covid19/covid-deaths-20-data-final.xlsx"

download.file(deaths_url_2020,
              destfile = deaths_source2020,
              mode = "wb")

wk_data_2020 <- read_excel(deaths_source2020,
                           sheet = 4, skip = 5) %>% 
  edit_table()



## 2021 WEEKLY DEATHS DATA ##

deaths_source2021 <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-deaths_2021", ".xlsx")

deaths_url_2021 <- "https://www.nrscotland.gov.uk/files//statistics/covid19/covid-deaths-21-data-final.xlsx"

download.file(deaths_url_2021,
              destfile = deaths_source2021,
              mode = "wb")

wk_data_2021 <- read_excel(deaths_source2021,
                           sheet = 4, skip = 5) %>% 
  edit_table()


## 2022/ MOST RECENT FILE ## 


deaths_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "-deaths_",today(), ".xlsx")

recent_file_2022 <- read_html("https://www.nrscotland.gov.uk/covid19stats/") %>% 
  html_nodes(".rteright+ td > a") %>% 
  html_attr('href') %>% 
 # .[2] %>% 
  stringr::str_replace("/files//statistics/covid19/", "")


deaths_url <- paste0("https://www.nrscotland.gov.uk/files//statistics/covid19/",
                     recent_file_2022)

## DOWNLOAD DEATHS recent file AND READ IN THE DATA ##

download.file(url = deaths_url,
              destfile = deaths_source,
              mode = "wb")


deaths_recent <- read_excel(deaths_source, sheet = 4, skip = 5) %>% 
  edit_table()


## MERGE ALL DATASETS: 2020, 2021, 2022 (MOST RECENT)

deaths <- bind_rows(wk_data_2020,
                    wk_data_2021,
                    deaths_recent)



## CLEANING AND WRANGLING 

deaths_cleaned <- deaths %>% 
  # dplyr::mutate(week = str_pad(Week_number,  2, "left", 0),
  #               ISO_WEEK = paste0(Year, "-W", 
  #                                 week, "-5"),
  #               Date = ISOweek::ISOweek2date(ISO_WEEK)) %>% 
  #dplyr::select(-c("Year", "Week_number", "ISO_WEEK", `Week beginning`, "week")) %>% 
  dplyr::select(-c("Year", "Week_number")) %>%
  dplyr::mutate(date_prep = as.Date(as.numeric(date_prep), origin = "1899-12-30")) %>% 
  dplyr::group_by(Sex) %>% 
  dplyr::arrange(date_prep) %>% 
  ## CONVERT THE NEWLY WEEKLY TO CUMULATIVE WEEKLY
  dplyr::mutate(across(.cols = -c("date_prep"), ~ cumsum(.x))) %>% 
  tidyr::pivot_longer(cols = -c("date_prep", "Sex"),
                      names_to = "Age",
                      values_to = "Value") %>% 
  dplyr::filter(!is.na(Value)) %>% 
  dplyr::mutate(Value = as.numeric(Value))


deaths_out <- deaths_cleaned %>% 
  dplyr::mutate(Age = recode(Age,
                             '<1' = "0",
                             '1-14' = "1",
                             '15-44' = "15",
                             '45-64' = "45",
                             '65-74' = "65",
                             '75-84' = "75",
                             '85+' = "85",
                             "All ages" = "TOT"),
                AgeInt = case_when(
                  Age == "0" ~ 1L,
                  Age == "1" ~ 14L,
                  Age == "15" ~ 30L,
                  Age == "45" ~ 20L,
                  Age == "65" ~ 10L,
                  Age == "75" ~ 10L,
                  Age == "85" ~ 20L,
                  Age == "TOT" ~ NA_integer_),
                Country = "Scotland",
                Region = "All",
                Code = "GB-SCT",
                Metric = "Count",
                Date = ddmmyyyy(date_prep),
                Measure = "Deaths") %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

## save a copy of deaths_out data on daily basis ## 

write_rds(deaths_out, 
          paste0(dir_n, "Data_sources/Scotland/", ctr, "_DeathsWeekly", Sys.Date(), ".rds"))


## Trend data ====================

trend_url <-
  read_html("https://www.opendata.nhs.scot/dataset/b318bddf-a4dc-4262-971f-0ba329e09b87/resource/9393bd66-5012-4f01-9bc5-e7a10accacf4") %>% 
  html_nodes('#content > div.row.wrapper.no-nav > section > div > p > a') %>% 
  html_attr('href')

## Extract trend data, ## 
sctrend <- read_csv(trend_url)

## keep record starting March 09, 2020 ## 

sct <-
  sctrend %>% 
  select(Date, 
         Sex, 
         Age = AgeGroup, 
         Value = CumulativePositive) %>%  
  mutate(
    Date = ymd(Date),
    Age = recode(Age,
                 'Total' = "TOT",
                 '0 to 14' = "0",
                 '15 to 19' = "15",
                 '20 to 24' = "20",
                 '25 to 44' = "25",
                 '45 to 64' = "45",
                 '65 to 74' = "65",
                 '75 to 84' = "75",
                 '85plus' = "85"),
    Sex = recode(Sex,'Female' = 'f',
                 'Male' = 'm',
                 'Total' = 'b'),
    AgeInt = case_when(
      Age == "TOT" ~ NA_real_,
      Age == "0" ~ 15,
      Age == "15" ~ 5,
      Age == "20" ~ 5,
      Age == "25" ~ 20,
      Age == "45" ~ 20,
      Age == "65" ~ 10,
      Age == "75" ~ 10,
      Age == "85" ~ 20),
    Measure = "Cases") %>% 
  filter(Age != "60+") %>% 
  filter(Age != "0 to 59") %>% 
  filter(Date >= ymd("2020-03-09")) %>% 
  arrange(Date, Sex, Measure, Age) %>% 
  ungroup() %>%  
  mutate(Country = "Scotland",
         Region = "All",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0('GB-SCT')) %>% 
  ## MK: bind weekly deaths since the daily are not published/ updated
  bind_rows(deaths_out) # %>% 
 # select(all_of(colnames(sc)))


## Totals data =======================

totals_url <- read_html('https://www.opendata.nhs.scot/dataset/b318bddf-a4dc-4262-971f-0ba329e09b87/resource/287fc645-4352-4477-9c8c-55bc054b7e76') %>% 
  html_nodes('#content > div.row.wrapper.no-nav > section > div > p > a') %>% 
  html_attr('href')

# Extract totals, which we hope are retrospectively corrected,
# or at least will be one day? In that case, adjustment will
# be automatic on our side.
sctot   <- read_csv(totals_url)

# Prepare totals
TOT <- 
  sctot %>% 
  mutate(Date = ymd(Date)) %>% 
  select(Date,
         Value = CumulativeCases) %>% 
  ## MK: no need for total deaths again, we have it in the weekly data 
     #    Deaths = Deaths) %>% 
  mutate(Country = "Scotland",
         Region = "All",
         Sex = "b",
         Metric = "Count",
         AgeInt = NA_integer_,
         Age = "TOT") %>% 
  mutate(Date = ddmmyyyy(Date),
         Measure = "Cases",
         Code = paste0("GB-SCT")) %>% 
  select(all_of(colnames(sc)))

# -----------------------

Date_cases  <- sc %>% dplyr::pull(Date) %>% unique() %>% dmy()
Date_trends <- sct %>% dplyr::pull(Date) %>% dmy() %>% max()

# Current input database
###########################################adapt here, how data gets read in############new from rds
SCin       <- 
  read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  filter(Age != "TOT") %>% 
  mutate(Code = "GB-SCT")


# 1) remove Date_cases if present:

SCin_keep <- SCin %>% 
  filter(dmy(Date) < Date_cases)

# 2) any dates in trends that aren't in SCin_keep at this time?

drive_dates        <- 
  SCin_keep %>% 
  dplyr::pull(Date) %>% 
  dmy() %>% unique() %>% 
  sort()

trend_dates        <- 
  sct %>% 
  dplyr::pull(Date) %>% 
  dmy() %>% 
  unique() %>% 
  sort()

trend_dates_include <- trend_dates[!trend_dates %in% c(drive_dates, Date_cases)]

sct_out <-
  sct %>% 
  filter(dmy(Date) %in% trend_dates_include)


# -----------------------------
# Compose what we want to keep:
SCout <- 
  SCin_keep %>% 
  bind_rows(sct_out) %>% # fills gaps
  bind_rows(TOT) %>% 
  bind_rows(sc) %>% 
  sort_input_data() %>% 
  group_by(Date,Sex,Measure) %>% 
  mutate(N=n()) %>% 
  ungroup() %>% 
  filter(N > 1) %>% 
  select(-N)
  
n <- duplicated(SCout[, c("Date", "Sex","Measure","Age")])
SCout <- 
  SCout %>% 
  dplyr::filter(!n)

# -----------------------------
##############################new rds file
## overwrite sheet 
#sheet_write(SCout,
#            ss = ss_i,
#            sheet = "database")
write_rds(SCout, paste0(dir_n, ctr, ".rds"))

N <- nrow(SCout)
log_update(pp = "Scotland", N = N)
#-----------------------------
# upload source sheets to Drive as google sheets

sheet_name <- paste0("Scotland_", Date_cases)

meta <- drive_create(sheet_name,
                     path = ss_db, 
                     type = "spreadsheet",
                     overwrite = TRUE)

write_sheet(sccases, 
            ss = meta$id,
            sheet = "today")

Sys.sleep(100)
write_sheet(sctrend, 
            ss = meta$id,
            sheet = "trend")

Sys.sleep(100)
write_sheet(sctot, 
            ss = meta$id,
            sheet = "totals")
sheet_delete(meta$id, "Sheet1")



## history =============
# deaths2 <- deaths %>% 
#   select(Date = DateCode, 
#          Sex, 
#          Age, 
#          Value,
#          Cause.Of.Death) %>% 
#   filter(Cause.Of.Death == "COVID-19 related",
#          Date != "2020",
#          Date != "2021",
#          Date != "2022",
#          Age != "All") %>% 
#   mutate(Date = substr(Date, 5, 14),
#     Date = ymd(Date),
#     Age = recode(Age,
#                  '0 years' = "0",
#                  '1-14 years' = "1",
#                  '15-44 years' = "15",
#                  '45-64 years' = "45",
#                  '65-74 years' = "65",
#                  '75-84 years' = "75",
#                  '85 years and over' = "85"),
#     Sex = recode(Sex,'Female' = 'f',
#                  'Male' = 'm',
#                  'All' = 'b'),
#     AgeInt = case_when(
#       Age == "0" ~ 1,
#       Age == "1" ~ 14,
#       Age == "15" ~ 30,
#       Age == "45" ~ 20,
#       Age == "65" ~ 20,
#       Age == "75" ~ 20,
#       Age == "85" ~ 20)
#     ) %>% 
#   arrange(Date, Sex ,Age) %>% 
#   group_by(Sex, Age) %>% 
#   mutate(Value = cumsum(Value)) %>% 
#   ungroup() 
# 
# #filter(Age != "60+") %>% 
#   #filter(Age != "0 to 59") %>% 
#   mutate(Country = "Scotland",
#          Region = "All",
#          Metric = "Count",
#          Measure = "Deaths",
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date), 
#                       sep = "."),
#          Code = paste0('GB-SCT')) %>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value) %>% 
#   sort_input_data()


#content > div.row.wrapper.no-nav > section > div > p > a

# -----------------------
# TR: removed both-sex creation, not needed
# -----------------------

# -----------------------
# define helper function that infers 0-14.
# for unique combos of Date, Sex, Measure
# age groups are the same now, not needed anymore
#infer_zero <- function(chunk){

#  chunk %>% 
#    mutate(TOT = Value[Age == "TOT"],
#           Marginal = sum(Value[Age!="TOT"]),
#           Value = ifelse(Age == "TOT", 
#                          TOT - Marginal,
#                          Value),
#           Age = ifelse(Age == "TOT", "0", Age),
#           AgeInt = ifelse(Age == "0", 15, AgeInt)) %>% 
#    select(-TOT, - Marginal) %>% 
#    arrange(Age)

#}

# --------------------------------
####I think this is not needed anymore
####data gets updates each day
