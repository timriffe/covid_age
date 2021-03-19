# 1. Preamble ---------------

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Japan"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# data from drive 
rubric_i <- get_input_rubric() %>% filter(Short == "JP")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


db_jp <- 
  read_csv("https://toyokeizai.net/sp/visual/tko/covid19/csv/demography.csv")

out <- 
  db_jp %>% 
  mutate(Date = make_date(y = year, m = month, d = date),
         age_group = ifelse(age_group == "10歳未満", "0", age_group),
         Age = str_sub(age_group, 1, 2),
         Age = ifelse(Age == "不明", "UNK", Age)) %>% 
  rename(Cases = tested_positive,
         Deaths = death) %>% 
  select(Date, Age, Cases, Deaths) %>% 
  gather(Cases, Deaths, key = Measure, value = Value) %>% 
  mutate(AgeInt = case_when(Age == "80" ~ 25,
                            Age == "UNK" ~ NA_real_,
                            TRUE ~ 10),
         Sex = "b",
         Metric = "Count",
         Country = "Japan",
         Region = "All",
         Date = ddmmyyyy(Date),
         Code = paste0("JP", Date)) %>% 
  sort_input_data()
  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# uploading database to Google Drive 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sheet_append(out,
             ss = ss_i,
             sheet = "database")

log_update(pp = "Japan", N = nrow(out))

data_source <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".csv")

write_csv(db_jp, data_source)


