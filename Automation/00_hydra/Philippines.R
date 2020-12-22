source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(tidyverse)
library(googlesheets4)
library(googledrive)
library(lubridate)
library(readr)
library(rvest)
library(longurl)
library(pdftools)

# info country and N drive address
ctr    <- "Philippines"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
PH_dir <- paste0(dir_n, "Data_sources/", ctr, "/")

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

bit.ly_url <- "bit.ly/DataDropPH"

# these auth keys given in the package documentation...
# no idea if it's problematic to use them or not.

drive_readme_url <- longurl::expand_urls(bit.ly_url)

# Download the README pdf that contains the link!
drive_id_shorter <- drive_readme_url$expanded_url %>% 
  gsub(pattern = "https://drive.google.com/drive/folders/",
       replacement = "") %>% 
  gsub(pattern = "?usp=sharing",
       replacement = "") %>% 
  googledrive::as_id() %>% 
  drive_ls() %>% 
  filter(grepl(name,pattern = "READ ME FIRST")) %>% 
  drive_download(path = "Data/PH_README.pdf",
                 overwrite=TRUE)

# read as text ()
PDF_TEXT <- pdf_text("Data/PH_README.pdf")
PAGE     <- PDF_TEXT[grepl(PDF_TEXT,pattern = "bit.ly/")] 
LINES <- capture.output(cat(PAGE)) %>% 
  gsub(pattern =" ", replacement = "") %>% 
  gsub(pattern = "\r", replacement = "")
ind <- which(grepl(LINES, pattern = "LinktoDOHDataDrop"))+ 1

folder_bitly_url <- LINES[ind]
# folder_bitly_url <- PAGE[grepl(PAGE,pattern="https://bit")] %>% 
#   gsub(pattern = "https://", replacement = "") %>% 
#   gsub(pattern = "\r",replacement= "")

drive_folder_url <- longurl::expand_urls(folder_bitly_url)


# Drive info for all folder contents
drive_contents <-
  drive_folder_url$expanded_url %>% 
  gsub(pattern = "https://drive.google.com/drive/folders/",
       replacement = "") %>% 
  gsub(pattern = "?usp=sharing",
       replacement = "") %>% 
  googledrive::as_id() %>% 
  drive_ls() 

# Drive info for Case file
case_url <-
  drive_contents %>% 
  filter(grepl(name, pattern="04 Case Information"))

# Drive info for Test file
tests_url <-
  drive_contents %>% 
  filter(grepl(name, pattern="07 Testing"))

# Download Cases
case_url %>% 
  drive_download(path = "Data/PH_Cases.csv",
                 overwrite = TRUE)
# Download Tests
tests_url %>% 
  drive_download(path = "Data/PH_Tests.csv",
                 overwrite = TRUE)


# Check for updates: open xlsx in drive, convert to google docs, then copy url here
      # https://ncovtracker.doh.gov.ph/

# 12.07.2020 New procedure:
# instead of an excel with tabs, each tab is delivered as a csv in Drive.
# could download as such and read with read_csv(), or convert to sheets and do the same
# as before. Here with the manual download:

IN <- read_csv("Data/PH_Cases.csv")

# IN$DateRepConf %>% range()
# IN$DateDied %>% range(na.rm=TRUE)

fromto1 <- IN %>% dplyr::pull(DateRepConf) %>% range() %>% as_date()
fromto2 <- IN %>% dplyr::pull(DateResultRelease) %>% range(na.rm=TRUE) %>% as_date()
fromto3 <- IN %>% dplyr::pull(DateSpecimen) %>% range(na.rm=TRUE) %>% as_date()
fromto4 <- IN %>% dplyr::pull(DateOnset) %>% range(na.rm=TRUE) %>% as_date()
fromto  <- range(fromto1, fromto2, fromto3, fromto4)

dates  <- seq(fromto[1], fromto[2], by = "days")
ages   <- 0:100
maxA   <- max(ages)
ages   <- c(as.character(ages),"UNK")

