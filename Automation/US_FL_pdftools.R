rm(list=ls())
library(pdftools)
library(tidyverse)
library(lubridate)
library(googlesheets4)

##########################
# Extracting data from pdf
##########################

# this is a View-permission link for the pdf:
#https://drive.google.com/file/d/1IsUEu4oTK7CDIzECCly6456XjMCZcHLh/view?usp=sharing
# you should download this file and refer to it for the following:

name_pdf <- "covid-19-data---daily-report-2020-05-02-0953"
pdf_file <- here::here(paste0(name_pdf, ".pdf"))

txt <- pdf_text(pdf_file)

# pages of pdf document containing cases and deaths
deaths_start <- 31
deaths_end   <- 55
cases_start  <- 56
cases_end    <- 629
# cases_end <- 150

# calibrate######
# p <- 157
# test <- capture.output(cat(txt[p]))
# i <- 17
# test[i]
# str_count(test[i])
# pos <- str_locate(test[i], "/../")[1,1]
# pos_m <- str_locate(test[i], "Male")[1,1] %>% replace_na(0)
# pos_f <- str_locate(test[i], "Female")[1,1] %>% replace_na(0)
# pos_sex <- pos_m + pos_f
# str_sub(test[i], c(1, pos_sex - 6, pos_sex, pos-2), c(6, pos_sex - 4, pos_sex + 6, pos+5))
#######

fu <- function(x){
  pos <- str_locate(x, "/../")[1,1]
  pos_sex <- str_locate(x, "Male")[1,1] %>% replace_na(0) + 
    str_locate(x, "Female")[1,1] %>% replace_na(0)
  pos_sex <- ifelse(pos_sex == 0, str_locate(x, "Unknown")[1,1], pos_sex)
  str_sub(x, c(1, pos_sex - 6, pos_sex, pos-2), c(6, pos_sex - 4, pos_sex + 6, pos+5))
}

deaths <- NULL
for (p in deaths_start : deaths_end){
  test <- txt[p]
  test3 <- capture.output(cat(test))
  line1 <- lapply(test3, fu)
  # i <- 1
  for (i in 1:length(line1)) {
    
    last <- length(line1[[i]])
    temp <- tibble(case = line1[[i]][1], 
                   age = line1[[i]][2], 
                   gender = line1[[i]][3], 
                   date = line1[[i]][4])
    
    deaths <- bind_rows(deaths, temp)
  }  
}

deaths2 <- deaths %>% 
  mutate(case = str_replace(case, ",", ""),
         case = as.numeric(case)) %>% 
  filter(!(is.na(case)))

unique(deaths2$gender)
unique(deaths2$age)
unique(deaths2$date)

##### cases

# calibrate #####
test <- txt[57]
test3 <- capture.output(cat(test))
test3[8]
str_count(test3[10])
str_sub(test3[15], c(1, 21, 27, 88), c(6, 23, 32, 95))

d1 <- str_count(test3[10]) - 8 ; d2 <- str_count(test3[10]) - 1
str_sub(test3[10], c(1, 25, 32, d1), c(6, 27, 37, d2))
lapply(test3, fu)


str_sub(test3[10], c(1, 21, 27, 95), c(7, 23, 32, 103))

#######

sep_cas <- function(x){
  pos <- str_locate(x, "/../")[1,1]
  pos_sex <- str_locate(x, "Male")[1,1] %>% replace_na(0) + 
    str_locate(x, "Female")[1,1] %>% replace_na(0)
  pos_sex <- ifelse(pos_sex == 0, str_locate(x, "Unknown")[1,1], pos_sex)
  str_sub(x, c(1, pos_sex - 6, pos_sex, pos - 2), c(7, pos_sex - 1, pos_sex + 6, pos + 5))
}

cases <- NULL  
for (p in cases_start : cases_end){
  test <- txt[p]
  test3 <- capture.output(cat(test))
  # line1 <- strsplit(test3[1:length(test3)], "\\s{2,}")
  line1 <- lapply(test3, sep_cas)
  # i <- 1
  for (i in 1:length(line1)) {
    
    last <- length(line1[[i]])
    temp <- tibble(case = line1[[i]][1], 
                   age = line1[[i]][2], 
                   gender = line1[[i]][3], 
                   date = line1[[i]][4])
    
    cases <- bind_rows(cases, temp)
  }  
}

cases2 <- cases %>% 
  mutate(case = str_replace(case, ",", ""),
         case = as.numeric(case)) %>% 
  filter(!(is.na(case))) 

unique(cases2$gender)
unique(cases2$date)
unique(cases2$age)

############################
# constructing daily reports 
############################

deaths3 <- deaths2 %>% 
  mutate(Value = 1,
         Age = as.numeric(age),
         Sex = case_when(gender == "Female " ~ "f",
                         gender == "Male   " ~ "m",
                         TRUE ~ "UNK"),
         date_f = mdy(date),
         Measure = "Deaths") %>% 
  select(Age, Sex, date_f, Measure, Value) 

unique(deaths3$date_f)

cases3 <- cases2 %>% 
  mutate(Value = 1,
         Age = as.numeric(age),
         Sex = case_when(gender == "Female " ~ "f",
                         gender == "Male   " ~ "m",
                         TRUE ~ "UNK"),
         date_f = mdy(date),
         Measure = "Cases") %>% 
  select(Age, Sex, date_f, Measure, Value) 

unique(cases3$Age)
unique(cases3$Sex)
unique(cases3$date_f)

db1 <- bind_rows(deaths3, cases3) %>% 
  mutate(Age = ifelse(Age > 100, 100, Age),
         Age = as.character(Age)) 

empty_db <- expand_grid(Sex = c("f", "m"),
                        Measure = c("Cases", "Deaths"),
                        Age = as.character(seq(0, 100, 1)))%>%
  bind_rows(expand_grid(Sex = c("f", "m", "b"),
                        Age = "TOT",
                        Measure = c("Cases", "Deaths")))

db_all <- NULL
min(db1$date_f)
date_start <- dmy("20/03/2020")
date_end <- max(db1$date_f)

ref <- date_start

while (ref <= date_end){
  
  db2 <- db1 %>% 
    filter(date_f <= ref) %>% 
    group_by(Age, Sex, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() 
  
  db3 <- db2 %>% 
    group_by(Measure, Sex) %>% 
    summarise(Value = sum(Value))%>% 
    mutate(Age = "TOT")
  
  db4 <- db2 %>% 
    group_by(Measure) %>% 
    summarise(Value = sum(Value))%>% 
    mutate(Sex = "b", Age = "TOT")
  
  db5 <- bind_rows(db2, db3, db4) %>%
    ungroup()
  
  db6 <- empty_db %>%
    left_join(db5) %>%
    mutate(date_f = ref,
           Value = replace_na(Value, 0))
  
  db_all <- bind_rows(db_all, db6)
  
  ref = ref + 1
}  

db_florida <- db_all %>%
  mutate(Region = "Florida",
         Date = paste(sprintf("%02d", day(date_f)),
                      sprintf("%02d", month(date_f)),
                      year(date_f), sep = "."),
         Country = "US",
         Code = paste0("US_FL_", Date),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            Age == 100 ~ 5,
                            TRUE ~ 1),
         Metric = "Count") %>% 
  arrange(date_f, Sex, Measure, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

db_florida %>% 
  filter(Date == "02.05.2020",
         Sex == "b") %>% 
  select(Metric, Value)


# Finally, push the database to Drive
write_sheet(db_florida,
            ss = "https://docs.google.com/spreadsheets/BIG_UGLY_LINK_TO_THE_DRIVE_TEMPLATE",
            sheet = "database")

