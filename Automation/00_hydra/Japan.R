


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
drive_auth(email = email)
gs4_auth(email = email)

# data from drive1 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_1")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive1 <- get_country_inputDB("JP_1")

# data from drive2 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_2")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive2 <- get_country_inputDB("JP_2")
# data from drive3 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_3")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive3 <- get_country_inputDB("JP_3")
# data from drive4 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_4")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive4 <- get_country_inputDB("JP_4")
# data from drive5 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_5")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive5 <- get_country_inputDB("JP_5")
# data from drive6 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_6")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive6 <- get_country_inputDB("JP_6")
# data from drive7 
rubric_i <- get_input_rubric() %>% filter(Short == "JP_7")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive7 <- get_country_inputDB("JP_7")
# data from drive8
rubric_i <- get_input_rubric() %>% filter(Short == "JP_8")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

db_drive8 <- get_country_inputDB("JP_8")

db_drive <- rbind(db_drive1, db_drive2, db_drive3, db_drive4, db_drive5, db_drive6, db_drive7, db_drive8)
#new death 

death <- read_csv("https://covid19.mhlw.go.jp/public/opendata/deaths_detail_cumulative_weekly.csv")
death2 <- death %>% 
  mutate(Date = sub("...........", "", Week),
  Date = ddmmyyyy(Date),
  Region = Prefecture)
death2 <- death2[-1]
death2 <- death2[-1]
death2 <- setDT(death2)
death3 <- melt(death2, id = c("Region", "Date"))
death4 <- death3 %>% 
  separate(variable, c("Sex","Age"), sep = (" ")) %>% 
  mutate(Age = case_when(Age == "Under" ~ 0,
                         Age == "10s" ~ 10,
                         Age == "20s" ~ 20,
                         Age == "30s" ~ 30,
                         Age == "40s" ~ 40,
                         Age == "50s" ~ 50,
                         Age == "60s" ~ 60,
                         Age == "70s" ~ 70,
                         Age == "80s" ~ 80,
                         Age == "Over" ~ 90),
         Sex = case_when(Sex == "Female" ~ "f",
                                Sex == "Male" ~ "m"),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           TRUE ~ 10L),
         Country = "Japan",
         Measure = "Death",
         Metric = "Count")
  

death4$value <- as.numeric(death4$value)
death4[is.na(death4)] <- 0

#coding for regions need to be done
death5 <- death4 %>% 
  mutate(Code = case_when(
Region=="Akita" ~ "JP_05_",       
Region=="ALL" ~ "JP_",   
Region=="Fukuoka" ~ "JP_40_",   
Region=="Fukushima" ~ "JP_07_",       
Region=="Gifu" ~ "JP_21_",        
Region=="Gunma" ~ "JP_10_",    
Region=="Hiroshima" ~ "JP_34_",     
Region=="Hokkaido" ~ "JP_01_",      
Region=="Ibaraki" ~ "JP_08_",        
Region=="Iwate" ~ "JP_03_",       
Region=="Kagawa" ~ "JP_37_",     
Region=="Kanagawa" ~ "JP_14_",        
Region=="Kochi" ~ "JP_39_",     
Region=="Kumamoto" ~ "JP_43_",        
Region=="Kyoto" ~ "JP_26_",   
Region=="Mie" ~ "JP_24_",       
Region=="Nagano" ~ "JP_20_",         
Region=="Nara" ~ "JP_29_",      
Region=="Niigata" ~ "JP_15_",         
Region=="Oita" ~ "JP_44_",      
Region=="Okayama" ~ "JP_33_",      
Region=="Okinawa" ~ "JP_47_",         
Region=="Saga" ~ "JP_41_",      
Region=="Saitama" ~ "JP_11_",        
Region=="Shiga" ~ "JP_25_",      
Region=="Shimane" ~ "JP_32_",     
Region=="Shizuoka" ~ "JP_22_",      
Region=="Tochigi" ~ "JP_09_",        
Region=="Tokyo" ~ "JP_13_",      
Region=="Tottori" ~ "JP_31_",   
Region=="Toyama" ~ "JP_16_",     
Region=="Wakayama" ~ "JP_30_",    
Region=="Yamaguchi" ~ "JP_35_",    
Region=="Yamanashi" ~ "JP_19_",
Region=="Miyagi" ~ "JP_04_",
Region=="Yamagata" ~ "JP_06_",
Region=="Chiba" ~ "JP_12_",
Region=="Ishikawa" ~ "JP_17_",
Region=="Fukui" ~ "JP_18_",
Region=="Aichi" ~ "JP_23_",
Region=="Osaka" ~ "JP_27_",
Region=="Hyogo" ~ "JP_28_",
Region=="Tokushima" ~ "JP_36_",
Region=="Ehime" ~ "JP_38_",
Region=="Nagasaki" ~ "JP_42_",
Region=="Miyazaki" ~ "JP_45_",
Region=="Kagoshima" ~ "JP_46_",
Region=="Aomori" ~ "JP_02_"),
Code = paste0(Code, Date),
Short = substr(Code, 1, nchar(Code)-11))
names(death5)[5] <- "Value"