Cases <- IN %>% 
  mutate(DateRepConf = as_date(DateRepConf),
         DateResultRelease = as_date(DateResultRelease),
         DateSpecimen = as_date(DateSpecimen),
         DateOnset = as_date(DateOnset),
         Date = DateRepConf,
         Date = ifelse(DateResultRelease < Date & !is.na(DateResultRelease),DateResultRelease,Date),
         Date = ifelse(DateSpecimen < Date & !is.na(DateSpecimen),DateSpecimen,Date),
         Date = ifelse(DateOnset < Date & !is.na(DateOnset),DateOnset,Date),
         Date = as_date(Date),
         Age = ifelse(is.na(Age),"UNK",Age),
         Age = ifelse(Age %in% as.character(100:120),"100",Age),
         Sex = case_when(Sex == "MALE"~"m",
                         Sex == "FEMALE" ~"f",
                         TRUE ~ Sex),
         Sex = ifelse(is.na(Sex), "UNK", Sex)) %>% 
  select(Age, Sex, Date) %>%
  group_by(Date, Age, Sex) %>% 
  summarize(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date = dates, Age = ages, Sex, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  arrange(Date,Sex,Age) %>% 
  mutate(Country = "Philippines",
         Region = "All",
           Date = paste(sprintf("%02d",day(Date)),    
                        sprintf("%02d",month(Date)),  
                        year(Date),sep="."),
         Code = paste0("PH", Date),
         Metric = "Count",
         Measure = "Cases",
         AgeInt = ifelse(Age == as.character(maxA), as.character(105 - maxA), 1),
         Age = ifelse(is.na(Age),"UNK",Age),
         AgeInt = ifelse(Age == "UNK",NA,AgeInt),
         AgeInt = suppressWarnings(as.integer(AgeInt))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()



# Different date range for deaths

fromto <- IN %>% dplyr::pull(DateDied) %>% range(na.rm=TRUE) %>% as_date()
dates  <- seq(fromto[1], fromto[2], by = "days")

maxAi<- max(suppressWarnings(as.integer(ages)),na.rm=TRUE) 
maxAc<- as.character(maxAi)
Deaths <- IN %>% 
  filter(!is.na(DateDied)) %>% 
  mutate(Date = as_date(DateDied),
         Age = ifelse(is.na(Age),"UNK",Age),
         Age = ifelse(Age %in% as.character(100:120),"100",Age),
         Sex = case_when(Sex == "MALE"~"m",
                         Sex == "FEMALE" ~"f",
                         TRUE ~ Sex),
         Sex = ifelse(is.na(Sex), "UNK", Sex)) %>% 
  select(Age, Sex, Date) %>% 
  group_by(Date, Age, Sex) %>% 
  summarize(Value = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Date = dates, Age = ages, Sex, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>% 
  arrange(Date,Sex,Age) %>% 
  mutate(Country = "Philippines",
         Region = "All",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("PH", Date),
         Metric = "Count",
         Measure = "Deaths",
         AgeInt = ifelse(Age == maxAc, 
                         105 - maxAi, 1),
         Age = ifelse(is.na(Age),"UNK",as.character(Age)),
         AgeInt = ifelse(Age == "UNK",NA,AgeInt),
         AgeInt = suppressWarnings(as.integer(AgeInt))) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#TESTS <- read_sheet(ss, sheet = "Sheet6", col_types = "cDiiiiiiiiiiiiiic")
TESTS <- read_csv("Data/PH_Tests.csv")
Tests <- 
  TESTS %>% 
  group_by(report_date) %>% 
  summarize(Value = sum(cumulative_samples_tested)) %>% 
  mutate(Date = paste(sprintf("%02d",day(report_date)),    
                      sprintf("%02d",month(report_date)),  
                      year(report_date),sep="."),
         Country = "Philippines",
         Region = "All",
         Metric = "Count",
         Measure = "Tests",
         AgeInt = NA,
         Sex = "b",
         Age = "TOT",
         Code = paste0("PH",Date)) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
out <-
  rbind(Deaths,Cases,Tests) %>% 
  sort_input_data()

out <-
  out %>% 
  filter(!(Age == "UNK" & Value == 0),
         !(Sex == "UNK" & Value == 0))

############################################
#### save out to N                      ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

N <- nrow(out)
log_update(pp = "Philippines", N = N)

############################################
### save artifacts                       ###
############################################
files <- c("Data/PH_Cases.csv","Data/PH_Tests.csv","Data/PH_README.pdf")
#ex_files <- c(paste0(PH_dir, files))

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname,
     files = files, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

file.remove(files)


# --------------------------------------------------
# Make graphs
do.this <- FALSE
if (do.this){
 out %>% 
   filter(Measure == "Cases") %>% 
   mutate(Date = dmy(Date)) %>% 
   group_by(Date) %>% 
   summarize(N = sum(Value)) %>% 
   ggplot(aes(x = Date,y = N)) + geom_line()

 out %>% 
   filter(Measure == "Deaths") %>% 
   mutate(Date = dmy(Date)) %>% 
   group_by(Date) %>% 
   summarize(N = sum(Value)) %>% 
   ggplot(aes(x = Date,y = N)) + geom_line()
 
 out %>% 
   filter(Measure%in%c("Cases","Deaths")) %>% 
   mutate(Date = dmy(Date),
          Agei = as.integer(Age)) %>% 
   filter(!is.na(Agei)) %>% 
   mutate(Age20 = Agei - Agei %% 20) %>% 
   group_by(Date, Age20, Measure) %>% 
   summarize(N = sum(Value)) %>% 
   pivot_wider(names_from=Measure, values_from=N) %>% 
   filter(Deaths > 5) %>% 
   ggplot(aes(x = Cases,y = Deaths,color=as.factor(Age20),group=Age20)) + 
   geom_line()+
   scale_x_log10()+
   scale_y_log10()
 

  
 library(colorspace)
 out %>% 
   filter(Measure == "Cases",
          Age != "TOT",
          Age != "UNK") %>% 
   mutate(Date = dmy(Date),
          Agei = as.integer(Age),
          Age20 = Agei - Agei %% 20) %>% 
   group_by(Date, Age20) %>% 
   summarize(Value = sum(Value)) %>% 
   group_by(Date) %>% 
   mutate(N = sum(Value),
          Frac = Value / N) %>% 
   ungroup() %>% 
   ggplot(aes(x = Date,
              y = Frac, 
              fill = as.factor(Age20))) + 
   geom_area() + 
   scale_fill_discrete_sequential("Emrld")
 
# same for NEW cases
   out %>% 
     filter(Measure == "Cases",
            Age != "TOT",
            Age != "UNK") %>% 
     mutate(Date = dmy(Date),
            Agei = as.integer(Age),
            Age20 = Agei - Agei %% 20) %>% 
     group_by(Date, Age20) %>% 
     summarize(Value = sum(Value)) %>% 
     group_by(Age20) %>% 
     arrange(Date) %>% 
     mutate(New = Value - lead(Value)) %>% 
     ungroup() %>% 
     filter(Date >= dmy("15.04.2020")) %>% 
     group_by(Date) %>% 
     mutate(N = sum(New),
            Frac = New / N) %>% 
     ungroup() %>% 
     ggplot(aes(x = Date,
                y = Frac, 
                fill = as.factor(Age20))) + 
     geom_area() + 
     scale_fill_discrete_sequential("Emrld")
   
   
out %>% 
  filter(Measure %in% c("Cases","Deaths")) %>% 
  mutate(
    Agei = as.integer(Age),
    Age5 = Agei - Agei %% 5) %>% 
  group_by(Date, Age5, Measure) %>% 
  summarize(Value = sum(Value)) %>% 
  ungroup() %>% 
  pivot_wider(names_from=Measure, values_from=Value) %>% 
  mutate(ASCFR = Deaths / Cases) %>% 
  filter(dmy(Date) >= dmy("01.05.2020")) %>% 
  ggplot(aes(x = Age5, y = ASCFR, color = dmy(Date), group = Date)) + 
  geom_line()

}
