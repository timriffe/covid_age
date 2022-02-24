
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "e.delfava@gmail.com"
}

# info country and N drive address
ctr <- "Estonia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

cols_in <- cols(
  id = col_character(),
  Gender = col_character(),
  AgeGroup = col_character(),
  Country = col_character(),
  County = col_character(),
  ResultValue = col_character(),
  StatisticsDate = col_date(format = ""),
  ResultTime = col_datetime(format = ""),
  AnalysisInsertTime = col_datetime(format = "")
)

db <- read_csv("https://opendata.digilugu.ee/opendata_covid19_test_results.csv", col_types = cols_in)

RegionCode <- matrix(c(
"EE-37",	"Harju County"
,"EE-39",	"Hiiu County"
,"EE-45",	"Ida-Viru County"
,"EE-52",	"Jarva County"
,"EE-50",	"Jogeva County"
,"EE-60",	"Laane-Viru County"
,"EE-56",	"Laane County"
,"EE-68",	"Parnu County"
,"EE-64",	"Polva County"
,"EE-71",	"Rapla County"
,"EE-74",	"Saare County"
,"EE-79",	"Tartu County",
"EE-UNK+","UNK"), ncol = 2, byrow = TRUE,
dimnames = list(NULL, c("Code","Region"))) %>% 
  as_tibble()

# db$County %>% unique()
# db$ResultTime %>% as_date() %>% table()
db2 <- db %>% 
  select(-id) %>% 
  rename(Sex = Gender) %>% 
  tidyr::separate(AgeGroup, c("Age","age2"), "-") %>% 
  mutate(Test = 1,
         Case = ifelse(ResultValue == "P", 1, 0),
         date_f =  as_date(ResultTime),
         Sex = case_when(Sex == 'N' ~ 'f',
                         Sex == 'M' ~ 'm',
                         TRUE ~ 'UNK'),
         Age = readr::parse_number(Age) %>% as.character(),
         Age = replace_na(Age, "UNK"),
         Code = case_when(
           County == "Harju maakond" ~ "EE-37",
           County == "Hiiu maakond" ~ "EE-39",
           County == "Ida-Viru maakond" ~ "EE-45",
           County == "Järva maakond" ~ "EE-52",
           County == "Jõgeva maakond" ~ "EE-50",
           County == "Lääne-Viru maakond" ~ "EE-60",
           County == "Lääne maakond" ~ "EE-56",
           County == "Pärnu maakond" ~ "EE-68",
           County == "Põlva maakond" ~ "EE-64",
           County == "Rapla maakond" ~ "EE-71",
           County == "Saare maakond" ~ "EE-74",
           County == "Tartu maakond" ~ "EE-79",
           County == "Võru maakond" ~ "EE-87",
           County == "Valga maakond" ~ "EE-81",
           County == "Viljandi maakond" ~ "EE-84",
           TRUE ~ "EE-UNK+"
         )) %>% 
  dplyr::filter(date_f >= dmy("01.01.2020")) %>% 
  group_by(date_f, Code, Age, Sex) %>% 
  summarise(Cases = sum(Case),
            Tests = sum(Test),
            .groups = "drop") %>% 
  pivot_longer(Cases:Tests, names_to = "Measure", values_to = "new") 

db3 <- db2 %>% 
  tidyr::complete(date_f = unique(db2$date_f), 
                  Code = unique(db2$Code),
                  Sex = unique(db2$Sex), 
                  Age = unique(db2$Age), 
                  Measure, 
                  fill = list(new = 0)) %>% 
  arrange(Code, Sex, Measure, Age, date_f) %>% 
  group_by(Code, Sex, Measure, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  arrange(Code, date_f, Sex, Measure, Age) %>% 
  ungroup() %>% 
  select(-new)

# TR: calculate Region All
db_tot <-  
  db3 %>% 
  group_by(date_f, Sex, Age, Measure) %>% 
  summarize(Value = sum(Value),
            .groups = "drop") %>% 
  mutate(Code = "EE")
  
# TR: these steps aren't necessary at the data entry stage.
# The R pipeline does all this.
# db4 <- db3 %>% 
#   group_by(date_f, Sex, Measure) %>% 
#   summarise(Value = sum(Value)) %>% 
#   mutate(Age = "TOT") %>%
#   ungroup() 
# 
 # db5 <- db3 %>% 
 #   group_by(date_f, Measure) %>% 
 #   summarise(Value = sum(Value)) %>% 
 #   mutate(Sex = "b", Age = "TOT") %>% 
 #   ungroup() 
# 
 # db6 <- db3 %>% 
 #   group_by(date_f, Age, Measure) %>% 
 #   summarise(Value = sum(Value)) %>% 
 #   mutate(Sex = "b") %>% 
 #   ungroup() 

db_all <- bind_rows(db3, 
                    db_tot) %>% 
  dplyr::filter(
    !(Age == "UNK" & Value == 0),
    !(Sex == "UNK" & Value == 0)) %>%
  mutate(Date = ddmmyyyy(date_f),
         Country = "Estonia",
         # Code = paste0("EE"),
         AgeInt = case_when(Age == "TOT" | Age == "UNK" ~ NA_real_, 
                            Age == "85" ~ 20,
                            TRUE ~ 5),
         Metric = "Count") %>% 
  left_join(RegionCode, by = "Code") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()

# remove date-counties with no cumulative cases (no effect?)
db_all <-
  db_all %>% 
  group_by(Code, Date) %>% 
  mutate(keep_ = sum(Value[Measure == "Cases"]) > 0) %>% 
  dplyr::filter(keep_) %>% 
  select(-keep_)
###########################
#### Saving data in N: ####
###########################

# database
write_rds(db_all, paste0(dir_n, ctr, ".rds"))
log_update(pp = "Estonia", N = nrow(db_all))

# datasource
data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&tests_",today(), ".csv")

write_csv(db, data_source)

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

