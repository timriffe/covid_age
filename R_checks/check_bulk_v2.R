# --------------------------------------------------- #
# Author: Marius D. Pascariu
# License: MIT
# Last update: Sun Apr 26 19:06:09 2020
# --------------------------------------------------- #
remove(list = ls())
library(tidyverse)

inputDB <- read_csv("Data/inputDB.csv") %>% 
  mutate(
    Date = as.Date(Date, format = "%d.%m.%Y"),
    Code = paste(Short, Region, Date, Sex, Metric, Measure, sep = "-"))

# Here we implement the 15 validations
# TRUE means VALID
# FALSE means "something's wrong"
valid <- inputDB %>% 
  mutate(
    v0 = TRUE,
    v1 = !is.na(Value),
    v2 = Country %in% unique(inputDB$Country), # here we should have a separate list of regions otherwise the check is useless.
    v3 = Age %in% c(0:105, "TOT", "UNK"),
    v4 = AgeInt %in% c(0:105, NA),
    v5 = replace(v0, Age %in% c("TOT", "UNL") & !is.na(AgeInt), FALSE),
    v6 = NA,
    v7 = TRUE,
    v8 = Sex %in% c("m", "f", "b", "UNK"),
    v9 = !is.na(Date),
    v10 = Date %in% seq(as.Date("2019-12-01"), 
                        by = "day", 
                        length.out = as.double((Sys.Date() - as.Date("2019-12-01"))) + 1),
    v11 = Metric %in% c("Count", "Fraction", "Ratio"),
    v12 = Measure %in% c("Cases", "Deaths", "Tests", "ASCFR"),
    v13 = NA,
    v14 = Value >= 0,
    v15 = !duplicated(paste(Code, Age))
    ) %>% 
  select(c("Code", paste0("v", 1:15)))

# Validation 6 needs more lines of code
V6 <- inputDB %>%
  filter(!is.na(AgeInt)) %>%
  group_by(Code) %>%
  summarise(v6 = sum(AgeInt, na.rm = TRUE) == 105)

valid <- left_join(valid, V6, by = "Code") %>% 
  mutate(v6 = replace(v6.y, is.na(v6.y), TRUE)) %>% 
  select(-v6.x, -v6.y)

# Validation 7 needs more lines of code too
# and the only one that needs the for loop and is not instant.

X <- inputDB %>% 
  filter(Age %in% 0:105) %>% 
  mutate(
    Age = as.integer(Age),
    AgeInt = as.integer(AgeInt),
    Age1 = Age + AgeInt,
    v7 = NA)
  
 for (k in unique(X$Code)) {
   d <- X[X$Code == k, ]
   valid[valid$Code == k, "v7"] <- all(d$Age[-1] == d$Age1[-length(d$Age1)])
 } 

# No. of failed validations 
valid$failures <- rowSums(!valid[, -1], na.rm = TRUE)

# Print all the failed cases
valid %>%
  filter(failures > 0) %>% 
  print(n = Inf)

# Print data that failed validation
inputDB[!valid$v1, ]
inputDB[!valid$v2, ]
inputDB[!valid$v3, ] # Not sure why the ages appear wrong in Colombia
inputDB[!valid$v4, ]
inputDB[!valid$v5, ]
inputDB[!valid$v6, ] %>% print(n = Inf)
inputDB[!valid$v7, ]
inputDB[!valid$v8, ]
inputDB[!valid$v9, ]
inputDB[!valid$v10, ]
inputDB[!valid$v11, ]
inputDB[!valid$v12, ]
# inputDB[!valid$v13, ]
inputDB[!valid$v14, ]
inputDB[!valid$v15, ] %>% print(n = Inf)

