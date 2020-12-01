
source(here("Automation/00_Functions_automation.R"))

# handle authentications
drive_auth(email = email)
gs4_auth(email = email)

# Get upload urls:
ss_list <- get_input_rubric() %>% 
  filter(Country == "Czechia")


###########################################
################ CASES ####################
###########################################

# NUTS 3 codes
# NUTS3 <- data.frame(
#   code = c("CZ010", "CZ020", "CZ031", "CZ032", 
#            "CZ041", "CZ042", "CZ051", "CZ052", 
#            "CZ053", "CZ063", "CZ064", "CZ071", 
#            "CZ072", "CZ080"), 
#   name = c("Prague", "Central Bohemian Region", "South Bohemian Region", "Plzen Region", 
#            "Karlovy Vary Region", "Usti nad Labe Region", "Liberec Region", "Hradec Kralove Region", 
#            "Pardubice Region", "Vysocina Region", "South Moravian Region", "Olomouc Region", 
#            "Zlin Region", "Moravian-Silesian Region")
# )

NUTS3 <- tibble(
  code = c("CZ010", "CZ020", "CZ031", "CZ032", 
           "CZ041", "CZ042", "CZ051", "CZ052", 
           "CZ053", "CZ063", "CZ064", "CZ071", 
           "CZ072", "CZ080"), 
  name = c("Prague", "Central Bohemia", "South Bohemia", "Plzen", 
           "Karlovy Vary", "Usti nad Labe", "Liberec", "Hradec Kralove", 
           "Pardubice", "Vysocina", "South Moravia", "Olomouc", 
           "Zlin", "Moravia-Silesia")
)
# Getting the data from the Health Ministery website
cases_url <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/osoby.csv" 

cz_cases<-read.csv(cases_url, 
                   header = TRUE, 
                   col.names = c("Date",
                                 "Age", # exact age
                                 "Sex2", # M=male, Z=female
                                 "NUTS3", #region of hygiene station which provides data, according to NUTS 3
                                 "LAU1", # region on LAU1 structure
                                 "Abroad_inf", # 1=claimed to be infected abroad
                                 "Country_inf" # claimed country of infection
                   )) %>% 
  mutate(Sex = ifelse(Sex2 == "M","m","f"), 
         Date = as.Date(Date, "%Y-%m-%d")) %>% 
  select(-Sex2)

cz_cases %>%  dplyr::pull("Age") %>%  unique()

Ages_All <- c(0,1,seq(5,100,by=5))
DateRange <- range(cz_cases$Date)
Dates_All <- seq(DateRange[1],DateRange[2],by="days")

### DATA ON NUTS3 level
cz_cases_region_ss <- 
  cz_cases %>% 
  select("NUTS3",  "Date", "Sex", "Age") %>% 
  mutate(Region = as.factor(NUTS3),
         # grouping age
      Age5 = Age - Age %% 5,
      Age = case_when(Age == 0 ~ 0,
                      Age >= 100 ~ 100,
                      TRUE ~ Age5)
  ) %>% 
  ### select
  select(Region, Date, Sex, Age, -Age5) %>% 
  group_by(Region, Date, Age, Sex) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  ### complete = Turns implicit missing values into explicit missing values => chci 
  ### vektor ttech vek skupin explicitne
  tidyr::complete(Region, 
           Date = Dates_All, 
           Age = Ages_All, 
           Sex, 
           fill = list(Value = 0)) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Region, Date, Sex, Age) %>% 
  mutate(Country = "Czechia",
         AgeInt = case_when(Age == 0 ~ 1,
                            Age == 1 ~ 4,
                            TRUE ~ 5), # what about the 100+? 
         Metric = "Count", 
         Measure = "Cases",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste("CZ", Region, Date, sep = "_")) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)


###########################################
################ DEATHS ###################
###########################################

# Getting the data from the Health Ministery website
deaths_url <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/umrti.csv"

cz_deaths<-read.csv(deaths_url, 
                    header = TRUE, 
                    col.names = c("Date", 
                                  "Age", 
                                  "Sex2", 
                                  "NUTS3", # "kraj" - NUTS 3 administrative unit
                                  "LAU1") # "okres" - LAU 1 administrative unit
) %>% 
  mutate(Sex = ifelse(Sex2 == "M","m","f"),  # no unknown Sex?
         Date = as.Date(Date, "%Y-%m-%d")) %>% 
  select(-Sex2)

cz_deaths %>%  dplyr::pull("Age") %>%  unique()


# we'll use the same Ages_All

DateRangeD <- range(cz_deaths$Date)
Dates_AllD <- seq(DateRange[1],DateRange[2],by="days")

