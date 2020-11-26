# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("U:/gits/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("Automation/00_Functions_automation.R")

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "NZ")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# TR:
# current operation just appends cases. I'd prefer to re-tabulate the full case history from the spreadsheet.


# reading data from Montreal and last date entered 
db_drive <- get_country_inputDB("NZ")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

# reading data from the website 
### source
m_url_2 <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases#age"
m_url_3 <- getURL(m_url_2)

# m_url_3 <- read_html(m_url_2)

tables <- readHTMLTable(m_url_3) 
date_f <- str_split(names(tables[1]), ",")[[1]][2] %>% dmy()


if (date_f > last_date_drive){
  m_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"

  ####################################
  # all cases from case-based database
  ####################################
  
  root <- "https://www.health.govt.nz"
  html <- read_html(m_url)
  
  # locating the links for Excel files

  url1 <- html_nodes(html, xpath = '//*[@id="node-10866"]/div/div/div/ul[2]/li[1]/a') %>%
    html_attr("href")
  
  db_c_conf <- rio::import(paste0(root, url1), 
                        sheet = "Confirmed",
                        skip = 2) %>% 
    as_tibble()
  
  db_c_prob <- rio::import(paste0(root, url1), 
                         sheet = "Probable",
                         skip = 2) %>% 
    as_tibble()
  
  
  db_c_conf2 <- db_c_conf %>% 
    rename(date = 1,
           age_gr = 3) %>% 
    mutate(date_f = ymd(date),
           type = "Confirmed") %>% 
    select(date_f, Sex, age_gr, type)
  
  db_c_prob2 <- db_c_prob %>% 
    rename(date = 1,
           age_gr = 3) %>% 
    mutate(date_f = ymd(date),
           type = "Probable") %>% 
    select(date_f, Sex, age_gr, type)
  
  db_c <- bind_rows(db_c_conf2, db_c_prob2) %>% 
    mutate(Age = case_when(str_sub(age_gr, 1, 2) == "1 " ~ "1",
                           str_sub(age_gr, 1, 2) == "5 " ~ "5",
                           str_sub(age_gr, 1, 2) == "<1" ~ "0",
                           TRUE ~ str_sub(age_gr, 1, 2)))
  
  ages <-  suppressWarnings(as.integer(unique(db_c$Age))) %>% sort() %>% as.character()
  dates <- unique(db_c$date_f) %>% sort()
  
  db_c2 <- db_c %>% 
    group_by(date_f, Age, Sex, type) %>% 
    summarise(new = n()) %>% 
    ungroup() %>% 
    tidyr::complete(date_f = dates, Sex = c("Female", "Male"), Age = ages, type, fill = list(new = 0)) %>% 
    group_by(Sex, Age, type) %>% 
    mutate(Value = cumsum(new)) %>% 
    arrange(date_f, Sex, type, Age) %>% 
    ungroup() 
  
  db_c_all_types <- db_c2 %>% 
    group_by(date_f, Age, Sex) %>% 
    summarise(Value = sum(Value)) %>% 
    mutate(Measure = "Cases") %>% 
    select(date_f, Sex, Age, Measure, Value) %>% 
    ungroup()
  
  db_c_conf3 <- db_c2 %>% 
    filter(type == "Confirmed") %>% 
    mutate(Measure = "Cases_confirmed") %>% 
    select(date_f, Sex, Age, Measure, Value)
  
  db_c_all <- bind_rows(db_c_all_types, db_c_conf3) %>% 
    mutate(Country = "New Zealand",
           Region = "All",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Sex = ifelse(Sex == "Male", "m", "f"),
           Metric = "Count",
           AgeInt = case_when(Age == 0 ~ "1",
                              Age == 1 ~ "4",
                              Age == 5 ~ "5",
                              Age == 10 ~ "5",
                              Age == 15 ~ "5",
                              Age == 70 ~ "35",
                              TRUE ~ "10")) %>% 
    arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
    select(Country,Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
    
  ####################################
  # deaths by age from html table
  ####################################
  
  table_b <- tables[[5]]
  
  table_b2 <- table_b %>%
    as_tibble() %>% 
    rename(Age = 1,
           Act = 2,
           Rec = 3,
           Deaths = 4,
           Cases = 5) %>% 
    mutate(Cases = as.numeric(as.character(Cases)),
           Deaths = as.numeric(as.character(Deaths)),
           Deaths = replace_na(Deaths, 0)) %>% 
    select(Age, Cases, Deaths) %>% 
    mutate(AgeInt = case_when(Age == "70+" ~ "35",
                              Age == "90+" ~ "15",
                              Age == "Total" ~ "",
                              TRUE ~ "10"),
           Age = case_when(Age == "0 to 9" ~ "0",
                           Age == "10 to 19" ~ "10",
                           Age == "20 to 29" ~ "20",
                           Age == "30 to 39" ~ "30",
                           Age == "40 to 49" ~ "40",
                           Age == "50 to 59" ~ "50",
                           Age == "60 to 69" ~ "60",
                           Age == "70 to 79" ~ "70",
                           Age == "70+" ~ "70",
                           Age == "80 to 89" ~ "80",
                           Age == "90+" ~ "90",
                           Age == "Total" ~ "TOT"),
           Country = "New Zealand",
           Region = "All",
           Metric = "Count",
           Measure = "Deaths",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Sex = "b") %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value")
  
  table_tests <- tables[[8]] 
  
  table_tests2 <- table_tests %>% 
    as_tibble() %>% 
    rename(date = 1,
           Value = 3) %>% 
    select(date, Value) %>% 
    separate(date, c('d', 'm')) %>% 
    mutate(date_f = dmy(paste(d, m, 2020, sep = "."))) %>% 
    filter(date_f > "2020-03-01") %>% 
    mutate(Value = as.numeric(Value),
           AgeInt = "",
           Age = "TOT",
           Country = "New Zealand",
           Region = "All",
           Metric = "Count",
           Measure = "Tests",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Sex = "b") %>% 
    select(Country,Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  db_drive2 <- db_drive %>% 
    filter(Sex == "b",
           Measure != "Tests") %>% 
    mutate(AgeInt = as.character(AgeInt))
    
  db_all <- bind_rows(db_drive2, table_b2, db_c_all, table_tests2) %>% 
    mutate(date_f = dmy(Date)) %>% 
    arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
    select(Country,Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
    ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  write_sheet(db_all, ss_i, sheet = "database")
  log_update(pp = "New_Zealand", N = nrow(db_all))
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  
  sheet_name <- paste0("NZ", date_f, "cases&deaths")
  
  meta <- drive_create(sheet_name,
                       path = ss_db, 
                       type = "spreadsheet",
                       overwrite = T)
  
  write_sheet(db_c_conf, 
              ss = meta$id,
              sheet = "cases_confirmed")
  
  write_sheet(db_c_prob, 
              ss = meta$id,
              sheet = "cases_probable")
  
  write_sheet(table_b, 
              ss = meta$id,
              sheet = "cases&deaths_age")
  
  write_sheet(table_tests, 
              ss = meta$id,
              sheet = "tests")
  
  sheet_delete(meta$id, "Sheet1")

} else if (date_f == last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = "New_Zealand", N = 0)
}




  
