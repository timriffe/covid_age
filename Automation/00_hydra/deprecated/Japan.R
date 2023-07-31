
# 1. Preamble ---------------

library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Japan"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



##previous data
db_drive <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  filter(Measure == "Cases")

## Source website <- "https://covid19.mhlw.go.jp/en/

#Weekly deaths since the start 

death <- read_csv("https://covid19.mhlw.go.jp/public/opendata/deaths_detail_cumulative_weekly.csv", skip = 1)

# death2 <- death %>% 
#   mutate(Week = sub("...........", "", Week))
#   #Date = ymd(Date))
# death2 <- death2[-1]
#death2 <- death2[-1]
death2 <- setDT(death) 

death2 <- melt(death2, id = c("Week"))

headers <- read.csv("https://covid19.mhlw.go.jp/public/opendata/deaths_detail_cumulative_weekly.csv", header = FALSE)
headers <- headers[1,]
headers <- reshape2::melt(headers, id = c("V1"))
headers <- headers %>% 
  filter(value != "") 
headers2 <- headers[rep(seq_len(nrow(headers)), each = (length(death2$Week)/48)), ]  # Base R
names(headers2)[3] <- "Region"
headers2 <- headers2[-c(1,2)]%>% 
  mutate(Region = case_when(
    Region == "ALL" ~ "All",
    TRUE ~ Region
  ))
death3 <- bind_cols(death2, headers2)

death4 <- death3 %>% 
  separate(variable, c("Sex","Age"), sep = (" ")) %>%  
  mutate(Age = substr(Age, 1, 3)) %>% 
  mutate(Age = case_when(Age == "Und" ~ 0,
                         Age == "10s" ~ 10,
                         Age == "20s" ~ 20,
                         Age == "30s" ~ 30,
                         Age == "40s" ~ 40,
                         Age == "50s" ~ 50,
                         Age == "60s" ~ 60,
                         Age == "70s" ~ 70,
                         Age == "80s" ~ 80,
                         Age == "Ove" ~ 90),
         Sex = case_when(Sex == "Female" ~ "f",
                                Sex == "Male" ~ "m"),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           TRUE ~ 10L),
         Country = "Japan",
         Measure = "Deaths",
         Metric = "Count") %>% 
  separate(Week, c("trash","Date"), sep = ("~")) %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."))
  

death4$Value <- as.numeric(death4$value)
death4[is.na(death4)] <- 0
death4 <- death4[,-c(1,5)]

#coding for regions need to be done
death5 <- death4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP-05",       
    Region=="All" ~ "JP",   
    Region=="Fukuoka" ~ "JP-40",   
    Region=="Fukushima" ~ "JP-07",       
    Region=="Gifu" ~ "JP-21",        
    Region=="Gunma" ~ "JP-10",    
    Region=="Hiroshima" ~ "JP-34",     
    Region=="Hokkaido" ~ "JP-01",      
    Region=="Ibaraki" ~ "JP-08",        
    Region=="Iwate" ~ "JP-03",       
    Region=="Kagawa" ~ "JP-37",     
    Region=="Kanagawa" ~ "JP-14",        
    Region=="Kochi" ~ "JP-39",     
    Region=="Kumamoto" ~ "JP-43",        
    Region=="Kyoto" ~ "JP-26",   
    Region=="Mie" ~ "JP-24",       
    Region=="Nagano" ~ "JP-20",         
    Region=="Nara" ~ "JP-29",      
    Region=="Niigata" ~ "JP-15",         
    Region=="Oita" ~ "JP-44",      
    Region=="Okayama" ~ "JP-33",      
    Region=="Okinawa" ~ "JP-47",         
    Region=="Saga" ~ "JP-41",      
    Region=="Saitama" ~ "JP-11",        
    Region=="Shiga" ~ "JP-25",      
    Region=="Shimane" ~ "JP-32",     
    Region=="Shizuoka" ~ "JP-22",      
    Region=="Tochigi" ~ "JP-09",        
    Region=="Tokyo" ~ "JP-13",      
    Region=="Tottori" ~ "JP-31",   
    Region=="Toyama" ~ "JP-16",     
    Region=="Wakayama" ~ "JP-30",    
    Region=="Yamaguchi" ~ "JP-35",    
    Region=="Yamanashi" ~ "JP-19",
    Region=="Miyagi" ~ "JP-04",
    Region=="Yamagata" ~ "JP-06",
    Region=="Chiba" ~ "JP-12",
    Region=="Ishikawa" ~ "JP-17",
    Region=="Fukui" ~ "JP-18",
    Region=="Aichi" ~ "JP-23",
    Region=="Osaka" ~ "JP-27",
    Region=="Hyogo" ~ "JP-28",
    Region=="Tokushima" ~ "JP-36",
    Region=="Ehime" ~ "JP-38",
    Region=="Nagasaki" ~ "JP-42",
    Region=="Miyazaki" ~ "JP-45",
    Region=="Kagoshima" ~ "JP-46",
    Region=="Aomori" ~ "JP-02"),
    Code = paste0(Code),
    Short = Code
  )
