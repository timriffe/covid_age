# CDC state data: Arizona	AZ
#Arkansas	AR
#Delaware	DE
#Guam 	GU
#Idaho	ID
#Kansas	KS
#Maine	ME
#Massachusetts	MA
#Minnesota	MN
#Montana	MT
#Nevada	NV
#New Jersey	NJ
#North Carolina	NC
#Oklahoma	OK
#Oregon	OR
#Pennsylvania	PA
#South Carolina	SC
#Tennessee	TN
#Virginia	VA

source(here::here("Automation/00_Functions_automation.R"))

library(dplyr)
library(lubridate)
#install.packages("arrow")
library(arrow)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


ctr          <- "US_CDC_cases_state" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Read in data 


# data1 <- read.csv(file= 'K:/CDC_Covid/covid_case_restricted_detailed-master_06_2021/data/2021-06-21/COVID_Cases_Restricted_Detailed_06212021_Part_1.csv', 
#                   fileEncoding="UTF-8-BOM", na.strings=c('NA','','Missing'))
# str(data1)
# 
# data2 <- read.csv(file= 'K:/CDC_Covid/covid_case_restricted_detailed-master_06_2021/data/2021-06-21/COVID_Cases_Restricted_Detailed_06212021_Part_2.csv',
#                   fileEncoding="UTF-8-BOM",  na.strings=c('NA','','Missing')) 
# 
# str(data2)
# 
# data3 <- read.csv(file= 'K:/CDC_Covid/covid_case_restricted_detailed-master_06_2021/data/2021-06-21/COVID_Cases_Restricted_Detailed_06212021_Part_3.csv',
#                   fileEncoding="UTF-8-BOM",  na.strings=c('NA','','Missing')) 
# 
# str(data3)
# 
# data4 <- read.csv(file= 'K:/CDC_Covid/covid_case_restricted_detailed-master_06_2021/data/2021-06-21/COVID_Cases_Restricted_Detailed_06212021_Part_4.csv',
#                   fileEncoding="UTF-8-BOM",  na.strings=c('NA','','Missing')) 


#read in data faster 

data1 <- read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_06_06_2022/COVID_Cases_Restricted_Detailed_06062022_Part_1.parquet",
                      col_select = c("cdc_case_earliest_dt", "sex", "age_group", "res_state"))
data2 <- read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_06_06_2022/COVID_Cases_Restricted_Detailed_06062022_Part_2.parquet",
                      col_select = c("cdc_case_earliest_dt", "sex", "age_group", "res_state"))
data3 <- read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_06_06_2022/COVID_Cases_Restricted_Detailed_06062022_Part_3.parquet",
                      col_select = c("cdc_case_earliest_dt", "sex", "age_group", "res_state"))
data4 <- read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_06_06_2022/COVID_Cases_Restricted_Detailed_06062022_Part_4.parquet",
                      col_select = c("cdc_case_earliest_dt", "sex", "age_group", "res_state"))

# Add datasets vertically
IN <- rbind(data1, data2, data3, data4)

rm(data1,data2,data3, data4);gc()
glimpse(IN)
states <- c("AZ","AR", "DE","GU","ID","KS","ME","MA","MN","MT","NV","NJ","NC","OK","OR","PA","SC","TN","VA", "IL")

Out1 <-
  IN %>%
  filter(res_state %in% states) %>%
  select(Date = cdc_case_earliest_dt, 
         Sex = sex, 
         Age = age_group, 
         State = res_state)%>%
  mutate(Sex =  case_when(is.na(Sex) ~ "UNK",
                          Sex == "NA" ~ "UNK",
                        Sex== "Unknown" ~ "UNK",
                        Sex== "Missing" ~ "UNK",
                        Sex== "Other" ~ "UNK",
                        Sex== "Male" ~ "m",
                        Sex== "Female"~"f",
                        TRUE ~ as.character(Sex)),
         Age = case_when (is.na(Age) ~ "UNK",
                         Age== "Unknown" ~" UNK",
                         TRUE~ as.character(Age)))%>%
  group_by(Date, Sex, Age, State) %>% 
  summarize(Value = n(), .groups = "drop")%>%
  tidyr::complete(Date, Sex, Age, State, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, State, Date) %>% 
  group_by(Sex, Age, State) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()%>%
  mutate(Age = recode(Age, 
                  `0 - 9 Years`="0",
                  `10 - 19 Years`="10",
                  `20 - 29 Years`="20",
                  `30 - 39 Years`="30",
                  `40 - 49 Years`="40",
                  `50 - 59 Years`="50",
                  `60 - 69 Years`="60",
                  `70 - 79 Years`="70",
                  `80+ Years`="80",
                  `Missing`="UNK",
                  `NA`="UNK")) %>% 
  group_by(Date, Age, Sex, State) %>% 
  summarise(Value = sum(Value))

