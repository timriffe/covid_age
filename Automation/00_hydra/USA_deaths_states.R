library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "USA_deaths_states"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "USA_CDC")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# # reading data in Drive 
# db_drive <- get_country_inputDB("USA_CDC")
db_drive <- read_rds(paste0(dir_n, ctr, ".rds"))
# -------------------------------------

# info by age for each state!!
url <- "https://data.cdc.gov/api/views/9bhg-hcku/rows.csv?accessType=DOWNLOAD"
data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
download.file(url, destfile = data_source)
db <- read_csv(data_source)

unique(db$`Age Group`)
unique(db$`Group`)

ages_all <- c("All Ages", "Under 1 year", "0-17 years", "1-4 years", 
              "5-14 years", "15-24 years", "18-29 years", "25-34 years", 
              "30-49 years", "35-44 years", "45-54 years", "50-64 years", 
              "55-64 years", "65-74 years", "75-84 years", "85 years and over")
ages1 <- c("All Ages", "Under 1 year", "1-4 years", "5-14 years", 
           "15-24 years", "25-34 years", "35-44 years", "45-54 years", 
           "55-64 years", "65-74 years", "75-84 years", "85 years and over")
ages2 <- c("All Ages", "0-17 years", "18-29 years", "30-49 years", 
           "50-64 years", "65-74 years", "75-84 years", "85 years and over")

date_report <- mdy(db$`Data As Of`[1])
date_f <- mdy(db$`End Date`[1])

db2 <- db %>% 
  select("State", "Age Group", "Sex", "COVID-19 Deaths", "Group") %>% 
  rename(Age = "Age Group",
         Value = "COVID-19 Deaths") %>% 
  filter(Age %in% ages1,
         Group == "By Total") %>% 
  select(-Group)
  
db3 <- db %>% 
  select("State", "Age Group", "Sex", "COVID-19 Deaths", "Group") %>% 
  rename(Age = "Age Group",
         Value = "COVID-19 Deaths") %>% 
  filter(Age %in% ages1,
         Sex != "Unknown",
         Group == "By Total") %>% 
  select(-Group)

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

# All states above 90% of ages identified when using wide age groups, 

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


# Imputation of NAs using the same distribution of the national level
#######################################################################

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

totals2 <- totals %>% 
  group_by(State) %>% 
  summarise(all = sum(all)) %>% 
  ungroup() %>% 
  mutate(Sex = "b") %>% 
  bind_rows(totals)

sums <- db4 %>% 
  filter(Age != "TOT") %>% 
  drop_na() %>% 
  group_by(State, Sex) %>% 
  summarise(no_nas = sum(Value))

diffs <- totals2 %>% 
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

# 51 cases excess in total for the whole country with imputations
excess_state %>% 
  group_by() %>% 
  summarise(diff_imp = sum(diff_imp))

ages_na3 <- ages_na2 %>% 
  rename(Value = imp2) %>% 
  select(State, Age, Sex, Value) %>% 
  mutate(imp = 1)
  

# binding data and imputations for NAs and adjusting to COVerAGE-DB format
###########################################################################

date_data <- ddmmyyyy(date_f)