death5 <- death5[,-11]


# Weekly cases

cases <- read_csv("https://covid19.mhlw.go.jp/public/opendata/confirmed_cases_detail_cumulative_weekly.csv", skip = 1)
cases2 <- setDT(cases)
cases2 <- melt(cases2, id = c("Week"))
headers <- read.csv("https://covid19.mhlw.go.jp/public/opendata/confirmed_cases_detail_cumulative_weekly.csv", header = FALSE)
headers <- headers[1,]
headers <- reshape2::melt(headers, id = c("V1"))
headers <- headers %>% 
  filter(value != "")
headers2 <- headers[rep(seq_len(nrow(headers)), each = (length(cases2$Week)/48)), ]  # Base R
names(headers2)[3] <- "Region"
headers2 <- headers2[-c(1,2)]%>% 
  mutate(Region = case_when(
    Region == "ALL" ~ "All",
    TRUE ~ Region
  ))

cases3 <- bind_cols(cases2, headers2)

cases4 <- cases3 %>% 
  separate(variable, c("Sex","Age"), sep = (" ")) %>%  
  mutate(Age = substr(Age, 1, 3)) %>% 
  mutate(Age = case_when(Age == "Und" ~ 0,
                         Age == "10s" ~ 10,
                         Age == "20s" ~ 20,
                         Age == "30s" ~ 30,
                         Age == "40s" ~ 40,
                         Age == "50s" ~ 50,
                         Age == "60s" ~ 60,
                         Age == "70s" ~ 70,
                         Age == "80s" ~ 80,
                         Age == "Ove" ~ 90),
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m"),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           TRUE ~ 10L),
         Country = "Japan",
         Measure = "Cases",
         Metric = "Count") %>% 
  separate(Week, c("trash","Date"), sep = ("~")) %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."))


cases4$Value <- as.numeric(cases4$value)
cases4[is.na(cases4)] <- 0
cases4 <- cases4[,-c(1,5)]




#coding for regions need to be done
cases5 <- cases4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP-05",       
    Region=="All" ~ "JP",   
    Region=="Fukuoka" ~ "JP-40",   
    Region=="Fukushima" ~ "JP-07",       
    Region=="Gifu" ~ "JP-21",        
    Region=="Gunma" ~ "JP-10",    
    Region=="Hiroshima" ~ "JP-34",     
    Region=="Hokkaido" ~ "JP-01",      
    Region=="Ibaraki" ~ "JP-08",        
    Region=="Iwate" ~ "JP-03",       
    Region=="Kagawa" ~ "JP-37",     
    Region=="Kanagawa" ~ "JP-14",        
    Region=="Kochi" ~ "JP-39",     
    Region=="Kumamoto" ~ "JP-43",        
    Region=="Kyoto" ~ "JP-26",   
    Region=="Mie" ~ "JP-24",       
    Region=="Nagano" ~ "JP-20",         
    Region=="Nara" ~ "JP-29",      
    Region=="Niigata" ~ "JP-15",         
    Region=="Oita" ~ "JP-44",      
    Region=="Okayama" ~ "JP-33",      
    Region=="Okinawa" ~ "JP-47",         
    Region=="Saga" ~ "JP-41",      
    Region=="Saitama" ~ "JP-11",        
    Region=="Shiga" ~ "JP-25",      
    Region=="Shimane" ~ "JP-32",     
    Region=="Shizuoka" ~ "JP-22",      
    Region=="Tochigi" ~ "JP-09",        
    Region=="Tokyo" ~ "JP-13",      
    Region=="Tottori" ~ "JP-31",   
    Region=="Toyama" ~ "JP-16",     
    Region=="Wakayama" ~ "JP-30",    
    Region=="Yamaguchi" ~ "JP-35",    
    Region=="Yamanashi" ~ "JP-19",
    Region=="Miyagi" ~ "JP-04",
    Region=="Yamagata" ~ "JP-06",
    Region=="Chiba" ~ "JP-12",
    Region=="Ishikawa" ~ "JP-17",
    Region=="Fukui" ~ "JP-18",
    Region=="Aichi" ~ "JP-23",
    Region=="Osaka" ~ "JP-27",
    Region=="Hyogo" ~ "JP-28",
    Region=="Tokushima" ~ "JP-36",
    Region=="Ehime" ~ "JP-38",
    Region=="Nagasaki" ~ "JP-42",
    Region=="Miyazaki" ~ "JP-45",
    Region=="Kagoshima" ~ "JP-46",
    Region=="Aomori" ~ "JP-02"),
    Code = paste0(Code),
    Short = Code
  )
