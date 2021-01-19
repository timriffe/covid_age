
library(readr)
library(lubridate)
library(tidyverse)
# Date;Gender;District;AgeGroup;Type
DeathsIn <- read_delim("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_Deaths_AgeGroup_District.csv", 
                col_types = "ccccc",
                delim=";",
                locale = readr::locale(encoding = "windows-1250"))

temp <- tempfile(fileext=".csv")
download.file("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_PositiveTests_AgeGroup_District.csv",
              destfile = temp)
# CasesIn <- read_delim(temp, 
#                        col_types = "cccc",
#                        delim=";",
#                        locale = readr::locale(encoding = "windows-1250"))
CasesIn <- read.table(temp,
           header = TRUE,
           sep = ";",
           colClasses = c("character","character","character","character"),
           encoding = "windows-1250")
unlink(temp)
# guess_encoding("https://raw.githubusercontent.com/Institut-Zdravotnych-Analyz/covid19-data/main/OpenData_Slovakia_Covid_Deaths_AgeGroup_District.csv")

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
                         "Čadca" = "Zilina" ,
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
  tidyr::complete(Region, Age = all_ages, Sex, Date = all_dates, fill = list(new = 0)) %>% 
  arrange(Region,Sex,Age,Date) %>% 
  mutate(Value = cumsum(new)) %>% 
  filter(weekdays(Date) == "Sunday") 
  
  
all_ages <- seq(0,100,by=5) %>% as.character()

C <- 
  CasesIn %>% 
  mutate(Date = ymd(Date)) %>% 
  select(Date, Sex = Gender, District, Age = AgeGroup)

all_dates_cases <- seq(min(C$Date),max(C$Date),by="days")
all_ages_cases   <- seq(0,120,by=5) %>% as.character()

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
                         "Čadca" = "Zilina" ,
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
