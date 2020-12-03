library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "ugofilippo.basellini@gmail.com"
}

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# info by age
# hm <- read_csv("https://data.cdc.gov/api/views/9bhg-hcku/rows.csv?accessType=DOWNLOAD")
db <- read_csv("https://data.cdc.gov/api/views/vsak-wrfu/rows.csv?accessType=DOWNLOAD")
# to <- read_csv("https://data.cdc.gov/api/views/r8kw-7aab/rows.csv?accessType=DOWNLOAD")

db2 <- db %>%
  select("Age Group", "Sex", "End Week", "COVID-19 Deaths") %>%
  rename(Age = "Age Group",
         date_f = "End Week",
         New = "COVID-19 Deaths") %>%
  mutate(Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "Un" ~ "0",
                         Age == "Al" ~ "TOT",
                         Age == "1-" ~ "1",
                         Age == "5-" ~ "5",
                         TRUE ~ as.character(Age)),
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m",
                         Sex == "All Sex" ~ "b"),
         AgeInt = case_when(Age == "TOT" ~ "",
                            Age == "0" ~ "1",
                            Age == "1" ~ "4",
                            Age == "5" ~ "10",
                            Age == "85" ~ "20",
                            TRUE ~ "10"),
         date_f = make_date(d = str_sub(date_f, 4, 5), m = str_sub(date_f, 1, 2), y = 2020)) %>%
  select(date_f, Sex, Age, AgeInt, New) %>%
  arrange(date_f, Sex, Age) %>%
  drop_na()

db3 <- db2 %>%
  group_by(Sex, Age) %>%
  mutate(Value = cumsum(New))

db_all <- db3 %>%
  filter(date_f > "2020-02-29") %>%
  mutate(Country = "USA",
         Region = "All",
         Metric = "Count",
         Measure = "Deaths",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Code = paste0("US", Date)) %>%
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>%
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################
write_rds(db_all, "N:/COVerAGE-DB/Automation/Hydra/USA_all_deaths.rds")
log_update(pp = "USA_all_deaths", N = nrow(db_all))

############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("US_All_", d, "cases&deaths")

# TR: pull urls from rubric instead
rubric_i <- get_input_rubric() %>% filter(Short == "US")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

meta <- drive_create(sheet_name,
                     path = ss_db,
                     type = "spreadsheet",
                     overwrite = TRUE)

write_sheet(db,
            ss = meta$id,
            sheet = "deaths_age")

write_sheet(to,
            ss = meta$id,
            sheet = "deaths_all")

sheet_delete(meta$id, "Sheet1")

Sys.sleep(100)
# uploading data for INED
# TR: not sure where this leads to, seems to be exact same place, overwriting the previous?
meta2 <- drive_create(sheet_name,
                     path = "https://drive.google.com/drive/folders/1t2_JQaVJEPWEZxAqhe8TxEDkIrYeMLCF?usp=sharing",
                     type = "spreadsheet",
                     overwrite = TRUE)

write_sheet(db,
            ss = meta2$id,
            sheet = "deaths_age")

sheet_delete(meta2$id, "Sheet1")
