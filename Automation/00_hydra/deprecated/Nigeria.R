## Nigeria EPI-DATA
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
ctr          <- "Nigeria" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the Kenya website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 



## Source Website <- "https://ncdc.gov.ng/diseases/sitreps/?cat=14&name=An%20update%20of%20COVID-19%20outbreak%20in%20Nigeria"
## this will unnecessarily download all Sitreps including those not COVID 

#read_html("https://ncdc.gov.ng/themes/common/files/sitreps/") %>% 
#  html_nodes("a ") %>% 
#  html_attr('href') 


urls_files <- read_html("https://ncdc.gov.ng/diseases/sitreps/?cat=14&name=An%20update%20of%20COVID-19%20outbreak%20in%20Nigeria") %>% 
  html_nodes('table') %>% 
  .[1] %>% 
  html_nodes("td a") 

files <- urls_files %>% 
  xml_attrs("download") %>% 
  bind_rows() %>% 
  select(pdf_url = href, pdf_extension = download)



## https://ncdc.gov.ng/diseases/sitreps/?cat=14&name=An%20update%20of%20COVID-19%20outbreak%20in%20Nigeria

## all PDFs; EPI-DATA Sitreps and Vaccination data

root = "https://ncdc.gov.ng"

all_files <- files %>% 
  mutate(url_pdf = paste0(root, pdf_url)) 



## EPI-DATA Sitreps PDFs 


epifiles_source <- paste0(dir_n, "Data_sources/", ctr, "/Sitreps/")


not_available <- c("https://ncdc.gov.ng/themes/common/files/sitreps/d01b0130f5e159fd45eacfc6c694f3dc.pdf",
                   "https://ncdc.gov.ng/themes/common/files/sitreps/b804d2e0a55289028429d54ee14e9cb8.pdf")

epi_urls <- all_files %>% 
  mutate(destinations = paste0(epifiles_source, pdf_extension)) %>% 
  ## to extract the most recent file ## 
  separate(pdf_extension, c("base_pdf", "date", "number"), sep = "_") %>% 
  mutate(date = dmy(date)) %>% 
  slice(which.max(date)) %>% 
  distinct(url_pdf, pdf_url, destinations) %>% 
  filter(!url_pdf %in% not_available)



epi_urls %>% 
  {map2(.$url_pdf, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


#save output data

#write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = "Downloaded")









