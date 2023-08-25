
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source(here::here("Automation/00_Functions_automation.R"))


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr   <- "Slovakia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
# dir_n <- "Data/Belgium/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## Source website: https://github.com/Institut-Zdravotnych-Analyz/covid19-data

cases_url <- "https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/PCR_Tests/OpenData_Slovakia_Covid_PositiveTests_AgeGroup_District.csv"

deaths_url <- "https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/Deaths/OpenData_Slovakia_Covid_Deaths_AgeGroup_District.csv"
# Date;Gender;District;AgeGroup;Type
DeathsIn <- read_delim(deaths_url, 
                       col_types = cols(.default = "c"),
                       delim=";",
                       locale = readr::locale(encoding = "windows-1250"))

unique(DeathsIn$Region)

# helper function due to inconsistent date codes
c_as_date <- function(x){
  as.Date(as.integer(x), 
          origin = "1899-12-30")
}

all_ages <- seq(0,100,by=5) %>% as.character()

B <- 
  DeathsIn %>% 
  mutate(Date1 = suppressWarnings(dmy(Date)),
         Date = case_when(is.na(Date1) ~ c_as_date(Date),
         TRUE ~ Date1))  %>% 
  select(Date, Sex = Gender, District, Age = AgeGroup)  
  

# daily series, for complete() expansion
all_dates <- seq(min(B$Date, na.rm = TRUE),max(B$Date,na.rm = TRUE),by="days")

for (i in 1:5){
ind <- is.na(B$Date) 
if (any(ind)){
  ind <- ind %>% which()
B$Date[ind] <- B$Date[ind + 1]
} else {break}
}

