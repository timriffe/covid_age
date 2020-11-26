# don't manually alter the below
# This is modified by sched()
# ##  ###
email <- "kikepaila@gmail.com"
setwd("U:/gits/covid_age")
# ##  ###

# end 

# TR New: you must be in the repo environment 
source("Automation/00_Functions_automation.R")

drive_auth(email = email)
gs4_auth(email = email)

SI_rubric <- get_input_rubric() %>% filter(Short == "SI")
ss_i  <- SI_rubric %>% dplyr::pull(Sheet)
ss_db <-  SI_rubric %>% dplyr::pull(Source)
# reading data from Montreal and last date ent

### reading data from the website 
m_url <- "https://www.nijz.si/sl/dnevno-spremljanje-okuzb-s-sars-cov-2-covid-19"
html <- read_html(m_url)

# locating the links for Excel files
url <- html_nodes(html, xpath = '//*[@id="node-5056"]/div[4]/div/div/div/p[7]/a') %>%
  html_attr("href")

paste0("https://www.nijz.si", url)
# tb4 cases
# tb6 deaths

###############################
### daily collection automation
###############################

### Cases
##############

db_c <- rio::import(paste0("https://www.nijz.si", url), 
                    sheet = "tb4", 
                    skip = 2) %>%
  as_tibble() 

var_names1 <- c("date_f",
               paste0("m_", c(0, seq(5, 85, 10), "TOT")), 
               paste0("f_", c(0, seq(5, 85, 10), "TOT")), 
               paste0("b_", c(0, seq(5, 85, 10), "TOT")))
               
db_c2 <- db_c %>% 
  rename_at(vars(1:34), ~ var_names1) %>%  
  gather(-date_f, key = Age, value = new) %>% 
  separate(Age, c("Sex", "Age"), sep = "_") %>% 
  mutate(date_f = as_date(as.integer(date_f), origin = "1899-12-30")) %>% 
  replace_na(list(new = 0)) %>% 
  drop_na()

# # test  
db_c2 %>%
  filter(Age != "TOT") %>%
  group_by(Sex) %>%
  summarise(sum(new))

db_c3 <- db_c2 %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(-new) %>% 
  ungroup() %>% 
  mutate(Measure = "Cases")

### deaths
##############
db_d <- rio::import(paste0("https://www.nijz.si", url), 
                    sheet = "tb6", 
                    skip = 2)

var_names2 <- c("date_f",
                paste0("m_", c(seq(35, 85, 10), "TOT")), 
                paste0("f_", c(seq(45, 85, 10), "TOT")), 
                paste0("b_", c(seq(35, 85, 10), "TOT")))

db_d2 <- db_d %>% 
  rename_at(vars(1:21), ~ var_names2) %>% 
  mutate(d_format = str_length(date_f),
         date_f = case_when(d_format == 5 ~ as_date(as.integer(date_f), origin = "1899-12-30"),
                            d_format == 9 ~ dmy(date_f),
                            TRUE ~ NA_Date_)) %>% 
  drop_na(date_f) %>% 
  select(-d_format) %>% 
  gather(-date_f, key = Age, value = new) %>% 
  separate(Age, c("Sex", "Age"), sep = "_") %>% 
  replace_na(list(new = 0))

# # test  
db_d2 %>%
  filter(Age != "TOT") %>%
  group_by(Sex) %>%
  summarise(sum(new))

db_d3 <- db_d2 %>% 
  complete(date_f, 
           Sex, 
           Age = c("0", as.character(seq(45, 85, 10)), "TOT"), 
           fill = list(new = 0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(-new) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths")


db_all <- bind_rows(db_c3, db_d3) %>% 
  mutate(Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Slovenia",
         Code = paste0("SI", Date),
         Region = "All",
         AgeInt = case_when(Age == "0" & Measure == "Deaths" & (Sex == "b" | Sex == "m") ~ "35", 
                            Age == "0" & Measure == "Deaths" & Sex == "f" ~ "45", 
                            Age == "0" & Measure == "Cases" ~ "5", 
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         Metric = "Count") %>% 
  arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

date_f <- db_d3 %>% 
  dplyr::pull(date_f) %>% 
  max()
############################################
#### uploading database to Google Drive ####
############################################
# This command append new rows at the end of the sheet
write_sheet(db_all,
             ss = ss_i,
             sheet = "database")
log_update(pp = "Slovenia", N = nrow(db_all))
############################################
#### uploading metadata to Google Drive ####
############################################

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

meta <- drive_create(paste0("SI", d, "_cases&deaths"),
                     path = ss_db, 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(db_c, 
            ss = meta$id,
            sheet = "cases_age_sex")

write_sheet(db_d, 
            ss = meta$id,
            sheet = "deaths_age_sex")

sheet_delete(meta$id, "Sheet1")





