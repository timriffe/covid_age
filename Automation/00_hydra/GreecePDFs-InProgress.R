## Greece PDFs EPI-DATA 
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Greece" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## The purpose of this script is to download the PDFs from the Greece MOH website.
## Probably for downloading automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

#Websource <- "https://eody.gov.gr/category/covid-19/"

## Manual exploration in internet shows that reports are probably available since 03.04.2020

## 1. Daily reports ## 

dates <- format(seq(from = as.Date("2020/06/01"), to = as.Date("2022/07/25"), by = "1 days"), "%Y-%m-%d")


dates_df <- data.frame(base = rep("https://eody.gov.gr/wp-content/uploads/", 
                                  times = length(dates)),
                       date = dates) %>% 
  separate(date, into = c("year", "month", "day"), sep = "-", remove = FALSE) %>% 
  mutate(date = format(as.Date(date), "%Y%m%d"),
         url = paste0(base, year, "/", month, "/covid-gr-daily-report-", date, ".pdf"),
         date = ymd(date),
         destinations = paste0(files_source, date, ".pdf"))

 
for(i in dates_df$date) {
  if(class(try(
  dates_df %>% {map2(.$url[i], .$destinations[i],
                     ~ download.file(url = .x, destfile = .y, mode="wb"))},
  silent = TRUE)) == "try-error"){
    next
  }
}


dates_df %>% 
  # filtering out the dates that have no reports as they show error 
  filter(!date %in% c("20200403", "20200404",
                      "20200405", "20200406",
                      "20200407", "20200408",
                      "20200409", "20200410",
                      "20200411", "20200412")) 
  # convert to date format so that we can filter on
  
  



dates_df %>%
  {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}











## Since 25.07.2022, the publishing shifted to weekly reports so here we go


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


CurrentWeek <- lubridate::week(today())

if(CurrentWeek == all_files$WeekNumber){
  all_files %>% 
    {map2(.$pdf_url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}
  log_update(pp = ctr, N = "Downloaded")
} else {
  log_update(pp = ctr, N = "NoUpdate")
}





## Since the PDFs are not published for a while, the following will update Hydra with 
## FALSE, if no PDFs, with Downloaded if PDF is downloaded




if(class(try(
  , 
  silent = TRUE)) == "try-error"){
  log_update(pp = ctr, N = "NoUpdate")
} else {
  log_update(pp = ctr, N = "Downloaded")
}



## END ##



