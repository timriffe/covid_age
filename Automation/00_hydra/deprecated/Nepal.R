## Nepal EPI-DATA PDFs.
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))
library(googledrive)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address
ctr          <- "Nepal" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

## The purpose of this script is to download the PDFs from the GAMBIA website.
## Not for automation though. 
## and so we may run this script once a month to download the PDFs. 


files_source <- paste0(dir_n, "Data_sources/", ctr, "/")

## Source website <- "https://covid19.mohp.gov.np/situation-report

# MK: I was not able to scrap the website using the following method! :(
# dates <- format(seq(from = as.Date("2020/01/28"), to = today(), by = "1 days"), "%d-%m-%Y")
# 
# 
# dates_df <- data.frame(base = rep("https://covid19.mohp.gov.np/covid/englishSituationReport/SitRep", 
#                                   times = length(dates)),
#                        date = dates) %>% 
#  # convert to date format so that we can filter on
#   mutate(number = row_number(),
#          url = paste0(base, number, "_COVID-19_", date, "_EN.pdf"),
#          date = dmy(date),
#          destinations = paste0(files_source, date, ".pdf")) %>% 
#   # filtering out the dates that have no reports as they show error 
#   filter(date != "2020-01-28")
# 
# 
# dates_df %>% 
#   # last published report was 17 July 2022 - to Monitor this
#  # filter(date <= "2022-07-17") %>% 
#   {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


## the following code is copied from this post

# https://stackoverflow.com/questions/64687627/download-all-files-and-subdirectories-from-a-google-drive-directory-from-r

## Full driver link: https://drive.google.com/drive/folders/1OcGKoZxTqdTWw6h0MfrEeXwg0PXaBaWa?usp=sharing


## This will download the all PDFs inside the sub-directories. so two versions of each report;
## ENGLISH & NEPALI reports 


#folder link to id
jp_folder = "https://drive.google.com/drive/folders/1OcGKoZxTqdTWw6h0MfrEeXwg0PXaBaWa"
folder_id = drive_get(as_id(jp_folder))

#find files in folder
files_drive = drive_ls(folder_id) 

files <- files_drive %>% 
  mutate(date = str_remove_all(name, paste0("SitRep#", "\\d+", "_")),
         date = as.Date(date, format = "%d-%m-%Y")) %>% 
  slice(which.max(date))
  ## we can filter for the PDFs after specific date now, to avoid downloading everything again
 # filter(date > "2022-08-09")

#loop dirs and download files inside them
for (i in seq_along(files$name)) {
  #list files
  i_dir = drive_ls(files[i, ])
  
  #mkdir
  dir.create(path = files_source,
             files$name[i])
  
  #download files
  for (file_i in seq_along(i_dir$name)) {
    #fails if already exists
    try({
      drive_download(
        as_id(i_dir$id[file_i]),
        
        ## change the path to file_source so it does not download in the project folder
        path = paste0(files_source, i_dir$name[file_i])
      )
    })
  }
}


#save output data

#write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = "Downloaded")










