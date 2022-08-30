#Hong Kong vaccines 

library(here)
source(here("Automation", "00_Functions_automation.R"))
library(purrr)
library(readODS)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address

ctr          <- "Hong_Kong_Vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"



#read previous data 

DataArchive <- read_rds(paste0(dir_n, ctr, ".rds")) 


## MK, 30.08.2022: removing duplicates ### ===========
# 
# archive_processed <- DataArchive %>%  
#   mutate(Date = dmy(Date)) %>% 
#   filter(Date != "2022-08-30", Date != "2022-08-23", Date != "2022-06-28") %>% 
#   mutate(Date = ddmmyyyy(Date),
#          AgeInt = as.integer(AgeInt))
# 
# duplicates <- paste0(dir_n, "Data_sources/", ctr, "/duplicates")
# 
# files <- list.files(path = duplicates,
#                     pattern = ".csv",
#                     all.files = TRUE,
#                     recursive = TRUE,
#                     full.names = TRUE) 
# 
# files_df <- data.frame(paths = files) %>% 
#   mutate(date_string = str_extract(paths, "\\d+-\\d+-\\d+.csv"),
#          date_string = str_remove(date_string, ".csv"),
#          Date = as.Date(date_string))
# 
# 
# totals_df <- files_df %>% 
#   filter(str_detect(paths, "_total_")) 
# 
# total <- totals_df %>% 
#   {map2_dfr(.$paths, .$Date, function(x,y) read.csv(x) %>% mutate(Date=y))}
#   
# 
# 
# 
# sex_df <- files_df %>% 
#   filter(str_detect(paths, "_sex_")) 
# 
# sex <- sex_df %>% 
#   {map2_dfr(.$paths, .$Date, function(x,y) read.csv(x) %>% mutate(Date=y))}
# 
# 
# 
# 
# age_df <- files_df %>% 
#   filter(str_detect(paths, "_age_")) 
# 
# age <- age_df %>% 
#   {map2_dfr(.$paths, .$Date, function(x,y) read.csv(x) %>% mutate(Date=y))}
# 



#total vaccines 
total= read.csv("https://static.data.gov.hk/covid-vaccine/summary.csv")

#vaccinations by age 
age= read.csv("https://static.data.gov.hk/covid-vaccine/pie_age.csv")

#vaccinations by sex 
sex= read.csv("https://static.data.gov.hk/covid-vaccine/pie_gender.csv") 


#process

#total 

out_total= total %>%
  select(Vaccination1= firstDoseTotal, 
         Vaccination2= secondDoseTotal, 
         Vaccination3 = thirdDoseTotal,
         Vaccination4 = fourthDoseTotal,
         Vaccinations = totalDosesAdministered)%>%
  pivot_longer(cols = everything(), names_to = "Measure", values_to= "Value") %>%
  mutate(Metric = "Count",
         Age= "TOT", 
         AgeInt= NA_integer_,
         Date =today(),
         Sex= "b")%>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("CN-HK"),
    Country = "China",
    Region = "Hong Kong",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  
#Age 

out_age= age %>%
  select(Age= age_group, Value= count)%>%
  mutate(Age=recode(Age, 
                    `Aged 0-2` = "0",
                    `Aged 3-11`="3",
                    `Aged 5-11` = "5",
                    `Aged 12-19`="12",
                    `Aged 20-29`="20",
                    `Aged 30-39`="30",
                    `Aged 40-49`="40",
                    `Aged 50-59`="50",
                    `Aged 60-69`="60",
                    `Aged 70-79`="70",
                    `Aged 80 and above`="80"))%>% 
  mutate(AgeInt = case_when(
    Age == "0" ~ 3L,
    Age == "3" ~ 9L,
    Age == "5" ~ 7L,
    Age == "12" ~ 8L,
    Age == "80" ~ 25L,
    TRUE ~ 10L))%>%
  mutate(Date= today(),
         Metric= "Count",
         Sex="b",
         Measure= "Vaccinations",
         Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("CN-HK"),
         Country = "China",
         Region = "Hong Kong",)%>%
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)

#Sex

