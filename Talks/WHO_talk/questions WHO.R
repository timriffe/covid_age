library(tidyverse)
library(readxl)
library(HMDHFDplus)
library(osfr)
library(lubridate)
###################
osf_retrieve_file("7tnfh") %>%
  osf_download(conflicts = "overwrite",
               path = "Data") 

# This reads it in
db5 <-  read_csv("Data/Output_5.zip",
                 skip = 3,
                 col_types = cols(.default = "c"))
  

db5_2 <- db5 %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Country == "Spain",
         Region == "All",
         Date == "2020-11-15") %>% 
  select(Sex, Age, Cases) %>% 
  mutate(Age = ifelse(as.integer(Age) > 90, 90, as.integer(Age)),
         Cases = as.integer(Cases),
         Sex = ifelse(Sex == "b", "t", Sex)) %>% 
  group_by(Sex, Age) %>% 
  summarise(Cases = sum(Cases)) %>% 
  ungroup()

  
pop <- read_delim("Data/pop_spain.txt", delim = " ", skip = 1)

pop2 <- pop %>% 
  rename(Year = 1,
         Age = 2,
         f = 3,
         m = 4,
         t = 5) %>% 
  gather(f, m, t, key = "Sex", value = "Pop") %>% 
  mutate(Year = as.integer(Year),
         Age = str_trim(Age),
         Age = ifelse(Age == "110+", 110, as.integer(Age)),
         Age = floor(Age / 5) * 5,
         Age = ifelse(Age > 90, 90, Age),
         Pop = as.integer(Pop)) %>% 
  filter(Year == 2019) %>% 
  group_by(Age, Sex) %>% 
  summarise(Pop = sum(Pop)) %>% 
  ungroup()

sero <- read_xlsx("Data/spain_global_prevalence_rounds_1-4.xlsx")

unique(sero$Sexo)
unique(sero2$Age)

sero2 <- sero %>% 
  mutate(Age = str_sub(Edad, 1, 2),
         Age = recode(Age,
                      "0-" = "0",
                      "5-" = "5",
                      "≥9" = "90",
                      "To" = "TOT"),
         Sex = recode(Sexo,
                      "Total" = "t",
                      "Hombres" = "m",
                      "Mujeres" = "f")) %>% 
  select(Age, Sex, central) %>% 
  filter(Age != "TOT") %>% 
  mutate(Age = as.integer(Age)) %>% 
  replace_na(list(Age = 90))


incidence <- 
  db5_2 %>% 
  left_join(pop2) %>% 
  mutate(Confirmed = 100 * Cases / Pop) %>% 
  left_join(sero2) %>% 
  rename(Serosurvey = central) %>% 
  gather(Confirmed, Serosurvey, key = "Source", value = "Prevalence")
  
incidence %>% 
  filter(Sex == "t",
         Age < 80) %>% 
  mutate(Age = Age + 2.5) %>% 
  ggplot()+
  geom_line(aes(Age, Prevalence, linetype = Source))+
  theme_bw()+
  scale_linetype_manual(values = c("dashed", "solid"))+
  labs(y = "Cumulative Incidence (%)")

ggsave("Talks/WHO_talk/conf_vs_serop.png", width = 4, height = 2)

incidence2 <- incidence %>% 
  filter(Sex == "t",
         Age < 80) %>% 
  group_by(Source) %>%
  mutate(all_prev = sum(Prevalence),
         age_dist = 100 * Prevalence / all_prev)


incidence2 %>% 
  mutate(Age = Age + 2.5) %>% 
  ggplot()+
  geom_line(aes(Age, age_dist, linetype = Source))+
  scale_linetype_manual(values = c("dashed", "solid"))+
  theme_bw()+
  labs(y = "Age distribution (%)") %>% 
  scale_y_continuous(limits = c(0, 10))

ggsave("Talks/WHO_talk/conf_vs_serop_stand.png", width = 4, height = 2)

# different from a regular age distribution
test <- incidence %>% 
  filter(Sex == "t",
         Age < 80) %>% 
  group_by() %>%
  mutate(Confirmed = 100 * Cases / Pop,
         all_conf = sum(Confirmed),
         age_dist2 = Confirmed / all_conf,
         all_cas = sum(Cases),
         age_dist = Cases / all_cas) %>%
  select(Age, age_dist, age_dist2) %>% 
  gather(age_dist, age_dist2, key = "type", value = "val")
  
test %>% 
  ggplot()+
  geom_line(aes(Age, val, col = type))

