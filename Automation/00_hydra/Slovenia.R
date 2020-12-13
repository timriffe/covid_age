library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "ugofilippo.basellini@gmail.com"
}

# info country and N drive address
ctr <- "Slovenia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

### reading data from the website 
# detecting the link to the xlsx file in the website
# this is a more stable method than using the xpath
m_url <- "https://www.nijz.si/sl/dnevno-spremljanje-okuzb-s-sars-cov-2-covid-19"

url <- paste0("https://www.nijz.si", 
       scraplinks(m_url) %>% 
         filter(str_detect(url, ".xlsx")) %>% 
         dplyr::pull(url))

# tb4 cases
# tb6 deaths

###############################
### daily collection automation
###############################

### Cases
##############

db_c <- rio::import(url, 
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
db_d <- rio::import(url, 
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
  tidyr::complete(date_f, 
           Sex, 
           Age = c("0", as.character(seq(45, 85, 10)), "TOT"), 
           fill = list(new = 0)) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(-new) %>% 
  ungroup() %>% 
  mutate(Measure = "Deaths")


out <- bind_rows(db_c3, db_d3) %>% 
  mutate(Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "Slovenia",
         Code = paste0("SI", Date),
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

date_f <- db_d3 %>% 
  dplyr::pull(date_f) %>% 
  max()

###########################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))


data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&deaths_",today(), ".xlsx")

download.file(url, destfile = data_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)