#new cases

cases <- read_csv("https://covid19.mhlw.go.jp/public/opendata/confirmed_cases_detail_cumulative_weekly.csv")
cases2 <- cases %>% 
  mutate(Date = sub("...........", "", Week),
         Date = ddmmyyyy(Date),
         Region = Prefecture)
cases2 <- cases2[-1]
cases2 <- cases2[-1]
cases2 <- setDT(cases2)
cases3 <- melt(cases2, id = c("Region", "Date"))
cases4 <- cases3 %>% 
  separate(variable, c("Sex","Age"), sep = (" ")) %>% 
  mutate(Age = case_when(Age == "Under" ~ 0,
                         Age == "10s" ~ 10,
                         Age == "20s" ~ 20,
                         Age == "30s" ~ 30,
                         Age == "40s" ~ 40,
                         Age == "50s" ~ 50,
                         Age == "60s" ~ 60,
                         Age == "70s" ~ 70,
                         Age == "80s" ~ 80,
                         Age == "Over" ~ 90),
         Sex = case_when(Sex == "Female" ~ "f",
                         Sex == "Male" ~ "m"),
         AgeInt = case_when(
           Age == "90" ~ 15L,
           TRUE ~ 10L),
         Country = "Japan",
         Measure = "Cases",
         Metric = "Count")


cases4$value <- as.numeric(cases4$value)
cases4[is.na(cases4)] <- 0

#coding for regions need to be done
cases5 <- cases4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP_05_",       
    Region=="ALL" ~ "JP_",   
    Region=="Fukuoka" ~ "JP_40_",   
    Region=="Fukushima" ~ "JP_07_",       
    Region=="Gifu" ~ "JP_21_",        
    Region=="Gunma" ~ "JP_10_",    
    Region=="Hiroshima" ~ "JP_34_",     
    Region=="Hokkaido" ~ "JP_01_",      
    Region=="Ibaraki" ~ "JP_08_",        
    Region=="Iwate" ~ "JP_03_",       
    Region=="Kagawa" ~ "JP_37_",     
    Region=="Kanagawa" ~ "JP_14_",        
    Region=="Kochi" ~ "JP_39_",     
    Region=="Kumamoto" ~ "JP_43_",        
    Region=="Kyoto" ~ "JP_26_",   
    Region=="Mie" ~ "JP_24_",       
    Region=="Nagano" ~ "JP_20_",         
    Region=="Nara" ~ "JP_29_",      
    Region=="Niigata" ~ "JP_15_",         
    Region=="Oita" ~ "JP_44_",      
    Region=="Okayama" ~ "JP_33_",      
    Region=="Okinawa" ~ "JP_47_",         
    Region=="Saga" ~ "JP_41_",      
    Region=="Saitama" ~ "JP_11_",        
    Region=="Shiga" ~ "JP_25_",      
    Region=="Shimane" ~ "JP_32_",     
    Region=="Shizuoka" ~ "JP_22_",      
    Region=="Tochigi" ~ "JP_09_",        
    Region=="Tokyo" ~ "JP_13_",      
    Region=="Tottori" ~ "JP_31_",   
    Region=="Toyama" ~ "JP_16_",     
    Region=="Wakayama" ~ "JP_30_",    
    Region=="Yamaguchi" ~ "JP_35_",    
    Region=="Yamanashi" ~ "JP_19_",
    Region=="Miyagi" ~ "JP_04_",
    Region=="Yamagata" ~ "JP_06_",
    Region=="Chiba" ~ "JP_12_",
    Region=="Ishikawa" ~ "JP_17_",
    Region=="Fukui" ~ "JP_18_",
    Region=="Aichi" ~ "JP_23_",
    Region=="Osaka" ~ "JP_27_",
    Region=="Hyogo" ~ "JP_28_",
    Region=="Tokushima" ~ "JP_36_",
    Region=="Ehime" ~ "JP_38_",
    Region=="Nagasaki" ~ "JP_42_",
    Region=="Miyazaki" ~ "JP_45_",
    Region=="Kagoshima" ~ "JP_46_",
    Region=="Aomori" ~ "JP_02_"),
    Code = paste0(Code, Date),
    Short = substr(Code, 1, nchar(Code)-11))
