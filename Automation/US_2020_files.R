rm(list=ls())
source("Automation/00_Functions_automation.R")
# install.packages("tidyverse")
# library(tidyverse)
fls <- list.files("Data/USA_2020_files")
# i <- 1
all <- tibble()
for(i in 1:length(fls)){
  temp1 <- 
    read_csv(paste0("Data/USA_2020_files/", fls[i]))
  
  temp2 <- 
    temp1 %>% 
    select(date_reg = 1,
           Date = 3,
           State, 
           Sex,
           Age = 6,
           Value = 7) %>% 
    filter(!Age %in% c("0-17 years", 
                       "18-29 years", 
                       "30-49 years", 
                       "50-64 years")) %>% 
    mutate(Sex = case_when(Sex %in% c("Female", "Female Total") ~ "f",
                           Sex %in% c("Male", "Male Total") ~ "m",
                           Sex %in% c("All Sexes", "All sexes", 
                                      "All Sexes Total", "All") ~ "t",
                           Sex %in% c("Unknown") ~ "u",
                           TRUE ~ "hhhh"),
           Age = str_sub(Age, 1, 2),
           Age = case_when(Age == "Un" ~ "0",
                           Age == "1-" ~ "1",
                           Age == "5-" ~ "5",
                           Age %in% c("Al", "Ma", "Fe") ~ "t",
                           TRUE ~ Age),
           State = str_replace(State, " Total", ""))
    
  all <- 
    all %>% 
    bind_rows(temp2)

}
  
unique(all$Sex)
unique(all$Age)

all2 <- 
  all %>% 
  group_by(Date, State, Sex, Age) %>% 
  filter(date_reg == max(date_reg)) %>% 
  mutate(id = 1:n()) %>% 
  ungroup() %>% 
  filter(id == 1) %>% 
  select(-id, -date_reg)

# no_nas <- 
#   all2 %>% 
#   drop_na() %>% 
#   filter(Age != "t",
#          Sex != "t") %>% 
#   group_by(Date, State) %>% 
#   summarise(no_na = sum(Value))
# 
# all3 <- 
#   all2 %>% 
#   filter(Age == "t", 
#          Sex == "t") %>% 
#   drop_na() %>% 
#   group_by(Date, State) %>% 
#   summarise(all = sum(Value, rm.na = T))
# 
# vs <- all3 %>% 
#   left_join(no_nas) %>% 
#   mutate(difs = all - no_na,
#          prop = no_na / all) %>% 
#   arrange(prop)


# Imputation of NAs using the same distribution of the national level
#######################################################################

all_us <- 
  all2 %>% 
  filter(State == "United States",
         Age != "t",
         Sex %in% c("f", "m")) %>% 
  select(Date, Sex, Age, Value) %>% 
  rename(us = Value)

totals <- 
  all2 %>% 
  filter(Age == "t",
         State != "United States",
         Sex %in% c("f", "m")) %>% 
  rename(all = Value) %>% 
  select(-Age) 

no_na_sum <- 
  all2 %>% 
  filter(Age != "t",
         Sex %in% c("f", "m")) %>% 
  drop_na() %>% 
  group_by(Date, State, Sex) %>% 
  summarise(no_nas = sum(Value)) %>% 
  ungroup()

diffs <- 
  totals %>% 
  drop_na(all) %>% 
  left_join(no_na_sum) %>% 
  mutate(diff = all - no_nas,
         prop_known = no_nas / all)

ages_na <- 
  all2 %>% 
  filter(is.na(Value),
         Age != "t",
         Sex %in% c("f", "m")) %>% 
  select(-Value) %>% 
  left_join(all_us) %>% 
  group_by(Date, State, Sex) %>% 
  mutate(prop = us / sum(us)) %>% 
  ungroup() %>% 
  left_join(diffs %>% 
              select(Date, State, Sex, diff, prop_known)) %>% 
  mutate(imput = diff * prop,
         imp2 = round(imput),
         imp2 = case_when(imp2 < 1 ~ 1, 
                          imp2 > 9 ~ 9, 
                          TRUE ~ imp2)) %>% 
  arrange(Date, State, Sex, suppressWarnings(as.integer(Age)))

to_include <- 
  ages_na %>% 
  filter(!is.na(imp2)) %>% 
  filter(!is.na(prop_known) & prop_known >= 0.7) %>% 
  select(Date, State, Sex) %>% 
  unique() %>% 
  mutate(include = 1)

props_known <- 
  diffs %>% 
  select(Date, State, Sex, prop_known) %>% 
  unique()

ages_na2 <- 
  ages_na %>% 
  arrange(Date, State, Sex, suppressWarnings(as.integer(Age))) %>%
  rename(Value = imp2) %>% 
  select(Date, State, Age, Sex, Value) %>% 
  mutate(imp = 1)

# excess_state <- 
#   ages_na %>%
#   group_by(Date, State, Sex) %>% 
#   mutate(tot_imp = sum(imp2),
#          diff_imp = tot_imp - diff) %>% 
#   summarise(diff_imp = mean(diff_imp))



