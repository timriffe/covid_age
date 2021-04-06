
tot <- read_xlsx("C:/Users/acosta/Downloads/Texas COVID-19 Fatality Count Data by County.xlsx",
                 skip = 2)

tot2 <- tot %>% 
  rename(place = 1) %>% 
  filter(place == "Total") %>% 
  gather(-place, key = date, value = Value) %>% 
  mutate(date = str_remove(date, "Fatalities "),
         date = mdy(date),
         Age = "TOT",
         Sex = "b",
         Measure = "Deaths",
         AgeInt = NA,
         Country = "USA",
         Region = "Texas",
         Date = ddmmyyyy(date),
         Code = paste0("US_TX", Date),
         Metric = "Counts") %>% 
  sort_input_data()


db_drive2 <- db_drive %>%
  select(-Short) %>% 
  filter(!(Age == "TOT" & Sex == "b" & Measure == "Deaths")) %>% 
  bind_rows(tot2) %>% 
  sort_input_data()



sheet_write(db_drive2,
             ss = ss_i,
             sheet = "database")