out_sex= sex %>%
  select(Sex= gender,Value= count)%>%
  mutate(Sex=recode(Sex, 
                    `Female`="f",
                    `Male`="m",), 
    Metric = "Count",
    Age= "TOT", 
    AgeInt= NA_integer_,
    Date =today(),
    Measure= "Vaccinations",
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("CN-HK"),
    Country = "China",
    Region = "Hong Kong",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  


#put togehter and appand prev data 

out_today <- bind_rows(out_total, out_age, out_sex)

out= rbind(DataArchive,out_today)

#save output 


write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

# updating hydra dashboard
#log_update(pp = ctr, N = nrow(out))

#zip input data

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_total_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")
data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_sex_",today(), ".csv")


write_csv(total,data_source_1)
write_csv(age, data_source_2)
write_csv(sex, data_source_3)


data_source <- c(data_source_1, data_source_2, data_source_3)

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





############################################################################################################################
#read in files that were manually saved before automating 

#Read in Age data 
#xlsx_dir <- "U:/COVerAgeDB/Datenquellen/Vaccination/Hong Kong/Age"
#all_paths <-
# list.files(path = xlsx_dir,
#  pattern = "Age",
#  full.names = TRUE)
#all_content <-
# all_paths %>%
# lapply(read_xlsx)
#all_filenames <- all_paths %>%
# basename() %>%
# as.list()
#include filename to get date from filename 
#all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

#Age_in <- rbindlist(all_lists, fill = T)


#Sex
#xlsx_dir <- "U:/COVerAgeDB/Datenquellen/Vaccination/Hong Kong/Sex"
#all_paths <-
# list.files(path = xlsx_dir,
#pattern = "Sex",
#full.names = TRUE)
#all_content <-
# all_paths %>%
# lapply(read_xlsx)
#all_filenames <- all_paths %>%
# basename() %>%
#as.list()

#include filename to get date from filename 
#all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
#Sex_in <- rbindlist(all_lists, fill = T)

#Total
#xlsx_dir <- "U:/COVerAgeDB/Datenquellen/Vaccination/Hong Kong/"

#all_paths <-
#list.files(path = xlsx_dir,
#pattern = "Total",
#full.names = TRUE)
#all_content <-
# all_paths %>%
#lapply(read_xlsx)

#all_filenames <- all_paths %>%
#basename() %>%
#as.list()

#include filename to get date from filename 
#all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
#Total_in <- rbindlist(all_lists, fill = T)


#pre saved data
#out_total_archive= Total_in %>%
#separate(V1, c("1","Date","2","3"), "_")%>%
#select(Vaccination1= firstDoseTotal, Vaccination2= secondDoseTotal, Vaccinations= totalDosesAdministered, Date)%>%
#mutate(Metric = "Count",
#Age= "TOT", 
#AgeInt= "")%>%
# pivot_longer(!Metric & !Age & !AgeInt & !Date, names_to = "Measure", values_to= "Value")%>%
# mutate(Sex= "b")%>%
# mutate(
# Date = dmy(Date),
# Date = paste(sprintf("%02d",day(Date)),    
#sprintf("%02d",month(Date)),  
# year(Date),sep="."),
# Code = paste0("CN_HK",Date),
# Country = "China",
# Region = "Hong Kong",)%>% 
#select(Country, Region, Code, Date, Sex, 
#Age, AgeInt, Metric, Measure, Value)



#out_age_Archive= Age_in %>%
#separate(V1, c("1","Date","2","3"), "_")%>%
#select(Age= age_group, Value= count, Date)%>%
#mutate(Age=recode(Age, 
#`Aged 16-19`="16",
#`Aged 20-29`="20",
# `Aged 30-39`="30",
# `Aged 40-49`="40",
# `Aged 50-59`="50",
# `Aged 60-69`="60",
# `Aged 70-79`="70",
# `Aged 80 and above`="80"))%>% 
#mutate(AgeInt = case_when(
# Age == "16" ~ 4L,
# Age == "80" ~ 25L,
# TRUE ~ 10L))%>%
# mutate(Metric= "Count",
#Sex="b",
#Measure= "Vaccinations",
# Date = dmy(Date),
# Date = paste(sprintf("%02d",day(Date)),    
#sprintf("%02d",month(Date)),  
# year(Date),sep="."),
#Code = paste0("CN_HK",Date),
# Country = "China",
# Region = "Hong Kong",)%>%
# select(Country, Region, Code, Date, Sex, 
#Age, AgeInt, Metric, Measure, Value)



#out_sex_Archive= Sex_in %>%
#separate(V1, c("1","Date","2","3"), "_")%>%
#select(Sex= gender,Value= count,Date)%>%
#mutate(Sex=recode(Sex, 
#`Female`="f",
#`Male`="m",), 
#Metric = "Count",
#Age= "TOT", 
#AgeInt= "",
#Measure= "Vaccinations",
#Date = dmy(Date),
#Date = paste(sprintf("%02d",day(Date)),    
#sprintf("%02d",month(Date)),  
#year(Date),sep="."),
# Code = paste0("CN_HK",Date),
# Country = "China",
# Region = "Hong Kong",)%>% 
#select(Country, Region, Code, Date, Sex, 
#Age, AgeInt, Metric, Measure, Value)



#put tigethter with prev saved data 

#out= rbind(out_total, out_age, out_sex, out_age_Archive, out_sex_Archive,out_total_archive)














######################################################################################################################################



