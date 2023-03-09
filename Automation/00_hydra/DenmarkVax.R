
source(here::here("Automation/00_Functions_automation.R"))
library(readr)
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr <- "DenmarkVax"
ctr_n <- "Denmark"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Hydra/Data_sources/Denmark/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



# reading data from Denmark stored in N drive
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
db_n <- read_rds(paste0(dir_n, ctr, ".rds")) 

unique(db_n$Measure)


dates_vacc_n <- db_n %>% 
  dplyr::filter(str_detect(Measure, "Vacc")) %>% 
  dplyr::pull(Date) %>% 
  unique() %>% 
  sort()


# reading new vaccines from the web
## Source: https://covid19.ssi.dk/overvagningsdata/download-fil-med-vaccinationsdata
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
m_url_v <- "https://covid19.ssi.dk/overvagningsdata/download-fil-med-vaccinationsdata"


## MK: 09.03.2023: In 12.2022, Denmark changed the data structure so that:
## Age group: are now based on the current age of the individuals 
## instead of the age the individuals had at the time of the first vaccination,
## Vaccination is: primary vaccination for receiving 2 doses,
## booster one, and booster 2##
## Data collection is changed accordingly, and the previous data structure is deprecated into deprecated folder. 

links_v <- scraplinks(m_url_v) %>% 
  dplyr::filter(str_detect(link, "zip")) %>% 
  separate(link, c("a", "b", "c", "d", "e", "f", "g", "h"))%>%
  mutate(Date= dmy(f)) %>% 
  select(Date, url) %>% 
  drop_na()

links_new_vacc <- links_v %>% 
  dplyr::filter(!Date %in% dates_vacc_n)

links_new_vacc <- links_v[1,]

# downloading new vaccine data and loading it


if(dim(links_new_vacc)[1] > 0){
  for(i in 1:dim(links_new_vacc)[1]){
    
    date_v <- links_new_vacc[i, 1] %>% dplyr::pull()
    data_source_v <- paste0(dir_n, "Data_sources/", 
                            ctr_n, "/VaxSince6-12-2022/", ctr_n, "_vaccines_", as.character(date_v), ".zip")
    download.file(as.character(links_new_vacc[i, 2]), destfile = data_source_v, mode = "wb")
    
    raw_vax <- read.table(unz(data_source_v, "Vaccine_DB/Vaccine_dato_region_alder_forloeb_booster.csv"), sep=";", header=TRUE)
    
    processed_all <- raw_vax %>%
      select(Date = Dato,
             Age = Aldersgruppe,
             Region = Region,
             Vaccination2 = `Antal.primærvaccinerede`,
             Vaccination3 = `Antal.boostervaccinerede`,
             Vaccination4 = `Antal.boostervaccinerede.siden.15..sep`) %>%
      pivot_longer(cols = c("Vaccination2", "Vaccination3", "Vaccination4"),
                   names_to = "Measure", values_to = "Value") %>%
      ## THESE DATA ARE BY REGION, SO WE SUM THE VALUES ##
      group_by(Date, Age, Measure) %>%
      summarise(Value = sum(Value),.groups = "drop") %>%
      mutate(Age = str_extract(Age, "\\d+"),
             Age = case_when(Age == "00" ~ "0",
                             Age == "05" ~ "5",
                             TRUE ~ Age)) %>%
      group_by(Age, Measure) %>%
      arrange(Date) %>%
      summarise(Value = cumsum(Value), Date = Date) %>%
      mutate(Date = ddmmyyyy(Date),
             Country = "Denmark",
             Code = "DK",
             Region = "All",
             Sex = "b",
             AgeInt = case_when(Age == "0" ~ 5L,
                                Age == "5" ~ 5L,
                                Age == "12" ~ 4L,
                                Age == "16" ~ 4L,
                                Age == "20" ~ 20L,
                                Age == "40" ~ 10L,
                                Age == "50" ~ 15L,
                                Age == "65" ~ 20L,
                                Age == "85" ~ 25L),
             Metric = "Count") %>%
      sort_input_data()
    
    processed_region <- raw_vax %>%
      select(Date = Dato,
             Age = Aldersgruppe,
             Region = Region,
             Vaccination2 = `Antal.primærvaccinerede`,
             Vaccination3 = `Antal.boostervaccinerede`,
             Vaccination4 = `Antal.boostervaccinerede.siden.15..sep`) %>%
      pivot_longer(cols = c("Vaccination2", "Vaccination3", "Vaccination4"),
                   names_to = "Measure", values_to = "Value")  %>%
      ## THESE DATA ARE BY REGION, SO WE SUM THE VALUES ##
      group_by(Date, Age, Region, Measure) %>%
      summarise(Value = sum(Value),.groups = "drop") %>%
      mutate(Age = str_extract(Age, "\\d+"),
             Age = case_when(Age == "00" ~ "0",
                             Age == "05" ~ "5",
                             TRUE ~ Age)) %>%
      arrange(Date, Age, Region, Measure) %>%
      group_by(Age, Region, Measure) %>%
      summarise(Value = cumsum(Value), Date = Date) %>%
      ungroup() %>%
      mutate(Date = ddmmyyyy(Date),
             Country = "Denmark",
             Code = case_when(Region == "Hovedstaden" ~ "DK-84",
                              Region == "Midtjylland" ~ "DK-82",
                              Region == "Nordjylland" ~ "DK-81",
                              Region == "Syddanmark" ~ "DK-83",
                              TRUE ~ "DK-85"),
             Sex = "b",
             AgeInt = case_when(Age == "0" ~ 5L,
                                Age == "5" ~ 5L,
                                Age == "12" ~ 4L,
                                Age == "16" ~ 4L,
                                Age == "20" ~ 20L,
                                Age == "40" ~ 10L,
                                Age == "50" ~ 15L,
                                Age == "65" ~ 20L,
                                Age == "85" ~ 25L),
             Metric = "Count") %>%
      sort_input_data()
    
    
    Vax_out <- bind_rows(processed_all, processed_region) %>%
      sort_input_data()
    
    write_rds(Vax_out, paste0(dir_n, ctr, ".rds"))
    
    log_update(pp = ctr, N = nrow(Vax_out))
  } 
} else {
    log_update(pp = ctr, N = "NoUpdate")
}

## END # 
