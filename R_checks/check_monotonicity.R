# --------------------------------------------------- #
# Check monotonicity of reported cases and death counts
# Last update: Fri May 08 15:12:05 2020
# --------------------------------------------------- #
remove(list = ls())
library(tidyverse)

inputDB <- read_csv("Data/inputDB.csv")

# Data preparation
d <- inputDB %>% 
  filter(Metric == "Count") %>% 
  mutate(Date = as.Date(Date, format = "%d.%m.%Y"))%>% 
  pivot_wider(names_from = Sex, 
              values_from = Value) %>% 
  arrange(Date) %>% 
  mutate(Code = paste(Short, Region, Measure, Age, sep = "-")) %>% 
  select(Code, Date, b, f, m)

# Check case by case
V <- NULL
for (i in unique(d$Code)){
  
  v <- d %>% filter(Code == i)
  
  b = v$b[!is.na(v$b)]
  f = v$f[!is.na(v$f)]
  m = v$m[!is.na(v$m)]
  
  w <- tibble(
    Code = i,
    valid_b = all(b == cummax(b)),    # Check monotonicity here
    valid_m = all(m == cummax(m)),
    valid_f = all(f == cummax(f))) %>% 
    mutate(all_valid = valid_b & valid_m & valid_f) %>%  # check if all sexes are valid
    filter(all_valid == FALSE)
  
  V <- bind_rows(V, w)
}

# List invalid cases

sum(!V[, 2:4]) # 260 time-series found not to be monotonically increasing 
V %>% print(n = Inf)

# Plot invalid cases
d %>% 
  filter(Code == "US_IL-Illinois-Tests-50") %>%
  pivot_longer(cols = b:m, names_to = "Sex", values_to = "Value") %>% 
  ggplot(aes(x = Date, y = Value, color = Sex)) + 
  geom_line(size = 1)

# This is an obvious and suggestive plot for Illinois.
# for other regions where the deviation are minor a more advance one migh be 
# needed.













