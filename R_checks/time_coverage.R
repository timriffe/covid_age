
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

inputDB3$Month <- sub("...", "", inputDB2$Date)
inputDB3$Year <- sub("......", "", inputDB2$Date)
inputDB3$Month = substr(inputDB3$Month,1,nchar(inputDB3$Month)-5)
inputDB3 <- inputDB3 %>% 
filter(Year != "2014",
       Year != "2016") %>%   
mutate(Date = paste0(Year,Month)) %>% 
  group_by(Country, Date, Measure) %>%
  summarise(Value = sum(Value)) %>% 
  mutate(Value = 1)

cases <- inputDB3 %>% 
  filter(Measure == "Cases")



cts <- cases %>%
  drop_na(Country) %>% 
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
    ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
    geom_point(color = rgb(0,0,1,0.5))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  
  ggsave(paste0("R_checks/coverage/cases", i, ".png")) 
}


cases %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


death <- inputDB3 %>% 
  filter(Measure == "Deaths")


death %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


test <- inputDB3 %>% 
  filter(Measure == "Tests")


test %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


vacc1 <- inputDB3 %>% 
  filter(Measure == "Vaccination1")


vacc1 %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


vacc2 <- inputDB3 %>% 
  filter(Measure == "Vaccination2")


vacc2 %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


vacc3 <- inputDB3 %>% 
  filter(Measure == "Vaccination3")


vacc3 %>% 
  ggplot(aes(x = Date, y = reorder(Country, Date, FUN = max)))+
  geom_point(color = rgb(0,0,1,0.5))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
