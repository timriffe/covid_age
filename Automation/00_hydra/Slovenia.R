#library(here)
#source(here("Automation/00_Functions_automation.R"))
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "ugofilippo.basellini@gmail.com"
}

# info country and N drive address
ctr <- "Slovenia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))
### reading data from the website 
# detecting the link to the xlsx file in the website
# this is a more stable method than using the xpath
m_url <- "https://www.nijz.si/sl/dnevno-spremljanje-okuzb-s-sars-cov-2-covid-19"

# capture all links with excel files
links <- scraplinks(m_url) %>% 
  filter(str_detect(url, "xlsx")) %>% 
  select(url)

# capture link with cases data by age
cases_url <- paste0("https://www.nijz.si", 
                    links %>% 
                      filter(str_detect(url, "/uploaded/dnevni_prikazi")) %>% 
                      dplyr::pull(url))

cases_url <- cases_url[-2] #there are two files on the website but we only need the newer one
# capture link with deaths data by age
deaths_url <- paste0("https://www.nijz.si", 
                    links %>% 
                      filter(str_detect(url, "umrli")) %>% 
                      dplyr::pull(url))

###############################
### daily collection automation
###############################

### Cases
##############

db_c <- rio::import(cases_url, 
                    sheet = "Tabela 5", 
                    skip = 2) %>%
  as_tibble() 

var_names1 <- c("date_f",
               paste0("m_", c(0, seq(5, 85, 10), "TOT")), 
               paste0("f_", c(0, seq(5, 85, 10), "TOT")), 
               paste0("u_", c(0, seq(5, 85, 10), "TOT")), 
               paste0("b_", c(0, seq(5, 85, 10), "TOT")))
               
db_c2 <- db_c %>% 
  rename_at(vars(1:45), ~ var_names1) %>%  
  gather(-date_f, key = Age, value = new) %>% 
  separate(Age, c("Sex", "Age"), sep = "_") %>% 
  filter(Sex != "u") %>% 
  mutate(date_f = dmy(date_f)) %>% 
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
db_d <- rio::import(deaths_url, 
                    sheet = "Tabela 5", 
                    skip = 2) %>% 
  select(-1)

var_names2 <- c("date_f",
                paste0("m_", c(0, seq(5, 85, 10))), 
                paste0("f_", c(0, seq(5, 85, 10))),
                "m_TOT", "f_TOT", "b_TOT")

db_d2 <- db_d %>% 
  rename_at(vars(1:24), ~ var_names2) %>% 
  mutate(date_f = dmy(date_f)) %>% 
  drop_na(date_f) %>% 
  gather(-date_f, key = Age, value = new) %>% 
  separate(Age, c("Sex", "Age"), sep = "_") %>% 
  replace_na(list(new = 0))

# # test  
db_d2 %>%
  filter(Age != "TOT") %>%
  group_by(Sex) %>%
  summarise(sum(new))

db_d3 <- db_d2 %>% 
  tidyr::complete(date_f, 
           Sex = c("m", "f"), 
           Age = c("0", as.character(seq(5, 85, 10)), "TOT"), 
           fill = list(new = 0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(-new) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths") %>% 
  arrange(Sex, suppressWarnings(as.integer(Age)), date_f)
  


out <- bind_rows(db_c3, db_d3) %>% 
  mutate(Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Slovenia",
         Code = paste0("SI"),
         Region = "All",
         AgeInt = case_when(Age == "0" & Measure == "Deaths" & (Sex == "b" | Sex == "m") ~ 35L, 
                            Age == "0" & Measure == "Deaths" & Sex == "f" ~ 45L, 
                            Age == "0" & Measure == "Cases" ~ 5L, 
                            Age == "85" ~ 20L,
                            Age == "TOT" ~ NA_integer_,
                            TRUE ~ 10L),
         Metric = "Count") %>% 
  arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

date_f <- db_c3 %>% 
  dplyr::pull(date_f) %>% 
  max()

###########################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

# saving data sources
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".xlsx")
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".xlsx")

download.file(cases_url, destfile = data_source_c)
download.file(deaths_url, destfile = data_source_d)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

data_source <- c(data_source_c, data_source_d)

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)


