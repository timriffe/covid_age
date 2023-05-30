library(tidyverse)
library(lubridate)

## This script aims to check on the last date of the collected data and 
## so we can get a hint of whether there is still published data or not :)

dir_n   <- "N:/COVerAGE-DB/Automation/Hydra/"

rds.list <-list.files(
  path= dir_n,
  pattern = ".rds",
  full.names = TRUE)

rds.df <- data.frame(rds.list) %>% 
  mutate(ctr_0 = str_remove(rds.list, dir_n),
         ctr = str_remove(ctr_0, ".rds"))


ctrs <- c("AU_New_South_Wales", "Australia_vaccine", 
          "Austria", "Brazil", "Bulgaria", "Belgium", "Canada", 
          "Czechia", "Colombia", "Croatia", "CA_Alberta", 
          "CA_British_Columbia", "CA_Ontario", "Canada_Vaccine", 
          "Chile", "Denmark", "Estonia", 
          "England", "Estonia_vaccine", 
          "ECDC_vaccine", "England_Vaccine", "Finland",
          "Finland_vaccine", "France", "France_Vaccine", 
          "Germany", "Germany_vaccine", "Guatemala", 
          "Hong_Kong_Vaccine", "India", "IndiaVax", "Italy", 
          "Italy_reg", "Ireland",  
          "Japan", "Malaysia", "Netherlands", "New Zealand",
          "Norway_Vaccine", "Philippines", "Peru", "Spain", 
          "Spain_vaccine", "Scotland", "Slovakia", "Slovenia", "SouthKorea",
          "SwedenVax", "SwitzerlandEpi", "Switzerland_Vaccine",
          "Taiwan", "US_Wisconsin", 
          "US_Virginia", "USA_All", "USA_all_deaths", "USA_deaths_states",
          "USA_Vaccine", "USA_Vaccine_states", "Lithuania_Vaccine")


filtered.list <- rds.df %>% 
  filter(ctr %in% ctrs) %>% 
  pull(rds.list)

#ctr_rds <- "N:/COVerAGE-DB/Automation/Hydra/Argentina.rds"

extract_date_measure <- function(ctr_rds){

  rdsData <- read_rds(ctr_rds) 
  
  rdsData %>% 
    dplyr::mutate(Date = dmy(Date)) %>% 
    ungroup() %>% 
    select(Country, Measure, Date) %>% 
    dplyr::distinct(Country, Measure, Date) %>% 
    dplyr::filter(Date == max(Date)) 
  
}

#extract_date_measure("N:/COVerAGE-DB/Automation/Hydra/Argentina.rds")

all_in_all <- map_dfr(filtered.list, extract_date_measure)



all_in_all %>% 
  group_by(Country, Measure) %>% 
  filter(Date == max(Date)) %>% 
  ungroup() %>% 
  distinct() %>% 
  pivot_wider(names_from = Measure, values_from = Date) %>% 
  writexl::write_xlsx("all_in_all.xlsx")