cases5 <- cases5[,-11]


##total cases
tot_cases <- read.csv("https://covid19.mhlw.go.jp/public/opendata/confirmed_cases_cumulative_daily.csv")
tot_cases2 <- melt(tot_cases, id = "ï..Date") 
totcases2 <- tot_cases2 %>% 
  mutate(Date = ddmmyyyy(ï..Date),
         Region = variable)
totcases2 <- totcases2[-1]
totcases2 <- totcases2[-1]
totcases4 <- totcases2 %>% 
  mutate(Age = "TOT",
         Sex = "b",
         AgeInt = NA,
         Country = "Japan",
         Measure = "Cases",
         Metric = "Count")%>% 
  mutate(Region = recode(Region, "ALL" = "All"))


#coding for regions need to be done
totcases5 <- totcases4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP-05",       
    Region=="All" ~ "JP",   
    Region=="Fukuoka" ~ "JP-40",   
    Region=="Fukushima" ~ "JP-07",       
    Region=="Gifu" ~ "JP-21",        
    Region=="Gunma" ~ "JP-10",    
    Region=="Hiroshima" ~ "JP-34",     
    Region=="Hokkaido" ~ "JP-01",      
    Region=="Ibaraki" ~ "JP-08",        
    Region=="Iwate" ~ "JP-03",       
    Region=="Kagawa" ~ "JP-37",     
    Region=="Kanagawa" ~ "JP-14",        
    Region=="Kochi" ~ "JP-39",     
    Region=="Kumamoto" ~ "JP-43",        
    Region=="Kyoto" ~ "JP-26",   
    Region=="Mie" ~ "JP-24",       
    Region=="Nagano" ~ "JP-20",         
    Region=="Nara" ~ "JP-29",      
    Region=="Niigata" ~ "JP-15",         
    Region=="Oita" ~ "JP-44",      
    Region=="Okayama" ~ "JP-33",      
    Region=="Okinawa" ~ "JP-47",         
    Region=="Saga" ~ "JP-41",      
    Region=="Saitama" ~ "JP-11",        
    Region=="Shiga" ~ "JP-25",      
    Region=="Shimane" ~ "JP-32",     
    Region=="Shizuoka" ~ "JP-22",      
    Region=="Tochigi" ~ "JP-09",        
    Region=="Tokyo" ~ "JP-13",      
    Region=="Tottori" ~ "JP-31",   
    Region=="Toyama" ~ "JP-16",     
    Region=="Wakayama" ~ "JP-30",    
    Region=="Yamaguchi" ~ "JP-35",    
    Region=="Yamanashi" ~ "JP-19",
    Region=="Miyagi" ~ "JP-04",
    Region=="Yamagata" ~ "JP-06",
    Region=="Chiba" ~ "JP-12",
    Region=="Ishikawa" ~ "JP-17",
    Region=="Fukui" ~ "JP-18",
    Region=="Aichi" ~ "JP-23",
    Region=="Osaka" ~ "JP-27",
    Region=="Hyogo" ~ "JP-28",
    Region=="Tokushima" ~ "JP-36",
    Region=="Ehime" ~ "JP-38",
    Region=="Nagasaki" ~ "JP-42",
    Region=="Miyazaki" ~ "JP-45",
    Region=="Kagoshima" ~ "JP-46",
    Region=="Aomori" ~ "JP-02"),
    Code = paste0(Code),
    Short = Code
  )
names(totcases5)[1] <- "Value"
totcases5 <- totcases5[,-11]




##total death

tot_death <- read.csv("https://covid19.mhlw.go.jp/public/opendata/deaths_cumulative_daily.csv")
tot_death2 <- melt(tot_death, id = "ï..Date")
totdeath2 <- tot_death2 %>% 
  mutate(Date = ddmmyyyy(ï..Date),
         Region = variable)
