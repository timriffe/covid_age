library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "gatemonte@gmail.com"
}

# info country and N drive address
ctr <- "Germany"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#JD: 24.08.2021- I updated the download link, seems they changed it 
# MK: 13.03.2023: moving to RKI dataset; as Arcgis dashboard stopped working!
## Source website: https://github.com/robert-koch-institut/SARS-CoV-2-Infektionen_in_Deutschland

## Dashboard website: https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4

#cases_url <- "https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data"
cases_url <- "https://media.githubusercontent.com/media/robert-koch-institut/SARS-CoV-2-Infektionen_in_Deutschland/main/Aktuell_Deutschland_SarsCov2_Infektionen.csv"
data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases&deaths_",today(), ".csv")

## MK: 06.07.2022: large file and give download error, so stopped this step and read directly instead
#download.file(cases_url, destfile = data_source, mode = "wb")
# db <- read_csv(cases_url, locale = locale(encoding = "UTF-8"))

db <- vroom::vroom(cases_url)


## Check unique values
unique(db$Geschlecht)
unique(db$IdLandkreis)
#unique(db$Bundesland)

## Raw data 

raw_prepared <- db |> 
  mutate(Sex = case_when(Geschlecht == "M" ~ "m",
                         Geschlecht == "W" ~ "f",
                         Geschlecht == "unbekannt" ~ "UNK"),
         Age = case_when(Altersgruppe == "A00-A04" ~ "0",
                         Altersgruppe == "A05-A14" ~ "5",
                         Altersgruppe == "A15-A34" ~ "15",
                         Altersgruppe == "A35-A59" ~ "35",
                         Altersgruppe == "A60-A79" ~ "60",
                         Altersgruppe == "A80+" ~ "80",
                         Altersgruppe == "unbekannt" ~ "UNK"),
         date_f = ymd(str_sub(Meldedatum, 1, 10)),
         Cases = case_when(AnzahlFall < 0 ~ 0, 
                           TRUE ~ AnzahlFall),
         Deaths = case_when(AnzahlTodesfall < 0 ~ 0, 
                            TRUE ~ AnzahlTodesfall),
         #  Region = Bundesland) |> 
         Region_code = IdLandkreis,
         Number= nchar(Region_code),
         RegID = case_when(Number == "4" ~ substr(Region_code,1,1),
                           TRUE ~ substr(Region_code,1,2)),
         Region= recode(RegID,
                        # "01"="Schleswig-Holstein",
                        # "02"="Hamburg",
                        # "03"="Niedersachsen",
                        # "04"="Bremen",
                        # "05"="Nordrhein-Westfalen",
                        # "06"="Hessen",
                        # "07"="Rheinland-Pfalz",
                        # "08"="Baden-Württemberg",
                        # "09"="Bayern",
                        "1"="Schleswig-Holstein",
                        "2"="Hamburg",
                        "3"="Niedersachsen",
                        "4"="Bremen",
                        "5"="Nordrhein-Westfalen",
                        "6"="Hessen",
                        "7"="Rheinland-Pfalz",
                        "8"="Baden-Württemberg",
                        "9"="Bayern",
                        "10"="Saarland",
                        "11"="Berlin",
                        "12"="Brandenburg",
                        "13"="Mecklenburg-Vorpommern",
                        "14"="Sachsen",
                        "15"="Sachsen-Anhalt",
                        "16"="Thüringen")) |>
  filter(Region!= "17", Region != "u") |> 
  select(date_f, Sex, Age, Cases, Deaths, Region) 
  

## to complete the dataset 

#unique(db_raw_summed$Region)
# unique(db_raw_summed$date_f)

ages    <- sort(unique(raw_prepared$Age))
sexes   <- unique(raw_prepared$Sex)
regions <- unique(raw_prepared$Region)
date_range <- range(raw_prepared$date_f)

# we can expand on days too
dates   <- seq(date_range[1], date_range[2], by = "days")

## National data 

