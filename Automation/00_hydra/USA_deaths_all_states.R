# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("C:/Users/acosta/Documents/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("R/00_Functions.R")

library(tidyverse)
library(lubridate)
library(googlesheets4)
library(googledrive)

drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "USA_CDC")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

# info by age for each state!!!!!!!!!!!!!!!!!!!!!!!!!!
db <- read_csv("https://data.cdc.gov/api/views/9bhg-hcku/rows.csv?accessType=DOWNLOAD")

unique(db$`Age group`)
ages

ages_all <- c("All Ages", "Under 1 year", "0-17 years", "1-4 years", "5-14 years", "15-24 years", "18-29 years", "25-34 years", "30-49 years", "35-44 years", "45-54 years", "50-64 years", "55-64 years", "65-74 years", "75-84 years", "85 years and over")
ages1 <- c("All Ages", "Under 1 year", "1-4 years", "5-14 years", "15-24 years", "25-34 years", "35-44 years", "45-54 years", "55-64 years", "65-74 years", "75-84 years", "85 years and over")
ages2 <- c("All Ages", "0-17 years", "18-29 years", "30-49 years", "50-64 years", "65-74 years", "75-84 years", "85 years and over")

date_report <- mdy(db$`Data as of`[1])
date_f <- mdy(db$`End Week`[1])

db2 <- db %>% 
  select("State", "Age group", "Sex", "COVID-19 Deaths") %>% 
  rename(Age = "Age group",
         Value = "COVID-19 Deaths") %>% 
  filter(Age %in% ages1)
  
db3 <- db %>% 
  select("State", "Age group", "Sex", "COVID-19 Deaths") %>% 
  rename(Age = "Age group",
         Value = "COVID-19 Deaths") %>% 
  filter(Age %in% ages1,
         Sex != "Unknown")

no_nas <- db3 %>% 
  drop_na() %>% 
  filter(Age != "All Ages",
         Sex != "All Sexes") %>% 
  group_by(State) %>% 
  summarise(no_na = sum(Value))

all <- db3 %>% 
  filter(Age == "All Ages", 
         Sex != "All Sexes") %>% 
  group_by(State) %>% 
  summarise(all = sum(Value))

vs <- all %>% 
  left_join(no_nas) %>% 
  mutate(difs = all - no_na,
         prop = no_na / all)

# Almost all states above 90% of ages identified when using wide age groups, 
# excepting Alaska, Vermont, and 	Wyoming
# When using narrow age groups, 8 states are below 90% of age identification

# Imputation of NAs can be done by attributing the same age structure of the country to ages where there is no information

db4 <- db3 %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "Un" ~ "0",
                         Age == "Al" ~ "TOT",
                         Age == "1-" ~ "1",
                         Age == "5-" ~ "5",
                         TRUE ~ as.character(Age)),
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex == "All Sexes" ~ "b")) 


# Imputation of NAs using the same distribution that the national level

all_us <- db4 %>% 
  filter(State == "United States",
         Age != "TOT") %>% 
  select(Sex, Age, Value) %>% 
  rename(us = Value)

totals <- db4 %>% 
  filter(Age == "TOT",
         State != "United States",
         Sex != "b") %>% 
  rename(all = Value) %>% 
  select(-Age)

sums <- db4 %>% 
  filter(Age != "TOT") %>% 
  drop_na() %>% 
  group_by(State, Sex) %>% 
  summarise(no_nas = sum(Value))

diffs <- totals %>% 
  left_join(sums) %>% 
  mutate(diff = all - no_nas)

ages_na <- db4 %>% 
  filter(is.na(Value)) %>% 
  select(-Value) %>% 
  left_join(all_us) %>% 
  group_by(State, Sex) %>% 
  mutate(sums = sum(us)) %>% 
  ungroup() %>% 
  mutate(prop = us / sums) %>% 
  left_join(diffs %>% 
              select(State, Sex, diff)) %>% 
  mutate(imput = diff * prop,
         imp2 = round(imput))

overs <- ages_na %>% 
  filter(imp2 == 0)

# rounding 0s to 1
ages_na2 <- ages_na %>% 
  mutate(imp2 = ifelse(imp2 < 1, 1, imp2)) 

# testing the excess mortality produced by imputations
excess_state <- ages_na2 %>%
  group_by(State, Sex) %>% 
  mutate(tot_imp = sum(imp2),
         diff_imp = tot_imp - diff) %>% 
  summarise(diff_imp = mean(diff_imp))

# 38 cases excess in total for the whole country with imputations
excess_state %>% 
  group_by() %>% 
  summarise(diff_imp = sum(diff_imp))

ages_na3 <- ages_na2 %>% 
  rename(Value = imp2) %>% 
  select(State, Age, Sex, Value) %>% 
  mutate(imp = 1)
  
# binding data and imputations for NAs
date = paste(sprintf("%02d",day(date_f)),
             sprintf("%02d",month(date_f)),
             year(date_f),
             sep=".")


