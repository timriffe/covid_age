#US Idaho 

library(here)
source(here("Automation/00_Functions_automation.R"))

library(lubridate)
library(dplyr)
library(tidyverse)
library(xlsx)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "US_Idaho" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Idaho"
dir_n_source_vacc <- "N:/COVerAGE-DB/Automation/Idaho-vaccine"
dir_n_source_up <- "N:/COVerAGE-DB/Automation/Idaho-Uptake"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# Read in data from drive 
at_rubric <- get_input_rubric() %>% filter(Short == "US_ID")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)

db_drive <- read_sheet(ss = ss_i, sheet = "database")

last_date_archive <- db_drive %>% 
  mutate(date_max = dmy(Date)) %>% 
  dplyr::pull(date_max) %>% 
  max()

# 
# #read in data deaths by age
# #read in most recent file 
# 
# # 
# # all_paths_age_death <-
# #   list.files(path = dir_n_source,
# #              pattern = "*Age Groups",
# #              full.names = TRUE)
# 
# 
# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*Age Groups",
#                            full.names = TRUE))
# 
# 
# most_recent_file_death= rownames(df)[which.max(df$mtime)]
# 
# 
# all_content_age_death <-
#   most_recent_file_death %>%
#   lapply(read_xlsx)
# 
# all_filenames_age_death <- most_recent_file_death %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_age_death, all_filenames_age_death, SIMPLIFY = FALSE)
# 
# death_in <- rbindlist(all_lists, fill = T)
# 
# #process
# 
# death_out= death_in %>%
#   select(Age= ...1, Value=Deaths, Date= V1)%>%
#   mutate(Date= substr(Date, 11, 18))%>%
#   separate(Age, c("Age", "Int"), "-")%>%
#   mutate(Age=recode(Age, 
#                     `<18`= "0",
#                     `80+`= "80"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 18L,
#     Age == "18" ~ 12L,
#     Age == "80" ~ 25L,
#     Age == "UNK" ~ NA_integer_,
#     TRUE ~ 10L)) %>% 
#   mutate(Measure= "Deaths",
#          Metric = "Count",
#          Sex= "b") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US-ID"),
#     Country = "USA",
#     Region = "Idaho",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# 
# 
# #read in total deaths  
# 
# # all_paths_tot_death <-
# #   list.files(path = xlsx_dir,
# #              pattern = "*Total Deaths",
# #              full.names = TRUE)
# 
# 
# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*Total Deaths",
#                            full.names = TRUE))
# 
# 
# most_recent_file_death_tot= rownames(df)[which.max(df$mtime)]
# 
# all_content_tot_death <-
#   most_recent_file_death_tot %>%
#   lapply(read_excel,col_names = FALSE )
# 
# 
# all_filenames_tot_death <- most_recent_file_death_tot %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_tot_death, all_filenames_tot_death, SIMPLIFY = FALSE)
# 
# death_in_tot <- rbindlist(all_lists, fill = T)
# 
# #process 
# 
# death_tot_out= death_in_tot%>%
#   select(Category= ...1, Value= ...2, Date= V1)%>%
#   subset(Category== "Deaths")%>%
#   mutate(Date= substr(Date, 17, 24))%>% 
#   mutate(Measure= "Deaths",
#          Metric = "Count",
#          Sex= "b",
#          Age= "TOT",
#          AgeInt=" ") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US-ID"),
#     Country = "USA",
#     Region = "Idaho",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# 
# #read in deaths by sex 
# 
# # all_paths_sex_death <-
# #   list.files(path = xlsx_dir,
# #              pattern = "Sex",
# #              full.names = TRUE)
# 
# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "Sex",
#                            full.names = TRUE))
# 
# 
# most_recent_file_death_sex= rownames(df)[which.max(df$mtime)]
# 
# all_content_sex_death <-
#   most_recent_file_death_sex %>%
#   lapply(read_excel)
# 
# 
# all_filenames_sex_death <- most_recent_file_death_sex %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_sex_death, all_filenames_sex_death, SIMPLIFY = FALSE)
# 
# death_in_sex <- rbindlist(all_lists, fill = T)
# 
# #process death by sex 
# 
# death_out_sex= death_in_sex%>%
#   select(Sex= ...1, Value=Deaths, Date=V1)%>%
#   mutate(Date= substr(Date, 4,11))%>%
#   mutate(Sex=recode(Sex, 
#                     `Female`= "f",
#                     `Male`= "m"))%>% 
#   mutate(Measure= "Deaths",
#          Metric = "Count",
#          Age= "TOT",
#          AgeInt=" ") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US-ID"),
#     Country = "USA",
#     Region = "Idaho",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# 
# #read in most recent file cases age 
# 
# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*Total by Age",
#                            full.names = TRUE))
# 
# 
# most_recent_file_case_age= rownames(df)[which.max(df$mtime)]
# 
# 
# all_content_age_cases <-
#   most_recent_file_case_age %>%
#   lapply(read_excel)
# 
# 
# all_filenames_age_cases <- most_recent_file_case_age %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_age_cases, all_filenames_age_cases, SIMPLIFY = FALSE)
# 
# cases_in <- rbindlist(all_lists, fill = T)
# 
# #process cases 
# 
# cases_age_out=cases_in %>%
#   select(Age= ...1, Value=Count, Date= V1)%>%
#   mutate(Date= substr(Date, 23, 30))%>%
#   separate(Age, c("Age", "Int"), "-")%>%
#   mutate(Age=recode(Age, 
#                     `100+`= "100"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 5L,
#     Age == "5" ~ 8L,
#     Age == "13" ~ 5L,
#     Age == "18" ~ 12L,
#     Age == "100" ~ 5L,
#     Age == "UNK" ~ NA_integer_,
#     TRUE ~ 10L)) %>% 
#   mutate(Measure= "Cases",
#          Metric = "Count",
#          Sex= "b") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US-ID"),
#     Country = "USA",
#     Region = "Idaho",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)

