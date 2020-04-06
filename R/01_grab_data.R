
source("R/00_Functions.R")

# for writing to the master input

# sheets_write(dat, ssMaster, "master")


# -----------------------------------
# THIS IS A VIOLENT RENEWAL, no checks yet. We need to make sure that the renewal
# is lossless unless it's warranted.
# -----------------------------------
library(here)

check_input_updates()

# gather all the inputDBs
outgoing <- compile_inputDB()

push_inputDB(outgoing)
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





#  ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"
#  
#  dat <- sheets_read(ss, sheet = "long(Flexible Inputs)",skip =1, na = "NA", col_types= "ccccccccd")
#  can <- dat %>% filter(Country == "Canada")
# View(can)