# binding data and imputations for NAs and adjusting to COVerAGE-DB format
###########################################################################

all3 <- 
  all2 %>% 
  filter(!is.na(Value),
         State != "United States",
         Sex != "u") %>% 
  mutate(imp = 0) %>% 
  bind_rows(ages_na2) %>% 
  arrange(Date, State, Sex, suppressWarnings(as.integer(Age))) %>% 
  left_join(to_include) %>%
  filter(!is.na(include)) %>% 
  mutate(Date = mdy(Date))

all4 <- 
  all3 %>% 
  group_by(Date, State, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b") %>% 
  bind_rows(all3) 
  
out <- 
  all4 %>% 
  mutate(Country = "USA",
         Region = State,
         Code = case_when(State == 'Alabama' ~ 'US-AL',
                          State == 'Alaska' ~ 'US-AK',
                          State == 'Arizona' ~ 'US-AZ',
                          State == 'Arkansas' ~ 'US-AR',
                          State == 'California' ~ 'US-CA',
                          State == 'Colorado' ~ 'US-CO',
                          State == 'Connecticut' ~ 'US-CT',
                          State == 'Delaware' ~ 'US-DE',
                          State == 'Florida' ~ 'US-FL',
                          State == 'Georgia' ~ 'US-GA',
                          State == 'Hawaii' ~ 'US-HI',
                          State == 'Idaho' ~ 'US-ID',
                          State == 'Illinois' ~ 'US-IL',
                          State == 'Indiana' ~ 'US-IN',
                          State == 'Iowa' ~ 'US-IA',
                          State == 'Kansas' ~ 'US-KS',
                          State == 'Kentucky' ~ 'US-KY',
                          State == 'Louisiana' ~ 'US-LA',
                          State == 'Maine' ~ 'US-ME',
                          State == 'Maryland' ~ 'US-MD',
                          State == 'Massachusetts' ~ 'US-MA',
                          State == 'Michigan' ~ 'US-MI',
                          State == 'Minnesota' ~ 'US-MN',
                          State == 'Mississippi' ~ 'US-MS',
                          State == 'Missouri' ~ 'US-MO',
                          State == 'Montana' ~ 'US-MT',
                          State == 'Nebraska' ~ 'US-NE',
                          State == 'Nevada' ~ 'US-NV',
                          State == 'New Hampshire' ~ 'US-NH',
                          State == 'New Jersey' ~ 'US-NJ',
                          State == 'New Mexico' ~ 'US-NM',
                          State == 'New York' ~ 'US-NY',
                          State == 'New York City' ~ 'US-NYC',
                          State == 'North Carolina' ~ 'US-NC',
                          State == 'North Dakota' ~ 'US-ND',
                          State == 'Ohio' ~ 'US-OH',
                          State == 'Oklahoma' ~ 'US-OK',
                          State == 'Oregon' ~ 'US-OR',
                          State == 'Pennsylvania' ~ 'US-PA',
                          State == 'Rhode Island' ~ 'US-RI',
                          State == 'South Carolina' ~ 'US-SC',
                          State == 'South Dakota' ~ 'US-SD',
                          State == 'Tennessee' ~ 'US-TN',
                          State == 'Texas' ~ 'US-TX',
                          State == 'Utah' ~ 'US-UT',
                          State == 'Vermont' ~ 'US-VT',
                          State == 'Virginia' ~ 'US-VA',
                          State == 'Washington' ~ 'US-WA',
                          State == 'West Virginia' ~ 'US-WV',
                          State == 'Wisconsin' ~ 'US-WI',
                          State == 'Wyoming' ~ 'US-WY',
                          State == 'District of Columbia' ~ 'US-DC',
                          State == 'American Samoa' ~ 'US-AS',
                          State == 'Guam' ~ 'US-GU',
                          State == 'Northern Mariana Islands' ~ 'US-MP',
                          State == 'Puerto Rico' ~ 'US-PR',
                          State == 'United States Minor Outlying Islands' ~ 'US-UM',
                          State == 'U.S. Virgin Islands' ~ 'US-VI'),
         Age = ifelse(Age == "t", "TOT", Age),
         AgeInt = case_when(Age == "0" ~ "1",
                            Age == "1" ~ "4",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         Metric = "Count",
         Measure = "Deaths") %>% 
  select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  arrange(Date, Region, Measure, Sex, suppressWarnings(as.integer(Age)))


# stored data
# ~~~~~~~~~~~
ctr <- "USA_deaths_states"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
db_drive <- 
  read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Date = dmy(Date))

# looking for the first date in drive
min_date <- 
  db_drive %>% 
  select(Date) %>% 
  filter(Date == min(Date)) %>% 
  unique() %>% 
  dplyr::pull()

# merging 2020 data and most recent data
out2 <- 
  out %>% 
  filter(Date < min_date) %>% 
  bind_rows(db_drive)


# saving data all together
write_rds(out2, paste0(dir_n, ctr, ".rds"))


# ==========================
# from monthly data

# url <- "https://data.cdc.gov/api/views/9bhg-hcku/rows.csv?accessType=DOWNLOAD"
# in1 <- read_csv(url)
# 
# ages1 <- c("All Ages", "Under 1 year", "1-4 years", "5-14 years", 
#            "15-24 years", "25-34 years", "35-44 years", "45-54 years", 
#            "55-64 years", "65-74 years", "75-84 years", "85 years and over")
# 
# in2 <- 
#   in1 %>% 
#   select(`End Date`, 'State', "Age Group", "Sex", "COVID-19 Deaths", "Group") %>% 
#   rename(Age = "Age Group",
#          Value = "COVID-19 Deaths",
#          Date = `End Date`) %>% 
#   filter(Age %in% ages1,
#          Group == "By Month") %>% 
#   mutate(Sex = case_when(Sex %in% c("Female", "Female Total") ~ "f",
#                          Sex %in% c("Male", "Male Total") ~ "m",
#                          Sex %in% c("All Sexes", "All sexes", 
#                                     "All Sexes Total", "All") ~ "t",
#                          Sex %in% c("Unknown") ~ "u",
#                          TRUE ~ "hhhh"),
#          Age = str_sub(Age, 1, 2),
#          Age = case_when(Age == "Un" ~ "0",
#                          Age == "1-" ~ "1",
#                          Age == "5-" ~ "5",
#                          Age %in% c("Al", "Ma", "Fe") ~ "t",
#                          TRUE ~ Age),
#          State = str_replace(State, " Total", ""))
# 
# mth_all_us <- 
#   in2 %>% 
#   filter(State == "United States",
#          Age != "t",
#          Sex %in% c("f", "m")) %>% 
#   select(Date, Sex, Age, Value) %>% 
#   rename(us = Value)
# 
# mth_totals <- 
#   in2 %>% 
#   filter(Age == "t",
#          State != "United States",
#          Sex %in% c("f", "m")) %>% 
#   rename(all = Value) %>% 
#   select(-Age) 
# 
# mth_no_na_sum <- 
#   in2 %>% 
#   filter(Age != "t",
#          Sex %in% c("f", "m")) %>% 
#   drop_na() %>% 
#   group_by(Date, State, Sex) %>% 
#   summarise(no_nas = sum(Value)) %>% 
#   ungroup()
# 
# mth_diffs <- 
#   mth_totals %>% 
#   drop_na(all) %>% 
#   left_join(mth_no_na_sum) %>% 
#   mutate(diff = all - no_nas,
#          prop_known = no_nas / all)
# 
# mth_ages_na <- 
#   in2 %>% 
#   filter(is.na(Value),
#          Age != "t",
#          Sex %in% c("f", "m")) %>% 
#   select(-Value) %>% 
#   left_join(mth_all_us) %>% 
#   group_by(Date, State, Sex) %>% 
#   mutate(prop = us / sum(us)) %>% 
#   ungroup() %>% 
#   left_join(mth_diffs %>% 
#               select(Date, State, Sex, diff, prop_known)) %>% 
#   mutate(imput = diff * prop,
#          imp2 = round(imput),
#          imp2 = case_when(imp2 < 1 ~ 1, 
#                           imp2 > 9 ~ 9, 
#                           TRUE ~ imp2)) %>% 
#   arrange(Date, State, Sex, suppressWarnings(as.integer(Age)))
# 
# mth_to_include <- 
#   mth_ages_na %>% 
#   filter(!is.na(imp2)) %>% 
#   filter(!is.na(prop_known) & prop_known >= 0.7) %>% 
#   select(Date, State, Sex) %>% 
#   unique() %>% 
#   mutate(include = 1)
# 
# mth_props_known <- 
#   mth_diffs %>% 
#   select(Date, State, Sex, prop_known) %>% 
#   unique()
# 
# mth_ages_na2 <- 
#   mth_ages_na %>% 
#   arrange(Date, State, Sex, suppressWarnings(as.integer(Age))) %>%
#   rename(Value = imp2) %>% 
#   select(Date, State, Age, Sex, Value) %>% 
#   mutate(imp = 1)
# 
# mth3 <- 
#   in2 %>% 
#   filter(!is.na(Value),
#          State != "United States",
#          Sex != "u") %>% 
#   mutate(imp = 0) %>% 
#   bind_rows(mth_ages_na2) %>% 
#   arrange(Date, State, Sex, suppressWarnings(as.integer(Age))) %>% 
#   left_join(mth_to_include) %>%
#   filter(!is.na(include)) %>% 
#   group_by(Date, State, Sex) %>% 
#   mutate(size = n()) %>% 
#   ungroup() %>% 
#   group_by(State, Sex, Age) %>% 
#   mutate(size2 = n()) %>% 
#   ungroup()
# 
# comps <- 
#   mth3 %>% 
#   select(Date, State, Sex, size2) %>% 
#   unique() %>% 
#   mutate(Date = mdy(Date))
#   
