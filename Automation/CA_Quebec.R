# Quebec
db_qc_c <- read_csv("Data/quebec_cases_age_historic.csv")
db_qc_d <- read_csv("Data/quebec_deaths_age_historic.csv")

db_qc_c2 <- db_qc_c %>% 
  rename(Date = 1) %>% 
  mutate(Date = ymd(Date)) %>% 
  gather(-Date, key = Age, value = New) %>% 
  group_by(Age) %>% 
  mutate(Cases = cumsum(New)) %>% 
  arrange(Date, Age) %>% 
  ungroup() %>% 
  filter(Date == max(Date)) %>% 
  select(-New)

db_qc_d2 <- db_qc_d %>% 
  rename(Date = 1) %>% 
  mutate(Date = ymd(Date)) %>% 
  gather(-Date, key = Age, value = New) %>% 
  group_by(Age) %>% 
  mutate(Deaths = cumsum(New)) %>% 
  arrange(Date, Age) %>% 
  ungroup() %>% 
  filter(Date == max(Date)) %>% 
  select(-New)