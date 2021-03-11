library(here)
library(jsonlite)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive user in case the script is verified manually  
if (!"email" %in% ls()){
  email <- "cimentadaj@gmail.com"
}

# info country and N drive address
ctr <- "Venezuela"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

VE_rubric <- get_input_rubric() %>% filter(Short == "VE")
ss_i  <- VE_rubric %>% dplyr::pull(Sheet)
ss_db <-  VE_rubric %>% dplyr::pull(Source)
# reading data from Montreal and last date entered

db_drive <- try(read_sheet(ss_i, sheet = "database"))

# If error
if (class(db_drive)[1] == "try-error") {
  
  Sys.sleep(120)
  
  # Try to load again
  db_drive <- try(db_drive <- read_sheet(ss_i, sheet = "database"))
  
  if (class(db_drive)[1] == "try-error") {
    
    Sys.sleep(120)
    
    # Try to load again
    db_drive <- try(db_drive <- read_sheet(ss_i, sheet = "database"))
    
    if (class(db_drive)[1] == "try-error") {
      
      Sys.sleep(120)
      
      # Try to load again
      db_drive <- try(read_sheet(ss_i, sheet = "database"))
      
    }
  }
}

last_date_drive <-
  db_drive %>%
  mutate(date_f = dmy(Date)) %>%
  dplyr::pull(date_f) %>%
  max()

# reading data from the website
r <- GET("https://covid19.patria.org.ve/api/v1/summary")
a <- httr::content(r, "text", encoding = "ISO-8859-1")
b <- fromJSON(a)

r2 <- GET("https://covid19.patria.org.ve/api/v1/timeline")
a2 <- httr::content(r2, "text", encoding = "ISO-8859-1")
b2 <- fromJSON(a2)

date_f <-
  b2 %>%
  dplyr::pull(Date) %>%
  max()

d <- paste(sprintf("%02d", day(date_f)), sprintf("%02d", month(date_f)), year(date_f), sep = ".")

if (date_f > last_date_drive) {

  out <-
    b$Confirmed$ByAgeRange %>%
    bind_cols %>%
    gather(key = age_g, value = Value) %>%
    separate(age_g, c("Age", "res")) %>%
    select(-res) %>%
    bind_rows(tibble(Age = "TOT",
                     Value = b$Confirmed$Count)) %>%
    mutate(Sex = "b") %>%
    bind_rows(tibble(Age = "TOT",
                     Sex = c("f", "m"),
                     Value = c(b$Confirmed$ByGender$female, b$Confirmed$ByGender$male))) %>%
    mutate(Measure = "Cases") %>%
    bind_rows(tibble(Age = "TOT",
                     Sex = c("b"),
                     Measure = "Deaths",
                     Value = b$Deaths$Count)) %>%
    mutate(Region = "All",
           Date = d,
           Country = "Venezuela",
           Code = paste0("VE", Date),
           AgeInt = case_when(Age == "TOT" ~ NA_real_,
                              Age == "90" ~ 15,
                              TRUE ~ 10),
           Metric = "Count") %>%
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

  out

  ############################################
  #### uploading database to Google Drive ####
  ############################################

  # This command append new rows at the end of the sheet
  
  X <- try(sheet_append(out,
                   ss = ss_i,
                   sheet = "database"))
  
  # If error
  if (class(X)[1] == "try-error") {
    
    Sys.sleep(120)
    
    # Try to load again
    X <- try(sheet_append(out,
                          ss = ss_i,
                          sheet = "database"))
   
    if (class(X)[1] == "try-error") {
      
      Sys.sleep(120)
      
      # Try to load again
      X <- try(sheet_append(out,
                            ss = ss_i,
                            sheet = "database"))
      
      if (class(X)[1] == "try-error") {
        
        Sys.sleep(120)
        
        # Try to load again
        X <- try(sheet_append(out,
                              ss = ss_i,
                              sheet = "database"))
        
      }
    }
  }

  
  log_update(pp = ctr, N = nrow(out))
  
  
  ############################################
  #### uploading metadata to Google Drive ####
  ############################################
  data_source <- paste0(dir_n, 
                        "Data_sources/", 
                        ctr,
                        "/", 
                        ctr,
                        "_data_",
                        today(), 
                        ".txt")
  
  writeLines(a, data_source)

} else {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = "Venezuela", N = 0)
}
