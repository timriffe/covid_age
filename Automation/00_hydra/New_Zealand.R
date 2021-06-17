# functions
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# info country and N drive address
ctr <- "New Zealand"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

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
m_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-data-and-statistics/covid-19-case-demographics"

# reading date of last update
html      <- read_html(m_url)
date_text <-
  html_nodes(html, xpath = '//*[@id="node-10866"]/div[2]/div/div/p[1]') %>%
  html_text()
loc_date1 <- str_locate(date_text, "Last updated ")[2] + 9
loc_date2 <- str_length(date_text[1])

date_f  <- str_sub(date_text, loc_date1, loc_date2) %>% 
  str_trim() %>% 
  str_replace("\\.", "") %>% 
  dmy()


if (date_f > last_date_drive){

  ####################################
  # all cases from case-based database
  ####################################

  root <- "https://www.health.govt.nz"
  
  # cases data
  html <- read_html(m_url)
  url1 <- html_nodes(html, xpath = '/html/body/div[2]/div/div[1]/section/div[2]/section/div/div/div[2]/div[2]/div/article/div[2]/div/div/p[12]/a') %>%
    html_attr("href")
  
  db_c <- read_csv(paste0(root, url1)) %>% 
    as_tibble()
  
  db_c2 <- 
    db_c %>% 
    select(date = 1,
           age_gr = 4,
           Sex) %>% 
    mutate(date_f = ymd(date))

  unique(db_c2$age_gr)
  
  db_c3 <- db_c2 %>% 
    separate(age_gr, c("Age", "trash"), sep = " to ") %>% 
    mutate(Age = case_when(Age == "90+" ~ "90",
                           TRUE ~ Age))
  unique(db_c3$Age)
  
  ages <-  suppressWarnings(as.integer(unique(db_c3$Age))) %>% sort() %>% as.character()
  dates <- unique(db_c3$date_f) %>% sort()
  
  db_c4 <- db_c3 %>% 
    group_by(date_f, Age, Sex) %>% 
    summarise(new = n()) %>% 
    ungroup() %>% 
    mutate(Sex = case_when(Sex == "Male" ~ "m", 
                           Sex == "Female" ~ "f", 
                           TRUE ~ "UNK")) %>% 
    tidyr::complete(date_f = dates, Sex = c("f", "m", "UNK"), Age = ages, fill = list(new = 0)) %>% 
    group_by(Sex, Age) %>% 
    mutate(Value = cumsum(new)) %>% 
    arrange(date_f, Sex, Age) %>% 
    ungroup() %>% 
    select(-new)

  db_c_sex <- db_c4 %>% 
    group_by(date_f, Age) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Sex = "b") %>% 
    filter(Age != "UNK")
  
  db_c_age <- db_c4 %>% 
    group_by(date_f, Sex) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT") %>% 
    filter(Sex != "UNK")
  
  db_c5 <- db_c4 %>% 
    filter(Age != "UNK" & Sex != "UNK") %>% 
    bind_rows(db_c_sex, db_c_age) 
  
  unique(db_c5$Sex)
  unique(db_c5$Age)
  
  db_c6 <- db_c5 %>% 
    mutate(Country = "New Zealand",
           Region = "All",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Metric = "Count",
           Measure = "Cases",
           AgeInt = case_when(Age == "90" ~ 15,
                              Age == "TOT" ~ NA_real_,
                              TRUE ~ 10)) %>% 
    arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
    select(Country,Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
    
  # ~~~~~~~~~~~~~
  # vaccines data
  # ~~~~~~~~~~~~~
  
  m_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-data-and-statistics/covid-19-vaccine-data#age"
  
  links <- scraplinks(m_url) %>% 
    filter(str_detect(url, "covid_vaccinations")) %>% 
    select(url) 
  
  url <- 
    links %>% 
    select(url) %>% 
    dplyr::pull()
  
  url_d = paste0("https://www.health.govt.nz",url)
  
  data_source6 <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".xlsx")
  
  #data_source <- paste0("U:/COVerAgeDB/Datenquellen/New Zealand_vaccine",today(), ".xlsx")
  
  download.file(url_d, data_source6, mode = "wb")

  #Date vaccine 
  
  date_vacc <- read_xlsx(data_source6,
                         sheet = "Notes", range = "F1:F2")
  
  colnames(date_vacc)[1] <- "Date"
  
  date= date_vacc%>%
    separate(Date, c("Date", "Time"), " ")%>%
    select(Date)%>% 
    dmy()
  
  
