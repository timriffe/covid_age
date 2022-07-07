##norway vaccines
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here::here("Automation/00_Functions_automation.R"))
if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Norway_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Norway"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


all_paths <-
  list.files(path = dir_n_source,
             pattern = ".csv",
             #pattern = "alder-2020",
             full.names = TRUE)

#historicalData <- readRDS(paste0(dir_n, "Norway_Vaccine.rds"))

all_content <-
  all_paths %>%
  lapply(read.csv)

# all_filenames <- all_paths %>%
#   basename() %>%
#   as.list()
# 
# #include filename to get date from filename 
# all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
# vacc_in$Date <- substr(vacc_in$V1,1, nchar(vacc_in$V1)-65)
# vacc_in <- vacc_in[,-2]
# vacc_in <- vacc_in %>%
#   separate(ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI,
#             c("Age","Dose1 male", "Dose1 female","Dose2 male","Dose2 female","Dose3 male","Dose3 female"),
#             sep = (";"))
# vacc_in <- melt(vacc_in, id= c("Age", "Date"))
# names(vacc_in)[4] <- "Value"
# 
# vacc_out_beforeJune22 <- vacc_in %>% 
#   mutate(AgeInt=case_when(
#     Age == "0-15 Ã¥r" ~ 16L,
#     Age == "12-15 Ã¥r" ~ 4L,
#     Age == "16-17 Ã¥r" ~ 2L,
#     Age == "16-44 Ã¥r" ~ 39L,
#     Age == "18-24 Ã¥r" ~ 7L,
#     Age == "25-39 Ã¥r" ~ 15L,
#     Age == "40-44 Ã¥r" ~ 5L,
#     Age == "45-54 Ã¥r" ~ 10L,
#     Age == "55-64 Ã¥r" ~ 10L,
#     Age == "65-74 Ã¥r" ~ 10L,
#     Age == "75-84 Ã¥r" ~ 10L,
#     Age == "85 og over" ~ 20L)) %>% 
#   mutate(Age=recode(Age, 
#                     `0-15 Ã¥r`="0",
#                     `12-15 Ã¥r`="12",
#                     `16-17 Ã¥r`="16",
#                     `16-44 Ã¥r`="16",
#                     `18-24 Ã¥r`="18",
#                     `25-39 Ã¥r`="25",
#                     `40-44 Ã¥r`="40",
#                     `45-54 Ã¥r`="45",
#                     `55-64 Ã¥r`="55",
#                     `65-74 Ã¥r`="65",
#                     `75-84 Ã¥r`="75",
#                     `85 og over`="85"))%>% 
#   mutate(
#     Measure = case_when(
#       variable == "Dose1 male" ~ "Vaccination1",
#       variable == "Dose1 female" ~ "Vaccination1",      
#       variable == "Dose2 male" ~ "Vaccination2",
#       variable == "Dose2 female" ~ "Vaccination2",
#       variable == "Dose3 female" ~ "Vaccination3",
#       variable == "Dose3 male" ~ "Vaccination3",
#       
#     ),
#     Metric = "Count",
#     Sex= case_when(
#       variable == "Dose1 male" ~ "m",
#       variable == "Dose1 female" ~ "f",
#       variable == "Dose2 male" ~ "m",
#       variable == "Dose2 female" ~ "f",         
#       variable == "Dose3 male" ~ "m",
#       variable == "Dose3 female" ~ "f"  
#     )) %>% 
#   filter(Date != "2021-12-07") %>% 
#   mutate(Date = ymd(Date)) %>% 
#   select(-variable)
# 

## MK: Norway changed their way of reporting vaccination in early June 2022 #
##Source for updates: https://github.com/folkehelseinstituttet/surveillance_data
## these data are downloaded manually & transformed as following ##


vacc_in <- rbindlist(all_content, fill = T)
 
vacc_in <- vacc_in[- grep("Covid", vacc_in$ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI),]

