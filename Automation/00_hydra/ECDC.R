library(here)
source(here("Automation/00_Functions_automation.R"))
library(lubridate)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr          <- "ECDC" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/ECDC"
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Country == "ECDC")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# Which weeks does the sheet already contain?
ECDCin <- get_country_inputDB("ECDC") %>% 
  select(-Short)

dates_in  <- ECDCin %>% 
  dplyr::pull(Date) %>% 
  dmy() 
yr_wk_in <-
  paste(year(dates_in),isoweek(dates_in),sep="-") %>% 
  unique()

# which weeks are available to add?
 # files_have <- c(" Week 47, 2020-age-sex-pyramids.txt",   " Week 47, 2020-age-specific-rates.txt",
 #  " Week 48, 2020-age-sex-pyramids.txt",   " Week 48, 2020-age-specific-rates.txt",
 #  "2.4.9-data-week-43.txt"             ,   "2.4.9-data-week-44.txt"              ,
 #  "Week 43, 2020-age-sex-pyramids.txt"       ,   "Week 44, 2020-age-sex-pyramids.txt"        ,
 #  "Week 45, 2020-age-sex-pyramids.txt"       ,   "age-specific-rates-week-43.txt"      ,
 #  "age-specific-rates-week-44.txt"     ,   "age-specific-rates-Week-45.txt"      ,
 #  "python-script.py"                   ,   "python.bat"                          ,
 #  "selenium-3.141.0.tar"               ,   "selenium-3.141.0.tar.gz"              ,
 #  "TESSy data quality-week-43.txt"     ,   "TESSy data quality-week-44.txt"      ,
 #  "Week 46, 2020-age-sex-pyramids.txt" ,   "Week 46, 2020-age-specific-rates.txt",
 #  "Week 47, 2020-age-sex-pyramids.txt" ,   "Week 47, 2020-age-specific-rates.txt")
files_have <- dir_n_source %>% dir()
age_sex_pyramids <- files_have[grepl(pattern = "age-sex-pyramids",files_have)] 
  
weeks_avail <-
  age_sex_pyramids %>% 
  gsub(pattern = " ", replacement = "") %>% 
  substr(start=5,stop=6) %>% 
  readr::parse_number() %>% 
  sprintf("%02d",.)

years_avail <- 
  age_sex_pyramids %>% 
  gsub(pattern = " ", replacement = "") %>% 
  substr(start=8,stop=11) %>% 
  as.integer()
yr_wk_avail <- paste(years_avail, weeks_avail, sep = "-")

weeks_collect <-
  yr_wk_avail[!yr_wk_avail %in% yr_wk_in] %>% 
  unique()
#####################################################
# parse the text dumps
#####################################################
ECDCout <- ECDCin
# week_i <- "2020-48"

PrepIN <-
  function(Invec){
    
    possible_cols <- 4:12
    zsums <- rep(0,length(possible_cols))
    i<- 0
    for (dimguess in possible_cols){
     
      i <- i+1
      if (length(Invec)%% dimguess == 0){
        X <- matrix(Invec,ncol = dimguess)
        zsums[i] <- max(colSums(X == "0"))
      }
  
    }
    ncols <- possible_cols[which.max(zsums)]
    X <- matrix(Invec, ncol = ncols)
    
    Countries <- X %in% c("Croatia","Germany") 
    Age       <- grepl(X,pattern = "60-69")
    Measure   <- X %in% c("All cases","Mild")
    Sex       <- X %in% c("M","F")
    Value     <- X == "0"
   
    
    dim(Countries) <- dim(X)
    dim(Age)       <- dim(X)
    dim(Measure)   <- dim(X)
    dim(Sex)       <- dim(X)
    dim(Value)     <- dim(X)
    
    Countryi       <- colSums(Countries) %>% which.max()
    Agei           <- colSums(Age) %>% which.max()
    Measurei       <- colSums(Measure) %>% which.max()
    Sexi           <- colSums(Sex) %>% which.max()
    Valuei         <- colSums(Value) %>% which.max()
    
    column_names   <- paste0("V",1:ncols)
    column_names[c(Countryi,Agei,Measurei,Sexi,Valuei)] <- c("Country","Age","Measure","Sex","Value")
    
    if (ncols > 6){
      Period      <- grepl(X,pattern = "P1")
      dim(Period) <- dim(X)
      Periodi     <- colSums(Period) %>% which.max()
      column_names[Periodi] <- "Period"
    }
    
    colnames(X)    <- column_names
    
    # Problem: can we just parse Value, and Period, if present? 
    # This way we can aggregate P1 and P2 if necessary and deliver
    # something standard.
    
    # TR: leaving off here, deciding to do a straight aggregation step in 
    # here, which will be innocuous if there are 6 columns and do the right thing
    # if periods are split. However, it requires some prelim parsing to happen in
    # here too. Still in progress.
    Y <-
      X %>% 
      as.tibble() %>% 
      mutate( Value  = gsub(Value, pattern = "\\[|\\]", replacement = ""),
              Value = gsub(Value, pattern = "n &lt; ",replacement = ""),
              Value = ifelse(Value == "null", NA, Value),
              Value = as.integer(Value),
              Measure = gsub(Measure, pattern = "\\[|\\]", replacement = ""),
              Country = gsub(Country, pattern = "\\[|\\]", replacement = ""),
              Sex  = gsub(Sex, pattern = "\\[|\\]", replacement = ""),
              Age  = gsub(Age, pattern = "\\[|\\]", replacement = "")) 
    
    
  }

