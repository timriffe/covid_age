
library(tidyverse)
library(reshape2)
library(lubridate)
inputDB <- readRDS("Data/inputDB.rds")

ITinfoD <- inputDB %>% 
  filter(Short == "ITinfo",
         Measure == "Deaths") %>% 
  mutate(Date = dmy(Date)) %>% 
  acast(Age~Date, value.var = "Value")

ITinfoCFR <- inputDB %>% 
  filter(Short == "ITinfo",
         Measure == "ASCFR") %>% 
  mutate(Date = dmy(Date)) %>% 
  acast(Age~Date, value.var = "Value")


ITbolD <- inputDB %>% 
  filter(Short == "ITbol",
         Measure == "Deaths",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  acast(Age~Date, value.var = "Value")

ITbolC <- inputDB %>% 
  filter(Short == "ITbol",
         Measure == "Cases",
         Sex == "b") %>% 
  mutate(Date = dmy(Date)) %>% 
  acast(Age~Date, value.var = "Value")


ITinfoD[,colnames(ITinfoD)%in%colnames(ITbolD)] - 
  ITbolD[,colnames(ITbolD)%in%colnames(ITinfoD)] 

library(DemoTools)
interp()









