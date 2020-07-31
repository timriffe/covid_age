rm(list=ls())
library(tidyverse)
library(readr)
library(googlesheets4)
library(lubridate)
library(aweek)
library(googledrive)

drive_auth(email = "kikepaila@gmail.com")
gs4_auth(email = "kikepaila@gmail.com")

# TODO: add pdf scraping.

# this is specifically for the way NL records isoweeks
isoweek_to_date_hack <- function(ISOWEEK){
  WK <- ISOWEEK %% 100
  YR <- (ISOWEEK - WK) / 100 %>% as.integer()

  out <- as.aweek(paste0(YR, "-W", sprintf("%02d",WK), "-", 7)) %>%
    as.Date()

  out[out > today()] <- today()
  out
}

NL_url <- "https://data.rivm.nl/covid-19/COVID-19_casus_landelijk.csv"

NL <- read_delim(NL_url, delim = ";")

dates_all <- seq(dmy("01.03.2020"), today(), by = "days")

# Just for cases, we need to redistribute the Age
# '<50'. This can happen after cumulative sums
redistribute_under50 <- function(chunk){
  u50   <- chunk %>% filter(Age == "<50")
  
  chunk <- chunk %>% filter(Age != "<50")
  if (nrow(u50)>0){
    chunk <-
      chunk %>% 
      mutate(au50 = Age %in% c("0","10","20","30","40"),
             au50PDF = Value / sum(Value[au50]),
             au50PDF = ifelse(is.nan(au50PDF), 0, au50PDF),
             au50PDF = ifelse(au50, au50PDF, 0),
             Value = Value + au50PDF * u50$Value) %>% 
      select(-one_of(c("au50","au50PDF")))
  }
  chunk
}

# this is convoluted. To redistribute the N cases that died
# under age 50, we need to cumulate all the other ages over
# time to get the distribution at each time point.
Cases <-
  NL %>%
  mutate(Sex = case_when(
                 Sex == "Female" ~ "f",
                 Sex == "Male" ~ "m",
                 Sex == "Unknown" ~ "UNK"),
         Age = case_when(Agegroup == "0-9" ~ "0",
                         Agegroup == "10-19" ~ "10",
                         Agegroup == "20-29" ~ "20",
                         Agegroup == "30-39" ~ "30",
                         Agegroup == "40-49" ~ "40",
                         Agegroup == "50-59" ~ "50",
                         Agegroup == "60-69" ~ "60",
                         Agegroup == "70-79" ~ "70",
                         Agegroup == "80-89" ~ "80",
                         Agegroup == "90+" ~ "90",
                         Agegroup == "<50" ~ "<50",  # can correct later.
                         Agegroup == "Unknown" ~ "UNK")
         ) %>% 
  group_by(Date_statistics, Sex, Age) %>% 
  summarize(New = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Sex, Age, Date_statistics = dates_all, fill = list(New = 0)) %>% 
  arrange(Sex, Age, Date_statistics) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  ungroup() %>% 
  # filter(!(Sex == "UNK" & Value == 0),
  #        !(Age == "UNK" & Value == 0)) %>% 
  arrange(Date_statistics, Sex, Age) %>% 
  select(date = Date_statistics, Sex, Age, Value) %>% 
  group_by(date, Sex) %>% 
  do(redistribute_under50(chunk = .data)) %>% 
  ungroup() %>% 
  mutate(Country = "Netherlands",
         Region = "All",
         Date = paste(sprintf("%02d", day(date)),
                      sprintf("%02d", month(date)),
                      year(date), sep = "."),
         Code = paste0("NL",Date),
         Metric = "Count",
         Measure = "Cases",
         AgeInt = case_when(
           Age == "UNK" ~ NA_real_,
           Age == "90" ~ 15,
           TRUE ~ 10
         )) %>% 
  select(Country, Region, Code, Date, Sex,Age, AgeInt, Metric, Measure, Value)
  
# Prepare Deaths:

# Assume Unknown Date of death is 1 week after Date_statistics

all_weeks <- 3:week(today())
all_dates <- (all_weeks + 202000) %>% isoweek_to_date_hack()


all_ages <- c("0","50","60","70","80","90","UNK")

