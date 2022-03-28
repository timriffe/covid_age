library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "CA_Ontario"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#--------- input files -------------------------------------#
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_and_deaths",today(), ".csv")
data_source_t <- paste0(dir_n, "Data_sources/", ctr, "/tests",today(), ".csv")

# case and death data
url <- "https://data.ontario.ca/dataset/f4112442-bdc8-45d2-be3c-12efae72fb27/resource/455fd63b-603d-4608-8216-7d8647f43350/download/conposcovidloc.csv"
# testing data
url_test <- "https://data.ontario.ca/dataset/f4f86e54-872d-43f8-8a86-3892fd3cb5e6/resource/ed270bb8-340b-41f9-a7c6-e8ef587e6d11/download/covidtesting.csv"


#-------saving input files locally and to Drive

download.file(url, destfile = data_source_c)
download.file(url_test, destfile = data_source_t)
# loading data
df <- read_csv(data_source_c)
df_test <- read_csv(data_source_t)

# compressing files and deleting original files
data_source <- c(data_source_c, data_source_t)

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
#file.remove(data_source)


#-------there are often date problems...checking...first case should be Jan 21, 2020
range(df$Accurate_Episode_Date)

#------- If the episode date is before Jan 21, 2020 - changing to case reported date
df_dated <-  df %>%
  mutate(Date=if_else(Accurate_Episode_Date < ymd("2020-01-22"), 
                      Case_Reported_Date, 
                      Accurate_Episode_Date))

#----------------------------------------------

date <- max(df_dated$Accurate_Episode_Date) %>% format.Date("%d.%m.%Y")





#--------------------------------------------
#--------Preparing cases and deaths
#--------------------------------------------

#------renaming variables
df <- df_dated

df$Outcome1 <- ifelse(df$Outcome1=="Fatal","Deaths","Cases")

df$Age_Group <- ifelse(df$Age_Group=="<20",0,
                       ifelse(df$Age_Group=="20s",20,
                              ifelse(df$Age_Group=="30s",30,
                                     ifelse(df$Age_Group=="40s",40,
                                            ifelse(df$Age_Group=="50s",50,
                                                   ifelse(df$Age_Group=="60s",60,
                                                          ifelse(df$Age_Group=="70s",70,
                                                                 ifelse(df$Age_Group=="80s",80,
                                                                        ifelse(df$Age_Group=="90+",90,"unknown")))))))))

df$Client_Gender <-  ifelse(df$Client_Gender=="FEMALE","f",
                            ifelse(df$Client_Gender=="MALE","m","oth"))                                   

#------------------------------------

# calculating the cumulative cases and cumulative deaths

df1 <- df %>%
  group_by(Date, Age_Group, Client_Gender, Outcome1) %>%
  count(Outcome1) %>%
  rename(Reported_Date=Date, 
         Sex=Client_Gender,
         Age=Age_Group,
         Daily_Cases=n,
         Measure=Outcome1) %>%   
  arrange(Sex,Age,Reported_Date) 

# Filling in zeroes over ages where there are no cases

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

Agedf <- data.frame(Age=c(0,20,30,40,50,60,70,80,90,"TOT"),
                    AgeInt=rep(c(20,rep(10,7),15,"")))

df6 <- left_join(df5,Agedf) 

df6$Reported_Date <- df6$Reported_Date %>% format.Date("%d.%m.%Y")


# finalizing the case&death data frame

Cases_Deaths_df <- df6 %>%
  mutate(Country="Canada", Region="Ontario", Metric="Count") %>%
  rename(Date=Reported_Date) %>%
  mutate(Code=paste("CA-ON")) %>%
  select(Country,Region,Code,Date,Sex,Age,AgeInt,Metric,Measure,Value)  

# write.csv(Cases_Deaths_df,paste("C:\\covid_ON\\output_data\\CA_ON",date,"_case_death_output.csv",sep=""),row.names=F)


# they created a testing csv on 15.02 which displays new tests 
# the # of tests up to 14.02 was 113082 source: https://www.ontario.ca/page/2019-novel-coronavirus 
# this website has now been taken down.

#--- On 05.06 they changed the variable names
cumtests <- df_test %>%
  rename(new_tests="Total tests completed in the last day") %>%
  select("Reported Date", new_tests) %>%
  filter(is.na(new_tests)==F) %>%
  mutate(Value=113082+cumsum(new_tests)) %>%
  mutate(Country="Canada", Region="Ontario", Metric="Count", Measure="Tests") %>%
  mutate(Sex="b", Age="TOT",AgeInt="") %>%
  rename(Date="Reported Date")

# -- Around Christmas 2020 they changed the date format - then changed it back after New Year 2021
cumtests$Date <- parse_date_time(cumtests$Date,"ymd") %>% format.Date("%d.%m.%Y")
#cumtests$Date <- parse_date_time(cumtests$Date,"%m/%d/%Y") %>% format.Date("%d.%m.%Y")


Date <- cumtests$Date[dim(cumtests)[1]]

Tests_df <- cumtests %>%
  mutate(Code=paste("CA-ON")) %>%
  select(Country,Region,Code,Date,Sex,Age,AgeInt,Metric,Measure,Value)    

# write.csv(Tests_df,paste("C:\\covid_ON\\output_data\\CA_ON",date,"_tests_output.csv",sep="."),row.names=F)


#-----------------------------------------------------------------------------------
# binding the cases, tests, and deaths


# then stick together
out <- 
  bind_rows(Cases_Deaths_df, Tests_df) %>% 
  sort_input_data()

# then push:
head(out)
tail(out)

# ss <-"https://docs.google.com/spreadsheets/d/1TWXNqa7PAe5nwFabS6ZUf_ToxuaVQPFBSUdZ1DZKXug/edit#gid=1079196673"
# write_sheet(outgoing, ss = ss, sheet = "database")



# saving the csv
############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

