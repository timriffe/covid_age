#USA vaccine 

library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
library(xlsx)
# assigning Drive credentials in the case the script is verified manually
##02.12.2021 MK: the script was changed due to a change in sources, data is now collected over a hardlink (refresh) and not over a python script anymore 
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "USA_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
#dir_n_source <- "N:/COVerAGE-DB/Automation/USA-Vaccine"


#make folder on hydra
if (!dir.exists(paste0(dir_n, "Data_sources/", ctr))){
  dir.create(paste0(dir_n, "Data_sources/", ctr))
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# reading in archive data  

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))

last_date_archive <- DataArchive %>% 
  mutate(date_max = dmy(Date)) %>% 
  dplyr::pull(date_max) %>% 
  max()


vacc <- data.table::fread("https://data.cdc.gov/api/views/km4m-vcsb/rows.csv?accessType=DOWNLOAD")

vacc_out_1 <- vacc %>% 
  select(Date, Demographic_category, Administered_Dose1, Series_Complete_Yes) %>% 
  filter(Demographic_category != "Age_known") %>% 
  filter(Demographic_category != "Race_eth_Hispanic") %>% 
  filter(Demographic_category != "Race_eth_known") %>% 
  filter(Demographic_category != "Race_eth_NHAIAN") %>% 
  filter(Demographic_category != "Race_eth_NHAsian") %>% 
  filter(Demographic_category != "Race_eth_NHBlack") %>% 
  filter(Demographic_category != "Race_eth_NHMult_Oth") %>% 
  filter(Demographic_category != "Race_eth_NHNHOPI") %>% 
  filter(Demographic_category != "Race_eth_NHWhite") %>% 
  filter(Demographic_category != "Race_eth_unknown") %>% 
  filter(Demographic_category != "Sex_known") %>% 
  filter(Demographic_category != "US") %>% 
  filter(Demographic_category != "Ages_<12yrs") %>% 
  filter(Demographic_category != "Ages_12-17_yrs") %>% 
    mutate(Age = case_when(
    Demographic_category == "Age_unknown" ~ "UNK",
    Demographic_category == "Ages_<5yrs" ~ "0",
    Demographic_category == "Ages_5-11_yrs" ~ "5",
    Demographic_category == "Ages_12-15_yrs" ~ "12",
    Demographic_category == "Ages_16-17_yrs" ~ "16",
    Demographic_category == "Ages_18-24_yrs" ~ "18",
    Demographic_category == "Ages_25-39_yrs" ~ "25",
    Demographic_category == "Ages_40-49_yrs" ~ "40",
    Demographic_category == "Ages_50-64_yrs" ~ "50",
    Demographic_category == "Ages_65-74_yrs" ~ "65",
    Demographic_category == "Ages_75+_yrs" ~ "75",
    Demographic_category == "Sex_Female" ~ "TOT",
    Demographic_category == "Sex_Male" ~ "TOT",
    Demographic_category == "Sex_unknown" ~ "TOT"),
    Sex = case_when(
      Demographic_category == "Age_unknown" ~ "b",
      Demographic_category == "Ages_<5yrs" ~ "b",
      Demographic_category == "Ages_12-15_yrs" ~ "b",
      Demographic_category == "Ages_12-17_yrs" ~ "b",
      Demographic_category == "Ages_16-17_yrs" ~ "b",
      Demographic_category == "Ages_18-24_yrs" ~ "b",
      Demographic_category == "Ages_25-39_yrs" ~ "b",
      Demographic_category == "Ages_40-49_yrs" ~ "b",
      Demographic_category == "Ages_5-11_yrs" ~ "b",
      Demographic_category == "Ages_50-64_yrs" ~ "b",
      Demographic_category == "Ages_65-74_yrs" ~ "b",
      Demographic_category == "Ages_75+_yrs" ~ "b",
      Demographic_category == "Sex_Female" ~ "f",
      Demographic_category == "Sex_Male" ~ "m",
      Demographic_category == "Sex_unknown" ~ "UNK"),
    AgeInt = case_when(
      Demographic_category == "Ages_<5yrs" ~ 5L,
      Demographic_category == "Ages_12-15_yrs" ~ 4L,
      Demographic_category == "Ages_16-17_yrs" ~ 2L,
      Demographic_category == "Ages_18-24_yrs" ~ 7L,
      Demographic_category == "Ages_25-39_yrs" ~ 15L,
      Demographic_category == "Ages_40-49_yrs" ~ 10L,
      Demographic_category == "Ages_5-11_yrs" ~ 7L,
      Demographic_category == "Ages_50-64_yrs" ~ 15L,
      Demographic_category == "Ages_65-74_yrs" ~ 10L,
      Demographic_category == "Ages_75+_yrs" ~ 30L,
    )) %>% 
  select(-2)

#vacc_out <-vacc_out[-2]

## melt is not working ##
# vacc_out <- melt(vacc_out, id = c("Date", "Age", "Sex", "AgeInt"))  
# names(vacc_out)[5] <- "Measure"
# names(vacc_out)[6] <- "Value"


