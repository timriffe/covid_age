## Isle of Man EPI-DATA PDFs.
## created by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address
ctr          <- "IsleOfMan" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the GAMBIA website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")



files <- read_html("https://www.gov.im/covid19-weekly-surveillance-report") %>% 
  html_nodes("a ") %>% 
  html_attr('href') 

remove_pattern1 <- paste0("https://www.gov.im/media/", "\\d+")


all_files <- data.frame(pdf_url = files) %>% 
  filter(str_detect(pdf_url, ".pdf")) %>% 
  mutate(pdf_extension = str_remove_all(pdf_url, "https://www.gov.im//media/"),
         pdf_url = paste0("https://www.gov.im/", pdf_extension),
         pdf_extension = str_replace_all(pdf_extension, "/", "-"),
         destinations = paste0(files_source, pdf_extension)) %>% 
  distinct(pdf_url, destinations)


all_files %>% 
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}