names(cases5)[5] <- "Value"

##total cases
tot_cases <- read.csv("https://covid19.mhlw.go.jp/public/opendata/confirmed_cases_cumulative_daily.csv")
totcases2 <- tot_cases %>% 
  mutate(Date = ddmmyyyy(ï..Date),
         Region = Prefecture)
totcases2 <- totcases2[-1]
totcases2 <- totcases2[-1]
totcases4 <- totcases2 %>% 
  mutate(Age = "TOT",
         Sex = "b",
         AgeInt = NA,
         Country = "Japan",
         Measure = "Cases",
         Metric = "Count")


#coding for regions need to be done
totcases5 <- totcases4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP_05_",       
    Region=="ALL" ~ "JP_",   
    Region=="Fukuoka" ~ "JP_40_",   
    Region=="Fukushima" ~ "JP_07_",       
    Region=="Gifu" ~ "JP_21_",        
    Region=="Gunma" ~ "JP_10_",    
    Region=="Hiroshima" ~ "JP_34_",     
    Region=="Hokkaido" ~ "JP_01_",      
    Region=="Ibaraki" ~ "JP_08_",        
    Region=="Iwate" ~ "JP_03_",       
    Region=="Kagawa" ~ "JP_37_",     
    Region=="Kanagawa" ~ "JP_14_",        
    Region=="Kochi" ~ "JP_39_",     
    Region=="Kumamoto" ~ "JP_43_",        
    Region=="Kyoto" ~ "JP_26_",   
    Region=="Mie" ~ "JP_24_",       
    Region=="Nagano" ~ "JP_20_",         
    Region=="Nara" ~ "JP_29_",      
    Region=="Niigata" ~ "JP_15_",         
    Region=="Oita" ~ "JP_44_",      
    Region=="Okayama" ~ "JP_33_",      
    Region=="Okinawa" ~ "JP_47_",         
    Region=="Saga" ~ "JP_41_",      
    Region=="Saitama" ~ "JP_11_",        
    Region=="Shiga" ~ "JP_25_",      
    Region=="Shimane" ~ "JP_32_",     
    Region=="Shizuoka" ~ "JP_22_",      
    Region=="Tochigi" ~ "JP_09_",        
    Region=="Tokyo" ~ "JP_13_",      
    Region=="Tottori" ~ "JP_31_",   
    Region=="Toyama" ~ "JP_16_",     
    Region=="Wakayama" ~ "JP_30_",    
    Region=="Yamaguchi" ~ "JP_35_",    
    Region=="Yamanashi" ~ "JP_19_",
    Region=="Miyagi" ~ "JP_04_",
    Region=="Yamagata" ~ "JP_06_",
    Region=="Chiba" ~ "JP_12_",
    Region=="Ishikawa" ~ "JP_17_",
    Region=="Fukui" ~ "JP_18_",
    Region=="Aichi" ~ "JP_23_",
    Region=="Osaka" ~ "JP_27_",
    Region=="Hyogo" ~ "JP_28_",
    Region=="Tokushima" ~ "JP_36_",
    Region=="Ehime" ~ "JP_38_",
    Region=="Nagasaki" ~ "JP_42_",
    Region=="Miyazaki" ~ "JP_45_",
    Region=="Kagoshima" ~ "JP_46_",
    Region=="Aomori" ~ "JP_02_"),
    Code = paste0(Code, Date),
    Short = substr(Code, 1, nchar(Code)-11))
names(totcases5)[1] <- "Value"




##total death

tot_death <- read.csv("https://covid19.mhlw.go.jp/public/opendata/deaths_cumulative_daily.csv")
totdeath2 <- tot_death %>% 
  mutate(Date = ddmmyyyy(ï..Date),
         Region = Prefecture)
totdeath2 <- totdeath2[-1]
totdeath2 <- totdeath2[-1]
totdeath4 <- totdeath2 %>% 
  mutate(Age = "TOT",
         Sex = "b",
         AgeInt = NA,
         Country = "Japan",
         Measure = "Death",
         Metric = "Count")


