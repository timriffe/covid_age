library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "CA_Manitoba"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Canadian Deaths
db_d2020 <- read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2020.csv")
db_d2021 <- read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2021.csv")

manit_2020 <- db_d2020 %>% 
  filter(province == "Manitoba") %>% 
  select(age, sex, date_death_report)

manit_2021 <- db_d2021 %>% 
  filter(province == "Manitoba") %>% 
  select(age, sex, date_death_report)

unique(manit$Age)

manit <- bind_rows(manit_2020, manit_2021) %>% 
  rename(Date = 3,
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
  group_by(Date, Sex, Age) %>% 
  summarise(New = n()) %>% 
  ungroup() %>% 
  complete(Date, Sex, Age, fill = list(New = 0)) %>% 
  arrange(Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Deaths = cumsum(New)) %>% 
  ungroup()

recent_mani <- manit %>% 
  filter(Date == max(Date))

manit_31oct <- 
  manit %>% 
  filter(Date == "2020-10-31")

manit_31oct %>% 
  summarise(sum(Deaths))

# Saskatchewan

unique(db_d2020$province)
sask_2020 <- db_d2020 %>% 
  filter(province == "Saskatchewan") %>% 
  select(age, sex, date_death_report)

sask_2021 <- db_d2021 %>% 
  filter(province == "Saskatchewan") %>% 
  select(age, date_death_report)

table(sask$Age)

sask <- bind_rows(sask_2020, sask_2021) %>% 
  rename(Date = 3,
         Age = age) %>% 
  mutate(Date = dmy(Date),
         Age = str_sub(Age, 1, 2),
         Age = case_when(Age == ">8" | Age == ">9" | Age == "90" ~ "80",
                         Age == "64" ~ "60",
                         Age == "No" ~ "UNK",
                          TRUE ~ Age)) %>% 
  group_by(Date, Age) %>% 
  summarise(New = n()) %>% 
  ungroup() %>% 
  complete(Date, Age, fill = list(New = 0)) %>% 
  arrange(Date) %>% 
  group_by(Age) %>% 
  mutate(Deaths = cumsum(New)) %>% 
  ungroup()

recent_sask <- sask %>% 
  filter(Date == max(Date))

sask_16nov <- 
  sask %>% 
  filter(Date == "2020-11-20")

