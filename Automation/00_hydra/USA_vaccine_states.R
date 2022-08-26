source(here::here("Automation/00_Functions_automation.R"))
#install.packages("tidyverse")
#install.packages("reshape2")
library(tidyverse)
library(reshape2)

vacc <- read.csv("https://data.cdc.gov/api/views/unsk-b7fc/rows.csv?accessType=DOWNLOAD")
vacc2 <- vacc %>% 
  select(Date, Location, Administered_Dose1_Recip, Administered_Dose1_Recip_5Plus, Administered_Dose1_Recip_12Plus, Administered_Dose1_Recip_18Plus,
         Administered_Dose1_Recip_65Plus, Series_Complete_Yes ,Series_Complete_5Plus, Series_Complete_12Plus, Series_Complete_18Plus, Series_Complete_65Plus,
         Additional_Doses, Additional_Doses_12Plus, Additional_Doses_18Plus, Additional_Doses_50Plus, Additional_Doses_65Plus,
         Second_Booster_50Plus, Second_Booster_65Plus, Second_Booster)
vacc3 <- vacc2 %>% 
  mutate(Vaccination1_TOT = Administered_Dose1_Recip,
         Vaccination1_5 = Administered_Dose1_Recip_5Plus - Administered_Dose1_Recip_12Plus,
         Vaccination1_12 = Administered_Dose1_Recip_12Plus - Administered_Dose1_Recip_18Plus,
         Vaccination1_18 = Administered_Dose1_Recip_18Plus - Administered_Dose1_Recip_65Plus,
         Vaccination1_65 = Administered_Dose1_Recip_65Plus,
         Vaccination2_TOT = Series_Complete_Yes,
         Vaccination2_5 = Series_Complete_5Plus - Series_Complete_12Plus,
         Vaccination2_12 = Series_Complete_12Plus - Series_Complete_18Plus,
         Vaccination2_18 = Series_Complete_18Plus - Series_Complete_65Plus,
         Vaccination2_65 = Series_Complete_65Plus,
         Vaccination3_TOT = Additional_Doses,
         Vaccination3_12 = Additional_Doses_12Plus - Additional_Doses_18Plus,
         Vaccination3_18 = Additional_Doses_18Plus - Additional_Doses_50Plus,
         Vaccination3_50 = Additional_Doses_50Plus - Additional_Doses_65Plus,
         Vaccination3_65 = Additional_Doses_65Plus,
         Vaccination4_50 = Second_Booster_50Plus - Second_Booster_65Plus,
         Vaccination4_65 = Second_Booster_65Plus) %>% 
  select(-c(Administered_Dose1_Recip, Administered_Dose1_Recip_5Plus, Administered_Dose1_Recip_12Plus, Administered_Dose1_Recip_18Plus,
            Administered_Dose1_Recip_65Plus, Series_Complete_Yes ,Series_Complete_5Plus, Series_Complete_12Plus, Series_Complete_18Plus, Series_Complete_65Plus,
            Additional_Doses, Additional_Doses_12Plus, Additional_Doses_18Plus, Additional_Doses_50Plus, Additional_Doses_65Plus,
            Second_Booster_50Plus, Second_Booster_65Plus, Second_Booster)) %>% 
  mutate(Vaccination1_TOT = as.numeric(Vaccination1_TOT),
         Vaccination1_5 = as.numeric(Vaccination1_5),
         Vaccination1_12 = as.numeric(Vaccination1_12),
         Vaccination1_18 = as.numeric(Vaccination1_18),
         Vaccination1_65 = as.numeric(Vaccination1_65),
         Vaccination2_5 = as.numeric(Vaccination2_5),
         Vaccination2_12 = as.numeric(Vaccination2_12),
         Vaccination2_18 = as.numeric(Vaccination2_18),
         Vaccination2_65 = as.numeric(Vaccination2_65),
         Vaccination2_TOT = as.numeric(Vaccination2_TOT),
         Vaccination3_TOT = as.numeric(Vaccination3_TOT),
         Vaccination3_12 = as.numeric(Vaccination3_12),
         Vaccination3_18 = as.numeric(Vaccination3_18),
         Vaccination3_50 = as.numeric(Vaccination3_50),
         Vaccination3_65 = as.numeric(Vaccination3_65),
         Vaccination4_50 = as.numeric(Vaccination4_50),
         Vaccination4_65 = as.numeric(Vaccination4_65)) %>% 
  mutate(Vaccination1_5 = case_when(
    Vaccination1_5 <= 0 ~ 0,
    TRUE ~ Vaccination1_5
  ),
  Vaccination1_12 = case_when(
    Vaccination1_12 <= 0 ~ 0,
    TRUE ~ Vaccination1_12
  ),
  Vaccination2_12 = case_when(
    Vaccination2_12 <= 0 ~ 0,
    TRUE ~ Vaccination2_12),
  Vaccination2_5 = case_when(
    Vaccination2_5 <= 0 ~ 0,
    TRUE ~ Vaccination2_5)
  ) %>% 
  melt(id.vars=c("Date", "Location")) %>% 
  separate(variable, c("Measure", "Age"), "_")

vacc4 <- vacc3 %>% 
  mutate(Date = as.Date(Date, "%m/%d/%Y"))

vacc3_vac1 <- vacc4 %>% 
  filter(Measure == "Vaccination1",
         Location == "US")

ggplot(vacc3_vac1, aes(x = Date, y = value, group = Age, color=Age)) +
  geom_line() 

