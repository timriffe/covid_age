##norway vaccines
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Norway_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Norway"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)



all_paths <-
  list.files(path = dir_n_source,
             pattern = "alder-2020-2021.csv",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read.csv)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

vacc_in <- rbindlist(all_lists, fill = T)
vacc_in <- vacc_in[- grep("Covid", vacc_in$ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI),]
vacc_in$Date <- substr(vacc_in$V1,1, nchar(vacc_in$V1)-65)
vacc_in <- vacc_in[,-2]
vacc_in <- vacc_in %>% 
separate(ï..Kilde..Nasjonalt.vaksinasjonsregister.SYSVAK..FHI, c("Age","Dose1 male", "Dose1 female","Dose2 male","Dose2 female"), sep = (";"))
vacc_in <- melt(vacc_in, id= c("Age", "Date"))
names(vacc_in)[4] <- "Value"


  



vacc_out <- vacc_in %>% 
  mutate(AgeInt=case_when(
    Age == "0-15 Ã¥r" ~ 16L,
    Age == "12-15 Ã¥r" ~ 4L,
    Age == "16-17 Ã¥r" ~ 2L,
    Age == "16-44 Ã¥r" ~ 39L,
    Age == "18-24 Ã¥r" ~ 7L,
    Age == "25-39 Ã¥r" ~ 15L,
    Age == "40-44 Ã¥r" ~ 5L,
    Age == "45-54 Ã¥r" ~ 10L,
    Age == "55-64 Ã¥r" ~ 10L,
    Age == "65-74 Ã¥r" ~ 10L,
    Age == "75-84 Ã¥r" ~ 10L,
    Age == "85 og over" ~ 20L)) %>% 
  mutate(Age=recode(Age, 
                    `0-15 Ã¥r`="0",
                    `12-15 Ã¥r`="12",
                    `16-17 Ã¥r`="16",
                    `16-44 Ã¥r`="16",
                    `18-24 Ã¥r`="18",
                    `25-39 Ã¥r`="25",
                    `40-44 Ã¥r`="40",
                    `45-54 Ã¥r`="45",
                    `55-64 Ã¥r`="55",
                    `65-74 Ã¥r`="65",
                    `75-84 Ã¥r`="75",
                    `85 og over`="85"))%>% 
  mutate(
    Measure = case_when(
      variable == "Dose1 male" ~ "Vaccination1",
      variable == "Dose1 female" ~ "Vaccination1",
      variable == "Dose2 male" ~ "Vaccination2",
      variable == "Dose2 female" ~ "Vaccination2"
    ),
    Metric = "Count",
    Sex= case_when(
      variable == "Dose1 male" ~ "m",
      variable == "Dose1 female" ~ "f",
      variable == "Dose2 male" ~ "m",
      variable == "Dose2 female" ~ "f"   
    )) %>% 
  filter(Date != "2021-12-07") 


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