db5 <- db4 %>% 
  filter(!is.na(Value),
         State != "United States") %>% 
  mutate(imp = 0) %>% 
  bind_rows(ages_na3) %>% 
  arrange(State, Sex, suppressWarnings(as.integer(Age))) %>% 
  mutate(Country = "USA",
         Region = State,
         Date = date_data,
         short = case_when(State == 'Alabama' ~ 'US_CDC_AL',
                           State == 'Alaska' ~ 'US_CDC_AK',
                           State == 'Arizona' ~ 'US_CDC_AZ',
                           State == 'Arkansas' ~ 'US_CDC_AR',
                           State == 'California' ~ 'US_CDC_CA',
                           State == 'Colorado' ~ 'US_CDC_CO',
                           State == 'Connecticut' ~ 'US_CDC_CT',
                           State == 'Delaware' ~ 'US_CDC_DE',
                           State == 'Florida' ~ 'US_CDC_FL',
                           State == 'Georgia' ~ 'US_CDC_GA',
                           State == 'Hawaii' ~ 'US_CDC_HI',
                           State == 'Idaho' ~ 'US_CDC_ID',
                           State == 'Illinois' ~ 'US_CDC_IL',
                           State == 'Indiana' ~ 'US_CDC_IN',
                           State == 'Iowa' ~ 'US_CDC_IA',
                           State == 'Kansas' ~ 'US_CDC_KS',
                           State == 'Kentucky' ~ 'US_CDC_KY',
                           State == 'Louisiana' ~ 'US_CDC_LA',
                           State == 'Maine' ~ 'US_CDC_ME',
                           State == 'Maryland' ~ 'US_CDC_MD',
                           State == 'Massachusetts' ~ 'US_CDC_MA',
                           State == 'Michigan' ~ 'US_CDC_MI',
                           State == 'Minnesota' ~ 'US_CDC_MN',
                           State == 'Mississippi' ~ 'US_CDC_MS',
                           State == 'Missouri' ~ 'US_CDC_MO',
                           State == 'Montana' ~ 'US_CDC_MT',
                           State == 'Nebraska' ~ 'US_CDC_NE',
                           State == 'Nevada' ~ 'US_CDC_NV',
                           State == 'New Hampshire' ~ 'US_CDC_NH',
                           State == 'New Jersey' ~ 'US_CDC_NJ',
                           State == 'New Mexico' ~ 'US_CDC_NM',
                           State == 'New York' ~ 'US_CDC_NY',
                           State == 'New York City' ~ 'US_CDC_NYC',
                           State == 'North Carolina' ~ 'US_CDC_NC',
                           State == 'North Dakota' ~ 'US_CDC_ND',
                           State == 'Ohio' ~ 'US_CDC_OH',
                           State == 'Oklahoma' ~ 'US_CDC_OK',
                           State == 'Oregon' ~ 'US_CDC_OR',
                           State == 'Pennsylvania' ~ 'US_CDC_PA',
                           State == 'Rhode Island' ~ 'US_CDC_RI',
                           State == 'South Carolina' ~ 'US_CDC_SC',
                           State == 'South Dakota' ~ 'US_CDC_SD',
                           State == 'Tennessee' ~ 'US_CDC_TN',
                           State == 'Texas' ~ 'US_CDC_TX',
                           State == 'Utah' ~ 'US_CDC_UT',
                           State == 'Vermont' ~ 'US_CDC_VT',
                           State == 'Virginia' ~ 'US_CDC_VA',
                           State == 'Washington' ~ 'US_CDC_WA',
                           State == 'West Virginia' ~ 'US_CDC_WV',
                           State == 'Wisconsin' ~ 'US_CDC_WI',
                           State == 'Wyoming' ~ 'US_CDC_WY',
                           State == 'District of Columbia' ~ 'US_CDC_DC',
                           State == 'American Samoa' ~ 'US_CDC_AS',
                           State == 'Guam' ~ 'US_CDC_GU',
                           State == 'Northern Mariana Islands' ~ 'US_CDC_MP',
                           State == 'Puerto Rico' ~ 'US_CDC_PR',
                           State == 'United States Minor Outlying Islands' ~ 'US_CDC_UM',
                           State == 'U.S. Virgin Islands' ~ 'US_CDC_VI'),
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
  
out <- db_drive %>% 
  filter(Date != date_data) %>% 
  mutate(AgeInt = as.character(AgeInt)) %>% 
  #select(-Short) %>% 
  bind_rows(db5) %>% 
  sort_input_data()

unique(out$Region)
unique(out$Date)

############################################
#### uploading database to Google Drive ####
############################################
write_sheet(out,
             ss = ss_i,
             sheet = "database")

write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

############################################
#### uploading metadata to Google Drive ####
############################################

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)


