
setwd("U:/gits/covid_age")
library(here)
source(here("Automation/00_Functions_automation.R"))
library(osfr)
library(tidyverse)
require(lubridate)
require(covidAgeData)
require(here)
#link_old <- "https://osf.io/7tnfh/download?version=135&displayName=Output_5-2021-01-13T07%3A22%3A39.845954%2B00%3A00.zip"
osf_retrieve_file("9dsfk") %>%
  osf_download(conflicts = "overwrite")

inputDB <-  read_csv("inputDB.zip",
                     skip = 1,
                     col_types = "cccccciccdc")

inputDB2 <- inputDB %>% 
  filter(Region == "All") %>% 
  mutate(Value = 1) %>% 
  group_by(Country, Measure, Date) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Value = 1) 
  #mutate(CountryRegion = paste0(Country,"-",Region))

inputDB2$Month <- sub("...", "", inputDB2$Date)
inputDB2$Year <- sub("......", "", inputDB2$Date)
inputDB2$Month = substr(inputDB2$Month,1,nchar(inputDB2$Month)-5)
inputDB2 <- inputDB2 %>% 
filter(Year != "2014",
       Year != "2016") %>%   
mutate(Date = paste0(Year,Month)) %>% 
  group_by(Country, Date, Measure) %>%
  summarise(Value = sum(Value)) %>% 
  mutate(Value = 1)

cases <- inputDB2 %>% 
  filter(Measure == "Cases")



cts <- cases %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  cases %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/cases", i, ".png")) 
}









death <- inputDB2 %>% 
  filter(Measure == "Deaths")



cts <- death %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  death %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/death", i, ".png")) 
}



test <- inputDB2 %>% 
  filter(Measure == "Tests")


cts <- test %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  test %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/tests", i, ".png")) 
}


vacc1 <- inputDB2 %>% 
  filter(Measure == "Vaccination1")

cts <- vacc1 %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  vacc1 %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/vacc1", i, ".png")) 
}

vacc2 <- inputDB2 %>% 
  filter(Measure == "Vaccination2")


cts <- vacc2 %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  vacc2 %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/vacc2", i, ".png")) 
}

vacc3 <- inputDB2 %>% 
  filter(Measure == "Vaccination3")


cts <- vacc3 %>%
  # drop_na(Country) %>% 
  ungroup() %>% 
  select(Country) %>% 
  unique() %>% 
  mutate(id = 1:n(),
         gr = floor(id/12) + 1)


for(i in 1:max(cts$gr)){
  cts_t <- 
    cts %>% 
    filter(gr == i) %>% 
    dplyr::pull(Country)
  
  vacc3 %>% 
    filter(Country %in% cts_t) %>%
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/vacc3", i, ".png")) 
}

