
source(here::here("Automation/00_Functions_automation.R"))
library(readr)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

## MK 15.12.2022- I split the cases/ deaths data script from the Vax script, since the vax data are changing every now and then. 

# info country and N drive address
ctr <- "Denmark"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Denmark/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

at_rubric <- get_input_rubric() %>% dplyr::filter(Short == "DK")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)


# reading data from Denmark stored in N drive
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
db_n <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Measure %in% c("Cases"))  
  # mutate(Value = str_remove(Value, "\\.000"),
  #        Value = str_remove_all(Value, "\\."),
  #        Value = as.numeric(Value))


# identifying dates already captured in each measure
dates_cases_n <- db_n %>% 
  dplyr::filter(Measure == "Cases") %>% 
  dplyr::pull(Date) %>% 
  unique() %>% 
  sort()




# reading new deaths from Drive
## SA collects deaths data on weekly basis by age and sex, so it is preferable to keep. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
db_drive <- read_sheet(ss = ss_i, sheet = "database")

db_drive_deaths <- db_drive %>% 
  dplyr::filter(Measure == "Deaths") %>% 
  mutate(Date = dmy(Date),
         Age = as.character(Age),
         AgeInt = as.integer(AgeInt))
  


# reading new cases from the web
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# detecting the link to the xlsx file in the website
# this is a more stable method than using the xpath
m_url_c <- "https://covid19.ssi.dk/overvagningsdata/download-fil-med-overvaagningdata"

# capture all links with excel files
links_c <- scraplinks(m_url_c) %>% 
  dplyr::filter(str_detect(link, "zip")) %>% 
  separate(link, c("a", "b", "c", "d", "e", "Date", "g", "h")) %>% 
  mutate(Date = dmy(Date)) %>% 
  select(Date, url) %>% 
  drop_na()

links_new_cases <- links_c %>% 
 dplyr:: filter(!Date %in% dates_cases_n)

links_new_cases <- links_c[1,]
# downloading new cases data and loading it
dim(links_new_cases)[1] > 0
db_cases <- tibble()
if(dim(links_new_cases)[1] > 0){
  # i <- 1
  for(i in 1:dim(links_new_cases)[1]){
    
    date_c <- links_new_cases[i, 1] %>% dplyr::pull()
    data_source_c <- paste0(dir_n, "Data_sources/", 
                            ctr, "/", ctr, "_data_", as.character(date_c), ".zip")
    
    
    download.file(as.character(links_new_cases[i, 2]), destfile = data_source_c, mode = "wb")
    db_sex <- read_csv2(unz(data_source_c, "Cases_by_sex.csv"))
    
    db_sex2 <- 
      db_sex %>% 
      rename(Age = 1,
             f = 2,
             m = 3,
             b = 4) %>% 
      mutate(f = str_remove_all(f, "\\."),
             m = str_remove_all(m, "\\."),
             b = as.character(b)) %>%
      tidyr::pivot_longer(cols = -Age, names_to = "Sex", values_to = "Values") %>% 
      tidyr::separate(Values, c("Value", "trash"), sep = " ") %>% 
      mutate(Value = as.numeric(Value),
             Measure = "Cases") %>% 
      select(-trash)
    
    db_c <- bind_rows(db_sex2) %>% 
      separate(Age, c("Age", "trash"), sep = "-") %>% 
      mutate(Age = case_when(Age == "90+" ~ "90",
                             Age == "I alt" ~ "TOT",
                             TRUE ~ Age),
             Age = as.character(Age),
             Date = date_c) %>% 
      select(-trash)
    
    db_cases <- db_cases %>% 
      bind_rows(db_c)
    
  }
}



Out <- bind_rows(db_n, db_drive_deaths, db_cases) %>% 
    mutate(Date = ddmmyyyy(Date),
           Country = "Denmark",
           Code = "DK",
           Region = "All",
           AgeInt = case_when(Age == "90" ~ 15L, 
                              Age == "TOT" ~ NA_integer_,
                              Age == "UNK" ~ NA_integer_,
                              TRUE ~ 10L),
           Metric = "Count") %>% 
  sort_input_data() %>% 
  # TR: should be without effect, and will not remove redundancies if values are different
  distinct() 

# TR: this pipeline ended with %>% unique. Is there not a better and more rigorous way to remove redundancies?
# unique 
  

###########################
#### Saving data in N: ####
###########################
write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))


## DEATHS HISTROICAL CODE ==========================

# dates_deaths_n <- db_n %>% 
#   dplyr::filter(Measure == "Deaths") %>% 
#   dplyr::pull(Date) %>% 
#   unique() %>% 
#   sort()

# # filtering deaths not included yet
# db_deaths <- db_drive_deaths %>% 
#   filter(!Date %in% dates_deaths_n) %>% 
#   mutate(Age = as.character(Age))
# 
# db_deaths2 <- 
#   db_deaths %>% 
#    bind_rows(
#      db_drive_deaths) %>% 
#       group_by(Country, Region, Code, Date, Sex, Metric, Measure) %>% 
#       summarise(Value = sum(Value)) %>% 
#       ungroup() %>% 
#       mutate(Age = "TOT",
#              AgeInt = NA)%>% 
#   dplyr::filter(Age != "UNK")


# MK: 15.12.2022: looks these data have changed; age groups are different and some files are not consistent
# Since deaths are collected manually each week; no need for confusion with Python outputs! 

##now getting data that is scraped by a python script
# deaths_py <-list.files(path= dir_n_source, 
#                 pattern = ".xlsx",
#                 full.names = TRUE)
# 
# # all_content_age_death <-
#   deaths_py %>%
#   lapply(read_xlsx)
# 
# all_filenames_age_death <- deaths_py %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content_age_death, all_filenames_age_death, SIMPLIFY = FALSE)
# 
# deaths_py_in <- rbindlist(all_lists, fill = T)
# 
# 
# deaths_py_out <- deaths_py_in %>% 
#   select(Age = age_group, Value = deaths, Date = `V1`) %>% 
#   mutate(Value = gsub(",", "", Value),
#          Value = as.numeric(Value),
#          Date = substr(Date, 15, 22),
#          Date = as.Date(as.character(Date),format="%Y%m%d"),
#          Measure = "Deaths",
#          Country = "Denmark",
#          Region = "All",
#          Code = "DK",
#          Sex = "b",
#          Age = case_when(
#            Age == "0-9" ~ "0",
#            Age == "10-19" ~ "10",
#            Age == "20-29" ~ "20",
#            Age == "30-39" ~ "30",
#            Age == "40-49" ~ "40",
#            Age == "50-59" ~ "50",
#            Age == "60-69" ~ "60",
#            Age == "70-79" ~ "70",
#            Age == "80-89" ~ "80",
#            Age == "90+" ~ "90" 
#          ),
#          AgeInt = case_when(
#            Age == "90" ~ 15L,
#            TRUE ~ 10L
#          ),
#          Metric = "Count") %>% 
#   select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
# 

