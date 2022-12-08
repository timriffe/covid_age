## Mozambique EPI-DATA PDFs.
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
ctr          <- "Mozambique" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")



files <- read_html("https://covid19.ins.gov.mz/documentos-em-pdf/boletins-diarios/") %>% 
  html_nodes("a ") %>% 
  html_attr('href') 

remove_pattern1 <- paste0("https://covid19.ins.gov.mz/wp-content/uploads/", "\\d+/\\d+")


all_files <- data.frame(pdf_url = files) %>% 
  filter(pdf_url != "https://covid19.ins.gov.mz/documentos-em-pdf/",
         str_detect(pdf_url, ".pdf")) %>% 
  mutate(pdf_extension = str_remove_all(pdf_url, "https://covid19.ins.gov.mz/wp-content/uploads/"),
         pdf_extension = str_replace_all(pdf_extension, "/", "-"),
         destinations = paste0(files_source, pdf_extension)) %>% 
  separate(pdf_extension, c("base", "bulletin_number"), sep = "_") %>% 
  mutate(bulletin_number = str_remove_all(bulletin_number, ".pdf"),
         bulletin_number = str_remove_all(bulletin_number, "-\\d+.\\d+")) %>% 
  filter(!is.na(bulletin_number),
         str_detect(bulletin_number, "\\d+")) %>% 
  distinct(pdf_url, bulletin_number, destinations)


all_files %>% 
  mutate(bulletin_number = as.integer(bulletin_number)) %>% 
  filter(!is.na(bulletin_number)) %>% 
  filter(bulletin_number == max(bulletin_number)) %>% 
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}

#save output data

#write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = "Downloaded") 

