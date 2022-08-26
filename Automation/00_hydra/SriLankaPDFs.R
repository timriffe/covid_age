## Sri Lanka EPI-DATA PDFs.
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
ctr          <- "SriLanka" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the Sri Lanka website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

## THESE ARE WEEKLY REPORTS ##

## Source Website <- "https://www.epid.gov.lk/web/index.php?option=com_content&view=article&id=225&Itemid=518&lang=en"


url_reports <- "https://www.epid.gov.lk/web/index.php?option=com_content&view=article&id=225&Itemid=518&lang=en"

files <- read_html(url_reports) %>% 
  html_nodes("a ") %>% 
  html_attr('href') 


## HISTORIC PDFs ## 


all_files <- data.frame(pdf_url = files) %>%
  filter(str_detect(pdf_url, "sl-en")) %>%
  mutate(url = paste0("https://www.epid.gov.lk", pdf_url),
         pdf_extension = str_remove(pdf_url, "/web/images/pdf/corona_virus_report/"),
         destinations = paste0(files_source, pdf_extension)) %>%
  distinct(url, destinations)

## LOOP TO DOWNLOAD HISTORIC DATA ##

# for(i in seq_along(all_files$url)){
#   if(class(try(download.file(all_files$url[i],
#                              destfile = all_files$destinations[i],
#                              mode="wb"),
#                silent = TRUE)) == "try-error"){
#     next
#   }
# }


## DAILY AUTOMATED DOWNLOAD ##

# files_day <- read_html(url_reports) %>% 
#   html_table() %>% 
#   .[1] %>% 
#   bind_rows() %>% 
#   select(Date = X2) %>% 
#   filter(!str_detect(Date, "Date"))


CurrentDay <- lubridate::ymd(today())

files_day <- all_files %>% 
  mutate(reportdate = str_extract(url, "\\d+-\\d+_\\d+_\\d+"),
         reportdate = str_replace(reportdate, "_10_", "-"),
         reportdate = dmy(reportdate)) %>% 
  filter(reportdate == CurrentDay)


if(class(try(download.file(files_day$url,
                           destfile = files_day$destinations,
                           mode="wb"),
             silent = TRUE)) == "try-error"){
  log_update(pp = ctr, N = "NoPDF")
} else {
  log_update(pp = ctr, N = "Downloaded")
}


## END ## 