#vaccines 


###############################################
#Date
#read in most recent date file 

df <- file.info(list.files(path= dir_n_source_vacc, 
                           pattern = "Footnote",
                           full.names = TRUE))


most_recent_file_date_vaccine= rownames(df)[which.max(df$mtime)]

all_content_vaccine_date <-
  most_recent_file_date_vaccine %>%
  lapply(read_excel, col_names= FALSE)


all_filenames_vaccine_date <- most_recent_file_date_vaccine %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_vaccine_date, all_filenames_vaccine_date, SIMPLIFY = FALSE)

date_vaccine_in <- rbindlist(all_lists, fill = T)

vaccine_date= date_vaccine_in%>%
  mutate(Date= substr(...1, 60, 68))%>%
  select(Date)%>%
  mdy()

# read in most recent vaccine age   

df <- file.info(list.files(path= dir_n_source_vacc, 
                           pattern = "General",
                           full.names = TRUE))


most_recent_file_age_vaccine= rownames(df)[which.max(df$mtime)]

all_content_vaccine_age <-
  most_recent_file_age_vaccine %>%
  lapply(read_excel, col_names= FALSE)


all_filenames_vaccine_age <- most_recent_file_age_vaccine %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_vaccine_age, all_filenames_vaccine_age, SIMPLIFY = FALSE)

age_vaccine_in <- rbindlist(all_lists, fill = T)

#process vaccine age 
#JD: the format of the file is changed weirdly when downloaded,
#there might be a more elegant way, but I took a pragmatic approach 

vaccine_age_out= age_vaccine_in%>%
  pivot_longer(!...1, names_to= "Age", values_to= "Value")%>%
  mutate(Age= recode(Age, #compared values to website to assign column to age group
                     "...2"= "16",
                     "...3"= "85",
                     "...4"="12",
                     "...5"="18",
                     "...6"="75",
                     "...7"="25",
                     "...8"="35",
                     "...9"="45",
                     "...10"="55",
                     "...11"="65"), 
         AgeInt = case_when(
           Age == "12" ~ 4L,
           Age == "16" ~ 12L,
           Age == "18"~ 7L,
           Age == "85"~ 20L,
           TRUE~ 10L))%>%
  separate(Value, c("Va", "Va2", "Va1"), "•")%>%
  separate(Va, c("Vaccinations", "Value"), ":")%>%
  separate(Va1, c("Vaccination1", "Value1"), ":")%>%
  separate(Va2, c("Vaccination2", "Value2"), ":")%>%
  #remove all the unnecessary rows 
  filter(Vaccinations== "At least one dose")%>%
  select(-...1, -Vaccinations, -Vaccination1, -Vaccination2)%>%
  pivot_longer(!Age& !AgeInt, names_to= "Measure", values_to= "Value")%>%
  mutate(Measure= recode(Measure, 
                         "Value"="Vaccinations",
                         "Value1"= "Vaccination1",
                         "Value2"= "Vaccination2"), 
         Sex= "b", 
         Metric= "Count", 
         Country= "USA", 
         Region= "Idaho") %>% 
mutate(Date=vaccine_date,
Date = ymd(Date),
Date = paste(sprintf("%02d",day(Date)),    
                    sprintf("%02d",month(Date)),  
                   year(Date),sep="."),
       Code = paste0("US-ID"),
       Country = "USA",
       Region = "Idaho",)%>% 
     select(Country, Region, Code, Date, Sex, 
            Age, AgeInt, Metric, Measure, Value)