Deaths <- NL %>% 
  # premised on "Unknown" diminishing with time
  filter(Deceased == "Yes") %>% 
  mutate(
    Week_of_death = 
      ifelse(is.na(Week_of_death), 
             week(Date_statistics + 14) + year(Date_statistics) * 100, 
             Week_of_death),
    # assign date to end of respective week,
    # implies week sampling of deaths.
    date = isoweek_to_date_hack(Week_of_death),
    Age = case_when(Agegroup == "<50" ~ "0",
                    Agegroup == "50-59" ~ "50",
                    Agegroup == "60-69" ~ "60",
                    Agegroup == "70-79" ~ "70",
                    Agegroup == "80-89" ~ "80",
                    Agegroup == "90+" ~ "90",
                    Agegroup == "Unknown" ~ "UNK"),
    Sex = case_when(
      Sex == "Female" ~ "f",
      Sex == "Male" ~ "m",
      Sex == "Unknown" ~ "UNK")
  ) %>% 
  select(date, Sex, Age) %>% 
  group_by(date,Sex,Age) %>% 
  summarize(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(date = all_dates,
             Sex,
             Age = all_ages,
             fill = list(Value = 0)) %>% 
    arrange(Sex,Age,date) %>% 
    group_by(Sex,Age) %>% 
    mutate(Value = cumsum(Value)) %>% 
    ungroup() %>% 
    mutate(Country = "Netherlands",
           Region = "All",
           Date = paste(sprintf("%02d", day(date)),
                        sprintf("%02d", month(date)),
                        year(date), sep = "."),
           AgeInt = case_when(
             Age == "0" ~ 50,
             Age == "90" ~ 15,
             Age == "UNK" ~ NA_real_,
             TRUE ~ 10
           ),
           Metric = "Count",
           Measure = "Deaths",
           Code = paste0("NL",Date)
    ) %>% 
    filter(!(Sex == "UNK" & Value == 0),
           !(Age == "UNK" & Value == 0)) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

  
# bind and sort:

out <- 
  bind_rows(Cases, Deaths) %>%
  mutate(date_f = dmy(Date)) %>% 
  filter(date_f >= dmy("01.03.2020")) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################

write_sheet(out, 
            ss = 'https://docs.google.com/spreadsheets/d/1OB-zNLIbC_fappgMv443PnTGsG97NMHiiehsprRkEpU/edit#gid=431079373', 
            sheet = "database")

############################################
#### uploading metadata to Google Drive ####
############################################

date_f <- Sys.Date()
d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

sheet_name <- paste0("NL", d, "cases&deaths")

meta <- drive_create(sheet_name, 
                     path = "https://drive.google.com/drive/folders/1rwemqsieh_PXe0Qj-6y4LlrQoCaq4SQp?usp=sharing", 
                     type = "spreadsheet",
                     overwrite = T)

write_sheet(NL, 
            ss = meta$id,
            sheet = "cases&deaths_sex_age")

sheet_delete(meta$id, "Sheet1")




#### to adjust later
#### escalate to totals from reports 

# # reports:
# library(pdftools)
# pdfs<- dir(here::here("Data/NL/Netherlands"))
# pdfs <- pdfs[grepl(pattern =".pdf",x=pdfs)]
# 
# # txt <- here::here("Data/NL/Netherlands",pdfs[1]) %>% pdf_text()
# 
# capture_table_3 <- function(path){
#   txt <- pdf_text(path)
#     # what date do we have?
#   dutch_months_short <- c("jan","feb","maa","apr","mei",
#                           "jun","jul","aug","sep","okt","nov","dec")
# 
#   # month<-lapply(dutch_months_short,function(x){
#   #   lapply(p1, grepl,pattern = x) %>% 
#   #     unlist()}) %>% 
#   #   data.frame() %>% 
#   #   colSums() %>% 
#   #   which.max()
#   
#   p1 <- capture.output(cat(txt[1]))
#   dline <-  p1 %>% lapply(grepl,pattern="10:00") %>% unlist() %>% which() %>% '['(1)
#   
#     parts <-
#       p1[dline] %>% 
#       gsub(pattern="Rijksinstituut voor Volksgezondheid en Milieu - RIVM ",replacement="")   %>% 
#       str_split(pattern = ",") %>% 
#       '[['(1) %>% 
#       '['(1) %>% 
#       str_split(pattern=" ") %>% 
#       '[['(1)
#     month <- sapply(dutch_months_short,grepl,x=parts[2]) 
#     if (sum(month) > 0){
#       Date  <- dmy(paste(parts[1],which(month),parts[3],sep="."))
#     } else {
#       Date <- dmy(parts)
#     }
#   if (all(is.na(Date))){
#     parts <- p1[dline] %>% str_split(pattern = " ") %>% unlist()
#     marker <- sapply(dutch_months_short,grepl,x=parts) %>% 
#       rowSums() %>% 
#       '>'(0) %>%
#       which()
#     day <- parts[marker-1]
#     month <- sapply(dutch_months_short,grepl,x=parts[marker]) %>% which()
#     year <- 2020
#     Date <- paste(day,month,year,sep=".") %>% dmy()
#   }
#   Date <- Date[!is.na(Date)]
# 
#   tab <- extract_tables(path, output = "data.frame")
#   cnames <- c("Leeftijdsgroep","Totaal","Overleden")
#   tab3i <- lapply(tab,function(X,cnames){
#     any(grepl(pattern="Leeftijdsgroep",colnames(X))) &
#       any(grepl(pattern="Totaal",colnames(X))) 
#   },cnames=cnames) %>% unlist() %>% which()
# 
#   if (length(tab3i) == 0){
#     tab <- extract_areas(path, output = "data.frame", method="stream")
#     tab3i <- lapply(tab, function(X){
#       any(grepl(pattern="Leeftijdsgroep",colnames(X))) &
#         any(grepl(pattern="Totaal",colnames(X))) 
#     }) %>% unlist() %>% which()
#   }
#   tab3      <- tab[[tab3i]]
#   agecol    <- grepl(pattern="Leeftijdsgroep",colnames(tab3)) %>% which()
#   casecol   <- grepl(pattern="Totaal",colnames(tab3)) %>% which()
#   deathcol  <- grepl(pattern="Overleden",colnames(tab3)) %>% which()
#   
#   tab3      <- tab3[,c(agecol,casecol,deathcol)]
#   colnames(tab3) <- c("AgeGroup","Cases","Deaths")
#   tab3$date <- Date
#   tab3
# }
# 
# 
# # THIS IS PARTIALLY INTERACTIVE!
# #
# tab3L <- list()
# for (i in 1:length(pdfs)){
#   cat(i,"\n")
#   tab3L[[i]] <- 
#     try(capture_table_3(path = here::here("Data/NL/Netherlands",pdfs[i])))
# }
# 
# tab3L %>% 
#   saveRDS(file="Data/NL/Netherlands/tab3L.rds")
# # 62, 57, 58, 59, 33
