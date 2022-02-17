source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr          <- "US_Oregon" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/Oregon"
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Drive urls
rubric <- get_input_rubric() %>% 
  filter(Short == "US_OR")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

# read in current state of the data
inOR <-  read_sheet(ss = ss_i, sheet = "database")

dates_in  <- 
  inOR %>% 
  filter(!Measure %in% c("Vaccinations", "Vaccination1", "Vaccination2")) %>% 
  dplyr::pull(Date) %>% 
  dmy() %>% 
  unique()

dates_in_strings <-
  dates_in %>% 
  gsub(pattern = "\\-", replacement = "") %>% 
  unique()

# what do we have so far?
files_have <- dir_n_source %>% 
  dir()

files_have <- files_have[!grepl(files_have, 
                                pattern = paste(dates_in_strings, 
                                                collapse="|"))]

files_new <- files_have[grepl(pattern = ".xlsx",files_have)] 

if (length(files_new) > 0){
  read_or_data <- function(filexcel){
    date_f <- filexcel %>% 
      str_replace("Demographic Data - Death", "") %>% 
      str_replace(".xlsx", "") %>% 
      ymd()
    
    table_full <- 
      read_xlsx(paste0(dir_n_source, "/", filexcel),
                skip = 1) %>% 
      rename(Demographic= 1, 
             var1 = 2,
             Deaths = 4,
             Cases = 5) %>% 
      group_by() %>% 
      fill(Demographic)
    
    #table_full <- 
     #read_xlsx(paste0(dir_n_source, "/", filexcel),
                #skip = 1) %>% 
     # rename(var1 = 2,
            # Deaths = 4,
             #Cases = 5) %>% 
     # group_by() %>% 
      #fill(Demographic)
    
    db_sex <- table_full %>% 
      filter(Demographic == "Sex Group") %>% 
      rename(Sex = var1) %>% 
      mutate(Sex = case_when(Sex == "Total" ~ "b",
                             Sex == "Female" ~ "f",
                             Sex == "Male" ~ "m",
                             TRUE ~ "UNK")) %>% 
      filter(Sex %in% c("b", "m", "f")) %>% 
      select(Sex, Cases, Deaths) %>% 
      mutate(Age = "TOT",
             AgeInt = NA_integer_)
    
    db_age <- table_full %>% 
      filter(Demographic == "Age Group") %>% 
      rename(Age = var1) %>% 
      separate(Age, c("Age", "trash"), sep = " to ") %>%
      mutate(Age = case_when(Age == "9 and younger" ~ "0",
                             Age == "80+" ~ "80",
                             Age == "Total" ~ "o",
                             Age == "Refused/Unknown" ~ "o",
                             TRUE ~ Age),
             AgeInt = ifelse(Age == "80", 25, 10)) %>% 
      filter(Age != "o") %>% 
      select(Age, AgeInt, Cases, Deaths) %>% 
      mutate(Sex = "b") %>% 
      replace_na(list(Deaths = 0))
    
    db_full <- bind_rows(db_age, db_sex) %>% 
      gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
      mutate(Date = date_f,
             Metric = "Count")
  }
  
  out <- 
    lapply(files_new, read_or_data) %>% 
    bind_rows() %>% 
    filter(!Date %in% dates_in) %>% 
    mutate(Country = "USA",
           Region = "Oregon",
           Metric = "Count",
           Date = paste(sprintf("%02d",day(Date)),    
                        sprintf("%02d",month(Date)),  
                        year(Date),sep="."),
           Code = paste0("US-OR")) %>% 
    select(all_of(colnames(inOR))) %>% 
    sort_input_data()

  sheet_append(ss = ss_i, out, sheet = "database")
  
  # update log
  log_update(ctr, nrow(out))
  
  # save source data to archive
  
  file.copy(paste0(dir_n_source, "/", files_new), 
            paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/", ctr, "/", files_new))
  
  file.remove(paste0(dir_n_source, "/", files_new))
  
} else {
  log_update(ctr, N=0)
}






