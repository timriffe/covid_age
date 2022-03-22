library(here)
source(here("Automation/00_Functions_automation.R"))
library(aweek)
library(ISOweek)

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}
# info country and N drive address
ctr <- "Netherlands"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# this is specifically for the way NL records isoweeks
isoweek_to_date_hack <- function(ISOWEEK){
  WK <- ISOWEEK %% 100
  YR <- (ISOWEEK - WK) / 100 %>% as.integer()

  out <- as.aweek(paste0(YR, "-W", sprintf("%02d",WK), "-", 7)) %>%
    as.Date()

  out[out > today()] <- today()
  out
}

cases_url <- "https://data.rivm.nl/covid-19/COVID-19_casus_landelijk.csv"

NL <- read_delim(cases_url, delim = ";")

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
Cases1 <-
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
  group_by(Date_statistics, Sex, Age, Province) %>% 
  summarize(New = n()) %>% 
  ungroup() %>% 
  filter(!is.na(Province))

Cases_total <-
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
  mutate(Province = "All")

Cases1 <- rbind(Cases_total , Cases1) %>% 
  arrange(Date_statistics, Province, Sex, Age)

Cases_full <- 
  Cases1 %>% 
  expand(Province, Sex, Age, Date_statistics = dates_all) 

Cases2 <- 
  Cases_full %>% 
  left_join(Cases1, by = c("Sex","Age","Date_statistics", "Province")) %>% 
  replace_na(list(New = 0)) %>% 
  # tidyr::complete(Sex, Age, Date_statistics = dates_all, fill = list(New = 0)) %>% 
  arrange(Province, Sex, Age, Date_statistics) %>% 
  group_by(Province, Sex, Age) %>% 
  mutate(Value = cumsum(New)) %>% 
  ungroup() %>% 
  # filter(!(Sex == "UNK" & Value == 0),
  #        !(Age == "UNK" & Value == 0)) %>% 
  arrange(Province, Date_statistics, Sex, Age) %>% 
  select(date = Date_statistics,Region = Province, Sex, Age, Value) %>% 
  group_by(date, Sex) %>% 
  do(redistribute_under50(chunk = .data)) %>% 
  ungroup() %>% 
  mutate(Country = "Netherlands",
         #Region = Province,
         Date = paste(sprintf("%02d", day(date)),
                      sprintf("%02d", month(date)),
                      year(date), sep = "."),
         Code = case_when(
           Region == "All" ~ "NL",
           Region == "Drenthe" ~ "NL-DR",
           Region == "Flevoland" ~ "NL-FL",
           Region == "Fryslân" ~ "NL-FR",
           Region == "Gelderland" ~ "NL-GE",
           Region == "Groningen" ~ "NL-GR",
           Region == "Limburg" ~ "NL-LI",
           Region == "Noord-Brabant" ~ "NL-NB",
           Region == "Noord-Holland" ~ "NL-NH",
           Region == "Overijssel" ~ "NL-OV",
           Region == "Utrecht" ~ "NL-UT",
           Region == "Zeeland" ~ "NL-ZE",
           Region == "Zuid-Holland" ~ "NL-ZH"
                    ),
         Metric = "Count",
         Measure = "Cases",
         AgeInt = case_when(
           Age == "UNK" ~ NA_real_,
           Age == "90" ~ 15,
           TRUE ~ 10
         )) %>% 
  select(Country, Region, Code, Date, Sex,Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()
  
# Prepare Deaths:

# Assume Unknown Date of death is 1 week after Date_statistics
today_week <- str_sub(ISOweek(today()), 7, 8) %>% as.numeric()
all_dates <- ISOweek::ISOweek2date(c(paste0(2020, "-W", sprintf("%02d",(3:53)), "-7"), 
                                     paste0(2021, "-W", sprintf("%02d",(1:today_week)), "-7")))

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
  select(Region = Province, date, Sex, Age) %>% 
  group_by(Region, date,Sex,Age) %>% 
  summarize(Value = n()) %>% 
  ungroup() 
  
death_total <- Deaths %>% 
  group_by(date, Sex, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(Region = "All")
Deaths <- rbind(Deaths, death_total) 
  


death_full <- 
  Deaths %>% 
  expand(Region, Sex, Age, date) 

Deaths2 <- 
  death_full %>% 
  left_join(Deaths, by = c("Sex","Age","date", "Region")) %>% 
  replace_na(list(Value = 0)) %>% 
    arrange(Region,Sex,Age,date) %>% 
    group_by(Region,Sex,Age) %>% 
    mutate(Value = cumsum(Value)) %>% 
    ungroup() %>% 
    mutate(Country = "Netherlands",
           #Region = "All",
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
           Code = case_when(
             Region == "All" ~ "NL",
             Region == "Drenthe" ~ "NL-DR",
             Region == "Flevoland" ~ "NL-FL",
             Region == "Fryslân" ~ "NL-FR",
             Region == "Gelderland" ~ "NL-GE",
             Region == "Groningen" ~ "NL-GR",
             Region == "Limburg" ~ "NL-LI",
             Region == "Noord-Brabant" ~ "NL-NB",
             Region == "Noord-Holland" ~ "NL-NH",
             Region == "Overijssel" ~ "NL-OV",
             Region == "Utrecht" ~ "NL-UT",
             Region == "Zeeland" ~ "NL-ZE",
             Region == "Zuid-Holland" ~ "NL-ZH"
           )) %>% 
    filter(!(Sex == "UNK" & Value == 0),
           !(Age == "UNK" & Value == 0)) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


# bind and sort:

out <- 
  bind_rows(Cases2, Deaths2) %>%
  mutate(date_f = dmy(Date)) %>% 
  filter(date_f >= dmy("01.03.2020")) %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### uploading database to Google Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out))

############################################
#### uploading metadata to Google Drive ####
############################################

data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&deaths_",today(), ".csv")

download.file(cases_url, destfile = data_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)



# end!








# out %>% 
#   mutate(Date = dmy(Date)) %>% 
#   filter(Measure == "Deaths") %>% 
#   group_by(Date) %>% 
#   summarize(N = sum(Value)) %>% 
#   ggplot(aes(x=Date, y = N)) + 
#   geom_line()


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