db_final <- db4 %>% 
  filter(!is.na(Value),
         State != "United States") %>% 
  mutate(imp = 0) %>% 
  bind_rows(ages_na3) %>% 
  arrange(State, Sex, suppressWarnings(as.integer(Age))) %>% 
  mutate(Country = "USA",
         Region = State,
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         short = case_when(State == 'Alabama' ~ 'US_AL_CDC',
                           State == 'Alaska' ~ 'US_AK_CDC',
                           State == 'Arizona' ~ 'US_AZ_CDC',
                           State == 'Arkansas' ~ 'US_AR_CDC',
                           State == 'California' ~ 'US_CA_CDC',
                           State == 'Colorado' ~ 'US_CO_CDC',
                           State == 'Connecticut' ~ 'US_CT_CDC',
                           State == 'Delaware' ~ 'US_DE_CDC',
                           State == 'Florida' ~ 'US_FL_CDC',
                           State == 'Georgia' ~ 'US_GA_CDC',
                           State == 'Hawaii' ~ 'US_HI_CDC',
                           State == 'Idaho' ~ 'US_ID_CDC',
                           State == 'Illinois' ~ 'US_IL_CDC',
                           State == 'Indiana' ~ 'US_IN_CDC',
                           State == 'Iowa' ~ 'US_IA_CDC',
                           State == 'Kansas' ~ 'US_KS_CDC',
                           State == 'Kentucky' ~ 'US_KY_CDC',
                           State == 'Louisiana' ~ 'US_LA_CDC',
                           State == 'Maine' ~ 'US_ME_CDC',
                           State == 'Maryland' ~ 'US_MD_CDC',
                           State == 'Massachusetts' ~ 'US_MA_CDC',
                           State == 'Michigan' ~ 'US_MI_CDC',
                           State == 'Minnesota' ~ 'US_MN_CDC',
                           State == 'Mississippi' ~ 'US_MS_CDC',
                           State == 'Missouri' ~ 'US_MO_CDC',
                           State == 'Montana' ~ 'US_MT_CDC',
                           State == 'Nebraska' ~ 'US_NE_CDC',
                           State == 'Nevada' ~ 'US_NV_CDC',
                           State == 'New Hampshire' ~ 'US_NH_CDC',
                           State == 'New Jersey' ~ 'US_NJ_CDC',
                           State == 'New Mexico' ~ 'US_NM_CDC',
                           State == 'New York' ~ 'US_NY_CDC',
                           State == 'North Carolina' ~ 'US_NC_CDC',
                           State == 'North Dakota' ~ 'US_ND_CDC',
                           State == 'Ohio' ~ 'US_OH_CDC',
                           State == 'Oklahoma' ~ 'US_OK_CDC',
                           State == 'Oregon' ~ 'US_OR_CDC',
                           State == 'Pennsylvania' ~ 'US_PA_CDC',
                           State == 'Rhode Island' ~ 'US_RI_CDC',
                           State == 'South Carolina' ~ 'US_SC_CDC',
                           State == 'South Dakota' ~ 'US_SD_CDC',
                           State == 'Tennessee' ~ 'US_TN_CDC',
                           State == 'Texas' ~ 'US_TX_CDC',
                           State == 'Utah' ~ 'US_UT_CDC',
                           State == 'Vermont' ~ 'US_VT_CDC',
                           State == 'Virginia' ~ 'US_VA_CDC',
                           State == 'Washington' ~ 'US_WA_CDC',
                           State == 'West Virginia' ~ 'US_WV_CDC',
                           State == 'Wisconsin' ~ 'US_WI_CDC',
                           State == 'Wyoming' ~ 'US_WY_CDC',
                           State == 'District of Columbia' ~ 'US_DC_CDC',
                           State == 'American Samoa' ~ 'US_AS_CDC',
                           State == 'Guam' ~ 'US_GU_CDC',
                           State == 'Northern Mariana Islands' ~ 'US_MP_CDC',
                           State == 'Puerto Rico' ~ 'US_PR_CDC',
                           State == 'United States Minor Outlying Islands' ~ 'US_UM_CDC',
                           State == 'U.S. Virgin Islands' ~ 'US_VI_CDC'),
         Code = paste0(short, Date),
         AgeInt = case_when(Age == "0" ~ "1",
                            Age == "1" ~ "4",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         Metric = "Count",
         Measure = "Deaths") %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  arrange(Region, Measure, Sex, suppressWarnings(as.integer(Age)))
  
############################################
#### uploading database to Google Drive ####
############################################
sheet_append(db_final,
             ss = ss_i,
             sheet = "database")
# log_update(pp = "Sweden", N = nrow(db_all))

############################################
#### uploading metadata to Google Drive ####
############################################
date = paste(sprintf("%02d",day(date_report)),
             sprintf("%02d",month(date_report)),
             year(date_report),
             sep=".")

sheet_name <- paste0("USA_CDC", date, "deaths")

meta <- drive_create(sheet_name,
                     path = ss_db, 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db, 
            ss = meta$id,
            sheet = "deaths_age")

sheet_delete(meta$id, "Sheet1")



