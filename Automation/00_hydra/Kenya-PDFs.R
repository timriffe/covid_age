## Kenya EPI-DATA & VACCINATION PDFs.
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address
ctr          <- "Kenya" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the Kenya website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 



## Source Website <- "https://www.health.go.ke/#1621663241218-5a50bcac-41da"


files <- read_html("https://www.health.go.ke/#1621663241218-5a50bcac-41da") %>% 
  html_nodes("a ") %>% 
  html_attr('href') 


## https://www.health.go.ke/wp-content/uploads/

## all PDFs; EPI-DATA Sitreps and Vaccination data

all_files <- data.frame(pdf_url = files) %>% 
  filter(str_detect(pdf_url, "https://www.health.go.ke/wp-content/uploads/")) 



## EPI-DATA Sitreps PDFs 

epifiles_source <- paste0(dir_n, "Data_sources/", ctr, "/EpiData/")


epi_urls <- all_files %>%
  filter(!str_detect(pdf_url, "IMMUNIZATION-")) %>%
  filter(str_detect(pdf_url, "SITREP")) %>%
  mutate(pdf_extension = str_remove_all(pdf_url, "https://www.health.go.ke/wp-content/uploads/"),
         pdf_extension = str_replace_all(pdf_extension, "/", "-"),
         destinations = paste0(epifiles_source, pdf_extension)) %>%
  distinct(pdf_url, destinations)



epi_urls %>%
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}



## Vaccination PDFs 

vaxfiles_source <- paste0(dir_n, "Data_sources/", ctr, "/Vax/")
date_base <- paste0("-MINISTRY-OF-HEALTH-KENYA-COVID-19-IMMUNIZATION-STATUS-REPORT-", "\\W")

vaccination_urls <- all_files %>% 
  filter(str_detect(pdf_url, "IMMUNIZATION-")) %>% 
  mutate(pdf_extension = str_remove_all(pdf_url, "https://www.health.go.ke/wp-content/uploads/"),
         pdf_extension = str_replace_all(pdf_extension, "/", "-"),
         destinations = paste0(vaxfiles_source, pdf_extension)) %>% 
  distinct(pdf_url, destinations)


vaccination_urls %>% 
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}













