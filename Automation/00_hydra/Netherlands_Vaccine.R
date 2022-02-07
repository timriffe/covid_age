##Netherlands Vaccination
##norway vaccines
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(reshape2) 
if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Netherlands_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Netherlands/Vaccinations of 2021"


# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)



df <-list.files(path= dir_n_source, 
                           pattern = "vaccinations",
                           full.names = TRUE)

all_paths <-
  list.files(path = dir_n_source,
             pattern = "alder-2020-2021.csv",
             full.names = TRUE)


#most_recent_file_death= rownames(df)[which.max(df$mtime)]


all_content_age_death <-
  df %>%
  lapply(read_xlsx)

all_filenames_age_death <- df %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_age_death, all_filenames_age_death, SIMPLIFY = FALSE)

death_in <- rbindlist(all_lists, fill = T)


vacc <- death_in %>% 
  select(`Target group`, V1, `First dose`, `Second dose`, Total4, Total, `Eerste dosis`, `Tweede dosis`, Totaal, Totaal4,
         `First dose3`, `Second dose7`, `Second dose3`, `Number of people who are fully vaccinated`, `Number of people who have started vaccination`,
         `Age group`)
names(vacc)[1] <- "group"

string_in_vacc <- unique(vacc$group)
string_in_vacc[c(1,2,4:8,12:16,22:24,26:27,31,32,42,43,45,85:92)]

vacc2 <- vacc %>% 
  filter(!group %in% string_in_vacc[c(1,2,4:8,12:16,22:24,26:27,31,32,42,43,45,85:92)])

names(vacc2)[3] <- "Vaccination1"
names(vacc2)[4] <- "Vaccination2"

vacc3 <- vacc2 %>% 
  mutate(Vaccination1 = case_when(is.na(Vaccination1) ~ `Number of people who have started vaccination`,
         TRUE ~ Vaccination1)) %>% 
  mutate(Vaccination1 = case_when(is.na(Vaccination1) ~ `First dose3`,
                                  TRUE ~ Vaccination1))%>% 
  mutate(Vaccination2 = case_when(is.na(Vaccination2) ~ `Second dose3`,
                                  TRUE ~ Vaccination2))%>% 
  mutate(Vaccination2 = case_when(is.na(Vaccination2) ~ `Second dose7`,
                                  TRUE ~ Vaccination2))%>% 
  mutate(Vaccination2 = case_when(is.na(Vaccination2) ~ `Number of people who are fully vaccinated`,
                                  TRUE ~ Vaccination2)) %>% 
  select(Age = group, Vaccination1, Vaccination2, week = V1)

vacc3$Vaccination1 <- gsub("\\.", "", vacc3$Vaccination1)
vacc3$Vaccination1 <- gsub("\\.", "", vacc3$Vaccination1)


vacc3$Vaccination1 <- gsub("[^0-9]+", "", vacc3$Vaccination1)
vacc3$Vaccination2 <- gsub("[^0-9]+", "", vacc3$Vaccination2)
vacc3$Vaccination1 <- as.numeric(vacc3$Vaccination1)
vacc3$Vaccination2 <- as.numeric(vacc3$Vaccination2)

vacc3

vacc3$week = substr(vacc3$week,1,nchar(vacc3$week)-5)
vacc3$week <- sub(".....................", "", vacc3$week)
vacc3 <- vacc3 %>% 
  mutate(YearWeekISO = paste0("2021-W", week)) %>% 
  mutate(YearWeekISO = case_when(
    YearWeekISO == "2021-W1" ~ "2021-W01",
    YearWeekISO == "2021-W2" ~ "2021-W02",
    YearWeekISO == "2021-W3" ~ "2021-W03",
    YearWeekISO == "2021-W4" ~ "2021-W04",
    YearWeekISO == "2021-W5" ~ "2021-W05",
    YearWeekISO == "2021-W6" ~ "2021-W06",
    YearWeekISO == "2021-W7" ~ "2021-W07",
    YearWeekISO == "2021-W8" ~ "2021-W08",
    YearWeekISO == "2021-W9" ~ "2021-W09",
    TRUE ~ YearWeekISO
  )) %>% 
