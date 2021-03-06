#Lebanon vaccine 

library(here)
source('U:/GitHub/Covid/Automation/00_Functions_automation.R')
library(lubridate)
library(dplyr)
library(tidyverse)
library(readxl)
library(googledrive)
library(purrr)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Lebanon" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% filter(Short == "LB")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# reading data from Drive and last date entered 

In_drive <- get_country_inputDB("LB")%>% 
  select(-Short)%>%
  mutate(AgeInt= as.character(AgeInt))%>%
  subset(Measure!= "Vaccinations")


#Read in manually downloaded data from drive until download can be automated 

## store the URL you have
folder_url <- "https://drive.google.com/drive/folders/1INEOfbXHU_7L4TtghkjnebL1sqKbVQAA"

## identify this folder on Drive
folder <- drive_get(as_id(folder_url))
## identify the csv files in that folder
xlsx_files <- drive_ls(folder, type = "xlsx")

## download them 
#This is the best way I could find to put them in a tempfile instead to locally downloading
#seems to be tricky to change to a tempfile when downloading multiple files 
xlsx_dir <- tempdir()
setwd(xlsx_dir)
walk(xlsx_files$id, ~ drive_download(as_id(.x), overwrite = TRUE))


#Read in Age data 

all_paths <-
  list.files(path = xlsx_dir,
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

View(Age_in)
#Process age data 


Age_Out= Age_in %>%
  separate(V1, c("1","2","Date","3","4"), "_")%>%
  select(Age= "Patient Date of Birth", Value= Count, Date)%>%
  #age lets assume we just take current year 
  mutate(Age= 2021- Age)%>% 
  #separated if working in health care, sum together
  group_by(Date, Age)%>%
  summarise(Value = sum(Value), .groups="drop")%>%
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    AgeInt= "1",
    Sex= "b")%>% 
  mutate(
    Date = dmy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LB",Date),
    Country = "Lebanon",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(Age= as.character(Age))

View(Age_Out)

#Read in sex data 
all_paths <-
  list.files(path = xlsx_dir,
             pattern = "Sex",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_xlsx)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

Sex_in <- rbindlist(all_lists, fill = T)



#Process sex data 


Sex_Out= Sex_in %>%
  separate(V1, c("1","2","Date","3","4"), "_")%>%
  select(Sex= Gender, Value= Count, Date, Sex2= `gender.keyword: Descending`)%>%
  mutate(Sex = case_when(
    Sex == "MALE" ~ "m",
    Sex == "FEMALE" ~ "f",
    Sex2 == "أنثى" ~ "f", #translate because some file use arabic names 
    Sex2 == "ذكر" ~ "m"))%>%
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    AgeInt= "",
    Age= "TOT")%>% 
  mutate(
    Date = dmy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LB",Date),
    Country = "Lebanon",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(Age= as.character(Age))




#Put dataframes together
Out<- bind_rows(In_drive,
                Sex_Out,
                Age_Out)


# upload to Drive, overwrites

write_sheet(Out, 
            ss = ss_i, 
            sheet = "database")


#log_update("Bulgaria", N = nrow(BG_out))



## ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_sex_",today(), ".csv")

write_csv(Age_in, data_source_1)
write_csv(Sex_in, data_source_2)

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

##############################################################################







