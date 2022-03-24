library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "US_NYC"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_NYC")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


# reading data from Drive and last date entered 
db_drive <- read_sheet(ss = ss_i, sheet = "database")

last_date_drive <- db_drive %>% 
  mutate(date_f = dmy(Date)) %>% 
  dplyr::pull(date_f) %>% 
  max()

db_age <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/totals/by-age.csv")
db_sex <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/totals/by-sex.csv")
db_sum <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/totals/summary.csv", col_names = F)
db_tests <- read_csv("https://github.com/nychealth/coronavirus-data/raw/master/trends/testing-by-age.csv")

date_f <- db_sum %>% 
  filter(X1 == "DATE_UPDATED") %>% 
  separate(X2, c("m", "d")) %>% 
  mutate(date = ymd(paste("2022", m, d, sep = "/"))) %>% 
  dplyr::pull(date)

if (date_f > last_date_drive){

  # cases by age
  db_a2_c <- db_age %>% 
    filter(AGE_GROUP != "0-17") %>% 
    mutate(Age = str_sub(AGE_GROUP, 1, 2),
           Age = case_when(Age == "0-" ~ "0",
                           Age == "5-" ~ "5",
                           Age == "Ci" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b",
           Measure = "Cases",
           date_f = date_f) %>% 
    rename(Value = CASE_COUNT) %>% 
    select(date_f, Sex, Age, Measure, Value)
  
  # deaths by age
  db_a2_d <- db_age %>% 
    filter(!(AGE_GROUP %in% c("0-4", "5-12", "13-17"))) %>% 
    mutate(Age = str_sub(AGE_GROUP, 1, 2),
           Age = case_when(Age == "0-" ~ "0",
                           Age == "Ci" ~ "TOT",
                           TRUE ~ Age),
           Sex = "b",
           Measure = "Deaths",
           date_f = date_f) %>% 
    rename(Value = DEATH_COUNT) %>% 
    select(date_f, Sex, Age, Measure, Value)
  
  # by sex
  db_s2 <- db_sex %>% 
    rename(Sex = SEX_GROUP,
           Cases = CASE_COUNT,
           Deaths = DEATH_COUNT) %>% 
    mutate(Sex = case_when(Sex == "Female" ~ "f",
                           Sex == "Male" ~ "m",
                           TRUE ~ "b"),
           Age = "TOT",
           date_f = date_f) %>% 
    select(date_f, Sex, Age, Cases, Deaths) %>% 
    filter(Sex != "b") %>% 
    gather(Cases, Deaths, key = Measure, value = Value)
  
  # tests by age
  db_t2 <- db_tests %>%
    rename(date_f = week_ending) %>% 
    select(date_f, starts_with("numtest")) %>% 
    gather(-date_f, key = "Age", value = "new") %>% 
    separate(Age, c("trash1", "Age", "trash2"), sep = "_") %>% 
    group_by(Age) %>% 
    mutate(Value = cumsum(new)) %>% 
    mutate(date_f = mdy(date_f),
           Age = case_when(Age == "all" ~ "TOT",
                           Age == "75up" ~ "75",
                           TRUE ~ Age),
           Sex = "b",
           Measure = "Tests") %>% 
    select(date_f, Sex, Age, Measure, Value)
  
  tests_drive <- db_drive %>% 
    filter(Measure == "Tests") %>% 
    mutate(date_f = dmy(Date),
           AgeInt = as.character(AgeInt)) %>% 
    dplyr::pull(date_f) %>% 
    unique
  
  db_t3 <- db_t2 %>% 
    filter(!(date_f %in% tests_drive))
  
  # data in previous dates on cases and deaths
  # db_drive2 <- db_drive %>% 
  #   filter(Measure %in% c("Cases", "Deaths")) %>% 
  #   mutate(date_f = dmy(Date),
  #          AgeInt = as.character(AgeInt)) %>% 
  #   select(-Short)

  out <- bind_rows(db_a2_c, db_a2_d, db_s2, db_t3) %>% 
    mutate(Country = "USA",
           Region = "NYC",
           Date = ddmmyyyy(date_f),
           Code = "US-NYC+",
           AgeInt = case_when(Age == "0" & Measure == "Deaths" ~ "18",
                              Age == "0" & (Measure == "Cases" | Measure == "Tests") ~ "5",
                              Age == "5" & (Measure == "Cases" | Measure == "Tests") ~ "8",
                              Age == "13" & (Measure == "Cases" | Measure == "Tests") ~ "5",
                              Age == "18" ~ "7",
                              Age == "75" ~ "30",
                              Age == "TOT" ~ "",
                              TRUE ~ "10"),
           Metric = "Count") %>% 
    # bind_rows(db_drive2) %>% 
    arrange(Country,
            Region,
            date_f,
            Code,
            Sex, 
            Measure,
            Metric,
            suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 
  
  ############################################
  #### uploading database to Google Drive ####
  ############################################
  
  # This command append new rows at the end of the sheet
  sheet_append(out,
              ss = ss_i,
              sheet = "database")
  log_update(pp = ctr, N = nrow(out))
  
  ############################################
  #### uploading metadata to N Drive ####
  ############################################
  
  data_source_a <- paste0(dir_n, "Data_sources/", ctr, "/age_",today(), ".csv")
  data_source_s <- paste0(dir_n, "Data_sources/", ctr, "/sex_",today(), ".csv")
  data_source_to <- paste0(dir_n, "Data_sources/", ctr, "/summary_",today(), ".csv")
  data_source_te <- paste0(dir_n, "Data_sources/", ctr, "/tests_",today(), ".csv")
  
  write_csv(db_age, data_source_a)
  write_csv(db_sex, data_source_s)
  write_csv(db_sum, data_source_to)
  write_csv(db_tests, data_source_te)
  
  data_source <- c(data_source_a, data_source_s, data_source_to, data_source_te)
  
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
  log_update(pp = "US_NYC", N = 0)
}
