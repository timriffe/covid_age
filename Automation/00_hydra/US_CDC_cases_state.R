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

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(dplyr)
library(lubridate)
#install.packages("arrow")
library(arrow)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}
gs4_auth(email = email)

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

data1=read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_03_01_2022/COVID_Cases_Restricted_Detailed_01032022_Part_1.parquet")
data2=read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_03_01_2022/COVID_Cases_Restricted_Detailed_01032022_Part_2.parquet")
data3=read_parquet("K:/CDC_Covid/covid_case_restricted_detailed-master_03_01_2022/COVID_Cases_Restricted_Detailed_01032022_Part_3.parquet")


# Add datasets vertically
IN <- rbind(data1, data2, data3)

rm(data1,data2);gc()
glimpse(IN)
states <- c("AZ","AR", "DE","GU","ID","KS","ME","MA","MN","MT","NV","NJ","NC","OK","OR","PA","SC","TN","VA")

Out <-
  IN %>%
  filter(res_state %in% states) %>%
  select(Date = cdc_case_earliest_dt, 
         Sex = sex, 
         Age = age_group, 
         State = res_state)%>%
  mutate(Sex =  case_when(is.na(Sex) ~ "UNK",
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
                  `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
mutate(
  Measure = "Cases",
  Metric = "Count",
  Country = "USA") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Region= recode(State, 
                   `AZ` = "Arizona",
                   `AR`= "Arkansas",	
                   `DE`= "Delaware",
                   `GU`=  "Guam",
                   `ID`= "Idaho",
                   `KS`= "Kansas",	
                   `ME`=  "Maine",	
                   `MA`=  "Massachusetts",	
                   `MN`=  "Minnesota",	
                   `MT`=  "Montana",	
                   `NV`=  "Nevada",	
                   `NJ`=  "New Jersey",	
                   `NC`=  "North Carolina",	
                   `OK`=  "Oklahoma",	
                   `OR`=  "Oregon",	
                   `PA`=  "Pennsylvania",	
                   `SC`= "South Carolina",	
                   `TN`= "Tennessee",	
                   `VA`=  "Virginia"),
    Code= paste0 ("US_", State, Date)) %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

View(Out)
dat2 <- 
  Out %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Region, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Region) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Region)
  
  dat2 %>% 
    filter(Region %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Value), size = 0.3)+
    facet_wrap(~Region, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/CDC_checks", i, ".png")) 
}

#save output data

write_rds(Out, paste0(dir_n, ctr, ".rds"))

#manual updates 
#log_update(pp = ctr, N = nrow(Out)) 


# input data is saved on K 