vacc_out <- vacc_in %>%
  tidyr::separate(ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI,
            c("Date",
              "Dose 1, Female, 12-15",
              "Dose 1, Male, 12-15",
              "Dose 1, Male, 16-17",
              "Dose 1, Female, 16-17",
              "Dose 1, Male, 18-24",
              "Dose 1, Female, 18-24",
              "Dose 1, Female, 25-39",
              "Dose 1, Male, 25-39",
              "Dose 1, Male, 40-44",
              "Dose 1, Female, 40-44",
              "Dose 1, Male, 45-54",
              "Dose 1, Female, 45-54",
              "Dose 1, Male, 55-64",
              "Dose 1, Female, 55-64",
              "Dose 1, Male, 65-74",
              "Dose 1, Female, 65-74",
              "Dose 1, Male, 75-79",
              "Dose 1, Female, 80-84",
              "Dose 1, Male, 80-84",
              "Dose 1, Female, 85",
              "Dose 1, Male, 85",
              "Dose 2, Female, 12-15",
              "Dose 2, Female, 16-17",
              "Dose 2, Male, 16-17",
              "Dose 2, Male, 18-24",
              "Dose 2, Female, 18-24",
              "Dose 2, Female, 25-39",
              "Dose 2, Male, 25-39",
              "Dose 2, Male, 40-44",
              "Dose 2, Female, 40-44",
              "Dose 2, Male, 45-54",
              "Dose 2, Female, 45-54",
              "Dose 2, Female, 55-64",
              "Dose 2, Male, 55-64",
              "Dose 2, Female, 65-74",
              "Dose 2, Male, 65-74",
              "Dose 2, Female, 75-79",
              "Dose 2, Male, 75-79",
              "Dose 2, Female, 80-84",
              "Dose 2, Male, 80-84",
              "Dose 2, Female, 85",
              "Dose 2, Male, 85",
              "Dose 3, Male, 12-15",
              "Dose 3, Female, 12-15",
              "Dose 3, Female, 16-17",
              "Dose 3, Male, 16-17",
              "Dose 3, Male, 18-24",
              "Dose 3, Male, 25-39",
              "Dose 3, Female, 40-44",
              "Dose 3, Male, 40-44",
              "Dose 3, Male, 45-54",
              "Dose 3, Female, 45-54",
              "Dose 3, Male, 55-64",
              "Dose 3, Female, 55-64",
              "Dose 3, Male, 65-74",
              "Dose 3, Female, 65-74",
              "Dose 3, Male, 75-79",
              "Dose 3, Female, 75-79",
              "Dose 3, Female, 80-84",
              "Dose 3, Male, 80-84",
              "Dose 3, Female, 85",
              "Dose 3, Male, 85",
              "Dose 4, Female, 12-15",
              "Dose 4, Female, 18-24",
              "Dose 4, Male, 18-24",
              "Dose 4, Female, 25-39",
              "Dose 4, Male, 25-39",
              "Dose 4, Female, 40-44",
              "Dose 4, Male, 40-44",
              "Dose 4, Female, 45-54",
              "Dose 4, Male, 45-54",
              "Dose 4, Female, 55-64",
              "Dose 4, Male, 55-64",
              "Dose 4, Female, 65-74",
              "Dose 4, Male, 65-74",
              "Dose 4, Female, 75-79",
              "Dose 4, Male, 75-79",
              "Dose 4, Female, 85",
              "Dose 4, Male, 85",
              "Dose 2, Male, 12-15",
              "Dose 3, Female, 18-24",
              "Dose 3, Female, 25-39",
              "Dose 4, Female, 80-84",
              "Dose 4, Male, 80-84"
            ),
            sep = (";")) %>%
  dplyr::slice(-1) %>%
  tidyr::pivot_longer(cols = -Date,
                      names_to = c("Measure", "Sex", "Age"),
                      names_sep = (", "),
                      values_to = "Value") %>%
  dplyr::mutate(
    Date = as.Date(Date, format = "%d.%m.%Y"),
    Date = ymd(Date),
    Sex = case_when(Sex == "Female" ~ "f",
                    Sex == "Male" ~ "m"),
    Measure = case_when(Measure == "Dose 1" ~ "Vaccination1",
                        Measure == "Dose 2" ~ "Vaccination2",
                        Measure == "Dose 3" ~ "Vaccination3",
                        Measure == "Dose 4" ~ "Vaccination4"),
    AgeInt=case_when(
      Age == "0-15" ~ 16L,
      Age == "12-15" ~ 4L,
      Age == "16-17" ~ 2L,
      Age == "16-44" ~ 39L,
      Age == "18-24" ~ 7L,
      Age == "25-39" ~ 15L,
      Age == "40-44" ~ 5L,
      Age == "45-54" ~ 10L,
      Age == "55-64" ~ 10L,
      Age == "65-74" ~ 10L,
      Age == "75-79" ~ 10L,
      Age == "80-84" ~ 10L,
      Age == "85" ~ 20L),
    Age=recode(Age,
               `0-15`="0",
               `12-15`="12",
               `16-17`="16",
               `16-44`="16",
               `18-24`="18",
               `25-39`="25",
               `40-44`="40",
               `45-54`="45",
               `55-64`="55",
               `65-74`="65",
               ## MK: Since June 2022:
               ## Age groups has changed to 75-79 and 80-84 (including the historical data) ##
               `75-79` = "75",
               `80-84`="80",
               `85`="85"),
    Metric = "Count")



##adding 0 to 11 from 27.09.2021
vacc_zero <- vacc_out %>% 
  filter(Date >= "2021-09-28",
         Age == 12) %>% 
  mutate(Age = 0,
         AgeInt = 12L,
         Value = 0)

vacc_out <- rbind(vacc_out, vacc_zero) %>% 
  mutate(
     Date = ymd(Date),
     Date = paste(sprintf("%02d",day(Date)),    
                  sprintf("%02d",month(Date)),  
                  year(Date),sep="."),
    Code = paste0("NO"),
     Country = "Norway",
    Region = "All",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)%>% 
  mutate(Value = as.character(Value)) %>% 
  sort_input_data()

#upload 

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))


log_update("Norway_Vaccine", N = nrow(vacc_out))

