## India Vaccination PDFs.
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
ctr          <- "India" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the GAMBIA website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

## To Download the daily report - PENDING the scrapping code or manually entering the data 

files <- read_html("https://www.mohfw.gov.in/") %>% 
  html_nodes("a ") %>% 
  html_attr('href') 


all_files <- data.frame(pdf_url = files) %>% 
  filter(str_detect(pdf_url, "CummulativeCovidVaccinationReport")) %>% 
  mutate(pdf_extension = str_remove_all(pdf_url, "http://mohfw.gov.in/pdf/"),
         destinations = paste0(files_source, pdf_extension)) %>% 
  distinct(pdf_url, destinations)

all_files %>% 
  {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


#save output data

#write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = "Downloaded") 


# 
# ## downloading the archive data 
# ## To my knowledge, the PDFs are available since 01 May 2022! 
# 
# dates <- format(seq(from = as.Date("2022/05/01"), to = today(), by = "1 days"), "%Y-%m-%d")
# 
# dates_df <- data.frame(base = rep("http://mohfw.gov.in/pdf/CummulativeCovidVaccinationReport",
#                                   times = length(dates)),
#                        date = dates) %>%
#   mutate(day = lubridate::day(date),
#          day = str_pad(day, width = 2, side = "left", pad = 0),
#          month = lubridate::month(date, label = TRUE),
#          year = lubridate::year(date),
#          date_url = paste0(day, month, year),
#          pdf_url = paste0(base, date_url, ".pdf"),
#          pdf_extension = str_remove_all(pdf_url, "http://mohfw.gov.in/pdf/"),
#          destinations = paste0(files_source, pdf_extension)) #%>%
  # filtering out the dates that have no reports as they show error
 # filter(date != "2020-01-28")

# 
# dates_df %>%
#   {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}
# 

# 
# for(i in seq_along(dates_df$pdf_url)){
#   if(class(try(download.file(dates_df$pdf_url[i],
#                              destfile = dates_df$destinations[i],
#                              mode="wb"),
#                silent = TRUE)) == "try-error"){
#     print(paste("No file for:", i))
#     next 
#     print(paste("downnloading:", i))
#   }
# }







