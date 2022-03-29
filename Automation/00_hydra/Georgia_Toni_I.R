### 1. try (Toni): Georgia source website
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

## if (! "email" %in% ls()){
## email <- "maxi.s.kniffka@gmail.com"
## }

# info country and N drive address
ctr    <- "Georgia"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- paste0("N:/COVerAGE-DB/Automation/", ctr, "/")

###save previous data that has been collected mannual
# previous <- read_rds(paste0(dir_n, "Georgia.rds")) %>% 
#   mutate(Date = dmy(Date)) %>% 
#   filter(Date <= "2022-03-29")

##get the new data that is automated
##vaccination1


all_paths <-
  list.files(path = dir_n_source,
             pattern = ".xlsx",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_xlsx, skip = 1)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

georgia_in <- rbindlist(all_lists, fill = T) 

names(georgia_in)[1] <- "Age"
names(georgia_in)[2] <- "Vaccination1"
names(georgia_in)[3] <- "Vaccination2"
names(georgia_in)[4] <- "Vaccination3"



georgia_vaccination1_in <- melt(georgia_in, id=c("Age", "V1"))
names(georgia_vaccination1_in)[3] <- "Sex"
names(georgia_vaccination1_in)[4] <- "Value"
georgia_vaccination1_out <- georgia_vaccination1_in %>% 
  mutate (Date = substr(V1, 32,39), ## noch kontrollieren
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Measure = "Vaccination",
          Country = "Georgia",
          Region = "All",
          Code = "GE",
          Sex = vaccination1_when(
            Sex == "Homme" ~ "m",
            Sex == "Femme" ~ "f"
          ),
          Age = vaccination1_when(
            Age == "0-11" ~ "0",
            Age == "12-15" ~ "12",
            Age == "16-17" ~ "16",
            Age == "18-49" ~ "18",
            Age == "50-54" ~ "50",
            Age == "60-64" ~ "60",
            Age == "65-69" ~ "65",
            Age == "70-74" ~ "75",
            Age == "75 et plus" ~ "75" 
          ),
          AgeInt = vaccination1_when(
            Age == "0" ~ 5L,
            Age == "85" ~ 20L,
            TRUE ~ 10L
          ),
          Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

## Vaccination2
all_paths2 <-
  list.files(path = dir_n_source,
             pattern = "vaccination2",
             full.names = TRUE)

all_content_age_vaccination2 <-
  all_paths2 %>%
  lapply(read_xlsx)

all_filenames2 <- all_paths2 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists2 <- mapply(c, all_content_age_vaccination2, all_filenames2, SIMPLIFY = FALSE)

georgia_vaccination2_in <- rbindlist(all_lists2, fill = T) 
names(georgia_vaccination2_in)[1] <- "Age"
georgia_vaccination2_in <- melt(georgia_vaccination2_in, id=c("Age", "V1"))
names(georgia_vaccination2_in)[3] <- "Sex"
names(georgia_vaccination2_in)[4] <- "Value"
georgia_vaccination2_out <- georgia_vaccination2_in %>% 
  mutate (Date = substr(V1, 32,39), ## noch kontrollieren
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Measure = "Vaccination2",
          Country = "Georgia",
          Region = "All",
          Code = "GE",
          Sex = vaccination2_when(
            Sex == "Homme" ~ "m",
            Sex == "Femme" ~ "f"
          ),
          Age = vaccination2_when(
            Age == "0-11" ~ "0",
            Age == "12-15" ~ "12",
            Age == "16-17" ~ "16",
            Age == "18-49" ~ "18",
            Age == "50-54" ~ "50",
            Age == "60-64" ~ "60",
            Age == "65-69" ~ "65",
            Age == "70-74" ~ "75",
            Age == "75 et plus" ~ "75" 
          ),
          AgeInt = vaccination2_when(
            Age == "0" ~ 5L,
            Age == "85" ~ 20L,
            TRUE ~ 10L
          ),
          Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 


## Vaccination3
all_paths3 <-
  list.files(path = dir_n_source,
             pattern = "vaccination3",
             full.names = TRUE)

all_content_age_vaccination3 <-
  all_paths3 %>%
  lapply(read_xlsx)

all_filenames3 <- all_paths3 %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists3 <- mapply(c, all_content_age_vaccination3, all_filenames3, SIMPLIFY = FALSE)

georgia_vaccination3_in <- rbindlist(all_lists3, fill = T) 
names(georgia_vaccination3_in)[1] <- "Age"
georgia_vaccination3_in <- melt(georgia_vaccination3_in, id=c("Age", "V1"))
names(georgia_vaccination3_in)[3] <- "Sex"
names(georgia_vaccination3_in)[4] <- "Value"
georgia_vaccination3_out <- georgia_vaccination3_in %>% 
  mutate (Date = substr(V1, 32,39), ## noch kontrollieren
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Measure = "Vaccination3",
          Country = "Georgia",
          Region = "All",
          Code = "GE",
          Sex = vaccination3_when(
            Sex == "Homme" ~ "m",
            Sex == "Femme" ~ "f"
          ),
          Age = vaccination3_when(
            Age == "0-11" ~ "0",
            Age == "12-15" ~ "12",
            Age == "16-17" ~ "16",
            Age == "18-49" ~ "18",
            Age == "50-54" ~ "50",
            Age == "60-64" ~ "60",
            Age == "65-69" ~ "65",
            Age == "70-74" ~ "75",
            Age == "75 et plus" ~ "75" 
          ),
          AgeInt = vaccination3_when(
            Age == "0" ~ 5L,
            Age == "85" ~ 20L,
            TRUE ~ 10L
          ),
          Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

###drive
rubric_i <- get_input_rubric() %>% filter(Short == "GE")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)
db_drive <-  read_sheet(ss = ss_i, sheet = "database") %>% 
  mutate(Date = dmy(Date)) 






out <- rbind(previous, georgia_vaccination1_out, georgia_vaccination2_out, georgia_vaccination3_out) %>%
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),
                      sprintf("%02d",month(Date)),
                      year(Date),
                      sep=".")) %>% 
  sort_input_data() %>% 
  unique()


write_rds(out, paste0(dir_n, "Georgia.rds"))
log_update(pp = ctr, N = nrow(out))

