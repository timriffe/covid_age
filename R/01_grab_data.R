
remotes::install_github("tidyverse/googlesheets4")
library(googlesheets4)
library(tidyverse)
library(lubridate)


# for writing to the master input

# sheets_write(dat, ssMaster, "master")

ss_rubric <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0"
input_rubric <- sheets_read(ss_rubric, sheet = "input") %>% 
  filter(!is.na(Sheet))

# -----------------------------------
# THIS IS A VIOLENT RENEWAL, no checks yet. We need to make sure that the renewal
# is lossless unless it's warranted.
# -----------------------------------

# renew the master input database
output_source_ss <- 
  sheets_read(ss_rubric, sheet = "output") %>% 
  filter(tab == "inputDB") %>% 
  pull(Sheet)

# gather all the inputDBs
input_list <- list()
for (i in input_rubric$Short){
  (ss_i           <- input_rubric %>% filter(Short == i) %>% pull(Sheet))
  input_list[[i]] <-  sheets_read(ss_i, sheet = "database", na = "NA", col_types= "ccccccccd")
}
# bind and sort:
outgoing <- 
input_list %>% 
  bind_rows() %>%  
  mutate(Date2 = dmy(Date)) %>% 
  arrange(Country,
          Date2,
          Sex, 
          Measure,
          Metric,
          Age) %>% 
  select(-Date2)

# write it out
sheets_write(outgoing, ss = output_source_ss, sheet = "inputDB")
# ---------------------------------------------------------------------------- #


# do.this <- FALSE
# if (do.this){
# # FOR ONCE-OFF updating / sorting of inputDB database sheets
# # update and sort a country input database 
# ShortCode <- "IT"
# 
# # standby <- dat %>% 
# #   filter(grepl(pattern = ShortCode, Code) &
# #            ! grepl(pattern = "ITinfo",Code))
# standby <- dat %>% 
#   filter(grepl(pattern = ShortCode, Code))
# 
# (codes_have <- standby %>% pull(Code) %>% unique())
# (ss_i       <- input_rubric %>% filter(Short == ShortCode) %>% pull(Sheet))
# incoming   <- sheets_read(ss_i, sheet = "database", na = "NA", col_types= "ccccccccd")
# 
# incoming <-
#   incoming %>% 
#   filter(!Code %in% codes_have)
# 
# outgoing <-
#   rbind(incoming,
#         standby)
# 
# outgoing <- 
#   outgoing %>% 
#   mutate(Date2 = dmy(Date)) %>% 
#   arrange(Date2,
#           Sex, 
#           Measure,
#           Metric,
#           Age) %>% 
#   select(-Date2)
# 
# sheets_write(outgoing, ss = ss_i, sheet = "database")
# }




# deprecated from old project
# ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"
# 
# dat <- sheets_read(ss, sheet = "long(Flexible Inputs)",skip =1, na = "NA", col_types= "ccccccccd")
# 
# dat %>% 
#   mutate(Date = dmy(Date)) 

# sheets_append()
