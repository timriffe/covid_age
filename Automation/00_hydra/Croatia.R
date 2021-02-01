
# This is just to get the Croatia script started.
install.packages("rjson")
library(rjson)
library(tidyverse)
IN_json <- fromJSON(file="https://www.koronavirus.hr/json/?action=po_osobama")



IN <- bind_rows(IN_json) 
IN2 <- IN %>% 
  select(Sex = spol, dob, Date = Datum, Region = Zupanija) %>%  # Regions = Counties
  group_by(Sex, dob, Date, Region) %>% 
  summarize(new = n(),.groups = "drop") %>% 
  mutate(Measure = "Cases")


IN_json <- fromJSON(file="https://www.koronavirus.hr/json/?action=po_danima_zupanijama")


r <- GET("https://www.koronavirus.hr/json/?action=po_osobama")
a <- httr::content(r, "text", encoding = "ISO-8859-1")
b <- fromJSON(a)