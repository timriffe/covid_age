#USA cases and deaths

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address
ctr          <- "USA_All" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/CDC"
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# read in archived data to append new 
DataArchive <- read_rds(paste0(dir_n, ctr, ".rds"))
DataArchive <- DataArchive %>% 
  filter(Measure == "Cases")


#Read in case data by age 

df <- file.info(list.files(path= dir_n_source,
                           pattern = "*cases_by_age",
                           full.names = TRUE))

most_recent_file_case_age= rownames(df)[which.max(df$mtime)]

all_content_case_age <-
  most_recent_file_case_age %>%
  lapply(read_csv, skip=2)

all_filenames_case_age <- 
  most_recent_file_case_age %>%
  basename() %>%
  as.list()

#include filename to get date from filename
all_lists <- mapply(c, all_content_case_age, all_filenames_case_age, SIMPLIFY = FALSE)
cases_age_in <- rbindlist(all_lists, fill = T)

#process age case data

case_age_out= cases_age_in%>%
  select(Age= `Age Group`, Value=`Count of cases`, Date= V1)%>%
  mutate(Date= substr(Date, 19, 26))%>%
  separate(Age, c("Age", "Trash"), "-")%>%
  mutate(Age=recode(Age,
                    `85+ Years`= "80"))%>%
  mutate(AgeInt = case_when(
    Age == "0" ~ 5L,
    Age == "5" ~ 7L,
    Age == "12" ~ 4L,
    Age == "16" ~ 2L,
    Age == "18" ~ 12L,
    Age == "50" ~ 15L,
    Age == "85" ~ 20L,
    Age == "UNK" ~ NA_integer_,
    TRUE ~ 10L)) %>%
  mutate(Measure= "Cases",
         Metric = "Count",
         Sex= "b") %>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),
                 sprintf("%02d",month(Date)),
                 year(Date),sep="."),
    Code = paste0("US"),
    Country = "USA",
    Region = "All",)%>%
  select(Country, Region, Code, Date, Sex,
         Age, AgeInt, Metric, Measure, Value)



# #Read in case data by sex 

df <- file.info(list.files(path= dir_n_source,
                           pattern = "*cases_by_sex",
                           full.names = TRUE))

most_recent_file_case_sex= rownames(df)[which.max(df$mtime)]

all_content_case_sex <-
  most_recent_file_case_sex %>%
  lapply(read_csv, skip=2)

all_filenames_case_sex <- most_recent_file_case_sex %>%
  basename() %>%
  as.list()

#include filename to get date from filename
all_lists <- mapply(c, all_content_case_sex, all_filenames_case_sex, SIMPLIFY = FALSE)
cases_sex_in <- rbindlist(all_lists, fill = T)

#process sex case data

case_sex_out= cases_sex_in%>%
  select(Sex, Value=`Count of cases`, Date= V1)%>%
  mutate(Date= substr(Date, 29, 36))%>%
  mutate(Sex=recode(Sex,
                    `Female`= "f",
                    `Male`= "m",
                    `Other`= "UNK"))%>%
  mutate(Measure= "Cases",
         Metric = "Count",
         AgeInt= "",
         Age= "TOT") %>%
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),
                 sprintf("%02d",month(Date)),
                 year(Date),sep="."),
    Code = paste0("US"),
    Country = "USA",
    Region = "All",)%>%
  select(Country, Region, Code, Date, Sex,
         Age, AgeInt, Metric, Measure, Value)


#deaths by age 

# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*deaths_by_age",
#                            full.names = TRUE))
# 
# most_recent_file_death_age= rownames(df)[which.max(df$mtime)]
# 
# all_content_death_age <-
#   most_recent_file_death_age %>%
#   lapply(read_csv, skip=2)
# 
# all_filenames_death_age <- most_recent_file_death_age %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_death_age, all_filenames_death_age, SIMPLIFY = FALSE)
# death_age_in <- rbindlist(all_lists, fill = T)
# 
# #process age death data 
# 
# death_age_out= death_age_in%>%
#   select(Age= `Age Group`, Value=`Count of deaths`, Date= V1)%>%
#   mutate(Date= substr(Date, 20, 27))%>%
#   separate(Age, c("Age", "Trash"), "-")%>%
#   mutate(Age=recode(Age, 
#                     `85+ Years`= "80"))%>%
#   mutate(AgeInt = case_when(
#     Age == "0" ~ 5L,
#     Age == "5" ~ 7L,
#     Age == "12" ~ 4L,
#     Age == "16" ~ 2L,
#     Age == "18" ~ 12L,
#     Age == "50" ~ 15L,
#     Age == "85" ~ 20L,
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
#     Code = paste0("US_All",Date),
#     Country = "USA",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 
# #deaths by sex 
# 
# df <- file.info(list.files(path= dir_n_source, 
#                            pattern = "*deaths_by_sex",
#                            full.names = TRUE))
# 
# most_recent_file_death_sex= rownames(df)[which.max(df$mtime)]
# 
# all_content_death_sex <-
#   most_recent_file_death_sex %>%
#   lapply(read_csv, skip=2)
# 
# all_filenames_death_sex <- most_recent_file_death_sex %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_death_sex, all_filenames_death_sex, SIMPLIFY = FALSE)
# death_sex_in <- rbindlist(all_lists, fill = T)
# 
# #process sex case data 
# 
# death_sex_out= death_sex_in%>%
#   select(Sex, Value=`Count of deaths`, Date= V1)%>%
#   mutate(Date= substr(Date, 30, 37))%>%
#   mutate(Sex=recode(Sex, 
#                     `Female`= "f",
#                     `Male`= "m",
#                     `Other`= "UNK"))%>%
#   #They give a intervall of deaths,I take the upper value 
#   separate(Value, c("Trash", "Value"), "-")%>%
#   mutate(Measure= "Deaths",
#          Metric = "Count",
#          AgeInt= "",
#          Age= "TOT") %>% 
#   mutate(
#     Date = ymd(Date),
#     Date = paste(sprintf("%02d",day(Date)),    
#                  sprintf("%02d",month(Date)),  
#                  year(Date),sep="."),
#     Code = paste0("US_All",Date),
#     Country = "USA",
#     Region = "All",)%>% 
#   select(Country, Region, Code, Date, Sex, 
#          Age, AgeInt, Metric, Measure, Value)
# 

#put togehter 

out= rbind(DataArchive, case_age_out, case_sex_out)%>%
  unique()


#save 
write_rds(out, paste0(dir_n, ctr, ".rds"))


#archive input data 

data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/cases_sex_",today(), ".csv")


write_csv(cases_age_in, data_source1)
write_csv(cases_sex_in, data_source3)


data_source <- c(data_source1, data_source3)


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

log_update(pp = ctr, N = nrow(out)) 






