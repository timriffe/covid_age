# AB covid data

rm(list=ls())

library(tidyverse)
library(xml2)
library(rvest)
library(lubridate)
library(googlesheets4) 
library(googledrive)


options(stringsAsFactors = F)


#---------------------------- Reading in the historic tests from google docs

ss <-"https://docs.google.com/spreadsheets/d/13UgFiuvTd3NJ60NDZwfgYzDK6WqYniL8K5xishu-xIM/edit#gid=0"

# reading in the old data
incoming <- read_sheet(ss, sheet = "database", col_types = "cccccccccd")

# --- grabbing the historic tests
Historic_Tests <- incoming %>% filter(Measure == "Tests") 


#----------------------------- Preparing case histories & testing data

#--------- Downloading data

df <- read_csv("https://www.alberta.ca/data/stats/covid-19-alberta-statistics-data.csv")


df$`Date reported` = ymd(df$`Date reported`)
date <- Sys.Date() %>% format.Date("%d.%m.%Y")


#------------ age-specific testing data

# Scrape a table from the website using Rvest

url <- "https://covid19stats.alberta.ca"

page <- url %>% read_html() 
tables <- page %>% html_nodes('table') 

# unfortunately the table format is messy because of the header rows containing merged cells,
# so instead I just pull the rows themselves
# update 10.06.2020 - they changed the table #.
# update 24.11.2020 - they changed the table #.
# update 27.11.2020 - they changed the table # and added gender X.

rows <- tables[9] %>% html_nodes('tr') 
#rows <- tables[8] %>% html_nodes('tr') 

# remove rows which do not have the full number of rows (i.e. header rows with merged cells) 
#rows <- rows[-which(sapply(rows, function(x){length(html_children(x))}) != 9)]

rows <- rows[4:16]

# convert to text
values <- rows %>% html_nodes('td') %>% html_text() %>% trimws()

# create data frame
df1 <- as.data.frame(matrix(values, ncol = 8, byrow=TRUE)) 
#df1 <- as.data.frame(matrix(values, ncol = 10, byrow=TRUE)) # updated Nov 27 b/c gender X

# taking the columns we need, removing tests of unknown age (row 12) which is implicit in TOT, and 
# getting rid of the comma separting the 1000s

female_tests <- as.numeric(gsub("," ,"", df1$V1[-12]))  
male_tests <-   as.numeric(gsub("," ,"", df1$V3[-12]))  
both_tests <-   as.numeric(gsub("," ,"", df1$V7[-12]))  
#both_tests <-   as.numeric(gsub("," ,"", df1$V9[-12]))  # updated Nov 27 b/c gender X

# create new data frame in long format
Age <- c(0,1,5,seq(10,80,10),"TOT")
test_df <- tibble(Country="Canada",Region="Alberta",
                  Code=paste("CA_AB",date,sep=""),
                  Date=date,
                  Sex=rep(c("f","m","b"),each=12),
                  Age=rep(Age,3),
                  AgeInt=rep(c(1,4,5,rep(10,7),25,""),3),
                  Metric="Count",
                  Measure="Tests",
                  Value=c(female_tests,male_tests,both_tests))                   
test_df

# saving case and test files locally

write.csv(df,paste("C:\\covid_AB\\input_data\\cases_deaths_",date,".csv",sep=""),row.names=F)
write.csv(test_df,paste("C:\\covid_AB\\input_data\\tests_",date,".csv",sep=""),row.names=F)


# pushing all input data to Google Drive


AB_drive <- "https://drive.google.com/drive/folders/1-cLqGWiuOGisqwdSzkM6zAJIs91cxC3s"

drive_upload(
  paste("C:\\covid_AB\\input_data\\cases_deaths_",date,".csv",sep=""),
  path = AB_drive,
  name = paste("CA_AB",date,"_cases&deaths.csv",sep=""),
  type = "spreadsheet",
  overwrite = T,
  verbose = TRUE
)


drive_upload(
  paste("C:\\covid_AB\\input_data\\tests_",date,".csv",sep=""),
  path = AB_drive,
  name = paste("CA_AB",date,"_tests.csv",sep=""),
  type = "spreadsheet",
  overwrite = F,
  verbose = TRUE
)



#-------------------------------------------------------------------------------------
# calculating the cumulative cases and cumulative deaths
#-------------------------------------------------------------------------------------

# cleaning