ungroup() %>%
  mutate(Day= "7")%>%
  unite('ISODate', YearWeekISO, Day, sep="-", remove=FALSE) %>% 
  mutate(Date= ISOweek::ISOweek2date(ISODate)) %>% 
  select(Age, Vaccination1, Vaccination2, Date)
vacc3$Age_p <- gsub("[^A-Z]+", "", vacc3$Age)

vacc4 <- vacc3 %>% 
  mutate(Age2 = case_when(
    Age == "\n<20 years\n" ~ "0",
    Age == "\n​​45-49-years\n" ~ "45",
    Age == "\n12-17-years\n" ~ "12",
    Age == "\n18-24-years\n" ~ "18",
    Age == "\n20 - 24 years\n" ~ "20",
    Age == "\n25-29-years\n" ~ "25",
    Age == "\n25 - 29 years\n" ~ "25",
    Age == "\n30-34-years\n" ~ "30",
    Age == "\n30 - 34 years\n" ~ "30",
    Age == "\n35-39-years\n" ~ "35",
    Age == "\n35 - 39 years\n" ~ "35",
    Age == "\n40-44-years\n" ~ "40",
    Age == "\n40 - 44 years\n" ~ "40",
    Age == "\n45 - 49 years\n" ~ "45",
    Age == "\n50-54-years\n" ~ "50",
    Age == "\n50 -54 years\n" ~ "50",
    Age == "\n55-59 years\n" ~ "55",
    Age == "\n60-64 years\n" ~ "60",
    Age == "\n65-69 years\n" ~ "65",
    Age == "\n70-74 years\n" ~ "70",
    Age == "\n75-79 years\n" ~ "75",
    Age == "\n80-84 years\n" ~ "80",
    Age == "\n85-89 years\n" ~ "85",
    Age == "\nAge not specified\n" ~ "UNK",
    Age == "\nAge unknown\n" ~ "UNK",
    Age == "nPeople aged 90 and up\n" ~ "90",
    Age == "12-17" ~ "12",
    Age == "12-17 years" ~ "12",
    Age == "18-24 years" ~ "18",
    Age == "18-25" ~ "18",
    Age == "25-29 years" ~ "25",
    Age == "26-30" ~ "26",
    Age == "30-34 years" ~ "30",
    Age == "31-35" ~ "31",
    Age == "35-39 years" ~ "35",
    Age == "36-40" ~ "36",
    Age == "40-44 years" ~ "40",
    Age == "41-45" ~ "41",
    Age == "45-49 years" ~ "45",
    Age == "46-50" ~ "46",
    Age == "50-54 years" ~ "50",
    Age == "51-55" ~ "51",
    Age == "55-59 years" ~ "55",
    Age == "56-60" ~ "56",
    Age == "60-64 years" ~ "60",
    Age == "61-65" ~ "61",
    Age == "65-69 years" ~ "65",
    Age == "66-70" ~ "66",
    Age == "70-74 years" ~ "70",
    Age == "71-75" ~ "71",
    Age == "75-79 years" ~ "75",
    Age == "76-80" ~ "76",
    Age == "80-84 years" ~ "80",
    Age == "81-85" ~ "81",
    Age == "85-89 years" ~ "85",
    Age == "86-90" ~ "86",
    Age == "91+" ~ "91",
    Age == "Age unknown" ~ "UNK",
    Age == "People aged 90 and up" ~ "90",
    Age_p == "P" ~ "90",
    Age == "Totaal" ~ "TOT",
    Age == "Total" ~ "TOT",
    Age == "Unknown" ~ "UNK" )) %>% 
  mutate(AgeInt = case_when(
    Age == "\n<20 years\n" ~ 20L,
    Age == "\n​​45-49-years\n" ~ 5L,
    Age == "\n12-17-years\n" ~ 5L,
    Age == "\n18-24-years\n" ~ 7L,
    Age == "\n20 - 24 years\n" ~ 5L,
    Age == "\n25-29-years\n" ~ 5L,
    Age == "\n25 - 29 years\n" ~ 5L,
    Age == "\n30-34-years\n" ~ 5L,
    Age == "\n30 - 34 years\n" ~ 5L,
    Age == "\n35-39-years\n" ~ 5L,
    Age == "\n35 - 39 years\n" ~ 5L,
    Age == "\n40-44-years\n" ~ 5L,
    Age == "\n40 - 44 years\n" ~ 5L,
    Age == "\n45 - 49 years\n" ~ 5L,
    Age == "\n50-54-years\n" ~ 5L,
    Age == "\n50 -54 years\n" ~ 5L,
    Age == "\n55-59 years\n" ~ 5L,
    Age == "\n60-64 years\n" ~ 5L,
    Age == "\n65-69 years\n" ~ 5L,
    Age == "\n70-74 years\n" ~ 5L,
    Age == "\n75-79 years\n" ~ 5L,
    Age == "\n80-84 years\n" ~ 5L,
    Age == "\n85-89 years\n" ~ 5L,
    Age == "nPeople aged 90 and up\n" ~ 15L,
    Age == "12-17" ~ 5L,
    Age == "12-17 years" ~ 5L,
    Age == "18-24 years" ~ 7L,
    Age == "18-25" ~ 8L,
    Age == "25-29 years" ~ 5L,
    Age == "26-30" ~ 5L,
    Age == "30-34 years" ~ 5L,
    Age == "31-35" ~ 5L,
    Age == "35-39 years" ~ 5L,
    Age == "36-40" ~ 5L,
    Age == "40-44 years" ~ 5L,
    Age == "41-45" ~ 5L,
    Age == "45-49 years" ~ 5L,
    Age == "46-50" ~ 5L,
    Age == "50-54 years" ~ 5L,
    Age == "51-55" ~ 5L,
    Age == "55-59 years" ~ 5L,
    Age == "56-60" ~ 5L,
    Age == "60-64 years" ~ 5L,
    Age == "61-65" ~ 5L,
    Age == "65-69 years" ~ 5L,
    Age == "66-70" ~ 5L,
    Age == "70-74 years" ~ 5L,
    Age == "71-75" ~ 5L,
    Age == "75-79 years" ~ 5L,
    Age == "76-80" ~ 5L,
    Age == "80-84 years" ~ 5L,
    Age == "81-85" ~ 5L,
    Age == "85-89 years" ~ 5L,
    Age == "86-90" ~ 5L,
    Age == "91+" ~ 14L,
    Age == "People aged 90 and up" ~ 15L,
    Age_p == "P" ~ 15L)) %>% 
  select(Vaccination1, Vaccination2, Age=Age2, AgeInt, Date)