for (week_i in weeks_collect){
  cat(week_i,"\n")
  
  yr_pick <- week_i %>% substr(1,4)
  wk_pick <- week_i %>% substr(6,nchar(week_i)) 
  
  this_file <- age_sex_pyramids[grepl(age_sex_pyramids, pattern = yr_pick) & 
                                grepl(age_sex_pyramids, pattern = wk_pick)][1]
  
  all_days  <- seq(ymd(paste0(yr_pick,"-01-01")),
                   ymd(paste0(yr_pick,"-12-31")),
                   by = "days")
  Sundays   <- all_days[weekdays(all_days) == "Sunday"]
  Date_i    <- Sundays[isoweek(Sundays) == as.integer(wk_pick)]
  

  IN <- suppressWarnings(readLines(file.path(dir_n_source,this_file))) %>% 
          gsub(pattern = "\\[\\[", replacement = "") %>% 
          gsub(pattern = '\\]\\]', replacement = "") %>% 
          gsub(pattern = '\\"', replacement = "") %>% 
          strsplit(split=",") %>% 
          '[['(1)
   
  #ECDC_i <- 
  INmat <-
    IN %>% 
    matrix(ncol=7) 
  
  
    as_tibble() %>% 
    separate(col = Outcome, 
             into = c("maybe", "Measure"),
             sep = " ") %>% 
    mutate(maybe = gsub(maybe, pattern = "\\[|\\]", replacement = ""),
           Measure = gsub(Measure, pattern = "\\[|\\]", replacement = ""),
           Country = gsub(Country, pattern = "\\[|\\]", replacement = ""),
           Sex  = gsub(Sex, pattern = "\\[|\\]", replacement = ""),
           Age  = gsub(Age, pattern = "\\[|\\]", replacement = ""),
           Value  = gsub(Value, pattern = "\\[|\\]", replacement = ""),
           maybe = tolower(maybe),
           Measure = tolower(Measure),
           Measure = case_when(
             maybe == "all" ~ "all",
             maybe == "fatal" ~ "dead",
             TRUE ~ Measure
           )) %>% 
    select(-X) %>% 
    filter(Measure %in% c("all","dead"))
  
  # %>% 
    mutate(Sex =tolower(Sex),
           Age = recode(Age,
            "&lt;10yr" = "0",
            "10-19yr" = "10",
            "20-29yr" = "20",
            "30-39yr" = "30",
            "40-49yr" = "40",
            "50-59yr" = "50",
            "60-69yr" = "60",
            "70-79yr" = "70",
            "70-79yr" = "70",
            "80+yr" = "80"
           ),
           Measure = recode(Measure,
              "all" = "Cases",
              "dead" = "Deaths"),
           Value = gsub(Value, pattern = "n &lt; ",replacement = ""),
           Value = ifelse(Value == "null", NA, Value),
           Value = as.integer(Value)) %>% 
    filter(Country != "EU/EEA and the UK") %>% 
    mutate(Region = "All",
           Date = Date_i,
           Date = paste(sprintf("%02d",day(Date)),    
                        sprintf("%02d",month(Date)),  
                        year(Date),sep="."),
           Metric = "Count",
           Short =  recode(Country,
             "Austria" = "AT",
             "Belgium" = "BE",
             "Bulgaria" = "BG",
             "Croatia" = "HR",
             "Cyprus" = "CY",
             "Czechia" = "CZ",
             "Denmark" = "DK",
             "Estonia" = "EE",
             "Finland" = "FI",
             "France" = "FR",
             "Germany" = "DE",
             "Hungary" = "HU",
             "Iceland" = "IS",
             "Ireland" = "IE",
             "Italy" = "IT",
             "Latvia" = "LV",
             "Lithuania" = "LT",
             "Luxembourg" = "LU",
             "Malta" = "MT",
             "Netherlands" = "NL",
             "Norway" = "NO",
             "Poland" = "PL",
             "Portugal" = "PT",
             "Romania" = "RO",
             "Slovakia" = "SK",
             "Sweden" = "SE",
             "United Kingdom" = "GB",
             TRUE ~ "Code ME!"),
           Code = paste0(Short,"_ECDC_",Date),
           AgeInt = ifelse(Age == "80", 25, 10)) %>% 
    select(-Short) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
    filter(!is.na(Value))

  ECDCout <- 
    ECDCout %>% 
    bind_rows(ECDC_i)
  
}

# provisional fix weeks 48 and 49
#################################

unique(ECDCout$Country)  
unique(ECDCout$Sex)  

exc1 <- c("P1: to 2020-07-31", "P2: from 2020-08-01")
exc2 <- c("p1: to 2020-07-31", "p2: from 2020-08-01")

ECDCout <-
  ECDCout %>% 
  filter(!(Country %in% exc1 | Sex %in% exc2)) 


###################################################
# prep output!
ECDCout <-
  ECDCout %>% 
  sort_input_data()

N <- nrow(ECDCout) - nrow(ECDCin)

# So, this can be scheduled daily, it just won't do anything 6 days per week..
if (N > 0){
# write it out!
  write_sheet(ECDCout, 
            ss = ss_i,
            sheet = "database")  


  log_update(pp = ctr, N = N)
}

###################################################