df$'Case status' <- ifelse(df$'Case status'=="Died","Deaths","Cases")

df$'Age group' <- ifelse(df$'Age group'=="Under 1 year",0,
                         ifelse(df$'Age group'=="1-4 years",1,
                                ifelse(df$'Age group'=="5-9 years",5,
                                       ifelse(df$'Age group'=="10-19 years",10,
                                              ifelse(df$'Age group'=="20-29 years",20,
                                                     ifelse(df$'Age group'=="30-39 years",30,
                                                            ifelse(df$'Age group'=="40-49 years",40,
                                                                   ifelse(df$'Age group'=="50-59 years",50,
                                                                          ifelse(df$'Age group'=="60-69 years",60,
                                                                                 ifelse(df$'Age group'=="70-79 years",70,
                                                                                        ifelse(df$'Age group'=="80+ years",80,"unknown")))))))))))

df$Gender <-  ifelse(df$Gender=="Female","f",
                     ifelse(df$Gender=="Male","m","oth"))                                       




df1 <- df %>%
  rename(Reported_Date='Date reported', 
         Sex=Gender,
         Age='Age group',
         Measure='Case status') %>%
  group_by(Reported_Date,Age,Sex,Measure) %>%  
  count(Measure) %>%  
  rename(Daily_Cases=n)


df1_template <- expand.grid(Reported_Date=sort(unique(df1$Reported_Date)),
                            Sex=c('m','f','oth'),
                            Age=unique(df1$Age),
                            Measure=c("Cases","Deaths")) %>%
  arrange(Reported_Date,Sex,Age)

df1_full <- left_join(df1_template,df1) %>% 
  replace_na(list(Daily_Cases = 0))

# Making a 'Value' column with cumulative cases

df1_cum <- df1_full %>%
  group_by(Sex,Age,Measure) %>%
  mutate(Value=cumsum(Daily_Cases)) %>%
  ungroup() 

# counts for both sexes combined

df2 <- df1_cum %>%
  group_by(Reported_Date,Measure,Age) %>%
  summarize(Value=sum(Value,na.rm=T)) %>%
  mutate(Sex='b') 

# merging the sex-specific and all sex dataframes 

df3 <- bind_rows(df1_cum,df2)  %>%
  filter(Sex!="oth") %>%
  arrange(Reported_Date,Sex,Measure,Age) %>%
  select(Reported_Date,Sex,Age,Value,Measure) 

# summing over age

df4 <- df3 %>% 
  group_by(Reported_Date,Sex,Measure) %>%
  summarize(Value=sum(Value, na.rm=T)) %>%
  mutate(Age="TOT") 


# adding total counts over all ages
df5 <- bind_rows(df3,df4) %>% 
  filter(Age!="unknown") %>% 
  arrange(Reported_Date,desc(Sex),Age)


# adding AgeInt column and changing Reported_Date to German format 

Agedf <- data.frame(Age=c(0,1,5,10,20,30,40,50,60,70,80,"TOT"),
                    AgeInt=c(1,4,5,rep(10,7),25,""))

df6 <- left_join(df5,Agedf) 

df6$Reported_Date <- df6$Reported_Date %>% format.Date("%d.%m.%Y")


# finalizing the case&death data frame

Cases_Deaths_df <- df6 %>%
  mutate(Country="Canada", Region="Alberta", Metric="Count") %>%
  rename(Date=Reported_Date) %>%
  mutate(Code=paste("CA_AB",Date,sep="")) %>%
  select(Country,Region,Code,Date,Sex,Age,AgeInt,Metric,Measure,Value)    


# gathering all the stuff

#Historic_Tests <- filter(Historic_Tests,Date!="24.05.2020")

new_tests <- test_df
old_tests <- Historic_Tests
tests <- bind_rows(old_tests,new_tests) 

# then sticking together
outgoing <- 
  bind_rows(Cases_Deaths_df,tests) %>% 
  mutate(date = dmy(Date), ageg=as.integer(Age)) %>% 
  arrange(date, Measure, Sex, ageg) %>% 
  select(-date) %>%
  select(-ageg)


head(outgoing)
tail(outgoing)
tail(Cases_Deaths_df)


# pushing locally and to drive

write_sheet(outgoing, ss = ss, sheet = "database")
write.csv(outgoing,paste("C:\\covid_AB\\output_data\\",date,"AB.csv",sep="."),row.names=F)




