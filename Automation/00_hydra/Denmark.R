library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Denmark"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

at_rubric <- get_input_rubric() %>% filter(Short == "DK")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)

# reading data from Denmark in Drive
db_drive <- get_country_inputDB("DK")
db_drive2 <- db_drive %>% 
  mutate(Date = dmy(Date)) %>% 
  select(-Short)

# reading cases data from the zip files
cases_zip <- read_sheet(ss_i, 
                  sheet = "database_cases", 
                  na = "NA", 
                  col_types= "cccccciccd") %>% 
  mutate(Date = dmy(Date))
  
last_drive <- cases_zip %>% 
  group_by() %>% 
  summarise(last_date = max(Date)) %>% 
  ungroup() %>% 
  dplyr::pull()

### reading data from the website 
# detecting the link to the xlsx file in the website
# this is a more stable method than using the xpath
m_url <- "https://covid19.ssi.dk/overvagningsdata/download-fil-med-overvaagningdata"

# capture all links with excel files
links <- scraplinks(m_url) %>% 
  filter(str_detect(link, "zip")) %>% 
  separate(link, c("a", "b", "c", "d", "e", "Date", "g", "h")) %>% 
  mutate(Date = dmy(Date)) %>% 
  select(Date, url)

last_report <- links %>% 
  group_by() %>% 
  filter(Date == max(Date)) %>% 
  ungroup() %>% 
  dplyr::pull(Date)

if(last_report > last_drive){

  last_url <- links %>% 
    group_by() %>% 
    filter(Date == max(Date)) %>% 
    ungroup() %>% 
    dplyr::pull(url)
  
  # capture link with cases data by age
  data_source <- paste0(dir_n, 
                        "Data_sources/", 
                        ctr,
                        "/", 
                        ctr,
                        "_data_",
                        last_report, 
                        ".zip")
  
  download.file(last_url, destfile = data_source, mode = "wb")
  db_t <- read_csv2(unz(data_source, "Cases_by_age.csv"))
  db_sex <- read_csv2(unz(data_source, "Cases_by_sex.csv"))
  
  db_t2 <- db_t %>% 
    select(Age = Aldersgruppe, Value = Antal_testede) %>% 
    mutate(Measure = "Tests",
           Sex = "b")
    
  db_sex2 <- 
    db_sex %>% 
    rename(Age = 1,
           f = 2,
           m = 3,
           b = 4) %>% 
    gather(-1, key = "Sex", value = "Values") %>% 
    separate(Values, c("Value", "trash"), sep = " ") %>% 
    mutate(Value = as.numeric(str_replace(Value, "\\.", "")),
           Measure = "Cases") %>% 
    select(-trash)
  
  db2 <- bind_rows(db_t2, db_sex2) %>% 
    separate(Age, c("Age", "trash"), sep = "-") %>% 
    mutate(Age = case_when(Age == "90+" ~ "90",
                           Age == "I alt" ~ "TOT",
                           TRUE ~ Age))
  
  db_zip_new <- 
    db2 %>% 
    mutate(Date = paste(sprintf("%02d", day(last_report)),
                        sprintf("%02d", month(last_report)),
                        year(last_report), sep = "."),
           Country = "Denmark",
           Code = paste0("DK", Date),
           Region = "All",
           AgeInt = case_when(Age == "90" ~ 15L, 
                              Age == "TOT" ~ NA_integer_,
                              TRUE ~ 10L),
           Metric = "Count") %>% 
    arrange(Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  sheet_append(db_zip_new,
               ss = ss_i,
               sheet = "database_cases")
  
  cases_zip2 <- cases_zip %>% 
    bind_rows(db_zip_new %>% 
                mutate(Date = dmy(Date))) %>% 
    select(Date, Sex, Age, Measure, Value)

} else {
  cases_zip2 <- cases_zip %>% 
    select(Date, Sex, Age, Measure, Value)
}


# replace in database in Drive the unknown values in age by total age values
db_drive_tots <- db_drive2 %>% 
  group_by(Date, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

db_drive_all <- db_drive2 %>% 
  mutate(Age = as.character(Age)) %>% 
  filter(Age != "UNK") %>% 
  select(Date, Sex, Age, Measure, Value) %>% 
  bind_rows(db_drive_tots) %>% 
  arrange(Date, Measure, Sex, suppressWarnings(as.integer(Age)))

# identify which rows in the Drive database are already collected from the zip files
combs_zip <- cases_zip2 %>% 
  select(Date, Sex, Age, Measure) %>% 
  mutate(inzip = 1)

db_no_zip <- db_drive_all %>% 
  left_join(combs_zip) %>% 
  replace_na(list(inzip = 0)) %>% 
  filter(inzip != 1) %>% 
  select(-inzip)

out <- db_no_zip %>% 
  bind_rows(cases_zip2) %>% 
  mutate(date_f = Date,
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Denmark",
         Code = paste0("DK", Date),
         Region = "All",
         AgeInt = case_when(Age == "90" ~ 15L, 
                            Age == "TOT" ~ NA_integer_,
                            TRUE ~ 10L),
         Metric = "Count") %>% 
  arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

###########################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))


# collectind data in zipped files from previous dates
# done 23.12.2020
#####################################################
# 
# dim(links)
# 
# db4 <- NULL
# 
# for(i in 1:dim(links)[1]){
# # for(i in 1:4){
#     # i <- 1
#   url <- links[i, 2] %>% dplyr::pull()
#   date_f <- links[i, 1] %>% dplyr::pull()
# 
# # capture link with cases data by age
#   data_source <- paste0(dir_n,
#                         "Data_sources/",
#                         ctr,
#                         "/",
#                         ctr,
#                         "_data_",
#                         date_f,
#                         ".zip")
# 
#   download.file(url, destfile = data_source, mode = "wb")
#   db_t <- read_csv2(unz(data_source, "Cases_by_age.csv"))
#   db_sex <- read_csv2(unz(data_source, "Cases_by_sex.csv"))
# 
#   db_t2 <- db_t %>%
#     select(Age = Aldersgruppe, Value = Antal_testede) %>%
#     mutate(Measure = "Tests",
#            Sex = "b")
# 
#   db_sex2 <-
#     db_sex %>%
#     rename(Age = 1,
#            f = 2,
#            m = 3,
#            b = 4) %>%
#     gather(-1, key = "Sex", value = "Values") %>%
#     separate(Values, c("Value", "trash"), sep = " ") %>%
#     mutate(Value = as.numeric(str_replace(Value, "\\.", "")),
#            Measure = "Cases") %>%
#     select(-trash)
# 
#   db2 <- bind_rows(db_t2, db_sex2) %>%
#     separate(Age, c("Age", "trash"), sep = "-") %>%
#     mutate(Age = case_when(Age == "90+" ~ "90",
#                            Age == "I alt" ~ "TOT",
#                            TRUE ~ Age))
# 
#   db3 <-
#     db2 %>%
#     mutate(Date = paste(sprintf("%02d", day(date_f)),
#                         sprintf("%02d", month(date_f)),
#                         year(date_f), sep = "."),
#            Country = "Denmark",
#            Code = paste0("DK", Date),
#            Region = "All",
#            AgeInt = case_when(Age == "90" ~ 15L,
#                               Age == "TOT" ~ NA_integer_,
#                               TRUE ~ 10L),
#            Metric = "Count")
#     
#   db4 <- db4 %>%
#     bind_rows(db3)
# }
# 
# db5 <- db4 %>%
#   mutate(date_f = dmy(Date)) %>% 
#   arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>%
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 
# write_sheet(db5,
#             ss = ss_i,
#             sheet = "database_cases")
