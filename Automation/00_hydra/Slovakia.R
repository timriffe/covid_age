
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")



# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr   <- "Slovakia"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
# dir_n <- "Data/Belgium/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

deaths_url <- "https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_Deaths_AgeGroup_District.csv"
# Date;Gender;District;AgeGroup;Type
DeathsIn <- read_delim(deaths_url, 
                col_types = "ccccc",
                delim=";",
                locale = readr::locale(encoding = "windows-1250"))


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
all_dates <- seq(min(B$Date),max(B$Date),by="days")

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
                         "Čadca" = "Zilina",
                         "?adca" = "Zilina",
                         "Detva" = "Banksa Bystrica",
                         "Dolný Kubín" = "Zilina",
                         "Dunajská Streda" = "Trnava",
                         "Galanta" = "Trnava",
                         "Gelnica" = "Kosice",
                         "Hlohovec" = "Trnava",
                         "Humenne" = "Presov",
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
  arrange(Region,Sex,Age,Date) %>% 
  mutate(Value = cumsum(new)) %>% 
  select(Region,Age,Sex,Date,Value)
  
# aggregate to totals
DeathsAll <-
  Deaths %>% 
  group_by(Date,Sex,Age) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  mutate(Region = "All")

# Make the regional data weekly
Deaths <-
  Deaths %>% 
  filter(weekdays(Date) == "Monday") # ISOweek cut points

# bind together
Deaths <-
  bind_rows(Deaths, DeathsAll)

# add other columns needed
Deaths_out <-
  Deaths %>% 
  mutate(Country = "Slovakia",
         Date = ddmmyyyy(Date),
         Code = paste0("SK",Date),
         Measure = "Deaths",
         Metric = "Count",
         AgeInt = ifelse(Age == "UNK",NA_integer_,5)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

############################################
#### saving database in N Drive ####
############################################
write_rds(Deaths_out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Deaths_out))

############################################
# archive inputs:
############################################
data_source <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")

data.table::fwrite(DeathsIn, file = data_source)

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















# Cases to be worked on once we get a decent jump-off
do.this <- FALSE
if (do.this){
  
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
  mutate(Date = ymd(Date)) %>% 
  select(Date, Sex = Gender, District, Age = AgeGroup)

all_dates_cases <- seq(min(C$Date),max(C$Date),by="days")
all_ages_cases   <- seq(0,120,by=5) %>% as.character()

# Note-region recode should copy from the above one...
Cases <-
  C %>% 
  mutate(Sex = case_when(Sex == "Muž" ~ "m",
                         Sex == "Žena" ~ "f",
                         TRUE ~ "UNK"),
         Region = recode(District,
                         "Banská Bystrica" = "Banksa Bystrica",
                         "Banská Štiavnica" = "Banksa Bystrica",
                         "Bardejov"= "Presov",
                         "Bánovce nad Bebravou" = "Trencin",
                         "Bratislava" = "Bratislava",
                         "Brezno" = "Banksa Bystrica",
                         "Bytca" = "Zilina",
                         "Čadca" = "Zilina",
                         "?adca" = "Zilina",
                         "Detva" = "Banksa Bystrica",
                         "Dolný Kubín" = "Zilina",
                         "Dunajská Streda" = "Trnava",
                         "Galanta" = "Trnava",
                         "Gelnica" = "Kosice",
                         "Hlohovec" = "Trnava",
                         "Humenne" = "Presov",
                         "Ilava" = "Trencin",
                         "Kežmarok" = "Presov",
                         "Komárno" = "Nitra",
                         "Košice" = "Kosice",
                         "Krupina" = "Banksa Bystrica",
                         "Kysucké Nové Mesto" = "Zilina",
                         "Levice" = "Nitra",
                         "Levoca" = "Presov",
                         "Liptovský Mikuláš" = "Zilina",
                         "Lucenec" = "Banksa Bystrica",
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
                         "Poltár" = "Banksa Bystrica",
                         "Poprad" = "Presov",
                         "Považská Bystrica" = "Trencin",
                         "Prešov" = "Presov",
                         "Prievidza" = "Trencin",
                         "Púchov" = "Trencin",
                         "Revúca" = "Banksa Bystrica",
                         "Rimavská Sobota" = "Banksa Bystrica",
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
                         "Turcianske Teplice" = "Zilina",
                         "Tvrdošín" = "Zilina",
                         "Veľký Krtíš" = "Banksa Bystrica",
                         "Vranov nad Toplou" = "Presov",
                         "Zlaté Moravce" = "Nitra",
                         "Zvolen" = "Banksa Bystrica",
                         "Žarnovica" = "Banksa Bystrica",
                         "Žiar nad Hronom" = "Banksa Bystrica",
                         "Žilina" = "Zilina")) %>% 
  group_by(Date, Sex, Region, Age) %>% 
  summarize(new = n(), .groups = "drop") %>% 
  tidyr::complete(Region, 
                  Age = all_ages_cases, 
                  Sex, 
                  Date = all_dates_cases, 
                  fill = list(new = 0)) %>% 
  arrange(Region,Sex,Age,Date) %>% 
  mutate(Value = cumsum(new)) %>% 
  filter(weekdays(Date) == "Sunday") 
}