db_national_out <- raw_prepared |> 
  pivot_longer(cols = c("Cases", "Deaths"), 
               names_to = "Measure", values_to ="Value") |> 
  group_by(date_f, Age, Sex, Measure)|>
  summarise(Value = sum(Value))|>
  ungroup()|>
  # tidyr::complete in Germany data
  tidyr::complete(Age, date_f, Sex, Measure, fill=list(Value=0)) |>   
  group_by(Age, Sex, Measure) |>
  arrange(date_f) |> 
  mutate(Value = cumsum(Value))|>
  ungroup() |>
  mutate(Country = "Germany",
         Region = "All",
         Date = ddmmyyyy(date_f),
         Code = paste0("DE"),
         AgeInt = case_when(Age == "0" ~ 5L,
                            Age == "5" ~ 10L,
                            Age == "15" ~ 20L,
                            Age == "35" ~ 25L,
                            Age == "60" ~ 20L,
                            Age == "80" ~ 25L,
                            Age == "UNK" ~ NA_integer_),
         Metric = "Count") |> 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) |> 
  sort_input_data()

## Regional data 
# Regions acronyms from https://en.wikipedia.org/wiki/ISO_3166-2:DE

db_regional_out <- raw_prepared |> 
  pivot_longer(cols = c("Cases", "Deaths"), 
               names_to = "Measure", values_to ="Value") |> 
  group_by(date_f, Age, Sex, Measure, Region)|>
  summarise(Value = sum(Value))|>
  ungroup()|>
  # tidyr::complete in Germany data
  tidyr::complete(Age, date_f, Sex, Measure, Region, fill=list(Value=0)) |>   
  group_by(Age, Sex, Measure, Region) |>
  arrange(date_f) |> 
  mutate(Value = cumsum(Value))|>
  ungroup() |>
  mutate(Country = "Germany",
         Date = ddmmyyyy(date_f),
         Code = case_when(Region == 'Baden-Württemberg' ~ 'DE-BW',
                          Region == 'Bayern' ~ 'DE-BY',
                          Region == 'Berlin' ~ 'DE-BE',
                          Region == 'Brandenburg' ~ 'DE-BB',
                          Region == 'Bremen' ~ 'DE-HB',
                          Region == 'Hamburg' ~ 'DE-HH',
                          Region == 'Hessen' ~ 'DE-HE',
                          Region == 'Mecklenburg-Vorpommern' ~ 'DE-MV',
                          Region == 'Niedersachsen' ~ 'DE-NI',
                          Region == 'Nordrhein-Westfalen' ~ 'DE-NW',
                          Region == 'Rheinland-Pfalz' ~ 'DE-RP',
                          Region == 'Saarland' ~ 'DE-SL',
                          Region == 'Sachsen' ~ 'DE-SN',
                          Region == 'Sachsen-Anhalt' ~ 'DE-ST',
                          Region == 'Schleswig-Holstein' ~ 'DE-SH',
                          Region == 'Thüringen' ~ 'DE-TH',
                          TRUE ~ "DE-UNK+"),
         AgeInt = case_when(Age == "0" ~ 5L,
                            Age == "5" ~ 10L,
                            Age == "15" ~ 20L,
                            Age == "35" ~ 25L,
                            Age == "60" ~ 20L,
                            Age == "80" ~ 25L,
                            Age == "UNK" ~ NA_integer_),
         Metric = "Count") |> 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) |> 
  sort_input_data()




## Bind both datasets and push to Hydra folder 
All_Out <- bind_rows(db_national_out, db_regional_out) |> 
  sort_input_data()
  

  
############################################
#### comparison with reported aggregate data
############################################

# comparison with aggregate data reported online in 
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html

All_Out |> 
  mutate(Date = dmy(Date)) |> 
  group_by() |> 
  filter(Date == max(Date)) |> 
  group_by(Region, Measure) |> 
  summarize(N = sum(Value)) |> 
  select(Region, Measure, N) |> 
  pivot_wider(names_from = Measure, values_from = N)
  

############################################
#### uploading database to Google Drive ####
############################################
write_rds(All_Out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(All_Out))

############################################
#### uploading metadata to Google Drive ####
############################################

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

# END #

# Historical =================
# unique(db$Landkreis)
# 120*411*3*21*2
# Remove days where cumulative sum is 0.
# out <-
#   db_full |> 
#   group_by(Region, Measure, date_f = dmy(Date)) |> 
#   mutate(N = sum(Value)) |> 
#   filter(N > 0) |> 
#   filter(!(Sex == "UNK" & Value == 0),
#          !(Age == "UNK" & Value == 0)) |> 
#   ungroup() |> 
#   select(-date_f, -N) |> 
#   sort_input_data()
