library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "CA_Manitoba_Saskatchewan"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# Canadian Deaths
db_d2020 <- read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2020.csv")
db_d2021 <- read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2021.csv")

db_ma_2020 <- db_d2020 %>% 
  filter(province == "Manitoba") %>% 
  select(province, age, sex, date_death_report)

db_ma_2021 <- db_d2021 %>% 
  filter(province == "Manitoba") %>% 
  select(province, age, sex, date_death_report)

db_ma <- bind_rows(db_ma_2020, db_ma_2021) %>% 
  rename(Region = province,
         Date = date_death_report,
         Age = age,
         Sex = sex) %>% 
  mutate(Date = dmy(Date),
         Age = str_sub(Age, 1, 3),
         Age = str_replace(Age, "-", ""),
         Age = case_when(Age == "<10" ~ "0", 
                         Age == "100" ~ "90",
                         TRUE ~ Age),
         Sex = recode(Sex, 
                      "Female" = "f",
                      "Male" = "m")) %>% 
  group_by(Region, Date, Sex, Age) %>% 
  summarise(New = n()) %>% 
  ungroup()

dates <- seq(ymd(min(db_ma$Date)), max(db_ma$Date), by = "1 day")

db_ma2 <- db_ma %>% 
  tidyr::complete(Region, Date = dates, Sex, Age, fill = list(New = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  ungroup() %>% 
  group_by(Date) %>% 
  filter(sum(Value) >= 50) %>% 
  ungroup() %>% 
  mutate(Date = ddmmyyyy(Date),
         Code = paste0("CA-MA"),
         AgeInt = case_when(Age == "90" ~ 15,
                            TRUE ~ 10)) %>% 
  select(-New)


# Saskatchewan
db_sk_2020 <- db_d2020 %>% 
  filter(province == "Saskatchewan") %>% 
  select(province, age, sex, date_death_report)

db_sk_2021 <- db_d2021 %>% 
  filter(province == "Saskatchewan") %>% 
  select(province, age, sex, date_death_report)

db_sk <- bind_rows(db_ma_2020, db_ma_2021) %>% 
  rename(Region = province,
         Date = date_death_report,
         Age = age,
         Sex = sex) %>% 
  mutate(Date = dmy(Date),
         Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "<1" ~ "0", 
                         Age == ">8" ~ "80", 
                         Age == ">9" ~ "80",
                         Age == "90" ~ "80",
                         Age == "No" ~ "UNK",
                         TRUE ~ Age),
         Sex = recode(Sex, 
                      "Female" = "f",
                      "Male" = "m",
                      "Not Reported" = "UNK")) %>% 
  group_by(Region, Date, Sex, Age) %>% 
  summarise(New = n()) %>% 
  ungroup()

dates_sk <- seq(ymd(min(db_sk$Date)), max(db_sk$Date), by = "1 day")

db_sk2 <- db_sk %>% 
  tidyr::complete(Region, Date = dates_sk, Sex, Age, fill = list(New = 0)) %>% 
  arrange(Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  ungroup() %>% 
  group_by(Date) %>% 
  filter(sum(Value) >= 50) %>% 
  ungroup() %>% 
  mutate(Date = ddmmyyyy(Date),
         Code = paste0("CA-SK"),
         AgeInt = case_when(Age == "80" ~ 25,
                            TRUE ~ 10)) %>% 
  select(-New)

out <- 
  bind_rows(db_ma2, db_sk2) %>% 
  mutate(Country = "Canada",
         Metric = "Count",
         Measure = "Deaths") %>% 
  sort_input_data()

# saving data in N drive
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

