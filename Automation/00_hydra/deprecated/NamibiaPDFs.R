## Namibia PDFs EPI-DATA 
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Namibia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## The purpose of this script is to download the PDFs from the Namibia AFRO WHO website.
## Probably for downloading automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

#Source Website: https://www.afro.who.int/publications/namibia-covid-19-situation-reports-number-212-419


files <- read_html("https://www.afro.who.int/publications/namibia-covid-19-situation-reports-number-212-419") %>% 
  html_nodes("a ") %>% 
  html_attr('href') 

all_files <- data.frame(pdf_url = files) %>% 
  filter(str_detect(pdf_url, ".pdf")) %>% 
  mutate(pdf_extension = str_remove(pdf_url, "https://www.afro.who.int/sites/default/files/"),
         pdf_extension = str_replace(pdf_extension, "/", "-"),
         destinations = paste0(files_source, pdf_extension)) %>% 
  distinct(pdf_url, destinations) 



all_files %>% 
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


## END ##