vacc5 <- melt(vacc4, id=c("Age", "Date", "AgeInt"))
names(vacc5)[4] <- "Measure"
names(vacc5)[5] <- "Value"
vacc5 <- vacc5 %>% 
  mutate(
    Country = "Netherlands",
    Region = "All",
    Code = "NL",
    Metric = "Count",
    Sex = "b"
  ) 
         

small_ages1 <- vacc5 %>% 
  filter(Date <= "2021-02-14",
         Age == "80") %>% 
  mutate(Age = "0",
         AgeInt = 80L,
         Value = 0)

small_ages2 <- vacc5 %>% 
  filter(Date >= "2021-02-28",
           Date <= "2021-03-14",
         Age == "75") %>% 
  mutate(Age = "0",
         AgeInt = 75L,
         Value = 0)

small_ages3 <- vacc5 %>% 
  filter(Date >= "2021-03-21",
         Date <= "2021-04-04",
         Age == "70") %>% 
  mutate(Age = "0",
         AgeInt = 70L,
         Value = 0)

small_ages4 <- vacc5 %>% 
  filter(Date >= "2021-04-11",
         Date <= "2021-04-18",
         Age == "55") %>% 
  mutate(Age = "0",
         AgeInt = 55L,
         Value = 0)

small_ages5 <- vacc5 %>% 
  filter(Date >= "2021-06-13",
         Date <= "2021-12-28",
         Age == "12") %>% 
  mutate(Age = "0",
         AgeInt = 12L,
         Value = 0)

vacc_out <- rbind(vacc5, small_ages1, small_ages2, small_ages3, small_ages4, small_ages5) %>% 
  mutate(Date = ymd(Date),
Date = paste(sprintf("%02d",day(Date)),
             sprintf("%02d",month(Date)),
             year(Date),
             sep=".")) %>% 
  sort_input_data()

write_rds(vacc_out, "N:/COVerAGE-DB/Automation/Hydra/Netherlands_Vaccine.rds")
