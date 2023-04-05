## South Africa EPI-DATA PDFs.
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
ctr          <- "SouthAfrica" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the GAMBIA website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

## THESE ARE WEEKLY REPORTS ##

## Source Website <- "https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/weekly-epidemiological-brief/"


url_reports <- "https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/weekly-epidemiological-brief/"

files <- read_html(url_reports) %>% 
  html_nodes("a ") %>% 
  html_attr('href') 

all_files <- data.frame(pdf_url = files) %>% 
  filter(str_detect(pdf_url, ".pdf")) %>% 
  mutate(pdf_extension = str_remove_all(pdf_url, paste0("https://www.nicd.ac.za/wp-content/uploads/", "\\d+/\\d+/")),
         destinations = paste0(files_source, pdf_extension)) %>% 
  distinct(pdf_url, destinations) %>% 
  ## this will require change in 2023 or if any bug ## 
  filter(str_detect(pdf_url, "week-\\d+-2022")) %>% 
  mutate(Week_Number = str_extract(pdf_url, "week-\\d+-2022"),
         WeekNumber = str_extract(Week_Number, "\\d+-"),
         WeekNumber = str_remove(WeekNumber, "-"),
         WeekNumber = as.integer(WeekNumber)) %>% 
  filter(WeekNumber == max(WeekNumber))


all_files %>% 
    {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}

#log_update(pp = ctr, N = "Downloaded")


## END ## 