Deaths <-
  B %>% 
  mutate(Sex = case_when(Sex == "M" ~ "m",
                         Sex == "F" ~ "f",
                         TRUE ~ "UNK"),
         Region = recode(District,
                         "Banská Bystrica" = "Banksa Bystrica",
                         "Banská Štiavnica" = "Banksa Bystrica",
                         "Bardejov"= "Presov",
                         "Bánovce nad Bebravou" = "Trencin",
                         "Bratislava" = "Bratislava",
                         "Brezno" = "Banksa Bystrica",
                         "Bytca" = "Zilina",
                         "Byt?a" = "Zilina",
                         "Čadca" = "Zilina",
                         "?adca" = "Zilina",
                         "Detva" = "Banksa Bystrica",
                         "Dolný Kubín" = "Zilina",
                         "Dunajská Streda" = "Trnava",
                         "Galanta" = "Trnava",
                         "Gelnica" = "Kosice",
                         "Hlohovec" = "Trnava",
                         "Humenne" = "Presov",
                         "Humenné" = "Presov",
                         "Ilava" = "Trencin",
                         "Kežmarok" = "Presov",
                         "Komárno" = "Nitra",
                         "Košice" = "Kosice",
                         "Krupina" = "Banksa Bystrica",
                         "Kysucké Nové Mesto" = "Zilina",
                         "Levice" = "Nitra",
                         "Levoca" = "Presov",
                         "Levo?a" = "Presov",
                         "Liptovský Mikuláš" = "Zilina",
                         "Lucenec" = "Banksa Bystrica",
                         "Lu?enec" = "Banksa Bystrica",
                         "Malacky" = "Bratislava",
                         "Martin" = "Zilina",
                         "Medzilaborce" = "Presov",
                         "Michalovce" = "Kosice",
                         "Myjava" = "Trencin",
                         "Námestovo" = "Zilina",
                         "Nitra" = "Nitra",
                         "Nové Mesto nad Váhom" = "Trencin",
                         "Nové Mesto n.Váhom"= "Trencin",
                         "Nové Zámky" = "Nitra",
                         "Partizánske" = "Trencin",
                         "Pezinok" = "Bratislava",
                         "Piešťany" = "Trnava",
                         "Pieš?any" = "Trnava",
                         "Poltár" = "Banksa Bystrica",
                         "Poprad" = "Presov",
                         "Považská Bystrica" = "Trencin",
                         "Prešov" = "Presov",
                         "Prievidza" = "Trencin",
                         "Púchov" = "Trencin",
                         "Revúca" = "Banksa Bystrica",
                         "Rimavská Sobota" = "Banksa Bystrica",
                         "Rožňava" = "Kosice",
                         "Rož?ava" = "Kosice",
                         "Ružomberok" = "Zilina",
                         "Sabinov" = "Presov",
                         "Senec" = "Bratislava",
                         "Senica" = "Trnava",
                         "Skalica" = "Trnava",
                         "Snina" = "Presov",
                         "Sobrance" = "Kosice",
                         "Spišská Nová Ves" = "Kosice",
                         "Stará Ľubovňa" = "Presov",
                         "Stará ?ubov?a" = "Presov",
                         "Stropkov" = "Presov",
                         "Svidník" = "Presov",
                         "Šaľa" = "Nitra",
                         "Ša?a" = "Nitra",
                         "Topolcany" = "Nitra",
                         "Topo??any" = "Nitra",
                         "Trebišov" = "Kosice",
                         "Trenčín" = "Trencin",
                         "Tren?ín" = "Trencin",
                         "Trnava" = "Trnava",
                         "Turcianske Teplice" = "Zilina",
                         "Tvrdošín" = "Zilina",
                         "Veľký Krtíš" = "Banksa Bystrica",
                         "Ve?ký Krtíš" = "Banksa Bystrica",
                         "Vranov nad Toplou" = "Presov",
                         "Vranov nad Top?ou" = "Presov",
                         "Zlaté Moravce" = "Nitra",
                         "Zvolen" = "Banksa Bystrica",
                         "Žarnovica" = "Banksa Bystrica",
                         "Žiar nad Hronom" = "Banksa Bystrica",
                         "Žilina" = "Zilina")) %>% 
  group_by(Date, Sex, Region, Age) %>% 
  summarize(new = n(), .groups = "drop") %>% 
  tidyr::complete(Region, Age = all_ages, Sex, Date = all_dates, fill = list(new = 0)) %>% 
  arrange(Region, Sex, Age, Date) %>% 
  group_by(Sex, Region, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(Region,Age,Sex,Date,Value) %>% 
  ungroup()
  
unique(Deaths$Region)

# aggregate to totals
DeathsAll <-
  Deaths %>% 
  group_by(Date,Sex,Age) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  mutate(Region = "All")

# Make the regional data weekly
Deaths <-
  Deaths %>% 
  filter(weekdays(Date) == "Monday") %>%  # ISOweek cut points
  drop_na()

# bind together
Deaths <-
  bind_rows(Deaths, DeathsAll)

# add other columns needed
Deaths_out <-
  Deaths %>% 
  mutate(Country = "Slovakia",
         Date = ddmmyyyy(Date),
         Code = paste0("SK"),
         Measure = "Deaths",
         Metric = "Count",
         AgeInt = ifelse(Age == "UNK",NA_integer_,5)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  # provisional fix while special characters are solved more appropriately
  filter(Region == "All")



# Cases
#######

  CasesIn <- read_delim(cases_url, 
                         col_types = cols(.default = "c"),
                         delim=";",
                        locale = locale(encoding = "UTF-8"))
  
  # temp <- tempfile(fileext=".csv")
  # download.file("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_PositiveTests_AgeGroup_District.csv",
  #               destfile = temp)
  # # CasesIn <- read_delim(temp, 
  # #                        col_types = "cccc",
  # #                        delim=";",
  # #                        locale = readr::locale(encoding = "windows-1250"))
  # CasesIn <- read.table(temp,
  #            header = TRUE,
  #            sep = ";",
  #            colClasses = c("character","character","character","character"),
  #            encoding = "windows-1250")
  # unlink(temp)
  # guess_encoding("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_Deaths_AgeGroup_District.csv")
  
C <- 
  CasesIn %>% 
  mutate(Date = ymd(Date),
         Age = as.double(AgeGroup)) %>% 
  select(Date, Sex = Gender, District, Age)

unique(C$Age) %>% sort

all_dates_cases <- seq(min(C$Date),max(C$Date),by="days")
# all_ages_cases   <- seq(0, 100, by=5) %>% as.character()

# Note-region recode should copy from the above one...
Cases <-
  C %>% 
  mutate(Sex = case_when(Sex == "Muž" ~ "m",
                         Sex == "Žena" ~ "f",
                         TRUE ~ "UNK"),
         dist2 = str_replace_all(District, "[^[A-Za-z,]]", " "),
         Region = recode(District,
                         "Banská Bystrica" = "Banksa Bystrica",
                         "Banská Štiavnica" = "Banksa Bystrica",
                         "Bardejov"= "Presov",
                         "Bánovce nad Bebravou" = "Trencin",
                         "Bratislava" = "Bratislava",
                         "Brezno" = "Banksa Bystrica",
                         "Bytca" = "Zilina",
                         "Bytča" = "Zilina",
                         "Čadca" = "Zilina",
                         "Čadca" = "Zilina",
                         "?adca" = "Zilina",
                         "Detva" = "Banksa Bystrica",
                         "Dolný Kubín" = "Zilina",
                         "Dunajská Streda" = "Trnava",
                         "Galanta" = "Trnava",
                         "Gelnica" = "Kosice",
                         "Hlohovec" = "Trnava",
                         "Humenne" = "Presov",
                         "Humenné" = "Presov",
                         "Ilava" = "Trencin",
                         "Kežmarok" = "Presov",
                         "Komárno" = "Nitra",
                         "Košice" = "Kosice",
                         "Košice - okolie" = "Kosice",
                         "Krupina" = "Banksa Bystrica",
                         "Kysucké Nové Mesto" = "Zilina",
                         "Levice" = "Nitra",
                         "Levoca" = "Presov",
                         "Levoča" = "Presov",
                         "Liptovský Mikuláš" = "Zilina",
                         "Lucenec" = "Banksa Bystrica",
                         "Lučenec" = "Banksa Bystrica",
                         "Malacky" = "Bratislava",
                         "Martin" = "Zilina",
                         "Medzilaborce" = "Presov",
                         "Michalovce" = "Kosice",
                         "Myjava" = "Trencin",
                         "Námestovo" = "Zilina",
                         "Nitra" = "Nitra",
                         "Nové Mesto nad Váhom" = "Trencin",
                         "Nové Zámky" = "Nitra",
                         "Partizánske" = "Trencin",
                         "Pezinok" = "Bratislava",
                         "Piešťany" = "Trnava",
                         "Piešťany" = "Trnava",
                         "Poltár" = "Banksa Bystrica",
                         "Poprad" = "Presov",
                         "Považská Bystrica" = "Trencin",
                         "Prešov" = "Presov",
                         "Prievidza" = "Trencin",
                         "Púchov" = "Trencin",
                         "Revúca" = "Banksa Bystrica",
                         "Rimavská Sobota" = "Banksa Bystrica",
                         "Rožňava" = "Kosice",
                         "Rožňava" = "Kosice",
                         "Ružomberok" = "Zilina",
                         "Sabinov" = "Presov",
                         "Senec" = "Bratislava",
                         "Senica" = "Trnava",
                         "Skalica" = "Trnava",
                         "Snina" = "Presov",
                         "Sobrance" = "Kosice",
                         "Spišská Nová Ves" = "Kosice",
                         "Stará Ľubovňa" = "Presov",
                         "Stropkov" = "Presov",
                         "Svidník" = "Presov",
                         "Šaľa" = "Nitra",
                         "Topolcany" = "Nitra",
                         "Trebišov" = "Kosice",
                         "Trenčín" = "Trencin",
                         "Trnava" = "Trnava",
                         "Turčianske Teplice" = "Zilina",
                         "Tvrdošín" = "Zilina",
                         "Veľký Krtíš" = "Banksa Bystrica",
                         "Veľký Krtíš" = "Banksa Bystrica",
                         "Vranov nad Topľou" = "Presov",
                         "Zlaté Moravce" = "Nitra",
                         "Zvolen" = "Banksa Bystrica",
                         "Žarnovica" = "Banksa Bystrica",
                         "Žiar nad Hronom" = "Banksa Bystrica",
                         "Žilina" = "Zilina"),
         Age = case_when(Age >= 100 & Age <= 120 ~ 100,
                         Age == 995 ~ NA_real_,
                         TRUE ~ Age)) %>% 
  group_by(Date, Sex, Region, Age) %>% 
  summarize(new = n(), .groups = "drop") %>% 
  tidyr::complete(Region, 
                  Age, 
                  Sex, 
                  Date = all_dates_cases, 
                  fill = list(new = 0)) %>% 
  arrange(Region,Sex,Age,Date) %>% 
  group_by(Sex, Region, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Age = ifelse(is.na(Age), "UNK", as.character(Age)))


# unique(Cases$Region)

# Cases <-
#   C %>%
#   mutate(Sex = case_when(Sex == "Muž" ~ "m",
#                          Sex == "Žena" ~ "f",
#                          TRUE ~ "UNK"),
#          dist2 = str_replace_all(District, "[^[A-Za-z,]]", " "))
# 
# unique(Cases$dist2) %>% sort


# aggregate to totals
CasesAll <-
  Cases %>% 
  group_by(Date,Sex,Age) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  mutate(Region = "All")

# Make the regional data weekly
Cases <-
  Cases %>% 
  filter(weekdays(Date) == "Monday") %>%  # ISOweek cut points
  drop_na()

# bind together
Cases <-
  bind_rows(Cases, CasesAll)

# add other columns needed
Cases_out <-
  Cases %>% 
  mutate(Country = "Slovakia",
         Date = ddmmyyyy(Date),
         Code = paste0("SK"),
         Measure = "Cases",
         Metric = "Count",
         AgeInt = ifelse(Age == "UNK",NA_integer_,5)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  # provisional fix while special characters are solved more appropriately
  filter(Region == "All")

# Binding together cases and deaths
out <- 
  bind_rows(Deaths_out, Cases_out) %>% 
  sort_input_data()

############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
#log_update(pp = ctr, N = nrow(Deaths_out))

############################################
# archive inputs:
############################################
data_source_d <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")
data_source_c <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")

data.table::fwrite(DeathsIn, file = data_source_d)
data.table::fwrite(CasesIn, file = data_source_c)

data_source <- c(data_source_d, data_source_c)

# Save out source data
zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_deaths_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)

#######################################

# out %>% 
#   filter(Region == "All") %>% 
#   mutate(Date = dmy(Date)) %>% 
#   group_by(Measure) %>% 
#   filter(Date == max(Date)) %>% 
#   summarise(Value = sum(Value))