db_v <- 
    read_xlsx(data_source6,
    sheet = "Ethnicity, Age, Gender by dose")%>%
  select(Age= `Ten year age group`, Sex= Gender, Measure= `Dose number`, Value= `# doses administered`)%>%
  #sum up numbers that were separated by race 
  group_by(Age, Sex, Measure) %>% 
  mutate(Value = sum(Value)) %>% 
  ungroup() %>% 
  distinct()%>%
  mutate(Age = str_sub(Age, 1, 2)) %>% 
  mutate(AgeInt = case_when(
    Age == "90" ~ 15L,
    TRUE ~ 10L))%>% 
  mutate(Sex = case_when(
   Sex == "Male" ~ "m",
   Sex == "Female" ~ "f",
   Sex== "Other / Unknown" ~ "UNK"),
   Measure= case_when(
      Measure== "1" ~ "Vaccination1",
     Measure== "2" ~ "Vaccination2"),
  Country = "New Zealand",
  Region = "All",
  Date = ddmmyyyy(date_vacc),
  Code = paste0("NZ",Date),
  Metric = "Count")


  ####################################
  # deaths by age from html table
  ####################################
  
  # cases and deaths by age for the last update
  m_url2 <- getURL(m_url)
  tables <- readHTMLTable(m_url2) 
  db_a <- tables[[3]] 
  db_s <- tables[[4]]
  
  db_a2 <- db_a %>% 
    as_tibble() %>% 
    select(Age = 1,
           Cases = 5,
           Deaths = 4) %>% 
    mutate(Cases = as.numeric(as.character(Cases)),
           Deaths = as.numeric(as.character(Deaths)),
           Deaths = replace_na(Deaths, 0)) %>% 
    separate(Age, c("Age", "trash"), sep = " to ") %>% 
    mutate(Age = case_when(Age == "90+" ~ "90",
                           Age == "Total" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b") %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
    select(-trash)
  
  db_s2 <- db_s %>% 
    as_tibble() %>% 
    select(Sex = 1,
           Cases = 5,
           Deaths = 4) %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           Sex == "Total" ~ "b",
                           TRUE ~ "UNK"),
           Age = "TOT") %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
    mutate(Value = as.numeric(Value)) %>% 
    filter(Sex != "UNK",
           Sex != "b")
    
  

  db_as <- bind_rows(db_a2, db_s2) %>% 
    mutate(AgeInt = case_when(Age == "90" ~ 15,
                              Age == "TOT" ~ NA_real_,
                              TRUE ~ 10))
  
  
  # tests by age and sex
  test_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-data-and-statistics/testing-covid-19"
  test_url2 <- getURL(test_url)
  tables_test <- readHTMLTable(test_url2) 
  db_ta <- tables_test[[13]] 
  db_ts <- tables_test[[14]] 
  
  
  db_ta2 <- db_ta %>% 
    as_tibble() %>% 
    select(Age = 1,
           Value = 2) %>% 
    filter(Age != "Unknown") %>% 
    mutate(Value = as.numeric(Value)) %>% 
    separate(Age, c("Age", "trash"), sep = " to ") %>% 
    mutate(Age = case_when(Age == "80+" ~ "80",
                           Age == "Total" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b") %>% 
    select(-trash)
  
  db_ts2 <- db_ts %>% 
    as_tibble() %>% 
    select(Sex = 1,
           Value = 2) %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           Sex == "Total" ~ "b",
                           TRUE ~ "UNK"),
           Age = "TOT") %>% 
    filter(Sex != "UNK",
           Sex != "b") %>% 
    mutate(Value = as.numeric(Value))
  
  db_tas <- bind_rows(db_ta2, db_ts2) %>% 
    mutate(AgeInt = case_when(Age == "80" ~ 25,
                              Age == "TOT" ~ NA_real_,
                              TRUE ~ 10),
           Measure = "Tests")
  
  
  db_last_update <- bind_rows(db_as, db_tas) %>% 
    mutate(Country = "New Zealand",
           Region = "All",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Metric = "Count") #%>% 
    #bind_rows(db_v)
  
  # back up of deaths and tests out of csv
  ########################################
  
  db_dv1 <- db_drive %>% 
    filter(Measure != "Cases") %>% 
    select(-Short)
  
  # combinations in the no-case base
  db_in <- db_dv1 %>% 
    select(Age, Sex, Measure, Date) %>% 
    mutate(already = 1)
    
  # combinations in the last_update
  db_lu <- 
    db_last_update %>% 
    filter(Measure != "Cases") %>% 
    select(Age, Sex, Measure, Date)
  
  # new stuff
  db_nw <- 
    db_lu %>% 
    left_join(db_in) %>% 
    filter(is.na(already)) %>% 
    select(-already) %>% 
    left_join(db_last_update)
  
  # new no-case base
  db_drive_out <- bind_rows(db_dv1, db_nw)
  
  # saving no cases info in Drive
  write_sheet(db_drive_out,
              ss = ss_i,
              sheet = "database")

  # filling missing dates between equal deaths
  ############################################

  db_dh <- 
    db_drive_out %>% 
    filter(Measure == "Deaths") %>% 
    mutate(date_f = dmy(Date)) %>% 
    select(date_f, Sex, Age, AgeInt, Metric, Measure, Value)
    
  db_dh2 <- 
    db_dh %>% 
    group_by(Age, Value) %>% 
    mutate(Val2 = mean(Value),
           orig = min(date_f),
           dest = max(date_f)) %>% 
    arrange(Age, date_f) %>% 
    ungroup() %>% 
    filter(date_f == orig | date_f == dest) %>% 
    mutate(wtf = case_when(date_f == orig ~ "origin",
                           date_f == dest ~ "destin"))
    
  combs <- db_dh2 %>% 
    select(Sex, Age, AgeInt, Metric, Measure, Val2) %>% 
    unique()
  
  db_filled1 <- NULL
  for(i in 1:dim(combs)[1]){
    a <- combs[i,2] %>% dplyr::pull()
    s <- combs[i,1] %>% dplyr::pull()
    v <- combs[i,6] %>% dplyr::pull()
    db_dh3 <- 
      db_dh2 %>% 
      filter(Age == a,
             Sex == s,
             Value == v)
    
    d1 <- min(db_dh3$date_f)
    d2 <- max(db_dh3$date_f)
    
    db_dh4 <- db_dh3 %>% 
      tidyr::complete(date_f = seq(d1, d2, "1 day"), Sex, Age, AgeInt, Metric, Measure, Value)
    
    db_filled1 <- db_filled1 %>% 
      bind_rows(db_dh4)
  }
  
  # keep dates in which the 11 age groups have information all together
  
  date_lupdate <- 
    db_last_update %>% 
    filter(Measure == "Deaths") %>% 
    mutate(date_f = dmy(Date)) %>% 
    select(date_f) %>%
    unique() %>% 
    dplyr::pull()
  
  db_deaths_out <- db_filled1 %>% 
    select(date_f, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
    filter(date_f != date_lupdate) %>% 
    group_by(date_f) %>% 
    filter(n() == 11) %>% 
    mutate(Country = "New Zealand",
           Region = "All",
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           Code = paste0("NZ",Date),
           Metric = "Count")
  
  
  
  # putting together cases database, last update, and deaths
  ########################################################
  
  out <- bind_rows(db_c6, db_last_update, db_deaths_out,db_v) %>% 
    mutate(date_f = dmy(Date)) %>% 
    arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
    select(Country,Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  # view(db_all)
  
  #### saving database in N Drive ####
  ####################################
  
  write_rds(out, paste0(dir_n, ctr, ".rds"))
  log_update(pp = ctr, N = nrow(out))
  
  
  
  #### uploading metadata to N: Drive ####
  ########################################

  data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/all_cases_",today(), ".csv")
  data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/day_age",today(), ".csv")
  data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/day_sex",today(), ".csv")
  data_source4 <- paste0(dir_n, "Data_sources/", ctr, "/tests_age",today(), ".csv")
  data_source5 <- paste0(dir_n, "Data_sources/", ctr, "/tests_sex",today(), ".csv")
  
  data_source <- c(data_source1,
                   data_source2,
                   data_source3,
                   data_source4,
                   data_source5,
                   data_source6)
  
  write_csv(db_c, data_source1)
  write_csv(db_a, data_source2)
  write_csv(db_s, data_source3)
  write_csv(db_ta, data_source4)
  write_csv(db_ts, data_source5)
  
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
  log_update(pp = ctr, N = 0)
}

  
  
  

#######################################################

#outdated processing vaccine data 


#%>% 
#rename(Age = 1,
#Vaccination1 = 2,
#Vaccination2 = 3) %>% 
#mutate(Age = str_sub(Age, 1, 2)) %>% 
#gather(-Age, key = Measure, value = Value) %>% 
#tidyr::complete(Age = as.character(seq(0, 80, 10)), Measure, fill = list(Value = 0)) %>% 
#mutate(Sex = "b")

#db_v_sex <- 
#read_xlsx(data_source6,
# sheet = "Sex") %>% 
#rename(Vaccination1 = 2,
#Vaccination2 = 3) %>% 
#mutate(Sex = case_when(Sex == "Female" ~ "f",
#Sex == "Male" ~ "m",
# TRUE ~ "UNK")) %>% 
# gather(-Sex, key = Measure, value = Value) %>% 
# mutate(Age = "TOT")

#db_v <- 
#bind_rows(db_v_age, db_v_sex) %>% 
#mutate(AgeInt = case_when(Age == "80" ~ 25,
# Age == "TOT" ~ NA_real_,
# TRUE ~ 10),
# Country = "New Zealand",
# Region = "All",
# Date = ddmmyyyy(date_vacc),
# Code = paste0("NZ",Date),
#Metric = "Count")
  
  
  
#url_v <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-data-and-statistics/covid-19-vaccine-data#age"
#html_v <- read_html(url_v)
#link_v <- html_nodes(html_v, xpath = '//*[@id="node-12052"]/div[2]/div/div/p[12]/a') %>%
#html_attr("href")

#new xpath to source file 

#url_v <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-data-and-statistics/covid-19-vaccine-data#age"
#html_v <- read_html(url_v)
#link_v <- html_nodes(html_v, xpath = '/html/body/div[2]/div/div[1]/section/div[2]/section/div/div/div[2]/div[2]/div/article/div[2]/div/div/p[22]/a') %>%
#html_attr("href")  



#loc_date_v <- str_locate(link_v, ".xlsx")[1]
#date_vacc <- str_sub(link_v, loc_date_v - 10, loc_date_v - 1) %>% dmy()

#data_source6 <- paste0(dir_n, "Data_sources/", ctr, "/vaccines", date_vacc, ".xlsx")

#download.file(paste0(root, link_v), data_source6, mode = "wb")

  
  
  
  
  
  
  