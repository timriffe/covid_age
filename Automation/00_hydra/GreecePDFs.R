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
# 
# dates <- format(seq(from = as.Date("2020/06/01"), to = as.Date("2022/07/25"), by = "1 days"), "%Y-%m-%d")
# 
# 
# dates_df <- data.frame(base = rep("https://eody.gov.gr/wp-content/uploads/", 
#                                   times = length(dates)),
#                        date = dates) %>% 
#   separate(date, into = c("year", "month", "day"), sep = "-", remove = FALSE) %>% 
#   mutate(date = format(as.Date(date), "%Y%m%d"),
#          url = paste0(base, year, "/", month, "/covid-gr-daily-report-", date, ".pdf"),
#          date = ymd(date),
#          destinations = paste0(files_source, date, ".pdf"))
# 
# 
# 
# for(i in seq_along(dates_df$url)){
#   if(class(try(download.file(dates_df$url[i],
#                              destfile = dates_df$destinations[i],
#                              mode="wb"),
#                silent = TRUE)) == "try-error"){
#     next
#   }
# }



## Weekly reports- since this started in July 2022, I will design the code as for 2022 as a whole, 

seq_dates <- format(seq(from = as.Date("2022/07/25"), to = today(), by = "1 days"), "%Y-%m-%d")


# link sample: https://eody.gov.gr/wp-content/uploads/2022/08/covid-gr-weekly-report-2022-30.pdf

weeks_df <- data.frame(base = rep("https://eody.gov.gr/wp-content/uploads/", 
                                  times = length(seq_dates)),
                       date = seq_dates) %>% 
  mutate(week = lubridate::week(date)) %>% 
  separate(date, into = c("year", "month", "day"), sep = "-", remove = FALSE) %>% 
  mutate(date = format(as.Date(date), "%Y%m%d"),
         YR_WEEK = paste0(year, "-", week),
         ## we may need to change /08 later ##
         url = paste0(base, year, "/08", "/covid-gr-weekly-report-", YR_WEEK, ".pdf"),
         destinations = paste0(files_source, "WeeklyReport-", YR_WEEK, ".pdf")) %>% 
  distinct(week, url, destinations) %>% 
  filter(week == max(week))

## download all files ## 
# 
# for(i in seq_along(weeks_df$url)){
#   if(class(try(download.file(weeks_df$url[i],
#                              destfile = weeks_df$destinations[i],
#                              mode="wb"),
#                silent = TRUE)) == "try-error"){
#     next
#   }
# }

## for daily script run ## 
CurrentWeek <- lubridate::week(today())

if(CurrentWeek == weeks_df$week){
  if(class(try(download.file(weeks_df$url,
                          destfile = weeks_df$destinations,
                          mode="wb"),
            silent = TRUE)) == "try-error")
  log_update(pp = ctr, N = "NoUpdate")
} else {
  log_update(pp = ctr, N = "Downloaded")
}


## END ##
