#Script that makes plots of totals for cases, deaths, tests from output5 to check for data jumps
#plots get saved in R_checks/quality_checks

setwd("U:/gits/covid_age")
library(here)
source(here("Automation/00_Functions_automation.R"))
library(osfr)
library(tidyverse)
require(lubridate)
require(covidAgeData)
require(here)

osf_ls_files(cdb_repo, path = "Data") %>%
  dplyr::filter(name == "Output_10.zip") %>%
  osf_download(conflicts = "overwrite")

dat <-  read_csv("Output_10.zip",
                       skip = 3,
                       col_types = "ccccciiddd")

########################Check1#######################################################
#plots for sex=b and regions=All

#Deaths

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Deaths) 

cts <- dat2 %>%
  drop_na(Deaths) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Deaths), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/deaths_checks", i, ".png")) 
}

#Cases

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Cases) 

cts <- dat2 %>%
  drop_na(Cases) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Cases), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/cases_checks", i, ".png")) 
}

#Tests

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Tests) 

cts <- dat2 %>%
  drop_na(Tests) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Tests), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/tests_checks", i, ".png")) 
}

##############################Check2###########################################
#countries by sex 

#Deaths

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex != "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Deaths) 

cts <- dat2 %>%
  drop_na(Deaths) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Deaths), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/deaths_sex_checks", i, ".png")) 
}

#Cases

dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex != "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Cases) 

cts <- dat2 %>%
  drop_na(Cases) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Cases), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/cases_sex_checks", i, ".png")) 
}

#Tests 


dat2 <- 
  dat %>% 
  filter(Region == "All",
         Sex != "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Tests) 

cts <- dat2 %>%
  drop_na(Tests) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Tests), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/tests_sex_checks", i, ".png")) 
}

#######################check3#######################################
##################vaccines from input DB############################

#input
cdb_repo <- osf_retrieve_node("mpwjq")
osf_ls_files(cdb_repo, path = "Data") %>%
  dplyr::filter(name == "inputDB.zip") %>%
  osf_download(conflicts = "overwrite")

inputDB <-  read_csv("inputDB.zip",
                     skip = 1,
                     col_types = "cccccciccdc")


#plots for sex=b and regions=All

#vaccination1 

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex == "b",
         Measure=="Vaccination1") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccine1_checks", i, ".png")) 
}


#vaccination2 

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex == "b",
         Measure=="Vaccination2") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccine2_checks", i, ".png")) 
}

#vaccinations 

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex == "b",
         Measure=="Vaccinations") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccines_checks", i, ".png")) 
}

#countries by sex 

#Vaccination1

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex != "b",
         Measure=="Vaccination1") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccination1_sex_checks", i, ".png")) 
}


#Vaccination2

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex != "b",
         Measure=="Vaccination2") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccination2_sex_checks", i, ".png")) 
}


#Vaccinations

dat2 <- 
  inputDB %>% 
  filter(Region == "All",
         Sex != "b",
         Measure=="Vaccinations") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup()%>%
  drop_na(Value) 

cts <- dat2 %>%
  drop_na(Value) %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  dat2 %>% 
    filter(Country %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date,Value), size = 0.3)+
    facet_wrap(~Country, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/vaccinations_sex_checks", i, ".png")) 
}


#####us states

#Deaths

dat2 <- 
  dat %>% 
  filter(Country == "USA",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Region, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Deaths) 

cts <- dat2 %>%
  drop_na(Deaths) %>% 
  select(Region) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Region)
  
  dat2 %>% 
    filter(Region %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Deaths), size = 0.3)+
    facet_wrap(~Region, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/deaths_checks_states", i, ".png")) 
}

#Cases

dat2 <- 
  dat %>% 
  filter(Country == "USA",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Region, Date) %>% 
  summarise(Deaths = sum(Deaths),
            Cases = sum(Cases),
            Tests = sum(Tests)) %>% 
  ungroup()%>%
  drop_na(Cases) 

cts <- dat2 %>%
  drop_na(Cases) %>% 
  select(Region) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Region)
  
  dat2 %>% 
    filter(Region %in% cts_t) %>% 
    ggplot()+
    geom_point(aes(Date, Cases), size = 0.3)+
    facet_wrap(~Region, scales = "free")+
    theme(
      axis.text.x = element_text(size = 5)
    )
  
  ggsave(paste0("R_checks/quality_checks/cases_checks_states", i, ".png")) 
}


