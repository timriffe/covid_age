
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
  standbyDB <- readRDS(here::here("Data/inputDB.rds"))
  
  (my_codes <- inputDB %>% pull(Short) %>% unique())
  run_checks(inputDB, "JP")
  
  
  # REMOVE DK Code selectively
  inputDB <- 
    inputDB %>% 
    filter(!Code %in% c("DK03.04.2020","DK04.04.2020","DK05.04.2020"),
           !is.na(Country))
  
  # REMOVE Taiwan until inputs fixed
  inputDB <- 
    inputDB %>% 
    filter(Country !="Taiwan")
  
  # REMOVE JAPAN until inputs fixed
  inputDB <- inputDB %>% 
    filter(Country != "Japan")

  inputDB %>% 
    filter(is.na(Date)) %>% 
    View()

  # Date range check:
  inputDB %>% 
    mutate(date = dmy(Date)) %>% 
    pull(date) %>% 
    range()

  # hunt down anything implausible
  # ----------------------
  inputDB %>% pull(Sex) %>% table()
  inputDB %>% filter(Sex %in% c("F","M","unk")) %>% View()
  
  # inputDB <-
  #   inputDB %>% 
  #   mutate(Sex = case_when(
  #     Sex == "M" ~ "m",
  #     Sex == "F" ~ "f",
  #     Sex == "unk" ~ "UNK",
  #     TRUE ~ Sex
  #   ))
  unique(inputDB$Age)
  # inputDB %>% 
  #   filter(is.na(Age)) %>% View()

  inputDB %>% filter(is.na(Code)) %>% View()
  # Remove blank subsets, where they coming from?
  inputDB <- inputDB %>% filter(!is.na(Country))
  
  # any remaining NAs in Value?
  inputDB %>% filter(is.na(Value)) %>% View()
  inputDB <- inputDB %>% 
    filter(!is.na(Value)) 
  # -------------------------------------
  # Check Measure 
  # Valid: Deaths, Cases, Tests, ASCFR
  inputDB %>% pull(Measure) %>% unique()
  
  # inputDB %>% filter(Measure == "Death") %>% 
  #   pull(Country) %>% 
  #   unique() 
  # just a few, nope
  table(inputDB$Measure)
  
  # inputDB <- inputDB %>% mutate(
  #   Measure = ifelse(Measure == "Death","Deaths",Measure)
  # )
  
  # Just for time being we remove probable / suspected, etc
  inputDB %>% filter(Measure == "Probable deaths") %>% pull(Region) %>% unique()
  inputDB <- inputDB %>% filter(Measure != "Probable deaths")
  # -------------------------------------
  
  # -------------------------------------
  # Check Metric
  # Count, Fraction, Ratio
  inputDB %>% pull(Metric) %>% unique()
  
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
  inspect_code(inputDB, inspect[90])

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
  
  
  # DNK has too many pathological cases to include at the moment
  # inputDB <- inputDB %>% filter(!Country %in% c("Denmark"))
  # inputDB <- inputDB %>% filter(!Code %in% c("CA_BC17.04.2020"))
  # These are all aggressive pushes:
  # Save out the inputDB
  #push_inputDB(inputDB)
  write_csv(inputDB, path = "Data/inputDB.csv")
  saveRDS(inputDB, "Data/inputDB.rds")
  
  # ---------------------------------------------------
  # # replace subset with new load after Date correction
  # NOTE THIS WILL FAIL FOR REGIONS!!
    # ShortCode <- "CA_AB"
    # X <- get_country_inputDB(ShortCode)
    #  inputDB <-
    #    inputDB %>% 
    #    filter(!grepl(ShortCode,Code)) %>% 
    #    rbind(X) %>% 
    #    sort_input_data()
  # ----------------------------------------------------
  # check closeout ages:
  CloseoutCheck <- 
    inputDB %>% 
    group_by(Code,Sex)  %>% 
    filter(Age!="UNK",
           Age!="TOT",
           Sex!="UNK") %>% 
    mutate(Age = as.integer(Age),
           AgeInt = as.integer(AgeInt))  %>% 
    slice(n()) %>% 
    mutate(Closeout = Age + AgeInt) %>% 
    filter(Closeout != 105)
  
  CloseoutCheck
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
  
  
  