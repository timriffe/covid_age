# Indiana 

library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


#open questions
#How do I keep the manually entered vaccine data?
#How to I set the connection with the automation sheet up? 


# info country and N drive address

ctr          <- "US_Indiana" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Bulgaria" #########################################What is this used for?  


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)



# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "US_IN")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

In_drive <- get_country_inputDB("US_IN")%>% 
  select(-Short)

#Read in files 

#Cases

cases_url <- "https://hub.mph.in.gov/datastore/dump/46b310b9-2f29-4a51-90dc-3886d9cf4ac1?bom=True"
IN_cases<- read_csv(cases_url)

##Death

# Read it in 
death_url <- "https://hub.mph.in.gov/datastore/dump/7661f008-81b5-4ff2-8e46-f59ad5aad456?bom=True"
IN_death<- read_csv(death_url)



################Reformat cases###############

#sort by date

#change to date class 
IN_cases$DATE <- as.Date(IN_cases$DATE,            
                      format = "%Y-%m-%d")

#Date class is Date now 

In_sort= IN_cases[order(IN_cases$DATE),]

library(dplyr)

In_select= In_sort %>%
  select(DATE, AGEGRP, GENDER, COVID_COUNT)


#sum by day  
In_sum= aggregate(COVID_COUNT~DATE+AGEGRP+GENDER, data=In_select, FUN=sum) 

#cumulative sum


In_csum= In_sum %>%
  group_by(GENDER,AGEGRP) %>%
  mutate(cum_sum = cumsum(COVID_COUNT))

Incsum_select= In_csum %>%
  select(DATE, AGEGRP, GENDER, cum_sum)

#reformate to database 

#reformate gender colunm for database 

In_cases_in= Incsum_select %>% 
  rename(Sex= GENDER)

In_cases_in$Sex[In_cases_in$Sex == "M"] <- "m"
In_cases_in$Sex[In_cases_in$Sex == "F"] <- "f"
In_cases_in$Sex[In_cases_in$Sex == "Unknown"] <- "UNK"

#change age groups 

In_cases_out= In_cases_in %>% 
  rename(Age = AGEGRP)%>% 
  mutate(Age=recode(Age, 
                    `0-19`="0",
                    `20-29`="20",
                    `30-39`="30",
                    `40-49`="40",
                    `50-59`="50",
                    `60-69`="60",
                    `70-79`="70",
                    `80+`="80",
                    `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 20L,
    Age == "80" ~ 35L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>% 
  rename(Value = cum_sum,
         Date=DATE) %>% 
  mutate(
    Measure = "Cases",
    Metric = "Count") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_IN",Date),
    Country = "USA",
    Region = "Indiana",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
 

#####################################Deaths#######################################################

#sort by date

#change to date class 
IN_death$date <- as.Date(IN_death$date,             
                          format = "%Y-%m-%d")

#Date class is Date now 

In_sortD= IN_death[order(IN_death$date),]


#sum by day
In_sumD= aggregate(covid_deaths~date+agegrp, data=In_sortD, FUN=sum) 

#cumulative sum

In_csumD= In_sumD %>%
  group_by(agegrp) %>%
  mutate(cum_sum = cumsum(covid_deaths))

Incsum_selectD= In_csumD %>%
  select(date, agegrp, cum_sum)


#reformate to database 

#change age groups 

In_death_out= Incsum_selectD %>% 
  rename(Age = agegrp)%>% 
  mutate(Age=recode(Age, 
                     `0-19`="0",
                     `20-29`="20",
                     `30-39`="30",
                      `40-49`="40",
                      `50-59`="50",
                      `60-69`="60",
                      `70-79`="70",
                      `80+`="80",
                      `Unknown`="UNK"))%>% 
  mutate(AgeInt = case_when(
                      Age == "0" ~ 20L,
                      Age == "80" ~ 35L,
                      Age == "UNK" ~ NA_integer_,
                      TRUE ~ 10L))%>% 
  rename(Value = cum_sum,
         Date= date) %>% 
  mutate(
  Measure = "Death",
  Metric = "Count",
  Sex= "b") %>% 
  mutate(
  Date = ymd(Date),
  Date = paste(sprintf("%02d",day(Date)),    
               sprintf("%02d",month(Date)),  
               year(Date),sep="."),
  Code = paste0("US_IN",Date),
  Country = "USA",
  Region = "Indiana",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


######combine both to one dataframe########## 

In_out <- bind_rows(In_cases_out,
                    In_death_out)

# In case we had earlier data, we keep it.
#############################################################################Not sure why I lose the vaccine data here 

In_out <- 
  In_drive %>% 
  filter(dmy(Date) < min(dmy(In_out$Date))) %>% 
  bind_rows(In_out) %>% 
  sort_input_data()

View(In_out)
View(In_drive)

# upload to Drive, overwrites


write_sheet(In_out, 
            ss = ss_i, 
            sheet = "database")


##########################################################Is this for the automation sheet? How do I set this up in the sheet?

#log_update("Bulgaria", N = nrow(BG_out))


# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")

write_csv(IN_cases, data_source_1)
write_csv(IN_death, data_source_2)

data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

####################################
















# Archive inputs
data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
write_csv(TH, data_source)
zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")
zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)
# end







