

library(lubridate)
library(rvest)
library(httr)
library(webshot)
#install_phantomjs()

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")


cases_url  <- "https://guineasalud.org/estadisticas/"


page <- read_html(cases_url)


# Very ugly code to extract reference date of data.
RefDateChar <- 
  page %>% 
  html_nodes(css = "body > div.wrapper > div > div > div > div.full_width > div > div:nth-child(1) > div > div > div > div > div:nth-child(1) > div > div > div > div > div > div.wpb_text_column.wpb_content_element.vc_custom_1610323760513 > div > p:nth-child(2) > em") %>% 
  html_text()

dMy <-
  RefDateChar %>% 
  gsub(pattern = "Datos: a", replacement = "") %>% 
  gsub(pattern = "de ", replacement = "") %>% 
  str_split(pattern = " ") %>% 
  '[['(1) %>% 
  '['(-1)

yr <- dMy[2]
dM <- str_split(dMy[1], pattern = "[:space:]") %>% 
  '[['(1)
dy <- dM[1]

ESmnths <- c("Enero", "Febrero", "Marzo","Abril","Mayo", "Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre") %>% tolower()
mth <- which(ESmnths == dM[2] %>% tolower())

ref_date <- dmy(paste(dy,mth,yr,sep ="."))

cases_png  <- paste0("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Equatorial_Guinea/GQ_cases_age_sex",ref_date,".png")
if (!"email" %in% ls() | system("whoami", intern = TRUE) == "tim"){
  setwd("/home/tim/workspace/covid_age")
  email <- "tim.riffe@gmail.com"
  cases_png  <- paste0("Data/Equatorial_Guinea/GQ_cases_age_",ref_date,".png")
} 

image_url <-
  page %>% 
  html_nodes(css = "body > div.wrapper > div > div > div > div.full_width > div > div:nth-child(1) > div > div > div > div > div:nth-child(6) > div > div > div:nth-child(2) > div > div > div.wpb_single_image.wpb_content_element.vc_align_left > div > div > img") %>% 
  html_attr("src")

webshot(image_url,
        file = cases_png,
        delay = 5)

Totals <-
  page %>% 
    html_nodes(css = "#tablepress-2") %>% 
    html_table() %>% 
    '[['(1) 
Tests <- 
  page %>% 
  html_nodes(css = "#tablepress-1") %>% 
  html_table() %>% 
  '[['(1) 



gs4_auth(email = email)
drive_auth(email = email)

ss_db <- get_input_rubric() %>% 
  filter(Country == "Equatorial Guinea") %>% 
  dplyr::pull(Source)

drive_put(cases_png,
          path = as_id(ss_db))

sheet_name <- paste0("GQ_", ref_date,"_totals")

meta <- drive_create(sheet_name,
                     path = as_id(ss_db), 
                     type = "spreadsheet",
                     overwrite = TRUE)
write_sheet(Totals, 
            ss = meta$id,
            sheet = "Totals")
write_sheet(Tests, 
            ss = meta$id,
            sheet = "Tests")
sheet_delete(meta$id, "Sheet1")
log_update("Equatorial_Guinea",N = "captured")

schedule.this <- FALSE
if (schedule.this){
 library(cronR)
  cmd <- cron_rscript("Automation/Equatorial_Guinea_screencaptures.R")
  cron_add(cmd, 
           frequency = 'daily', 
           id = "COVerAGE-DB_Equatorial_Guinea", 
           at = "15:03")
  cron_ls()
  cron_clear(ask=FALSE)
}