###############################################################

#Total vaccination1 
# read in most recent vaccine age   

df <- file.info(list.files(path= dir_n_source_up, 
                           pattern = "Dose",
                           full.names = TRUE))


most_recent_file_tot_vaccine1= rownames(df)[which.max(df$mtime)]

all_content_vaccine1_tot <-
  most_recent_file_tot_vaccine1 %>%
  lapply(read_excel)


all_filenames_vaccine1_tot <- most_recent_file_tot_vaccine1 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_vaccine1_tot, all_filenames_vaccine1_tot, SIMPLIFY = FALSE)

tot_vaccine1_in <- rbindlist(all_lists, fill = T)


#process total vaccination1 

vaccine1_tot_out= tot_vaccine1_in%>%
  select(Value= `People who received one dose of a two dose series (series in progress)`)%>%
  mutate(Measure= "Vaccination1",
         Age= "TOT",
         Metric = "Count",
         Sex= "b",
         AgeInt= " ",
         Date= vaccine_date)%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-ID"),
    Country = "USA",
    Region = "Idaho",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#total vaccination2

df <- file.info(list.files(path= dir_n_source_up, 
                           pattern = "Complete",
                           full.names = TRUE))


most_recent_file_tot_vaccine2= rownames(df)[which.max(df$mtime)]

all_content_vaccine2_tot <-
  most_recent_file_tot_vaccine2 %>%
  lapply(read_excel)


all_filenames_vaccine2_tot <- most_recent_file_tot_vaccine2 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_vaccine2_tot, all_filenames_vaccine2_tot, SIMPLIFY = FALSE)

tot_vaccine2_in <- rbindlist(all_lists, fill = T)


#process total vaccination2 

vaccine2_tot_out= tot_vaccine2_in%>%
  select(Value=`People who are fully vaccinated (depending on brand)`)%>%
  mutate(Measure= "Vaccination2",
         Age= "TOT",
         Metric = "Count",
         Sex= "b",
         AgeInt= " ",
         Date= vaccine_date)%>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US-ID"),
    Country = "USA",
    Region = "Idaho",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)




#put together

Out=rbind(vaccine1_tot_out, vaccine2_tot_out, vaccine_age_out)

#append to drive 

sheet_append(Out,
             ss= ss_i,
             sheet = "database")

#archive 

# data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".xlsx")
# data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".xlsx")
# data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/death_sex_",today(), ".xlsx")
# data_source_4 <- paste0(dir_n, "Data_sources/", ctr, "/death_TOT_",today(), ".xlsx")
data_source_5 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".xlsx")
data_source_6 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine1_TOT_",today(), ".xlsx")
data_source_7 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine2_TOT_",today(), ".xlsx")


# write.xlsx(cases_in, data_source_1)
# write.xlsx(death_in, data_source_2)
# write.xlsx(death_in_sex, data_source_3)
# write.xlsx(death_in_tot, data_source_4)
write.xlsx(age_vaccine_in, data_source_5)
write.xlsx(tot_vaccine1_in, data_source_6)
write.xlsx(tot_vaccine2_in, data_source_7)


data_source <- c(data_source_5,data_source_6, data_source_7)

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

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Out))









  
  
  
  
  
  
  



















############old code for vaccine file in csv format#######
# = age_vaccine_in%>%
#   select(Age= `Age Group Detail`, Dose= demographics_label_age)%>%
#   separate(Dose, c("Vaccinations", "Vaccination2", "Vaccination1"), "•")%>%
#   distinct()%>%
#   separate(Vaccination2, c("Label2","Vaccination2"), ":" )%>%
#   separate(Vaccination1, c("Label1","Vaccination1"), ":" )%>%
#   select(Age, Vaccination1, Vaccination2)%>%
#   separate(Age, c("Age", "Int"), "-")%>%
#   mutate(Age=recode(Age, 
#                     `85+`= "85"))%>%
#   mutate(AgeInt = case_when(
#     Age == "12 " ~ 5L,
#     Age == "16 " ~ 2L,
#     Age == "18 " ~ 7L,
#     Age == "85" ~ 20L,
#     Age == "UNK" ~ NA_integer_,
#     TRUE ~ 10L))%>%
#   select(Age, AgeInt, Vaccination1, Vaccination2)%>%
#   pivot_longer(!Age & !AgeInt, names_to= "Measure", values_to= "Value")%>%
#   mutate(Metric = "Count",
#          Sex= "b", 
#          Date= vaccine_date) %>% 
#   mutate(
#     Date=vaccine_date,
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US_ID",Date),
#     Country = "USA",
#     Region = "Idaho",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)















