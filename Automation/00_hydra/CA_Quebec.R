# Quebec
library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "CA_Quebec"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

source_dir <- "U:/nextcloud/Projects/COVID_19/COVerAGE-DB/CA_Quebec/"
# source_dir <- "C:/Users/kikep/nextcloud/Projects/COVID_19/COVerAGE-DB/CA_Quebec/"

db_qc_c <- read_csv(paste0(source_dir, "Graphique 1.7 - page age-sexe.csv"))
db_qc_d <- read_csv(paste0(source_dir, "Graphique 2.7 - page age-sexe.csv"))

data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")

write_csv(db_qc_c, data_source_c)
write_csv(db_qc_d, data_source_d)

data_source <- c(data_source_c, data_source_d)

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

db_qc_c2 <- db_qc_c %>% 
  rename(Date = 1) %>% 
  mutate(Date = ymd(Date)) %>% 
  gather(-Date, key = Age, value = New) %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  arrange(Date, Age) %>% 
  ungroup() %>% 
  select(-New) %>% 
  mutate(Measure = "Cases")

db_qc_d2 <- db_qc_d %>% 
  rename(Date = 1) %>% 
  mutate(Date = ymd(Date)) %>% 
  gather(-Date, key = Age, value = New) %>% 
  group_by(Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  arrange(Date, Age) %>% 
  ungroup() %>% 
  select(-New) %>% 
  mutate(Measure = "Deaths")

out <- 
  bind_rows(db_qc_c2, db_qc_d2) %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = ifelse(Age == "0-", "0", Age), 
         Sex = "b",
         Country = "Canada",
         Region = "Quebec",
         Date = ddmmyyyy(Date),
         Code = paste0("CA-QC"),
         AgeInt = case_when(Age == "90" ~ 15,
                            TRUE ~ 10),
         Metric = "Count") %>% 
  sort_input_data()

# saving data in N drive
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