totdeath2 <- totdeath2[-1]
totdeath2 <- totdeath2[-1]
totdeath4 <- totdeath2 %>% 
  mutate(Age = "TOT",
         Sex = "b",
         AgeInt = NA,
         Country = "Japan",
         Measure = "Deaths",
         Metric = "Count")%>% 
  mutate(Region = recode(Region, "ALL" = "All"))


#coding for regions need to be done
totdeath5 <- totdeath4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP-05",       
    Region=="All" ~ "JP",   
    Region=="Fukuoka" ~ "JP-40",   
    Region=="Fukushima" ~ "JP-07",       
    Region=="Gifu" ~ "JP-21",        
    Region=="Gunma" ~ "JP-10",    
    Region=="Hiroshima" ~ "JP-34",     
    Region=="Hokkaido" ~ "JP-01",      
    Region=="Ibaraki" ~ "JP-08",        
    Region=="Iwate" ~ "JP-03",       
    Region=="Kagawa" ~ "JP-37",     
    Region=="Kanagawa" ~ "JP-14",        
    Region=="Kochi" ~ "JP-39",     
    Region=="Kumamoto" ~ "JP-43",        
    Region=="Kyoto" ~ "JP-26",   
    Region=="Mie" ~ "JP-24",       
    Region=="Nagano" ~ "JP-20",         
    Region=="Nara" ~ "JP-29",      
    Region=="Niigata" ~ "JP-15",         
    Region=="Oita" ~ "JP-44",      
    Region=="Okayama" ~ "JP-33",      
    Region=="Okinawa" ~ "JP-47",         
    Region=="Saga" ~ "JP-41",      
    Region=="Saitama" ~ "JP-11",        
    Region=="Shiga" ~ "JP-25",      
    Region=="Shimane" ~ "JP-32",     
    Region=="Shizuoka" ~ "JP-22",      
    Region=="Tochigi" ~ "JP-09",        
    Region=="Tokyo" ~ "JP-13",      
    Region=="Tottori" ~ "JP-31",   
    Region=="Toyama" ~ "JP-16",     
    Region=="Wakayama" ~ "JP-30",    
    Region=="Yamaguchi" ~ "JP-35",    
    Region=="Yamanashi" ~ "JP-19",
    Region=="Miyagi" ~ "JP-04",
    Region=="Yamagata" ~ "JP-06",
    Region=="Chiba" ~ "JP-12",
    Region=="Ishikawa" ~ "JP-17",
    Region=="Fukui" ~ "JP-18",
    Region=="Aichi" ~ "JP-23",
    Region=="Osaka" ~ "JP-27",
    Region=="Hyogo" ~ "JP-28",
    Region=="Tokushima" ~ "JP-36",
    Region=="Ehime" ~ "JP-38",
    Region=="Nagasaki" ~ "JP-42",
    Region=="Miyazaki" ~ "JP-45",
    Region=="Kagoshima" ~ "JP-46",
    Region=="Aomori" ~ "JP-02"),
    Code = paste0(Code),
    Short = Code
    )
names(totdeath5)[1] <- "Value"
totdeath5 <- totdeath5[,-11]

pre_out <- rbind(db_drive, totdeath5, totcases5, death5, cases5) |> 
  unique() |> 
  sort_input_data()

## MK: there was duplication of values in 20.09.2022, so I filtered these out separately and append to the dataset again

sep_22 <- pre_out %>% 
  filter(str_detect(Date, "20.09.2022")) %>% 
  filter(Value != 0)

out <- pre_out %>% 
  filter(!str_detect(Date, "20.09.2022")) %>% 
  bind_rows(sep_22) %>% 
  unique() %>% 
  sort_input_data()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# uploading database to Google Drive and N
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#sheet_append(out,
#             ss = ss_i,
#             sheet = "database")
write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = "Japan", N = nrow(out))


###backup
data_source1 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
data_source2 <- paste0(dir_n, "Data_sources/", ctr, "/death_age",today(), ".csv")
data_source3 <- paste0(dir_n, "Data_sources/", ctr, "/cases_all",today(), ".csv")
data_source4 <- paste0(dir_n, "Data_sources/", ctr, "/death_all",today(), ".csv")

data_source <- c(data_source1,
                 data_source2,
                 data_source3,
                 data_source4)

write_csv(cases, data_source1)
write_csv(death, data_source2)
write_csv(tot_cases, data_source3)
write_csv(tot_death, data_source4)

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


