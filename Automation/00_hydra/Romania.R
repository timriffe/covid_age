#Romania cases 

library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
library(dplyr)
library(tidyverse)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Romania" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Romania"



# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)


# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "RO")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive 

In_drive <- get_country_inputDB("RO")%>% 
  select(-Short)%>% 
  mutate(Value = as.character(Value))

#Read in downloads from N 
 
#Read in Age data 

all_paths <-
  list.files(path = dir_n_source,
             pattern = "Age",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_xlsx)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

Age_in <- rbindlist(all_lists, fill = T)


#process 

Age_Out= Age_in %>%
  separate(V1, c("1","2","Date"), "a")%>%
  select(Age, Value= Numbers, Date)%>%
  separate(Date,c("Date", "4"), ".xlsx" )%>%
  separate(Value, c("Value", "5"), " ")%>%
  select(Age, Date, Value)%>%
  mutate(Age=recode(Age, 
                    `0-9`="0",
                    `10-19`="10",
                    `20-29`="20",
                    `30-39`="30",
                    `40-49`="40",
                    `50-59`="50",
                    `60-69`="60",
                    `70-79`="70",
                    `>80`="80",
                    `în procesare`="UNK"))%>% 
  mutate(AgeInt = case_when(
    Age == "80" ~ 25L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L))%>%
  mutate(
    Measure = "Cases",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("RO"),
    Country = "Romania",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Value = as.character(Value))

###death data


#put together

RO_out <- 
  In_drive %>% 
  filter(dmy(Date) < min(dmy(Age_Out$Date))) %>% 
  bind_rows(Age_Out) %>% 
  sort_input_data()



#upload 

write_sheet(RO_out, 
            ss = ss_i, 
            sheet = "database")


log_update("Romania", N = nrow(RO_out))


# ------------------------------------------
# now archive

data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")

write_csv(Age_in, data_source)

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






























