Out <- Out1 %>% 
  mutate(AgeInt = case_when(
         Age == "80" ~ 25L,
         Age == "UNK" ~ NA_integer_,
         TRUE ~ 10L),
    Measure = "Cases",
    Metric = "Count",
    Country = "USA",
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Region= case_when( 
              State == "AZ" ~ "Arizona",
              State == "AR" ~ "Arkansas",
              State == "DE" ~ "Delaware",
              State == "GU" ~  "Guam",
              State == "ID" ~ "Idaho",
              State == "KS" ~ "Kansas",
              State == "ME" ~  "Maine",
              State == "MA" ~  "Massachusetts",
              State == "MN" ~  "Minnesota",
              State == "MT" ~  "Montana",
              State == "NV" ~  "Nevada",
              State == "NJ" ~  "New Jersey",
              State == "NC" ~  "North Carolina",
              State == "OK" ~  "Oklahoma",
              State == "OR" ~  "Oregon",
              State == "PA" ~  "Pennsylvania",
              State == "SC" ~ "South Carolina",
              State == "TN" ~ "Tennessee",
              State == "VA" ~  "Virginia",
              State == "IL" ~ "Illinois"),
                   ## states abbs
             #    State == "AK" ~ "Alaska",
             #    State == "AL" ~ "Alabama",
             #    State == "AR" ~ "Arkansas",
             #    State == "AZ" ~ "Arizona",
             #    State == "BP2"~ "Bureau of Prisons",
             #    State == "CA" ~ "California",
             # #   State == "CA."~ "California",
             #    State == "CO" ~ "Colorado",
             #    State == "CT" ~ "Connecticut",
             #    State == "DC" ~ "District of Columbia",
             #    State == "DE" ~ "Delaware",
             #    State == "FL" ~ "Florida",
             #    State == "GA" ~ "Georgia",
             #    State == "GU" ~ "Guam",
             #    State == "HI" ~ "Hawaii",
             #    State == "IA" ~ "Iowa",
             #    State == "ID" ~ "Idaho",
             #    State == "IL" ~ "Illinois",
             #    State == "IN" ~ "Indiana",
             #    State == "KS" ~ "Kansas",
             #    State == "KY" ~ "Kentucky",
             #    State == "LA" ~ "Louisiana",
             #    State == "MA" ~ "Massachusetts",
             #    State == "MD" ~ "Maryland",
             #    State == "ME" ~ "Maine",
             #    State == "MI" ~ "Michigan",
             #    State == "MN" ~ "Minnesota",
             #    State == "MO" ~ "Missouri",
             #    State == "MP" ~ "Northern Mariana Islands",
             #    State == "MS" ~ "Mississippi",
             #    State == "MT" ~ "Montana",
             #    State == "NC" ~ "North Carolina",
             #    State == "ND" ~ "North Dakota",
             #    State == "NE" ~ "Nebraska",
             #    State == "NH" ~ "New Hampshire",
             #    State == "NJ" ~ "New Jersey",
             #    State == "NM" ~ "New Mexico",
             #    State == "NV" ~ "Nevada",
             #    State == "NY" ~ "New York State",
             #    State == "OH" ~ "Ohio",
             #    State == "OK" ~ "Oklahoma",
             #    State == "OR" ~ "Oregon",
             #    State == "PA" ~ "Pennsylvania",
             #    State == "PR" ~ "Puerto Rico",
             #    State == "RI" ~ "Rhode Island",
             #    State == "SC" ~ "South Carolina",
             #    State == "SD" ~ "South Dakota",
             #    State == "TN" ~ "Tennessee",
             #    State == "TX" ~ "Texas",
             #    State == "UT" ~ "Utah",
             #    State == "VA" ~ "Virginia",
             #    State == "VI" ~ "Virgin Islands",
             #    State == "VT" ~ "Vermont",
             #    State == "WA" ~ "Washington",
             #    State == "WI" ~ "Wisconsin",
             #    State == "WV" ~ "West Virginia",
             #    State == "WY" ~ "Wyoming",
             #    State == "NA" ~ "Unknown"),
    Code= paste0 ("US-", State)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#save output data

write_rds(Out, paste0(dir_n, ctr, ".rds"))

#manual updates 
#log_update(pp = ctr, N = nrow(Out)) 


# input data is saved on K 

