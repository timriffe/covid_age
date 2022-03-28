source("Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "USA_all_deaths"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# info by age
url <- "https://data.cdc.gov/api/views/vsak-wrfu/rows.csv?accessType=DOWNLOAD"
db <- read_csv(url)

db2 <- db %>%
  select(Age = `Age Group`, Sex, date_f = `End Week`, New = `COVID-19 Deaths`) %>%
  mutate(Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "Un" ~ "0",
                         Age == "Al" ~ "TOT",
                         Age == "1-" ~ "1",
                         Age == "5-" ~ "5",
                         TRUE ~ as.character(Age)),

         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex == "All Sex" ~ "b"),
         AgeInt = case_when(Age == "TOT" ~ NA_integer_,
                            Age == "0" ~ 1L,
                            Age == "1" ~ 4L,
                            Age == "5" ~ 10L,
                            Age == "85" ~ 20L,
                            TRUE ~ 10L),
         date_f = lubridate::mdy(date_f)) %>%
  select(date_f, Sex, Age, AgeInt, New) %>%
  arrange(date_f, Sex, Age) 

db3 <- db2 %>%
  group_by(Sex, Age) %>%
  mutate(Value = cumsum(New))

out <- db3 %>%
  filter(date_f > ymd("2020-02-29")) %>%
  mutate(Country = "USA",
         Region = "All",
         Metric = "Count",
         Measure = "Deaths",
         Date = ddmmyyyy(date_f),
         Code = paste0("US")) %>%
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>%
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out))

############################################
#### uploading metadata to N Drive ####
############################################

data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")

download.file(url, destfile = data_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)

