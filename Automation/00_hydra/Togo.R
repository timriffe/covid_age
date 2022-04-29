##Togo

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Togo"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- paste0("N:/COVerAGE-DB/Automation/", ctr, "/")


drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

###save previous data that has been collected mannual

previous <- read_rds(paste0(dir_n, "Togo.rds")) %>% 
mutate(Date = dmy(Date)) %>% 
  filter(Date <= "2022-01-19")

##get the new data that is automated
##cases

all_paths <-
  list.files(path = dir_n_source,
             pattern = "cases",
             full.names = TRUE)

all_content_age_death <-
  all_paths %>%
  lapply(read_xlsx)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content_age_death, all_filenames, SIMPLIFY = FALSE)

togo_cases_in <- rbindlist(all_lists, fill = T) 
names(togo_cases_in)[1] <- "Age"
togo_cases_in <- melt(togo_cases_in, id=c("Age", "V1"))
names(togo_cases_in)[3] <- "Sex"
names(togo_cases_in)[4] <- "Value"
togo_cases_out <- togo_cases_in %>% 
  mutate (Date = substr(V1, 32,39),
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Measure = "Cases",
          Country = "Togo",
          Region = "All",
          Code = "TG",
          Sex = case_when(
            Sex == "Homme" ~ "m",
            Sex == "Femme" ~ "f"
          ),
          Age = case_when(
            Age == "0-4" ~ "0",
            Age == "15-24" ~ "15",
            Age == "25-34" ~ "25",
            Age == "35-44" ~ "35",
            Age == "45-54" ~ "45",
            Age == "5-14" ~ "5",
            Age == "55-64" ~ "55",
            Age == "65-74" ~ "65",
            Age == "75-84" ~ "75",
            Age == "85 et plus" ~ "85" 
          ),
          AgeInt = case_when(
            Age == "0" ~ 5L,
            Age == "85" ~ 20L,
            TRUE ~ 10L
          ),
          Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 


####deaths
all_paths2 <-
  list.files(path = dir_n_source,
             pattern = "death",
             full.names = TRUE)

all_content_age_death2 <-
  all_paths2 %>%
  lapply(read_xlsx)

all_filenames2 <- all_paths2 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists2 <- mapply(c, all_content_age_death2, all_filenames2, SIMPLIFY = FALSE)

togo_deaths_in <- rbindlist(all_lists2, fill = T) 
names(togo_deaths_in)[1] <- "Age"
togo_deaths_in <- melt(togo_deaths_in, id=c("Age", "V1"))
names(togo_deaths_in)[3] <- "Sex"
names(togo_deaths_in)[4] <- "Value"
togo_deaths_out <- togo_deaths_in %>% 
  mutate (Date = substr(V1, 24,31),
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Measure = "Deaths",
          Country = "Togo",
          Region = "All",
          Code = "TG",
          Sex = case_when(
            Sex == "Homme" ~ "m",
            Sex == "Femme" ~ "f"
          ),
          Age = case_when(
            Age == "0-4" ~ "0",
            Age == "15-24" ~ "15",
            Age == "25-34" ~ "25",
            Age == "35-44" ~ "35",
            Age == "45-54" ~ "45",
            Age == "5-14" ~ "5",
            Age == "55-64" ~ "55",
            Age == "65-74" ~ "65",
            Age == "75-84" ~ "75",
            Age == "85 et plus" ~ "85" 
          ),
          AgeInt = case_when(
            Age == "0" ~ 5L,
            Age == "85" ~ 20L,
            TRUE ~ 10L
          ),
          Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 



out <- rbind(previous, togo_cases_out, togo_deaths_out) %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),
                      sprintf("%02d",month(Date)),
                      year(Date),
                      sep=".")) %>% 
  sort_input_data() %>% 
  unique()


write_rds(out, paste0(dir_n, "Togo.rds"))
log_update(pp = ctr, N = nrow(out))
