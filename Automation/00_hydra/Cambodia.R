source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Cambodia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

db <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQkLytTn5lDnsOht865NZRmypUBQKZDN5Sf9RLVs11O9f1AbmF_ZhA53sErE2tG637HtOABPoaEX1Fn/pub?gid=0&single=true&output=csv")

# cases
db_c <- db %>% 
  select(province_en, gender_en, age, infected, death, created_at) %>% 
  mutate(Age = floor(floor(age) / 5) * 5,
         Date = ymd(str_sub(created_at, 1, 10)),
         Sex = case_when(gender_en == "Male" ~ "m",
                         gender_en == "Female" ~ "f",
                         TRUE ~ "UNK")) %>% 
  group_by(Sex, Age, Date) %>% 
  summarise(new = n(), .groups = "drop") %>% 
  arrange(Date, Age)

# all dates
dates <- seq(min(db_c$Date), max(db_c$Date), by = "1 day")

# cases for all ages
db_c_all_ages <- db_c %>% 
  group_by(Sex, Date) %>% 
  summarise(new = sum(new), .groups = "drop") %>% 
  tidyr::complete(Sex, Date = dates, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Sex) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new) %>% 
  mutate(Age = "TOT")
  
# total cases by day
db_c_tot <- db_c_all_ages %>% 
  group_by(Date) %>%
  summarise(Value = sum(Value)) %>% 
  mutate(Sex = "b",
         Age = "TOT")

# dates with at least 50 cases (cases will be disagregated by ages in these dates only)
dates_desag <- db_c_tot %>% 
  filter(Value >= 50) %>% 
  dplyr::pull(Date)

ages <- seq(0, 100, 5)

# completing cumulative cases for all days  
db_c2 <- db_c %>% 
  tidyr::complete(Sex, Age = ages, Date = dates_desag, fill = list(new = 0)) %>% 
  arrange(Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  select(-new) %>% 
  filter(Date %in% dates_desag) %>% 
  mutate(Age = as.character(Age)) %>% 
  bind_rows(db_c_tot, db_c_all_ages) %>% 
  arrange(Date, Sex, Age) %>% 
  mutate(Measure = "Cases")
 
# deaths data 
#############

db_d2 <- tibble()

deaths <- db %>% 
  filter(death == 1) %>% 
  summarise(deaths = n())

if(deaths > 0){
  
  db_d <- db %>% 
    select(province_en, gender_en, age, infected, death, created_at) %>% 
    filter(death == 1) %>% 
    mutate(Age = floor(floor(age) / 5) * 5,
           Date = ymd(str_sub(created_at, 1, 10)),
           Sex = case_when(gender_en == "Male" ~ "m",
                           gender_en == "Female" ~ "f",
                           TRUE ~ "UNK")) %>% 
    group_by(Sex, Age, Date) %>% 
    summarise(new = n()) %>% 
    ungroup() %>% 
    arrange(Date, Age)
  
  # all dates
  dates <- seq(min(db_d$Date), max(db_d$Date), by = "1 day")
  
  # deaths for all ages
  db_d_all_ages <- db_d %>% 
    group_by(Sex, Date) %>% 
    summarise(new = sum(new)) %>% 
    ungroup() %>% 
    tidyr::complete(Sex, Date = dates, fill = list(new = 0)) %>% 
    arrange(Date) %>% 
    group_by(Sex) %>% 
    mutate(Value = cumsum(new)) %>% 
    ungroup() %>% 
    select(-new) %>% 
    mutate(Age = "TOT")
  
  # total cases by day
  db_d_tot <- db_d_all_ages %>% 
    group_by(Date) %>%
    summarise(Value = sum(Value)) %>% 
    mutate(Sex = "b",
           Age = "TOT")
  
  db_d2 <- bind_rows(db_c_tot, db_c_all_ages) %>% 
    mutate(Measure = "Deaths")
  
  if(deaths > 0){
    # dates with at least 50 cases (cases will be disagregated by ages in these dates only)
    dates_d_desag <- db_d_tot %>% 
      filter(Value >= 50) %>% 
      dplyr::pull(Date)
    
    ages <- seq(0, 100, 5)
    
    # completing cumulative cases for all days  
    db_d2 <- db_d %>% 
      tidyr::complete(Sex, Age = ages, Date = dates_d_desag, fill = list(new = 0)) %>% 
      arrange(Date) %>% 
      group_by(Sex, Age) %>% 
      mutate(Value = cumsum(new)) %>% 
      ungroup() %>% 
      select(-new) %>% 
      filter(Date %in% dates_desag) %>% 
      mutate(Age = as.character(Age)) %>% 
      bind_rows(db_c_tot, db_c_all_ages) %>% 
      arrange(Date, Sex, Age)  %>% 
      mutate(Measure = "Deaths")
  }
} else {
  db_d2 <- tibble(Sex = "b", Age = "TOT", Date = max(db_c2$Date), Value = 0, Measure = "Deaths")
}

out <- bind_rows(db_c2, db_d2) %>% 
  mutate(Country = "Cambodia",
         Region = "All",
         AgeInt = case_when(Age == "TOT" ~ NA_real_,
                            TRUE ~ 5),
         Date = ddmmyyyy(Date),
         Code = paste0("KH"),
         Metric = "Count") %>% 
  sort_input_data()

#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

#### uploading metadata to N Drive ####
############################################
data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&deaths_",today(), ".csv")
write_csv(db, data_source)
