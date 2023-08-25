
source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive user in case the script is verified manually  
if (!"email" %in% ls()){
  email <- "ugofilippo.basellini@gmail.com"
}

# info country and N drive address
ctr <- "US_Virginia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# reading data from the website

url_tests <- "https://data.virginia.gov/api/views/3u5k-c2gr/rows.csv?accessType=DOWNLOAD"


db_tests  <- read_csv(url_tests)

date_f_tests <- db_tests %>% 
  rename(date_f = "Lab Report Date") %>% 
  mutate(date_f = ymd(date_f)) %>%
  drop_na(date_f) %>% 
  dplyr::pull(date_f) %>% 
  max()

d_tests <- ddmmyyyy(date_f_tests)

db_tests2 <- db_tests %>% 
  rename(tests = "Number of PCR Testing Encounters",
         date = "Lab Report Date") %>% 
  mutate(date_f =  ymd(date)) %>% 
  replace_na(list(tests = 0)) %>% 
  filter(!is.na(date_f)) %>% 
  group_by(date_f) %>% 
  summarise(new = sum(tests), .groups = "drop") %>%
  arrange(date_f) %>% 
  mutate(Value = cumsum(new),
         Sex = "b",
         Age = "TOT",
         Measure = "Tests") 

out <- db_tests2 %>% 
  mutate(Country = "USA",
         Region = "Virginia",
         AgeInt = NA_integer_,
         Date = ddmmyyyy(date_f),
         Code = paste0("US-VA"),
         Metric = "Count") %>% 
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

#### save local N           
write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(out))

#### uploading metadata to N Drive ####


data_source_t <- paste0(dir_n, "Data_sources/", ctr, "/test_",today(), ".csv")


download.file(url_tests, destfile = data_source_t)

data_source <- c(data_source_t)

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
  
## END ##



## HISTROCIAL CODE AS WE DEPRECTAED THE CASES DATA ## =============
# url_age <- "https://data.virginia.gov/api/views/uktn-mwig/rows.csv?accessType=DOWNLOAD"
# url_sex   <- "https://data.virginia.gov/api/views/tdt3-q47w/rows.csv?accessType=DOWNLOAD"

# db_age <- read_csv(url_age)
# db_sex    <- read_csv(url_sex)


# date_f <- max(mdy(db_age$`Report Date`))
# 
# d <- paste(sprintf("%02d", day(date_f)),
#            sprintf("%02d", month(date_f)),
#            year(date_f), sep = ".")
  
# d_tests <- paste(sprintf("%02d", day(date_f_tests)),
#                  sprintf("%02d", month(date_f_tests)),
#                  year(date_f_tests), sep = ".")


# db_age$`Age Group` %>% unique()
# db_age2 <- 
#   db_age %>% 
#   dplyr::filter(`Age Group Type` == "Case Age Group") %>% 
#   rename(date = "Report Date",
#          Cases = "Number of Cases") %>% 
#   separate("Age Group", c("Age", NA), sep = "-", fill = "right") %>% 
#   replace_na(list(Cases = 0)) %>% 
#   mutate(date_f =  mdy(date),
#          Age = gsub(Age, pattern = " Years", replacement = ""),
#          Age = case_when(Age == "80+" ~ "80",
#                          Age == "Missing" ~ "UNK",
#                          TRUE ~ Age),
#          AgeInt = case_when(Age == "UNK" ~ NA_integer_,
#                             Age == "80" ~ 25L,
#                             TRUE ~ 10L))  %>% 
#   dplyr::select(date_f, Age, AgeInt, Cases) %>% 
#   pivot_longer(Cases, names_to = "Measure", values_to = "new") %>% 
#   group_by(date_f, Age, AgeInt,Measure) %>% 
#   summarise(Value = sum(new), .groups = "drop") %>% 
#   mutate(Sex = "b")
# 
#  db_sex2 <- 
#   db_sex %>% 
#   rename(date = "Report Date",
#          Cases = "Number of Cases") %>% 
#   replace_na(list(Cases = 0)) %>% 
#   mutate(date_f =  mdy(date)) %>% 
#   mutate(Sex = case_when(Sex == "Female" ~ "f",
#                          Sex == "Male" ~ "m",
#                          TRUE ~ "UNK")) %>% 
#   select(date_f, Sex, Cases) %>% 
#   pivot_longer(Cases, names_to = "Measure", values_to = "Value") %>% 
#   group_by(date_f, Sex, Measure) %>% 
#   summarise(Value = sum(Value), .groups = "drop") %>% 
#   mutate(Age = "TOT")


#bind_rows(db_age2, db_sex2, db_tests2) %>% 

# data_source_c, data_source_s, 


# data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/age_",today(), ".csv")
# data_source_s <- paste0(dir_n, "Data_sources/", ctr, "/sex_",today(), ".csv")


# download.file(url_age, destfile = data_source_c)
# download.file(url_sex, destfile = data_source_s)