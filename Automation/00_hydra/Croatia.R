
# This is just to get the Croatia script started.
#install.packages("rjson")
library(rjson)
library(tidyverse)
IN_json <- fromJSON(file="https://www.koronavirus.hr/json/?action=po_osobama")


IN <- bind_rows(IN_json) 
IN2 <- IN %>% 
  select(Sex = spol, dob, Date = Datum, Region = Zupanija) %>%  # Regions = Counties
  group_by(Sex, dob, Date, Zupanja) %>% 
  summarize(new = n(),.groups = "drop") %>% 
  mutate(Measure = "Cases")
  
