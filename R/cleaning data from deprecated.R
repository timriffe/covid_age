library(tidyverse)

files <- c("inputDB.rds", "inputDBhold.rds")
for(i in files){

  db <- 
    read_rds(paste0("Data/", i))

  db2 <- 
    db %>% 
    filter(
      # excluding ECDC
      !str_detect(Code, "ECDC"),
      # excluding Brazil TRC
      !str_detect(Code, "BR_TRC"),
      # excluding 'vaccinations' measure from Denmark
      !(Country == "Denmark" & Measure == "Vaccinations"),
      # refreshing data from Kenya
      !(Country == "Kenya"),
      # refreshing data from Slovakia
      !(Country == "Slovakia"))
  
  write_rds(db2, paste0("Data/", i))

}

