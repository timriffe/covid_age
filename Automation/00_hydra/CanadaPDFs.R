## Canada PDFs EPI-DATA 
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Canada" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## The purpose of this script is to download the PDFs from the Greece MOH website.
## Probably for downloading automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

#Source Website: https://health-infobase.canada.ca/covid-19/archive/

## Weekly reports- since this started in July 2022, I will design the code as for 2022 as a whole, 
# 
# seq_dates <- format(seq(from = as.Date("2020/01/01"), to = today(), by = "1 days"), "%Y-%m-%d")
# 
# # link sample: https://health-infobase.canada.ca/covid-19/archive/2022-06-10/
# 
# weeks_df <- data.frame(base = rep("https://health-infobase.canada.ca/covid-19/archive/", 
#                                   times = length(seq_dates)),
#                        date = seq_dates) %>% 
#   mutate(url = paste0(base, date, "/"),
#          destinations = paste0(files_source, "Report-", date, ".pdf"))

## FOR THE DAILY SCRIPT RUN ON HYDRA 

seq_dates <- format(seq(from = as.Date("2020/01/01"), to = today(), by = "1 days"), "%Y-%m-%d")

# link sample: https://health-infobase.canada.ca/covid-19/archive/2022-06-10/

weeks_df <- data.frame(base = rep("https://health-infobase.canada.ca/covid-19/archive/", 
                                  times = length(seq_dates)),
                       date = seq_dates) %>% 
  mutate(url = paste0(base, date, "/"),
         destinations = paste0(files_source, "Report-", date, ".pdf")) %>% 
  filter(date >= "2022-06-10")

# EXAMPLE TO WRITE THE BELOW FUNCTION
# files <- read_html("https://health-infobase.canada.ca/covid-19/archive/2022-06-10/") %>% 
#   html_nodes("a ") %>% 
#   html_attr('href') 
# 
# data.frame(pdf_url = files,
#            baselink = "https://health-infobase.canada.ca/covid-19/archive/2022-06-10/") %>% 
#   filter(str_detect(pdf_url, ".pdf")) %>% 
#   distinct(pdf_url, baselink) 


pdf_urls <- data.frame()

find_pdf <- function(i){
  files <- read_html(i) %>% 
    html_nodes("a ") %>% 
    html_attr('href') 
  
  files_urls <- data.frame(pdf_url = files,
             baselink = i) %>% 
    filter(str_detect(pdf_url, ".pdf")) %>% 
    distinct(pdf_url, baselink) 
  
 .GlobalEnv$files_urls <- files_urls

}

for(i in seq_along(weeks_df$url)){
  if(class(try(find_pdf(weeks_df$url[i]),
               silent = TRUE)) == "try-error"){
    print(paste("No Pdf link for:", i))
  } else{
    print(paste("Extracting Pdf link for:", i))
    pdf_urls <- rbind(pdf_urls, files_urls)
  }
}

filesdownload <- pdf_urls %>% 
  inner_join(weeks_df, by = c("baselink" = "url")) %>% 
  select(pdf_url, destinations) %>% 
  mutate(date = str_extract(destinations, "\\d+-\\d+-\\d+"),
         date = ymd(date)) %>% 
  filter(date == max(date))



for(i in seq_along(filesdownload$pdf_url)){
  if(class(try(download.file(filesdownload$pdf_url[i],
                             destfile = filesdownload$destinations[i],
                             mode="wb"),
               silent = TRUE)) == "try-error"){
    log_update(pp = ctr, N = "NoPDF")
    next
  } else {
    log_update(pp = ctr, N = "Downloaded")
  }
}


## END ##
