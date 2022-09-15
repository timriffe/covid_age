library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Austria"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

print(today())

drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# TR: pull urls from rubric instead 
at_rubric <- get_input_rubric() %>% filter(Short == "AT")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)

#JD: Since August 2021 source uploads whole time series since 02.2020
#changed the structure of the script from append to refresh 
#this overwrites the previous append data 
#old append- code is at the end of the script as comment 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", today(), ".zip")
download.file("https://covid19-dashboard.ages.at/data/data.zip", data_source, mode = "wb")

db_age <- read_csv2(unz(data_source, "CovidFaelle_Altersgruppe.csv"))

#Cases and Deaths 

db_age2= db_age%>%
  select(Region=Bundesland, Time, Altersgruppe, Geschlecht,BundeslandID, Cases=Anzahl, Deaths=AnzahlTot)%>%
  separate(Time, c("Date", "trash"), sep = " ")%>%
  separate(Altersgruppe, c("Age", "trash"), sep = "-") %>%
  mutate(Country = "Austria",
         Age = case_when(Age == "<5" ~ "0",
                         Age == ">84" ~ "85",
                         TRUE ~ Age),
         Sex = recode(Geschlecht,
                      "W" = "f",
                      "M" = "m"),
         Metric = "Count",
         Region = ifelse(Region == "Österreich", "All", Region),
         Code = paste0(ifelse(BundeslandID < 10, paste0("AT-", BundeslandID), "AT")),
         AgeInt = case_when(Age == "0" ~ "5",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         AgeInt = as.integer(AgeInt)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Cases, Deaths) %>% 
  gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
  sort_input_data()

#Cant upload anymore, exceeds 5000000 cell limit
#output data gets saved on N 
# #### updating Google Drive ####
# ###############################
# # Overwrite 
# #cases and death in drive 
# write_sheet(db_age2,
#             ss = ss_i,
#             sheet = "database")


### vaccination data ###
########################

## Source: https://info.gesundheitsministerium.at/opendata#COVID19_vaccination_doses_agegroups
vacc <- read_delim("https://info.gesundheitsministerium.gv.at/data/timeline-eimpfpass.csv", delim = ";")


vacc2 <- vacc %>% 
  select(Datum, Name, BundeslandID, Teilgeimpfte, Vollimmunisierte, starts_with("Gruppe")) %>% 
  gather(-Datum, -Name, -BundeslandID, key = "Group", value = "Value") %>% 
  rename(Date = Datum,
         Region = Name) %>% 
  mutate(Group = str_replace(Group, "e<24", "e_0"),
         Group = case_when(Group == "Teilgeimpfte" ~ "Group_TOT_b_1",
                           Group == "Vollimmunisierte" ~ "Group_TOT_b_2",
                           TRUE ~ Group),
         Region = ifelse(Region == "Österreich", "All", Region), 
         Date = ymd(str_sub(Date, 1, 10))) %>% 
  separate(Group, c("trash", "Age", "Sex", "Measure"), sep = "_") %>%  
  mutate(Measure = paste0("Vaccination", Measure),
         Sex = recode(Sex,
                      "M" = "m",
                      "W" = "f",
                      "D" = "o"),
         Region= recode(Region,
                        "KeineZuordnung"= "UNK"),
         Age = recode(Age,
                      "<15" = "0",
                      "15-24"= "15",
                      "25-34" = "25",
                      "35-44" = "35",
                      "45-54" = "45",
                      "55-64" = "55",
                      "65-74" = "65",
                      "75-84" = "75",
                      ">84" = "85")) %>% 
  select(-trash)


vacc_all_sex <- vacc2 %>% 
  filter(Age != "TOT") %>% 
  group_by(Date, Region, BundeslandID, Age, Measure) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b")



vacc3 <- vacc2 %>% 
  filter(Sex != "o") %>% 
  bind_rows(vacc_all_sex) %>% 
  mutate(Country = "Austria",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0(ifelse(BundeslandID < 10, paste0("AT-", BundeslandID), "AT")),
         AgeInt = case_when(Age == "0" ~ "15",
                            Age == "85" ~ "20",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         AgeInt = as.integer(AgeInt)) %>%
  filter(Age != "NichtZuordenbar") %>%
  mutate(Code = case_when(
    Region == "UNK" ~ "AT-UNK+",
    TRUE ~ Code
  )) %>% 
  sort_input_data()

####################### ========

## MK in 26.07.2022
## IN 29.06.2022, Austria changed the published data to update daily. Also, changes on number of doses and the way they report.
## As a result, we have a gap from 15.12.2021 till 25.07.2022- however, they mentioned that the archive data will be uploaded shortly
## TODO: needs revisiting. In order to lessen lose the data, the following is to download the recent data and append daily. 
## Noting that we have a missing data gap. 
## the vaccine data are updated each day so: we filter the archived data for >= 25.07.2022 and append to the historical & recent data

vacc_archive_2022 <- readRDS(paste0(dir_n, ctr,".rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(str_detect(Measure, "Vaccin"),
         Date >= "2022-07-25") %>% 
  mutate(Date = ddmmyyyy(Date),
         AgeInt = case_when(Age == "UNK" ~ NA_integer_,
                            TRUE ~ AgeInt)) %>% 
  mutate(Region = case_when(
    Region == "Ã–sterreich" ~ "All",
    Region == "KÃ¤rnten" ~ "Kärnten",
    Region == "NiederÃ¶sterreich" ~ "Niederöstereich",
    Region == "OberÃ¶sterreich" ~ "Oberösterreich",
    TRUE ~ Region),
    Measure = case_when(
      Measure == "Vaccination5+" ~ "Vaccination5",
      TRUE ~ Measure))


vacc_today <- read.csv2("https://info.gesundheitsministerium.at/data/COVID19_vaccination_doses_agegroups_v202206.csv") 

vacc_recent <- vacc_today %>% 
  select(Date = 1, 
         state_id, 
         Region = state_name, 
         Age = age_group, Sex = gender, 
         Measure = dose_number,
         Value = doses_administered_cumulative) %>% 
  mutate(Date = ymd(str_sub(Date, 1, 10)),
         Age = recode(Age,
                      "00-11" = "0",
                      "12-14" = "12",
                      "15-24"= "15",
                      "25-34" = "25",
                      "35-44" = "35",
                      "45-54" = "45",
                      "55-64" = "55",
                      "65-74" = "65",
                      "75-84" = "75",
                      "85+" = "85",
                      "NotAssigned" = "UNK"),
         Sex = recode(Sex,
                      "Male" = "m",
                      "Female" = "f",
                      "NonBinary" = "NonBinary",
                      "NotAssigned" = "UNK"),
         Measure = paste0("Vaccination", Measure),
         Region= recode(Region,
                        "NoState"= "UNK")) %>% 
  group_by(Date, Age, Sex, state_id, Region, Measure) %>% 
  summarize(Value = sum(Value)) %>% 
  ungroup() %>% 
  distinct(Date, Age, Sex, Region, state_id,
           Measure, Value) %>% 
  mutate(Country = "Austria",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0(ifelse(state_id < 10, paste0("AT-", state_id), "AT")),
         AgeInt = case_when(Age == "0" ~  12L,
                            Age == "12" ~ 3L,
                            Age == "85" ~ 20L,
                            #Age == "TOT" ~ "",
                            Age == "UNK" ~ NA_integer_,
                            TRUE ~ 10L),
         Code = case_when(Region == "UNK" ~ "AT-UNK+",
                          TRUE ~ Code)) %>% 
  mutate(Region = case_when(
    Region == "Ã–sterreich" ~ "All",
    Region == "KÃ¤rnten" ~ "Kärnten",
    Region == "NiederÃ¶sterreich" ~ "Niederöstereich",
    Region == "OberÃ¶sterreich" ~ "Oberösterreich",
    TRUE ~ Region),
  Measure = case_when(
    Measure == "Vaccination5+" ~ "Vaccination5",
    TRUE ~ Measure)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


# MK:15.09.2022: when the archive is published for the data (29.06.2022- 31.07.2022), I downloaded these and processed it; 
# check (SideWork.Rmd) and so here we bind the processed_data once. 
#vacc_out <- bind_rows(vacc3, processed_data, vacc_archive_2022, vacc_recent)

vacc_out <- bind_rows(vacc3, vacc_archive_2022, vacc_recent)

#Archive vaccine data (the historical raw and all processed)


data_source_vacc <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_historical", ".csv")
write_csv(vacc, data_source_vacc)

data_source_vacc_all <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_sex_all_",today(), ".csv")
write_csv(vacc_out, data_source_vacc_all)

data_source_zip <-  c(data_source_vacc, data_source_vacc_all)


zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_vaccine",
                  today(), 
                  ".zip")
zip::zipr(zipname, 
          data_source_zip, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source_zip)


### combine case/death and vaccine data ####
####################################################################################
out <- 
  bind_rows(db_age2,
            vacc_out) %>% 
  sort_input_data()

# saving data in N drive
########################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))


# END #

#############Outdated Append code################################
# # reading data from Austria and last date entered 
# db_drive <- get_country_inputDB("AT")
# db_drive2 <- db_drive %>% 
#   mutate(date_f = dmy(Date))
# 
# last_date_drive <- max(db_drive2$date_f)
# 
# # loading data from the website 
# # source deprecated on Jan 31 2021,
# # download.file("https://info.gesundheitsministerium.at/data/data.zip", data_source, mode = "wb")
# data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", today(), ".zip")
# download.file("https://covid19-dashboard.ages.at/data/data.zip", data_source, mode = "wb")
# 
# db_age <- read_csv2(unz(data_source, "CovidFaelle_Altersgruppe.csv"))
# meta <- read_csv2(unz(data_source, "Version.csv"))
# date_f <- meta %>% separate(CreationDate, c("date_f", "trash"), " ") %>% dplyr::pull(date_f) %>% dmy
# 
# d <- paste(sprintf("%02d", day(date_f)),
#            sprintf("%02d", month(date_f)),
#            year(date_f), sep = ".")
# 
# # verify if new data is not already included in Drive
# if (date_f > last_date_drive){
#   
#   db_age2 <- db_age %>% 
#     rename(Cases = Anzahl,
#            Deaths = AnzahlTot,
#            Region = Bundesland) %>% 
#     separate(Altersgruppe, c("Age", "trash"), sep = "-") %>% 
#     mutate(Country = "Austria",
#            Age = case_when(Age == "<5" ~ "0",
#                            Age == ">84" ~ "85",
#                            TRUE ~ Age),
#            Sex = recode(Geschlecht,
#                         "W" = "f",
#                         "M" = "m"),
#            Date = d,
#            Metric = "Count",
#            Region = ifelse(Region == "Österreich", "All", Region),
#            Code = paste0(ifelse(BundeslandID < 10, paste0("AT_", BundeslandID, "_"), "AT_"), d),
#            AgeInt = case_when(Age == "0" ~ "5",
#                               Age == "85" ~ "20",
#                               Age == "TOT" ~ "",
#                               TRUE ~ "10"),
#            AgeInt = as.integer(AgeInt)) %>% 
#     select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Cases, Deaths) %>% 
#     gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
#     sort_input_data()
#   
#   #### updating Google Drive ####
#   ###############################
#   # This command append new rows at the end of the sheet
#   sheet_append(db_age2,
#                ss = ss_i,
#                sheet = "database")
#   
#   
#   ### vaccination data ###
#   ########################
#   vacc <- read_delim("https://info.gesundheitsministerium.gv.at/data/timeline-eimpfpass.csv", delim = ";")
#   
#   vacc2 <- vacc %>% 
#     select(Datum, Name, BundeslandID, Teilgeimpfte, Vollimmunisierte, starts_with("Gruppe")) %>% 
#     gather(-Datum, -Name, -BundeslandID, key = "Group", value = "Value") %>% 
#     rename(Date = Datum,
#            Region = Name) %>% 
#     mutate(Group = str_replace(Group, "e<24", "e_0"),
#            Group = case_when(Group == "Teilgeimpfte" ~ "Group_TOT_b_1",
#                              Group == "Vollimmunisierte" ~ "Group_TOT_b_2",
#                              TRUE ~ Group),
#            Region = ifelse(Region == "Österreich", "All", Region), 
#            Date = ymd(str_sub(Date, 1, 10))) %>% 
#     separate(Group, c("trash", "Age", "Sex", "Measure"), sep = "_") %>%  
#     mutate(Measure = paste0("Vaccination", Measure),
#            Sex = recode(Sex,
#                         "M" = "m",
#                         "W" = "f",
#                         "D" = "o"),
#            Age = recode(Age,
#                         "25-34" = "25",
#                         "35-44" = "35",
#                         "45-54" = "45",
#                         "55-64" = "55",
#                         "65-74" = "65",
#                         "75-84" = "75",
#                         ">84" = "85")) %>% 
#     select(-trash)
#   
#   unique(vacc2$Sex)
#   
#   vacc_all_sex <- vacc2 %>% 
#     filter(Age != "TOT") %>% 
#     group_by(Date, Region, BundeslandID, Age, Measure) %>% 
#     summarise(Value = sum(Value)) %>% 
#     ungroup() %>% 
#     mutate(Sex = "b")
#   
#   vacc3 <- vacc2 %>% 
#     filter(Sex != "o") %>% 
#     bind_rows(vacc_all_sex) %>% 
#     mutate(Country = "Austria",
#            Metric = "Count",
#            Date = ddmmyyyy(Date),
#            Code = paste0(ifelse(BundeslandID < 10, paste0("AT_", BundeslandID, "_"), "AT_"), Date),
#            AgeInt = case_when(Age == "0" ~ "25",
#                               Age == "85" ~ "20",
#                               Age == "TOT" ~ "",
#                               TRUE ~ "10"),
#            AgeInt = as.integer(AgeInt)) %>% 
#     sort_input_data()
#   
#   
#   ### appending last data in drive with new cases and deaths and vaccination data ####
#   ####################################################################################
#   out <- db_drive2 %>% 
#     select(-Short, -date_f) %>% 
#     bind_rows(db_age2,
#               vacc3) %>% 
#     sort_input_data()
#   
#   
#   # saving data in N drive
#   ########################
#   write_rds(out, paste0(dir_n, ctr, ".rds"))
#   
#   # updating hydra dashboard
#   log_update(pp = ctr, N = nrow(bind_rows(db_age2,
#                                           vacc3)))
#   
# } else if (date_f == last_date_drive) {
#   cat(paste0("no new updates so far, last date: ", date_f))
#   log_update(pp = ctr, N = 0)
# }

  