vacc_out <- vacc_out_1 %>% 
  pivot_longer(cols = -c("Date", "Age", "Sex", "AgeInt"),
               names_to = "Measure",
               values_to = "Value") %>% 
  mutate(Measure = case_when(
    Measure == "Administered_Dose1" ~ "Vaccination1",
    Measure == "Series_Complete_Yes" ~ "Vaccination2"
      ),
    Metric = "Count",
    Country = "USA",
    Region = "All")

vacc_out2 <- vacc_out %>% 
  mutate(Date = mdy(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("US"))%>% 
  sort_input_data()
#read in age data fully vaccinated 

#find most recent file 

# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*age_groups_of_people_fully_vaccinated",
#                            full.names = TRUE))
#                 
#                 
# most_recent_file_vac2_age= rownames(df)[which.max(df$mtime)]  

  # all_paths_age_vac2 <-
  #   list.files(path= dir_n_source, 
  #              pattern = "*age_groups_of_people_fully_vaccinated",
  #              full.names = TRUE)
  # 

# 
#   all_content_age_vac2 <-
#     most_recent_file_vac2_age %>%
#     lapply(read.csv2, sep= ";", fileEncoding="UTF-8-BOM")
#   
#   all_filenames_age_vac2 <- most_recent_file_vac2_age %>%
#     basename() %>%
#     as.list()
#   
#   #include filename to get date from filename 
#   all_lists <- mapply(c, all_content_age_vac2, all_filenames_age_vac2, SIMPLIFY = FALSE)
#   
#   age_vac2_in <- rbindlist(all_lists, fill = T)
#   
#process vaccination2 age data 

#process

# age_vac2_out= age_vac2_in%>%
#   select(Age= Age.Groups.of.People.Fully.Vaccinated, V1 )%>%
#   separate(Age, c("Age", "trash", "Value"), sep= ",")%>%
#   mutate(Date = str_sub(V1, 38, 45))%>%
#   select(Age, Value, Date)%>%
# mutate(AgeInt = case_when(
#   Age == "<12" ~ 11L,
#   Age == "12_15" ~ 4L,
#   Age == "16_17" ~ 2L,
#   Age == "18_24" ~ 7L,
#   Age == "<18" ~ 18L,
#   Age == "18-29" ~ 10L,
#   Age == "25_39" ~ 15L,
#   Age == "30-39" ~ 10L,
#   Age == "40-49" ~ 10L,
#   Age == "40_49" ~ 10L,
#   Age == "50-64" ~ 15L,
#   Age == "50_64" ~ 15L,
#   Age == "65-74"  ~ 10L,
#   Age == "75+" ~ 30L,
#   TRUE ~ 9999L))%>%
#   filter(AgeInt != "9999")%>%
#   separate(Age, c("Age", "trash"), sep= "-")%>%
#   separate(Age, c("Age", "trash2"), sep= "_")%>%
#   mutate(Age= recode(Age, 
#                      "<12"= "0",
#                      "<18"= "0",
#                      "75+"= "75"), 
#          Sex = "b",
#          Country = "USA",
#          Region = "All",
#          Metric = "Count",
#          Measure= "Vaccination2",
#          Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep="."),
#          Code = paste0("US_All_",Date))%>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
#   
# #age vaccination1 

#read in age data partially vaccinated 
# 
# all_paths_age_vac1 <-
#   list.files(path= dir_n_source, 
#              pattern = "*age_groups_of_people_with_at_least",
#              full.names = TRUE)


# df1 <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*age_groups_of_people_with_at_least",
#                            full.names = TRUE))
# 
# most_recent_file_vac1_age= rownames(df1)[which.max(df1$mtime)]  
# 
# 
# all_content_age_vac1 <-
#   most_recent_file_vac1_age %>%
#   lapply(read.csv2, sep= ";", fileEncoding="UTF-8-BOM")
# 
# all_filenames_age_vac1 <- most_recent_file_vac1_age %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_age_vac1, all_filenames_age_vac1, SIMPLIFY = FALSE)
# 
# age_vac1_in <- rbindlist(all_lists, fill = T)
#                                                                             
# 
# #process vaccination 1 by age 
# 
# age_vac1_out= age_vac1_in%>%
#   select(Age= Age.Groups.of.People.with.at.least.One.Dose.Administered, V1 )%>%
#   separate(Age, c("Age", "trash", "Value"), sep= ",")%>%
#   mutate(Date = str_sub(V1, 57, 64))%>%
#   select(Age, Value, Date)%>%
#   mutate(AgeInt = case_when(
#     Age == "<12" ~ 11L,
#     Age == "12_15" ~ 4L,
#     Age == "16_17" ~ 2L,
#     Age == "18_24" ~ 7L,
#     Age == "<18" ~ 18L,
#     Age == "18-29" ~ 10L,
#     Age == "25_39" ~ 15L,
#     Age == "30-39" ~ 10L,
#     Age == "40-49" ~ 10L,
#     Age == "40_49" ~ 10L,
#     Age == "50-64" ~ 15L,
#     Age == "50_64" ~ 15L,
#     Age == "65-74"  ~ 10L,
#     Age == "75+" ~ 30L,
#     TRUE ~ 9999L))%>%
#   filter(AgeInt != "9999")%>%
#   separate(Age, c("Age", "trash"), sep= "-")%>%
#   separate(Age, c("Age", "trash2"), sep= "_")%>%
#   mutate(Age= recode(Age, 
#                      "<12"= "0",
#                      "<18"= "0",
#                      "75+"= "75"), 
#          Sex = "b",
#          Country = "USA",
#          Region = "All",
#          Metric = "Count",
#          Measure= "Vaccination1",
#          Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep="."),
#          Code = paste0("US_All_",Date))%>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# 
# #read in sex data partially vaccinated 
# 
# # all_paths_sex_vac1 <-
# #   list.files(path= dir_n_source, 
# #              pattern = "*sex_of_people_with_at_least",
# #              full.names = TRUE)
# 
# 
# df2 <- file.info(list.files(path= dir_n_source, 
#                             pattern = "*sex_of_people_with_at_least",
#                             full.names = TRUE))
# 
# most_recent_file_vac1_sex= rownames(df2)[which.max(df2$mtime)] 
# 
# 
# all_content_sex_vac1 <-
#   most_recent_file_vac1_sex %>%
#   lapply(read.csv2, sep= ";", fileEncoding="UTF-8-BOM")
# 
# all_filenames_sex_vac1 <- most_recent_file_vac1_sex %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_sex_vac1, all_filenames_sex_vac1, SIMPLIFY = FALSE)
# 
# sex_vac1_in <- rbindlist(all_lists, fill = T)
# 
# 
# #process
# 
# sex_vac1_out= sex_vac1_in%>%
#   select(Sex= Sex.of.People.with.at.least.One.Dose.Administered, V1 )%>%
#   separate(Sex, c("Sex", "trash", "Value"), sep= ",")%>%
#   mutate(Date = str_sub(V1, 50, 57))%>%
#   select(Sex, Value, Date)%>%
#   filter(Sex != "Sex")%>%
#   na.omit()%>%
#   mutate(Sex= recode(Sex, 
#                      "Female"= "f",
#                      "Male"= "m"), 
#          Age = "TOT",
#          AgeInt= " ",
#          Country = "USA",
#          Region = "All",
#          Metric = "Count",
#          Measure= "Vaccination1",
#          Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep="."),
#          Code = paste0("US_All_",Date))%>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# 
# #read in vaccination 2 by sex 
# 
# # all_paths_sex_vac2 <-
# #   list.files(path= dir_n_source, 
# #              pattern = "*sex_of_people_fully_vaccinated",
# #              full.names = TRUE)
# 
# 
# df3 <- file.info(list.files(path= dir_n_source, 
#                             pattern = "*sex_of_people_fully_vaccinated",
#                             full.names = TRUE))
# 
# most_recent_file_vac2_sex= rownames(df3)[which.max(df3$mtime)] 
# 
# 
# all_content_sex_vac2 <-
#   most_recent_file_vac2_sex %>%
#   lapply(read.csv2, sep= ";", fileEncoding="UTF-8-BOM")
# 
# all_filenames_sex_vac2 <- most_recent_file_vac2_sex %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_sex_vac2, all_filenames_sex_vac2, SIMPLIFY = FALSE)
# 
# sex_vac2_in <- rbindlist(all_lists, fill = T)
# 
# 
# #process
# 
# sex_vac2_out= sex_vac2_in%>%
#   select(Sex= Sex.of.People.Fully.Vaccinated, V1 )%>%
#   separate(Sex, c("Sex", "trash", "Value"), sep= ",")%>%
#   mutate(Date = str_sub(V1, 31, 38))%>%
#   select(Sex, Value, Date)%>%
#   filter(Sex != "Sex")%>%
#   na.omit()%>%
#   mutate(Sex= recode(Sex, 
#                      "Female"= "f",
#                      "Male"= "m"), 
#          Age = "TOT",
#          AgeInt= " ",
#          Country = "USA",
#          Region = "All",
#          Metric = "Count",
#          Measure= "Vaccination2",
#          Date = ymd(Date),
#          Date = paste(sprintf("%02d",day(Date)),    
#                       sprintf("%02d",month(Date)),  
#                       year(Date),sep="."),
#          Code = paste0("US_All_",Date))%>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# 
# 
# #put together 
# 
# new_data= rbind(sex_vac1_out,sex_vac2_out, age_vac1_out, age_vac2_out)
# 
# #get maximum date from new data 
# 
# date_f <- new_data %>% 
#   mutate(date_max = dmy(Date)) %>% 
#   dplyr::pull(date_max) %>% 
#   max()
# 
# 
# #appand only new data 
# 
# if (date_f > last_date_archive){
# 
# #append when there is new data 
# Out= rbind(DataArchive, new_data)

#save output file on N 

write_rds(vacc_out2, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc_out2))

# now archive new data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(vacc_out2, data_source)



zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "vaccine_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

# } else if (date_f == last_date_archive) {
#   log_update(pp = ctr, N = 0)
# }
# 
# 
# 






















