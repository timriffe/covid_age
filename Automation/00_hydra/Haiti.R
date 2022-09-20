## Haiti PDFs EPI-DATA AND VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Haiti" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## The purpose of this script is to download the PDFs from the Haiti website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

#Websource <- "https://www.mspp.gouv.ht/documentation/?start=0&debut=&fin=&categorie=0&mot="


## Manual exploration in internet shows that reports are probably available since 01.05.2020

dates <- format(seq(from = as.Date("2020/05/01"), to = today(), by = "1 days"), "%d-%m-%Y")


dates_df <- data.frame(base = rep("https://mspp.gouv.ht/site/downloads/Sitrep%20COVID-19_", 
                                  times = length(dates)),
                       date = dates) %>% 
  # filtering out the dates that have no reports as they show error 
  filter(!date %in% c("09-05-2020", "15-05-2020", 
                      "22-07-2020", "12-08-2020",
                      "22-08-2020", "26-08-2020", 
                      "18-09-2020", "09-10-2020",
                      "02-12-2020", "13-12-2020",
                      "26-12-2020", "01-01-2021",
                      "02-01-2021", "28-01-2021",
                      "14-02-2021", "03-04-2021",
                      "26-05-2021", "28-05-2021",
                      "07-07-2021", "09-08-2021", 
                      "30-11-2021", "24-12-2021",
                      "31-01-2022", "08-02-2022", 
                      "09-02-2022", "08-03-2022",
                      "09-03-2022", "11-03-2022",
                      "03-04-2022", "04-05-2022",
                      "20-05-2022", "06-06-2022",
                      "07-07-2022", "18-07-2022")) %>% 
  # convert to date format so that we can filter on
  mutate(url = paste0(base, date, ".pdf"),
         date = dmy(date),
         destinations = paste0(files_source, date, ".pdf"))

## Since the PDFs are not published for a while, the following will update Hydra with 
## FALSE, if no PDFs, with Downloaded if PDF is downloaded


if(class(try(
  dates_df %>%
  filter(date > "2022-09-07") %>% 
  #slice(which.max(date)) %>% 
  # last published report was 17 July 2022 - to Monitor this
  #  filter(date <= "2022-07-17") %>% 
  {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}, 
  silent = TRUE)) == "try-error"){
  log_update(pp = ctr, N = "NoUpdate")
} else {
  log_update(pp = ctr, N = "Downloaded")
}
  
         
 
## END ##



