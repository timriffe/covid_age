library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Austria"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = email)
gs4_auth(email = email)

# TR: pull urls from rubric instead 
at_rubric <- get_input_rubric() %>% filter(Short == "AT")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)

# reading data from Austria and last date entered 
db_drive <- get_country_inputDB("AT")
db_drive2 <- db_drive %>% 
  mutate(date_f = dmy(Date))

last_date_drive <- max(db_drive2$date_f)

# loading data from the website 
# source deprecated on Jan 31 2021,
# download.file("https://info.gesundheitsministerium.at/data/data.zip", data_source, mode = "wb")
data_source <- paste0(dir_n, "Data_sources/", ctr, "/", ctr, "_data_", today(), ".zip")
download.file("https://covid19-dashboard.ages.at/data/data.zip", data_source, mode = "wb")

db_age <- read_csv2(unz(data_source, "CovidFaelle_Altersgruppe.csv"))
meta <- read_csv2(unz(data_source, "Version.csv"))
date_f <- meta %>% separate(CreationDate, c("date_f", "trash"), " ") %>% dplyr::pull(date_f) %>% dmy

d <- paste(sprintf("%02d", day(date_f)),
           sprintf("%02d", month(date_f)),
           year(date_f), sep = ".")

# verify if new data is not already included in Drive
if (date_f > last_date_drive){
  
  db_age2 <- db_age %>% 
    rename(Cases = Anzahl,
           Deaths = AnzahlTot,
           Region = Bundesland) %>% 
    separate(Altersgruppe, c("Age", "trash"), sep = "-") %>% 
    mutate(Country = "Austria",
           Age = case_when(Age == "<5" ~ "0",
                           Age == ">84" ~ "85",
                           TRUE ~ Age),
           Sex = recode(Geschlecht,
                        "W" = "f",
                        "M" = "m"),
           Date = d,
           Metric = "Count",
           Region = ifelse(Region == "Österreich", "All", Region),
           Code = paste0(ifelse(BundeslandID < 10, paste0("AT_", BundeslandID, "_"), "AT_"), d),
           AgeInt = case_when(Age == "0" ~ "5",
                              Age == "85" ~ "20",
                              Age == "TOT" ~ "",
                              TRUE ~ "10"),
           AgeInt = as.integer(AgeInt)) %>% 
    select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Cases, Deaths) %>% 
    gather(Cases, Deaths, key = "Measure", value = "Value") %>% 
    sort_input_data()
  
  #### updating Google Drive ####
  ###############################
  # This command append new rows at the end of the sheet
  sheet_append(age2,
               ss = ss_i,
               sheet = "database")
  
  
  ### vaccination data ###
  ########################
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
           Age = recode(Age,
                        "25-34" = "25",
                        "35-44" = "35",
                        "45-54" = "45",
                        "55-64" = "55",
                        "65-74" = "65",
                        "75-84" = "75",
                        ">84" = "85")) %>% 
    select(-trash)
  
  unique(vacc2$Sex)
  
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
           Code = paste0(ifelse(BundeslandID < 10, paste0("AT_", BundeslandID, "_"), "AT_"), Date),
           AgeInt = case_when(Age == "0" ~ "25",
                              Age == "85" ~ "20",
                              Age == "TOT" ~ "",
                              TRUE ~ "10"),
           AgeInt = as.integer(AgeInt)) %>% 
    sort_input_data()
  
  
  ### appending last data in drive with new cases and deaths and vaccination data ####
  ####################################################################################
  out <- db_drive2 %>% 
    select(-Short, -date_f) %>% 
    bind_rows(db_age2,
              vacc3) %>% 
    sort_input_data()
  
  
  # saving data in N drive
  ########################
  write_rds(out, paste0(dir_n, ctr, ".rds"))
  
  # updating hydra dashboard
  log_update(pp = ctr, N = nrow(bind_rows(db_age2,
                                          vacc3)))
  
} else if (date_f == last_date_drive) {
  cat(paste0("no new updates so far, last date: ", date_f))
  log_update(pp = ctr, N = 0)
}

  
