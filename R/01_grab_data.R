
source("R/00_Functions.R")
source("R_checks/inputDB_check.R")
# for writing to the master input

rubric_old <- readRDS("Data/rubric_old.rds")
# check for new data:
rubric     <- get_input_rubric()
saveRDS(rubric, "Data/rubric_old.rds")

rubric_old <- rubric_old %>% select(Short, Rows)
Updates    <- 
  left_join(rubric, rubric_old, by = "Short") %>% 
  mutate(
    Rows.y = ifelse(is.na(Rows.y),0,Rows.y),
    Change = Rows.x - Rows.y) %>% 
  filter(Change > 0)

#check_input_updates()

# gather all the inputDBs

check_db <- FALSE
full     <- FALSE
if (check_db){   
  
  # full build
  if (full){
     tic()
     inputDB <- compile_inputDB()
     toc()
  } else {
    Updates <-
      Updates %>% 
      select(Country, Region, Short, Rows = Rows.x, Sheet)
      
    # Otherwise, just the pieces that grew.
    tic()
    inputDB <- compile_inputDB(Updates)
    toc()
  }
  #
  if (!full){
    new_codes <- inputDB %>% pull(Short) %>% unique()
    holdDB <- readRDS("Data/inputDBhold.rds")
    holdDB <-
      holdDB %>% 
      filter(!Short %in% new_codes) %>% 
      bind_rows(inputDB) %>% 
      filter(!(Sex == "UNK" & Value == 0),
             !(Age == "UNK" & Value == 0)) 
    saveRDS(holdDB,here::here("Data/inputDBhold.rds"))
 
  } else {
    inputDB <- inputDB %>% 
      filter(!(Sex == "UNK" & Value == 0),
             !(Age == "UNK" & Value == 0)) 
    saveRDS(inputDB,here::here("Data/inputDBhold.rds"))
  }
  #

  # Temporary filters
  inputDB <-
    inputDB %>% 
    filter(Code != "CA_ON30.08.2019")
  
  # Israel has two problems:
  # 1) <15 counts are NA
  # 2) data are new counts, not cumulative, so there
  # is presently no good way to accumulate. If the source
  # could provide a snapshot of cumulative counts then we 
  # could infer backwards somewhat, but for now we have no 
  # procedure in place to deal with this.
  inputDB <-
    inputDB %>% 
    filter(Short != "IL")

  # Entry error that the maintainer should fix
  inputDB <- 
    inputDB %>% 
    filter(!(Country =="Romania" & Sex %in% c("m","f") & Measure == "Cases"))

  # Date range check: 
  inputDB %>% 
    mutate(date = dmy(Date)) %>% 
    pull(date) %>% 
    range()    
  
  # inputDB %>% 
  #   mutate(date = dmy(Date)) %>% 
  #   filter(is.na(date)) %>% View()

  # hunt down anything implausible
  # ----------------------
  inputDB %>% pull(Sex) %>% table(useNA = "ifany")
  inputDB %>% pull(Measure) %>% table(useNA = "ifany")
  inputDB %>% pull(Metric) %>% table(useNA = "ifany")
  inputDB %>% pull(Age) %>% table(useNA = "ifany")
  
  # These are special cases that we would like to account for
  # eventually, but that we don't have a protocol for at this time.
  inputDB <- inputDB %>% filter(Measure != "Probable deaths")
  # eventually, but that we don't have a protocol for at this time
  inputDB <- inputDB %>% filter(Measure != "Probable cases")
  inputDB <- inputDB %>% filter(Measure != "Confirmed deaths")
  inputDB <- inputDB %>% filter(Measure != "Confirmed cases")
  inputDB <- inputDB %>% filter(Metric != "Rate")
  inputDB <- inputDB %>% filter(Measure != "Tested")
  # inputDB %>% filter(Sex %in% c("F","M","unk")) %>% View()

  # ---------------------------------- #
  # duplicates check:
  # -----------------------------------#
  
  n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
  sum(n)

  (my_codes <- inputDB %>% pull(Short) %>% unique())
  run_checks(inputDB, my_codes)
  
  # If it's a partial build then swap out the data.
  if (!full){
    swap_codes  <- inputDB %>% pull(Short) %>% unique()
    inputDB_old <- readRDS("Data/inputDB.rds")
    inputDB_old <- inputDB_old %>% 
      filter(!(Short %in% swap_codes))
    inputDB <- 
      bind_rows(inputDB_old,
                inputDB) %>% 
      sort_input_data()
  }
  
  
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix="",suffix=""))
  write_lines(header_msg, path = "Data/inputDB.csv")
  
  write_csv(inputDB, path = "Data/inputDB.csv", append = TRUE, col_names = TRUE)
  saveRDS(inputDB, "Data/inputDB.rds")
  
  # ---------------------------------------------------
  # # replace subset with new load after Date correction
  # NOTE THIS WILL FAIL FOR REGIONS!!
  do_this <-FALSE
  if(do_this){
    inputDB <- swap_country_inputDB(inputDB, "BD")
  }
  # ----------------------------------------------------


}

# ---------------------------------------------------------------------------- #


# do.this <- FALSE
# if (do.this){
# # FOR ONCE-OFF updating / sorting of inputDB database sheets
# # update and sort a country input database 
# ShortCode <- "ET"
# 
# # standby <- dat %>% 
# #   filter(grepl(pattern = ShortCode, Code) &
# #            ! grepl(pattern = "ITinfo",Code))
# standby <- dat %>% 
#   filter(grepl(pattern = ShortCode, Code))
# 
# input_rubric <- get_input_rubric()
# (codes_have <- standby %>% pull(Code) %>% unique())
# (ss_i       <- input_rubric %>% filter(Short == ShortCode) %>% pull(Sheet))
# incoming   <- read_sheet(ss_i, sheet = "database", na = "NA", col_types= "cccccciccd")
# 
# incoming <- incoming %>% 
#   mutate(AgeInt = ifelse(Age == "95", 10, 
#                          ifelse(Age == "UNK", NA, 1)))
# 

# outgoing <- 
#   outgoing %>% 
#   sort_input
# 
# write_sheet(incoming, ss = ss_i, sheet = "database")
# }





#  ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"
#  
#  dat <- sheets_read(ss, sheet = "long(Flexible Inputs)",skip =1, na = "NA", col_types= "ccccccccd")
#  can <- dat %>% filter(Country == "Canada")
# View(can)
# 
 # inputDB %>% 
 #   filter(Short == "BR_RJ", 
 #          Sex == "b", 
 #          Measure == "Cases", 
 #          Metric == "Count",
 #          Age != "TOT") %>% 
 #   group_by(Date)%>% 
 #   summarize(Value = sum(Value)) %>%
 #   ungroup() %>% 
 #   mutate(date = dmy(Date)) %>% 
 #   ggplot(aes(x=date,y=Value)) +
 #   geom_line() 
 #  
 #  
  

  