#coding for regions need to be done
totdeath5 <- totdeath4 %>% 
  mutate(Code = case_when(
    Region=="Akita" ~ "JP_05_",       
    Region=="ALL" ~ "JP_",   
    Region=="Fukuoka" ~ "JP_40_",   
    Region=="Fukushima" ~ "JP_07_",       
    Region=="Gifu" ~ "JP_21_",        
    Region=="Gunma" ~ "JP_10_",    
    Region=="Hiroshima" ~ "JP_34_",     
    Region=="Hokkaido" ~ "JP_01_",      
    Region=="Ibaraki" ~ "JP_08_",        
    Region=="Iwate" ~ "JP_03_",       
    Region=="Kagawa" ~ "JP_37_",     
    Region=="Kanagawa" ~ "JP_14_",        
    Region=="Kochi" ~ "JP_39_",     
    Region=="Kumamoto" ~ "JP_43_",        
    Region=="Kyoto" ~ "JP_26_",   
    Region=="Mie" ~ "JP_24_",       
    Region=="Nagano" ~ "JP_20_",         
    Region=="Nara" ~ "JP_29_",      
    Region=="Niigata" ~ "JP_15_",         
    Region=="Oita" ~ "JP_44_",      
    Region=="Okayama" ~ "JP_33_",      
    Region=="Okinawa" ~ "JP_47_",         
    Region=="Saga" ~ "JP_41_",      
    Region=="Saitama" ~ "JP_11_",        
    Region=="Shiga" ~ "JP_25_",      
    Region=="Shimane" ~ "JP_32_",     
    Region=="Shizuoka" ~ "JP_22_",      
    Region=="Tochigi" ~ "JP_09_",        
    Region=="Tokyo" ~ "JP_13_",      
    Region=="Tottori" ~ "JP_31_",   
    Region=="Toyama" ~ "JP_16_",     
    Region=="Wakayama" ~ "JP_30_",    
    Region=="Yamaguchi" ~ "JP_35_",    
    Region=="Yamanashi" ~ "JP_19_",
    Region=="Miyagi" ~ "JP_04_",
    Region=="Yamagata" ~ "JP_06_",
    Region=="Chiba" ~ "JP_12_",
    Region=="Ishikawa" ~ "JP_17_",
    Region=="Fukui" ~ "JP_18_",
    Region=="Aichi" ~ "JP_23_",
    Region=="Osaka" ~ "JP_27_",
    Region=="Hyogo" ~ "JP_28_",
    Region=="Tokushima" ~ "JP_36_",
    Region=="Ehime" ~ "JP_38_",
    Region=="Nagasaki" ~ "JP_42_",
    Region=="Miyazaki" ~ "JP_45_",
    Region=="Kagoshima" ~ "JP_46_",
    Region=="Aomori" ~ "JP_02_"),
    Code = paste0(Code, Date),
    Short = substr(Code, 1, nchar(Code)-11)
    )
names(totdeath5)[1] <- "Value"

out <- rbind(db_drive, totdeath5, totcases5, death5, cases5)

###old code
#db_jp <- 
#  read_csv("https://toyokeizai.net/sp/visual/tko/covid19/csv/demography.csv")

#out <- 
#  db_jp %>% 
#  mutate(Date = make_date(y = year, m = month, d = date),
#         age_group = ifelse(age_group == "10歳未満", "0", age_group),
#         Age = str_sub(age_group, 1, 2),
#         Age = ifelse(Age == "不明", "UNK", Age)) %>% 
#  rename(Cases = tested_positive,
#         Deaths = death) %>% 
#  select(Date, Age, Cases, Deaths) %>% 
#  gather(Cases, Deaths, key = Measure, value = Value) %>% 
#  mutate(AgeInt = case_when(Age == "80" ~ 25,
#                            Age == "UNK" ~ NA_real_,
#                            TRUE ~ 10),
#         Sex = "b",
#         Metric = "Count",
#         Country = "Japan",
#         Region = "All",
#         Date = ddmmyyyy(Date),
#         Code = paste0("JP", Date)) %>% 
#  sort_input_data()
  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# uploading database to Google Drive and N
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#sheet_append(out,
#             ss = ss_i,
#             sheet = "database")
write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = "Japan", N = nrow(out))

data_source <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".csv")

write_csv(out, data_source)


