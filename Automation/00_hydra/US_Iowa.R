# TR
# main url: "https://iowacovid19tracker.org/downloadable-data"
# Automation/Iowa

# 1)
# Iowa Testing Data & Percent Change
# Show: All
# download csv

# 2) 
# Age Groups
# Show: All
# download csv

# 3)
# Biological Sex
# Show: All
# download csv

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "US_Iowa" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Iowa"
# dir_n_source <- "Data/Iowa"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Region == "Iowa")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)


# determine most recent date captured:
all_files <- dir(dir_n_source)
csvs <- all_files[grepl(all_files,pattern="US_IA_age")]
max_date <-
  str_split(csvs,pattern = "-") %>% 
  lapply("[",2) %>% 
  unlist() %>% 
  gsub(pattern = ".csv", replacement = "") %>% 
  ymd() %>% 
  max()

datestring <- max_date %>% as.character() %>% gsub(pattern = "-", replacement = "")

age_csv   <- file.path(dir_n_source,paste0("US_IA_age-",datestring,".csv"))
sex_csv   <- file.path(dir_n_source,paste0("US_IA_sex-",datestring,".csv"))
tests_csv <- file.path(dir_n_source,paste0("US_IA_tests-",datestring,".csv"))

# read in local downloaded files.
AgeIN   <- read_csv(age_csv) 
SexIN   <- read_csv(sex_csv) 
TestsIN <- read_csv(tests_csv) 

AgeINfiltered <- 
  AgeIN %>% 
  filter(!Date %in% c("08/29/2020","09/19/2020","10/09/2020","10/16/2020"))

# Now process to inputDB format
Age <-
  AgeINfiltered %>%
  select(Date, 
         starts_with("Deaths: Cumulative"), 
         starts_with("Positives: Cumulative")) %>% 
  pivot_longer(2:ncol(.), 
               names_to = "MeasureAge",
               values_to = "Value") %>% 
  filter(!is.na(Value),
         !grepl(MeasureAge,pattern = "&")) %>%
  mutate(MeasureAge = sub(MeasureAge, 
                          pattern = "Age Groups", 
                          replacement = "TOT")) %>% 
  separate(MeasureAge, 
           into = c("Measure", NA, "Age"),
           sep = " ") %>% 
  mutate(Date = mdy(Date),
         AgeInt = case_when(
           Age == "0-17" ~ 18L,
           Age == "18-40" ~ 23L,
           Age == "41-60" ~ 20L,
           Age == "61-80" ~ 20L,
           Age == "81+" ~ 24L,
           Age == "18-29" ~ 12L,
           Age == "30-39" ~ 10L,
           Age == "40-49" ~ 10L,
           Age == "50-59" ~ 10L,
           Age == "60-69" ~ 10L,
           Age == "70-79" ~ 10L,
           Age ==  "80+" ~ 25L
         ),
         Age = recode(Age,
                      "0-17" = "0",
                      "18-40" = "18",
                      "41-60" = "41",
                      "61-80" = "61",
                      "81+" = "81",
                      "18-29" = "18",
                      "30-39" = "30",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80+" = "80"),
         Measure = sub(Measure, pattern = ":", replacement = ""),
         Measure = ifelse(Measure == "Positives","Cases",Measure)) %>% 
  mutate(Country = "USA",
         Region = "Iowa",
         Date = paste(sprintf("%02d",day(Date)),    
               sprintf("%02d",month(Date)),  
               year(Date),sep="."),
         Metric = "Count",
         Code = paste0("US-IA"),
         Sex = "b"
  )


Tests <- 
  TestsIN %>% 
  select(Date,
         Value = `Total Individuals Tested`) %>% 
  mutate(Date = mdy(Date)) %>% 
  filter(!is.na(Value)) %>% 
  arrange(Date) %>% 
  mutate(New = Value - lag(Value)) %>% 
  filter(sign(New) > 0) %>% 
  select(-New) %>% 
  mutate(Country = "USA",
         Region = "Iowa",
         Metric = "Count",
         Measure = "Tests",
         Age = "TOT",
         AgeInt = NA_integer_,
         Date = paste(sprintf("%02d", day(Date)),    
                      sprintf("%02d", month(Date)),  
                      year(Date), sep = "."),
         Code = paste0("US-IA"),
         Sex = "b")


Sex <- SexIN %>% 
   select(Date, 
          Cases_f = `Positives: Cumulative Women`,
          Cases_m = `Positives: Cumulative Men`,
          Deaths_f = `Deaths: Cumulative Women`,
          Deaths_m = `Deaths: Cumulative Men`) %>% 
    pivot_longer(Cases_f:ncol(.), names_to = "MeasureSex", values_to = "Value") %>% 
    separate(MeasureSex, into = c("Measure","Sex"), sep = "_") %>% 
    mutate(Date = mdy(Date),
           Country = "USA",
           Region = "Iowa",
           Metric = "Count",
           Age = "TOT",
           AgeInt = NA_integer_,
           Date = paste(sprintf("%02d", day(Date)),    
                        sprintf("%02d", month(Date)),  
                        year(Date), sep = "."),
           Code = paste0("US-IA"))


# Bind together
US_IA_out <-
  bind_rows(Age, Tests, Sex) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

# upload to Drive
write_sheet(US_IA_out,
            ss = ss_i,
            sheet = "database")

N <- nrow(US_IA_out)
log_update("US_Iowa",N)

# ------------------------------------------
# now archive

data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/sex_",today(), ".csv")
data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/tests_",today(), ".csv")

write_csv(AgeIN, data_source_1)
write_csv(SexIN, data_source_2)
write_csv(TestsIN, data_source_3)

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


# -------------------------------
# clean up file chaff
file.remove(data_source)
# # source file rm:
# file_source <- dir(dir_n_source)
# file_rm     <- file_source[grepl(file_source,pattern=".csv")]
# file.remove(file.path(dir_n_source, file_rm))

# Oct 9th is repeated, and Oct 10th is missing. The second Oct 9 is surely larger.
#AgeIN %>% filter(Date %in% c("10/08/2020","10/09/2020","10/10/2020","10/11/2020")) %>% View()
# AgeIN %>% filter(Date %in% c("08/28/2020","08/29/2020")) %>% View()
#  AgeIN %>% 
#    group_by(Date) %>% 
#    mutate(n=n()) %>% 
#    ungroup() %>% 
#    filter(n>1) %>% 
#    View()
#  AgeINfiltered %>% 
#    mutate(Date = mdy(Date)) %>% 
#    ggplot(aes(x = Date, y = `Positives: Cumulative Age Groups`)) + 
#    geom_line()
# # 
#  AgeINfiltered %>% 
#    mutate(Date = mdy(Date),
#           MyNew = lead(`Deaths: Cumulative 41-60`) - `Deaths: Cumulative 41-60`) %>% 
#    ggplot(aes(x = Date, y = MyNew)) + 
#    geom_line()
# # 
#  AgeINfiltered %>% 
#    mutate(Date = mdy(Date),
#           MyNew = lead(`Positives: Cumulative Age Groups`) - `Positives: Cumulative Age Groups`) %>%   filter(MyNew < 0)
# "2020-08-29"
# "2020-10-15"


