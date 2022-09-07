source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
library(tidyverse)
library(lubridate)
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
# info country and N drive address
ctr   <- "Thailand"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# TR: pull urls from rubric instead 
at_rubric <- get_input_rubric() %>% filter(Short == "TH")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)


cases_url <- "https://data.go.th/dataset/8a956917-436d-4afd-a2d4-59e4dd8e906e/resource/be19a8ad-ab48-4081-b04a-8035b5b2b8d6/download/confirmed-cases.csv"

## CHANGE SYS.LOCALE to THAI so that sex can be recoded ##
Sys.setlocale(locale = "Thai")
TH <- read_csv(cases_url)


Ages <- as.character(0:100,"UNK")

Cases <-
  TH %>% 
  select(Date = announce_date,
         Age = age,
         Sex = sex) %>% 
  mutate(Date = dmy(Date),
         Age = ifelse(sign(Age) == -1, -Age,Age), # one case of -34 must mean 34, right?
         Age = if_else(Age >= 105, 105, Age),
         Age = as.integer(Age),
         Age = ifelse(is.na(Age),"UNK",as.character(Age)),
         Sex = ifelse(is.na(Sex),"UNK",as.character(Sex)),
         Sex = case_when(
           Sex %in% c("ชาย", "นาย") ~ "m",
           Sex %in% c("หญิง") ~ "f",
           TRUE ~ Sex))%>% 
  group_by(Date, Sex, Age) %>% 
  summarize(Value = n(), .groups="drop") %>% 
  tidyr::complete(Date, Sex, Age = Ages, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup() %>%
  mutate(Country = "Thailand",
         Region = "All",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Metric = "Count",
         Measure = "Cases",
         AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                            Age == "100" ~ 5L,
                            TRUE ~ 1L),
         Code = "TH") %>% 
  sort_input_data() %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  filter(!(Sex == "UNK" & Value == 0),
         !(Age == "UNK" & Value == 0))

## CHANGE SYS.LOCALE BACK TO all ##
Sys.setlocale("LC_ALL","English")

# Save and log
write_rds(Cases, paste0(dir_n, ctr, ".rds"))
log_update("Thailand", N = nrow(Cases))

# Archive inputs
data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")
write_csv(TH, data_source)
zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")
zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)
# end