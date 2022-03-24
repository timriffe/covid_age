##Missouri##
##old deaths and new vaccines


source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library("zoo")


if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "US_Missouri"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- paste0("N:/COVerAGE-DB/Automation/", "USA-Missouri", "/")

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))
###save previous data that has been collected mannual

previous <- read_rds(paste0(dir_n, "US_Missouri.rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Date <= "2022-03-18")


##once get data from drive

#####drive
rubric_i <- get_input_rubric() %>% filter(Short == "US_MO")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)
db_drive <-  read_sheet(ss = ss_i, sheet = "database") 
  

##get the new data that is automated
##vacc by age
##initiated vacc by age


date <- as.character(today())  
date = gsub("[^0-9]+", "", date)

all_paths_age_vacc1 <-
  list.files(path = dir_n_source,
             pattern = paste0(date,"_Initiated Vaccinations by Age Group"),
             full.names = TRUE)

all_content_age_vacc1 <-
  all_paths_age_vacc1 %>%
  lapply(read_xlsx, skip = 1)

all_filenames_age_vacc1 <- all_paths_age_vacc1 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists_age_vacc1 <- mapply(c, all_content_age_vacc1, all_filenames_age_vacc1, SIMPLIFY = FALSE)

age_vacc1 <- rbindlist(all_lists_age_vacc1, fill = TRUE) 
names(age_vacc1)[1] <- "Date"
age_vacc2 <- melt(age_vacc1, id ="Date")


numberofdates <- age_vacc2 %>% 
  select(Date) %>% 
  unique()

##headers

headers <-read_xlsx(all_paths_age_vacc1, col_names=FALSE)[1,]
headers <- melt(headers, id="...1") 
headers$value2 <- na.locf(headers$value) 
headers2 <- headers[rep(seq_len(nrow(headers)), each = (length(numberofdates$Date)*1267)), ]  
names(headers2)[3] <- "Region"
headers2 <- headers2[-c(1,2)]%>% 
  mutate(Region = case_when(
    Region == "ALL" ~ "All",
    TRUE ~ Region
  ))
