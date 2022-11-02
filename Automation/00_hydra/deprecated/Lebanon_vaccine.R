#Lebanon vaccine 

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}


# info country and N drive address

ctr          <- "Lebanon_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))




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

#Process age data 

all_ages <- seq(0,100,by = 5)
Age_Out <-
  Age_in %>%
  separate(V1, c(NA,NA,"Date",NA,NA), "_")%>%
  select(YOB = "Patient Date of Birth", Value = Count, Date) %>%
  #age lets assume we just take current year 
  mutate(
    Date = lubridate::dmy(Date),
    Age = lubridate::year(Date) - YOB,
    Age = Age - Age %% 5,
    Age = if_else(Age > 100,100,Age)) %>% 
  tidyr::complete(Date, Age = all_ages, fill = list(Value = 0)) %>% 
  #separated if working in health care, sum together
  group_by(Date, Age)%>%
  summarise(Value = sum(Value), .groups="drop")%>%
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    AgeInt = 5L,
    Sex = "b") %>% 
  mutate(
    Date = ddmmyyyy(Date),
    Code = paste0("LB"),
    Country = "Lebanon",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>%
  mutate(Age = as.character(Age)) %>% 
  dplyr::filter(Date != "24.08.2021")

# Age_Out %>% 
#   group_by(dmy(Date)) %>% 
#   summarize(TOT = sum(Value)) %>% 
#   View()
# 
# Age_Out %>% 
#   mutate(Date = dmy(Date)) %>% 
#   ggplot(aes(x=Date,y = Value)) +
#   geom_line() +
#   facet_wrap(~Age, scales = "free_y")

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

# TR: Sex2 does not seem to get used, does it have a purpose?
Sex_Out <-
  Sex_in %>%
  separate(V1, c(NA, NA, "Date", NA, NA), "_") %>%
  select(Sex = Gender, Value = Count, Date, Sex2 = `gender.keyword: Descending`)%>%
  mutate(Sex = case_when(
    Sex == "MALE" ~ "m",
    Sex == "FEMALE" ~ "f",
    Sex == "أنثى" ~ "f",
    Sex == "ذكر" ~ "m",
    Sex == "Missing" ~ "UNK",
    Sex2 == "أنثى" ~ "f", #translate because some file use arabic names 
    Sex2 == "ذكر" ~ "m")) %>% 
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    AgeInt= NA_integer_,
    Age= "TOT")%>% 
  mutate(
    Date = dmy(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("LB"),
    Country = "Lebanon",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>%
  mutate(Age= as.character(Age))

# Sex_Out %>% 
#   ggplot(aes(x = dmy(Date), y = Value)) +
#   geom_line() +
#   facet_wrap(~Sex)


#Put dataframes together
Out<- bind_rows(Sex_Out,
                Age_Out) %>% 
  sort_input_data()

# upload to N




write_rds(Out, paste0(dir_n, ctr, ".rds"))


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






