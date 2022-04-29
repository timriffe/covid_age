##Caces and Death for Somalia

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Somalia"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- paste0("N:/COVerAGE-DB/Automation/", ctr, "/")

###save previous data that has been collected mannual

previous <- read_rds(paste0(dir_n, "Somalia.rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Date <= "2022-03-18")


##get the new data that is automated

all_paths <-
  list.files(path = dir_n_source,
             pattern = "cases_by_age",
             full.names = TRUE)

all_content_age_death <-
  all_paths %>%
  lapply(read_xlsx)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_age_death, all_filenames, SIMPLIFY = FALSE)

cases_in <- rbindlist(all_lists, fill = T) 
names(cases_in)[1] <- "Age"
cases_in <- melt(cases_in, id=c("Age", "V1"))
names(cases_in)[3] <- "Measure"
names(cases_in)[4] <- "Value"
cases_out <- cases_in %>% 
  mutate (Date = substr(V1, 14,21),
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Country = "Somalia",
          Region = "All",
          Code = "SO",
          Age = case_when(
            Age == "20 to 30 yrs" ~ "20",
            Age == "30 to 40 yrs" ~ "30",
            Age == "40 to 50 yrs" ~ "40",
            Age == "50 to 60 yrs" ~ "50",
            Age == "below 20 yrs" ~ "0",
            Age == "over 60 yrs" ~ "60"
          ),
          AgeInt = case_when(
            Age == "0" ~ 20L,
            Age == "60" ~ 25L,
            TRUE ~ 10L
          ),
          Sex = "b",
          Metric = "Fraction",
          Measure = case_when(
            Measure == "Confirmed cases" ~ "Cases",
            Measure == "Death cases" ~ "Deaths"
          ),
          Value = Value / 100,
          Sex = "b") %>%  
  select(Country, Region, Code, Date, Age, AgeInt, Metric, Measure, Value, Sex) 

##totals and by sex##

all_paths2 <-
  list.files(path = dir_n_source,
             pattern = "info",
             full.names = TRUE)


all_content_age_death2 <-
  all_paths2 %>%
  lapply(read_xlsx, col_names = FALSE)


all_filenames2 <- all_paths2 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists2 <- mapply(c, all_content_age_death2, all_filenames2, SIMPLIFY = FALSE)

info_in <- rbindlist(all_lists2, fill = T) 

info_out <- info_in %>% 
             mutate(
             Sex = substr(...1, 1,4),
             Sex = case_when(
               Sex == "Fema" ~ "f",
               Sex == "Male" ~ "m",
               TRUE ~ "b"
             )) %>% 
  filter(...1 != "Cases by gender are") %>% 
  mutate(Measure = substr(...1, 11,16),
         Measure = case_when(
           Measure == "deaths" ~ "Deaths",
           TRUE ~ "Cases"
         )) %>% 
  mutate(Value = substr(...1, 14,30)) %>% 
  mutate(Value = gsub("[^0-9]+", "", Value)) %>% 
  mutate(Date = substr(V1, 26,33),
         Date = as.Date(as.character(Date),format="%Y%m%d")) %>% 
  select(Sex, Measure, Value, Date) %>% 
  mutate(Age = "TOT",
         AgeInt = NA_integer_,
         Country = "Somalia",
         Code = "SO",
         Metric = "Count",
         Region = "All") 
  
  
data <- rbind(cases_out, info_out, previous) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date), 
                      sep = ".")) %>% 
  sort_input_data()
  

##save and update dashboard
write_rds(data, paste0(dir_n, ctr, ".rds"))

N <- nrow(data)
log_update(pp = "Somalia", N = N)




          










