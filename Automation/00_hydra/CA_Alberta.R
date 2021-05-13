# AB covid data

# functions
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# info country and N drive address
ctr <- "CA_Alberta"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

options(stringsAsFactors = F)


#---------------------------- Reading in the historic tests from google docs

ss <-"https://docs.google.com/spreadsheets/d/13UgFiuvTd3NJ60NDZwfgYzDK6WqYniL8K5xishu-xIM/edit#gid=0"

# reading in the old data
incoming <- read_sheet(ss, sheet = "tests", col_types = "cccccccccd")

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

new_tests <- test_df
old_tests <- Historic_Tests
tests <- bind_rows(old_tests,new_tests) %>% 
  mutate(AgeInt = as.integer(AgeInt)) %>% 
  unique()


# saving case and test files locally in N

write_csv(df, paste0(dir_n, "Data_sources/", ctr, "/cases_deaths_",date,".csv"))
write_csv(test_df, paste0(dir_n, "Data_sources/", ctr, "/tests_",date,".csv"))

#-------------------------------------------------------------------------------------
# calculating the cumulative cases and cumulative deaths
#-------------------------------------------------------------------------------------

df2 <- 
  df %>% 
  rename(Age = 'Age group',
         status = 'Case status',
         date_f = 'Date reported',
         Sex = Gender) %>% 
  mutate(Age = str_sub(Age, 1, 2),
         Age = recode(Age,
                      "Un" = "0",
                      "1-" = "1",
                      "5-" = "5",
                      "80+" = "80",
                      "unknown" = "UNK"),
         Sex = case_when(Sex == "Female" ~ "f",
                            Sex == "Male" ~ "m",
                            TRUE ~ "UNK")) %>% 
  select(date_f, Sex, Age, status)
  
dates_f <- seq(min(df2$date_f), max(df2$date_f), by = '1 day')

cases <- 
  df2 %>% 
  group_by(date_f, Age, Sex) %>% 
  summarise(new = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Sex, Age, date_f = dates_f, fill = list(new = 0)) %>% 
  mutate(Measure = "Cases")

deaths <- 
  df2 %>% 
  filter(status == "Died") %>% 
  group_by(date_f, Age, Sex) %>% 
  summarise(new = n()) %>% 
  ungroup() %>% 
  tidyr::complete(Sex, Age, date_f = dates_f, fill = list(new = 0)) %>% 
  mutate(Measure = "Deaths")

df3 <- 
  bind_rows(deaths, cases) %>% 
  group_by(Sex, Age, Measure) %>% 
  mutate(Value = cumsum(new))

# summarising totals by age and sex in each date -----------------------------------
db_tot_age <- df3 %>% 
  group_by(date_f, Sex, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT")

db_tot_sex <- df3 %>% 
  group_by(date_f, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b")

db_tot <- df3 %>% 
  group_by(date_f, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b",
         Age = "TOT")


# starting date when at least 50 cases in all ages
date_start <- db_tot %>% 
  filter(Measure == "Cases",
         Value >= 50) %>% 
  dplyr::pull(date_f) %>% 
  min()

# appending all data in one database ----------------------------------------------
out <- 
  df3 %>% 
  bind_rows(db_tot_age, db_tot_sex, db_tot) %>% 
  filter(Sex != "UNK",
         Age != "UNK",
         date_f >= date_start) %>% 
  select(-new) %>% 
  arrange(date_f, Measure, Sex, Age) %>% 
  mutate(AgeInt = case_when(Age == "0" ~ 1,
                            Age == "1" ~ 4,
                            Age == "5" ~ 5,
                            Age == "TOT" ~ NA_real_,
                            TRUE ~ 10),
         Country = "Canada",
         Region = "Alberta",
         Date = ddmmyyyy(date_f),
         Code = paste0("CA_AB",Date),
         Metric = "Count") %>% 
  bind_rows(tests) %>% 
  sort_input_data()


head(out)
tail(out)

# pushing tests to Drive
# ~~~~~~~~~~~~~~~~~~~~~~
write_sheet(tests,
             ss = ss,
             sheet = "tests")

###########################
#### Saving data in N: ####
###########################
write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))


