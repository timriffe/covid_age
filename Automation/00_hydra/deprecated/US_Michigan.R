library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "e.delfava@gmail.com"
}

# info country and N drive address
ctr <- "US_Michigan"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_MI")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

# what's current most recent date?
db_drive <-  read_sheet(ss = ss_i, sheet = "database")
db_drive2 <- db_drive %>% 
  mutate(date_f = dmy(Date))

last_date_drive <- max(db_drive2$date_f, na.rm = T)

# reading data from the website 
### source
### https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html

m_url <- "https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html"
root <- "https://www.michigan.gov"
html <- read_html(m_url)

### when using links from the wayback machine
# m_url <- "https://web.archive.org/web/20200627034205/https://www.michigan.gov/coronavirus/0,9753,7-406-98163_98173---,00.html"
# root <- "https://web.archive.org"

#tryouts
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "xlsx"))

# locating the links for Excel files

url3 <- links[4,2]

# importing data from the Excel files

db_tests <- rio::import(paste0(root, url3)) %>% 
  as_tibble()

date_f <- as.Date(max(db_tests$Updated))


if (date_f > last_date_drive){

  db_tests2 <- db_tests %>% 
    filter(TestType == "Diagnostic") %>% 
    mutate(Date = as_date(Updated)) %>% 
    group_by(Date) %>% 
    summarise(Value = sum(Count)) %>% 
    mutate(Age = "TOT",
           Sex = "b",
           Measure = "Tests")
  
  out <- db_tests2 %>% 
    mutate(AgeInt = NA_integer_,
           Country = "USA",
           Region = "Michigan",
           Date = ddmmyyyy(Date),
           Code = paste0("US-MI"),
           Metric = "Count") %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
    sort_input_data()
  
# This command append new rows at the end of the sheet
  sheet_append(out,
               ss = ss_i,
               sheet = "database")
  
  ## MK 19.05.2023: No further update as of 15.05.2023 following the end of emergency status in US. 
 # log_update(pp = ctr, N = nrow(out))
  

  
  data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/tests_",today(), ".csv")
  
  download.file(paste0(root, url3), destfile = data_source_3)
  
  data_source <- c(data_source_3)
  
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

} else if (date_f == last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
 # log_update(pp = ctr, N = 0)
}

### END ===========

#### =================================================================================================
## Historical code as we deprecated the cases data part =============

# # locating the links for Excel files
# 
# url1 <- links[2,2]
# 
# #url2 <- links[3,2] ## THIS IS FOR THE CASES DATA AND WE DEPRECATE THIS PART
# 
# url3 <- links[4,2]
# 
# # importing data from the Excel files
# db_tot <- rio::import(paste0(root, url1)) %>% 
#   as_tibble()
# 
# # db_demo <- rio::import(paste0(root, url2)) %>% 
# #   as_tibble()
# 
# db_tests <- rio::import(paste0(root, url3)) %>% 
#   as_tibble()
# 
# date_f <- as.Date(max(db_tot$Updated))
# 
# d <- paste(sprintf("%02d", day(date_f)),
#            sprintf("%02d", month(date_f)),
#            year(date_f), sep = ".")
# 
# d
# if (date_f > last_date_drive){
#   
#   ###################
#   # Formatting data #
#   ###################
#   db2 <- db_demo %>% 
#     mutate(Cases = ifelse(Cases == "Suppressed", "1", Cases),
#            Deaths = ifelse(Deaths == "Suppressed", "1", Deaths),
#            Cases = as.numeric(Cases),
#            Deaths = as.numeric(Deaths),
#            Age = str_sub(AgeCat, 1, 2),
#            Age = ifelse(Age == "0-", "0", Age),
#            Sex = case_when(SEX == "Female" ~ "f",
#                            SEX == "Male" ~ "m",
#                            SEX == "Unknown" ~ "u")) %>% 
#     filter(CASE_STATUS == "Confirmed") %>% 
#     group_by(Age, Sex) %>% 
#     summarise(Cases = sum(Cases),
#               Deaths = sum(Deaths)) %>% 
#     ungroup()
#   
#   db_sex_t <- db2 %>% 
#     filter(Sex != "u") %>% 
#     group_by(Sex) %>% 
#     summarise(Cases = sum(Cases),
#               Deaths = sum(Deaths)) %>% 
#     mutate(Age = "TOT") %>% 
#     ungroup()
#   
#   db_b <- db2 %>% 
#     filter(Age != "Un") %>% 
#     group_by(Age) %>% 
#     summarise(Cases = sum(Cases),
#               Deaths = sum(Deaths)) %>% 
#     mutate(Sex = "b") %>% 
#     ungroup()
#   
#   db_t <- db_tot %>% 
#     filter(CASE_STATUS == "Confirmed") %>% 
#     group_by() %>% 
#     summarise(Cases = sum(Cases),
#               Deaths = sum(Deaths)) %>% 
#     ungroup() %>% 
#     mutate(Age = "TOT",
#            Sex = "b")
#   
#   db_tests2 <- db_tests %>% 
#     filter(TestType == "Diagnostic") %>% 
#     group_by() %>% 
#     summarise(Value = sum(Count)) %>% 
#     mutate(Age = "TOT",
#            Sex = "b",
#            Measure = "Tests")
#   
#   out <- db2 %>% 
#     filter(Sex != "u", Age != "Un") %>% 
#     bind_rows(db_b, db_sex_t, db_t) %>% 
#     gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
#     bind_rows(db_tests2) %>% 
#     mutate(AgeInt = case_when(Age == "0" ~ "20",
#                               Age == "80" ~ "25",
#                               Age == "TOT" ~ "",
#                               TRUE ~ "10"),
#            Country = "USA",
#            Region = "Michigan",
#            Date = d,
#            Code = paste0("US-MI"),
#            Metric = "Count") %>% 
#     arrange(Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
#     select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
#     filter(Measure == "Tests") %>% 
#     sort_input_data()
#   
#   ############################################
#   #### uploading database to Google Drive ####
#   ############################################
#   
#   # This command append new rows at the end of the sheet
#   sheet_append(out,
#                ss = ss_i,
#                sheet = "database")
#   log_update(pp = ctr, N = nrow(out))
#   
#   ############################################
#   #### uploading metadata to N Drive ####
#   ############################################
#   
#   data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/total_",today(), ".csv")
#   data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/demo_",today(), ".csv")
#   data_source_3 <- paste0(dir_n, "Data_sources/", ctr, "/tests_",today(), ".csv")
#   
#   download.file(paste0(root, url1), destfile = data_source_1)
#   download.file(paste0(root, url2), destfile = data_source_2)
#   download.file(paste0(root, url3), destfile = data_source_3)
#   
#   data_source <- c(data_source_1, data_source_2, data_source_3)
#   
#   zipname <- paste0(dir_n, 
#                     "Data_sources/", 
#                     ctr,
#                     "/", 
#                     ctr,
#                     "_data_",
#                     today(), 
#                     ".zip")
#   
#   zipr(zipname, 
#        data_source, 
#        recurse = TRUE, 
#        compression_level = 9,
#        include_directories = TRUE)
#   
#   # clean up file chaff
#   file.remove(data_source)
#   
# } else if (date_f == last_date_drive) {
#   cat(paste0("no new updates so far, last date: ", date_f))
#   log_update(pp = ctr, N = 0)
# }