### DATA ON NUTS3 level
cz_deaths_region_ss <- 
  cz_deaths %>% 
  select("NUTS3",  "Date", "Sex", "Age") %>% 
  mutate(Region = as.factor(NUTS3),
         # grouping age
         Age5 = Age - Age %% 5,
         Age = case_when(Age == 0 ~ 0,
                        Age >= 100 ~ 100,
                        TRUE ~ Age5)
  ) %>% 
  select(Region, Date, Sex, Age) %>% 
  group_by(Region, Date, Age, Sex) %>% 
  summarise(Value = n(),
            .groups = "drop") %>% 
  ungroup() %>% 
  tidyr::complete(Region, 
           Date = Dates_AllD, 
           Age = Ages_All, 
           Sex, 
           fill = list(Value = 0)) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Region, Date, Sex,Age) %>% 
  mutate(AgeInt = 5, # what about the 100+? 
         Metric = "Count", 
         Measure = "Deaths",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste("CZ", Region, Date, sep = "_"),
         Country = "Czechia") %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)

# final spreadsheet 

cz_spreadsheet_region <-
  bind_rows(cz_cases_region_ss, 
            cz_deaths_region_ss) %>% 
  left_join(NUTS3, by = c("Region" = "code")) %>% 
  select(Country, Region = name, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#############################################3
# CZ All should be in single ages

Ages_all_single <- 0:100

cz_cases_all_ss <- 
  cz_cases %>% 
  select("NUTS3",  "Date", "Sex", "Age") %>% 
  mutate(Region = "All",
         # grouping age
         Age = ifelse(Age >= 100, 100, Age)) %>% 
  ### select
  select(Region, Date, Sex, Age,) %>% 
  group_by(Region, Date, Age, Sex) %>% 
  summarise(Value = n()) %>% 
  ungroup() %>% 
  ### complete = Turns implicit missing values into explicit missing values => chci 
  ### vektor ttech vek skupin explicitne
  tidyr::complete(Region = "All",
           Date = Dates_All, 
           Age = Ages_all_single, 
           Sex, 
           fill = list(Value = 0)) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Region, Date, Sex, Age) %>% 
  mutate(Country = "Czechia",
         AgeInt = ifelse(Age == 100,5,1), 
         Metric = "Count", 
         Measure = "Cases",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste("CZ", Date, sep = "_")) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)

cz_deaths_all_ss <- 
  cz_deaths %>% 
  select("NUTS3",  "Date", "Sex", "Age") %>% 
  mutate(Region = "All",
         # grouping age
         Age = ifelse(Age >= 100, 100, Age)) %>% 
  select(Region, Date, Sex, Age) %>% 
  group_by(Region, Date, Age, Sex) %>% 
  summarise(Value = n(),
            .groups = "drop") %>% 
  ungroup() %>% 
  tidyr::complete(Region = "All",
           Date = Dates_AllD, 
           Age = Ages_all_single, 
           Sex, 
           fill = list(Value = 0)) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Region, Sex, Age) %>% 
  mutate(Value = cumsum(Value)) %>%  # cumulative!
  ungroup() %>% 
  arrange(Region, Date, Sex, Age) %>% 
  mutate(AgeInt = ifelse(Age == 100,5,1), 
         Metric = "Count", 
         Measure = "Deaths",
         Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste("CZ", Date, sep = "_"),
         Country = "Czechia") %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value)


cz_spreadsheet_all <-
   bind_rows(cz_cases_all_ss,
             cz_deaths_all_ss) %>% 
  select(Country, 
         Region, 
         Code, 
         Date, 
         Sex, 
         Age, 
         AgeInt, 
         Metric, 
         Measure, 
         Value) %>% 
    arrange(dmy(Date), Sex, Measure, Age)




# Start uploads:

ss_all <- ss_list %>% 
  filter(Region == "All") %>% 
  dplyr::pull(Sheet)

write_sheet(cz_spreadsheet_all,
            ss = ss_all,
            sheet = "database")

Sys.sleep(120)

# region loop:

for (i in 1:7){
  reg_i <- paste0("Reg",i)
  ss_i  <- ss_list %>% 
    filter(Region == reg_i) %>% 
    dplyr::pull(Sheet)
  # Two Regions at a time:
  ind     <- (i - 1) * 2 + 1
  regions <- NUTS3[c(ind, ind + 1), ]$name
  
  RegSub <- cz_spreadsheet_region %>% 
    filter(Region %in% regions)
  
  write_sheet(RegSub,
              ss = ss_i,
              sheet = "database")
  
  Sys.sleep(120)
}


# make a note in the automation log
N <- nrow(cz_spreadsheet_region) + nrow(cz_spreadsheet_all)
log_update(pp = "Czechia", N = N)


# upload to Drive. Best if it's a Google Sheet since it doesn't take space.

# only space for one url in rubric.
ss_sources <- ss_list %>% 
  filter(Region == "All") %>% 
  dplyr::pull(Source)


download.file(cases_url, destfile = "cz_cases.csv")
download.file(deaths_url, destfile = "cz_deaths.csv")

# this puts the .csv on the drive
drive_put(media = "cz_cases.csv", 
          path = ss_sources, 
          name = "cz_cases.csv")

drive_put(media = "cz_deaths.csv", 
          path = ss_sources, 
          name = "cz_deaths.csv")

file.remove("cz_cases.csv")
file.remove("cz_deaths.csv")
