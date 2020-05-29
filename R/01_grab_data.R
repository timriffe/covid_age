
source("R/00_Functions.R")
source("R_checks/inputDB_check.R")
# for writing to the master input

# sheets_write(dat, ssMaster, "master")


# -----------------------------------
# THIS IS A VIOLENT RENEWAL, no checks yet. We need to make sure that the renewal
# is lossless unless it's warranted.
# -----------------------------------


#check_input_updates()

# gather all the inputDBs

check_db <- FALSE
if (check_db){   
  tic()
  inputDB <- compile_inputDB()
  inputDB <- inputDB %>% 
  filter(!(Sex == "UNK" & Value == 0),
         !(Age == "UNK" & Value == 0)) 
  saveRDS(inputDB,here::here("Data/inputDBhold.rds"))
  toc()
  dim(inputDB)
  #standbyDB <- readRDS(here::here("Data/inputDB.rds"))
  
  (my_codes <- inputDB %>% pull(Short) %>% unique())
  run_checks(inputDB, my_codes)
  
  #inputDB <- inputDB %>% mutate(Country = ifelse(Country == "US","USA",Country))
  # # REMOVE JP Dates start 24.04.2020
  
   # inputDB <- 
   #   inputDB %>% 
   #   mutate(date = dmy(Date)) %>% 
   #   filter(!(Country == "Japan" & date > dmy("23.04.2020"))) %>% 
   #   select(-date) 
  # inputDB <- 
  #   inputDB %>% 
  #   filter(Code == "CA_AB20.05.2020" & Measure == "Tests")
  # REMOVE Argentina until data are cumulative 
  inputDB <- 
    inputDB %>% 
    filter(Country !="Argentina")
  # REMOVE sex-specific data from Romania:
  inputDB <- 
    inputDB %>% 
    filter(!(Country =="Romania" & Sex %in% c("m","f") & Measure == "Cases"))
  # TEMP: remove USA CASES 
  # inputDB <- 
  #   inputDB %>% 
  #   filter(!(Country =="USA" & Region == "All" & Measure == "Cases"))
  # 
  # inputDB <- 
  #   inputDB %>% 
  #   filter(Region !="Florida")
  # inputDB <- 
  #   inputDB %>% 
  #   filter(Country !="Finland")    filter(!(Country =="USA" & Region == "All" & Measure == "Cases"))

    # inputDB <- inputDB %>% 
    #   filter(!(Code %in% "KR09.05.2020"))
     # inputDB <- inputDB %>% 
     #   filter(!Code %in% "CA_BC22.05.2020")
  inputDB %>% 
    filter(is.na(Date)) %>% 
    View()
  inputDB <- inputDB %>% filter(!is.na(Date))

  

  # Date range check:    filter(Country !="Argentina")    filter(Country !="Argentina")
  inputDB %>% 
    mutate(date = dmy(Date)) %>% 
    pull(date) %>% 
    range()    filter(!(Country =="USA" & Region == "All" & Measure == "Cases"))
  
  inputDB %>% 
    mutate(date = dmy(Date)) %>% 
    filter(is.na(date)) %>% View()
  # inputDB <-
  #   inputDB %>% 
  #   mutate(date = dmy(Date)) %>% 
  #   filter(!is.na(date)) %>% 
  #   select(-date)
  

  # hunt down anything implausible
  # ----------------------
  inputDB %>% pull(Sex) %>% table(useNA = "ifany")
  inputDB %>% pull(Measure) %>% table(useNA = "ifany")
  inputDB %>% pull(Metric) %>% table(useNA = "ifany")
  inputDB %>% pull(Age) %>% table(useNA = "ifany")
  
  # These are special cases that we would like to account for
  # eventually, but that we don't have a protocol for at this time.
  inputDB <- inputDB %>% filter(Measure != "Probable deaths")
  inputDB <- inputDB %>% filter(Metric != "Rate")
  inputDB <- inputDB %>% filter(Measure != "Tested")
  
  # inputDB %>% filter(Sex %in% c("F","M","unk")) %>% View()
  
  # inputDB <-
  #   inputDB %>% 
  #   mutate(Sex = case_when(
  #     Sex == "M" ~ "m",
  #     Sex == "F" ~ "f",
  #     Sex == "unk" ~ "UNK",
  #     TRUE ~ Sex
  #   ))
  unique(inputDB$Age)
   inputDB %>% 
     filter(is.na(Age)) %>% View()
   
  # Remove blank subsets, where they coming from?
  inputDB <- inputDB %>% filter(!is.na(Country))
  
  # any remaining NAs in Value?
  inputDB %>% filter(is.na(Value)) %>% View()
  inputDB <- inputDB %>% 
    filter(!is.na(Value)) 

  # inputDB <- inputDB %>% mutate(
  #   Measure = ifelse(Measure == "Death","Deaths",Measure)
  # )
  

  # -------------------------------------

  # -------------------------------------
  # Check NA values
  # inputDB %>% pull(Value) %>% is.na() %>% sum()
  # inputDB %>%
  #   filter(is.na(Value)) %>% 
  #   View()
  # inputDB <- inputDB %>% filter(!is.na(Value))
  # inputDB %>% 
  # inputDB <- inputDB %>% 
  #   mutate(Value = ifelse(is.na(Value),0,Value))
  # 
  # inspect_code(inputDB, inspect[90])

  # temp JP correction
  # unique(inputDB$Sex)
  # inputDB %>% filter(Sex == "t") %>% 
  #   pull(Country) %>% 
  #   unique()
  # table(inputDB$Sex)
  # 
  #  inputDB <- inputDB %>% 
  #    mutate(Sex = ifelse(Sex == "t","b",Sex))
  
  # ---------------------------------- #
  # duplicates check:
  # -----------------------------------#
  
  n <- duplicated(inputDB[,c("Code","Sex","Age","Measure","Metric")])
  sum(n)
  # inputDB[n, ] %>% View()
  # inputDB <- inputDB[-n, ]
  # inputDB <- inputDB %>% filter(!(Country == "South Korea" & Date == "09.05.2020"))
  # 
  # DNK has too many pathological cases to include at the moment
  # inputDB <- inputDB %>% filter(!Country %in% c("Denmark"))
  # inputDB <- inputDB %>% filter(!Code %in% c("CA_BC17.04.2020"))
  # These are all aggressive pushes:
  # Save out the inputDB
  #push_inputDB(inputDB)
  
  header_msg <- paste("COVerAGE-DB input database, filtered after some simple checks:",timestamp(prefix="",suffix=""))
  write_lines(header_msg, path = "Data/inputDB.csv")
  
  write_csv(inputDB, path = "Data/inputDB.csv", append = TRUE, col_names = TRUE)
  saveRDS(inputDB, "Data/inputDB.rds")
  
  # ---------------------------------------------------
  # # replace subset with new load after Date correction
  # NOTE THIS WILL FAIL FOR REGIONS!!
  do_this <-FALSE
  if(do_this){
    inputDB <- swap_country_inputDB(inputDB, "NZ")
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
  

  