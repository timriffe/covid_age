
# This is just to get the Croatia script started.
#install.packages("rjson")
library(rjson)
library(tidyverse)
IN_json <- fromJSON(file="https://www.koronavirus.hr/json/?action=po_osobama")


IN <- bind_rows(IN_json) %>% 
  select(spol = Sex, dob, Date = Datum, Zupanija = Region) %>%  # Regions = Counties
  group_by(Sex, dob, Date, Zupanja) %>% 
  summarize(new = n(),.groups = "drop") %>% 
  mutate(Measure = "Cases")
  
