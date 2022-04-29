library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Ukraine"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))
today()
at_rubric <- get_input_rubric() %>% filter(Short == "UA")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)

# loading INED data
# ~~~~~~~~~~~~~~~~~
m_url     <- "https://dc-covid.site.ined.fr/en/data/pooled-datafiles/"
html      <- read_html(m_url)
# xpath extracted when inspecting the date element
link_ined <-
  html_nodes(html, xpath = '//*[@id="para_nb_1"]/div/div/div/h2[1]/a') %>%
  html_attr("href")

data_source <- paste0(dir_n, 
                      "Data_sources/", 
                      ctr, "/", ctr, 
                      "_ined_deaths_", 
                      as.character(today()), 
                      ".zip")

download.file(link_ined, destfile = data_source, mode = "wb")

zipdf <- utils::unzip(data_source, list = TRUE)


db_age <- read_csv(unz(data_source, "AgeSex/Cum_deaths_by_age_sex.csv"))



deaths_ined <- db_age %>% 
  filter(country == "Ukraine") %>% 
  select(Age = age_group, 
         Date = death_reference_date, 
         m = cum_death_male, 
         f = cum_death_female, 
         b = cum_death_both) %>% 
  mutate(Date = ddmmyyyy(Date)) %>% 
  filter(!Age %in% c("Total known", "Total unknown")) %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = recode(Age,
                      "0-" = "0",
                      "To" = "TOT")) %>% 
  gather(m, f, b, key = Sex, value = Value) %>% 
  mutate(Country = "Ukraine",
         Region = "All",
         Measure = "Deaths",
         Metric = "Count",
         AgeInt = case_when(Age == "90" ~ 15,
                            Age == "TOT" ~ NA_real_,
                            TRUE ~ 10),
         Code = paste0('UA')) %>%
  sort_input_data()
  

#deaths_ined <- read_csv(link_ined) %>% 
#  filter(country == "Ukraine") %>% 
#  select(Age = age_group, 
#         Date = death_reference_date, 
#         m = cum_death_male, 
#         f = cum_death_female, 
#         b = cum_death_both) %>% 
#  filter(!Age %in% c("Total known", "Total unknown")) %>% 
#  mutate(Age = str_sub(Age, 1, 2),
#         Age = recode(Age,
#                      "0-" = "0",
#                      "To" = "TOT")) %>% 
#  gather(m, f, b, key = Sex, value = Value) %>% 
#  mutate(Country = "Ukraine",
#         Region = "All",
#         Measure = "Deaths",
#         Metric = "Count",
#         AgeInt = case_when(Age == "90" ~ 15,
#                            Age == "TOT" ~ NA_real_,
#                            TRUE ~ 10),
#         Code = paste0('UA', Date)) %>%
#  sort_input_data()


dates_ined <- deaths_ined$Date %>% unique()
  

# loading data from Drive
# ~~~~~~~~~~~~~~~~~~~~~~~
db_drive <- get_country_inputDB("UA") %>% 
  mutate(Code = "UA")

deaths_drive <- 
  db_drive %>% 
  filter(Measure == "Deaths",
    !Date %in% dates_ined)# %>% 
  #select(-Short)

# all data together
# ~~~~~~~~~~~~~~~~~
out <- 
  db_drive %>% 
  filter(Measure != "Deaths") %>% 
  bind_rows(deaths_drive, deaths_ined) %>% 
  sort_input_data()

###########################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))


#### uploading metadata to N: Drive ####
########################################


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

