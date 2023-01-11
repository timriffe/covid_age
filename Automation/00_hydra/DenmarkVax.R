
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


## MK: 15.12.2022 Vaccination Data until 05.12.2022 =======

## based on revieiwng closely the previous data, there was an issue with the sex-age data; when sum to get the totals, 
## the data looks as decreasing, possibly there was unknown values/ other genders that are not included. 
## Plus, the data we have did not start from the date the data published! 
## so here I read the final available vaccination data before 06.12.2022 and adjust the collection code! 

# raw_2022 <- read.table(file = paste0(dir_n_source, "VaxSince6-12-2022/till5_12_2022_Vaccine_dato_region_alder_vaccage.csv"), 
#                        sep=";", header=TRUE)
# 
# 
# processed_2022_all <- raw_2022 %>% 
#   rename(Date = 1,
#          Age = 2,
#          Region = 3,
#          Vaccination1 = 4,
#          Vaccination2 = 5,
#          Vaccination3 = 6,
#          Vaccination4 = 7) %>%
#   pivot_longer(cols = c("Vaccination1", "Vaccination2", "Vaccination3", "Vaccination4"), 
#                names_to = "Measure", values_to = "Value") %>%
#   ## THESE DATA ARE BY REGION, SO WE SUM THE VALUES ##
#   group_by(Date, Age, Measure) %>%
#   summarise(Value = sum(Value),.groups = "drop") %>%
#   mutate(
#     Age = str_sub(Age, 1, 2),
#     Age = case_when(Age == "0-" ~ "0",
#                     is.na(Age) ~ "UNK",
#                     TRUE ~ Age)) %>% 
#   group_by(Age, Measure) %>% 
#   arrange(Date) %>% 
#   summarise(Value = cumsum(Value), Date = Date) %>% 
#   mutate(Date = ddmmyyyy(Date),
#          Country = "Denmark",
#          Code = "DK",
#          Region = "All",
#          Sex = "b",
#          AgeInt = case_when(Age == "90" ~ 15L,
#                             Age == "TOT" ~ NA_integer_,
#                             Age == "UNK" ~ NA_integer_,
#                             TRUE ~ 10L),
#          Metric = "Count") %>% 
#   sort_input_data()
# 
# 
# processed_2022_region <- raw_2022 %>% 
#   rename(Date = 1,
#          Age = 2,
#          Region = 3,
#          Vaccination1 = 4,
#          Vaccination2 = 5,
#          Vaccination3 = 6,
#          Vaccination4 = 7) %>%
#   pivot_longer(cols = c("Vaccination1", "Vaccination2", "Vaccination3", "Vaccination4"), 
#                names_to = "Measure", values_to = "Value") %>%
#   ## THESE DATA ARE BY REGION, SO WE SUM THE VALUES ##
#   group_by(Date, Age, Region, Measure) %>%
#   summarise(Value = sum(Value),.groups = "drop") %>%
#   mutate(
#     Age = str_sub(Age, 1, 2),
#     Age = case_when(Age == "0-" ~ "0",
#                     is.na(Age) ~ "UNK",
#                     TRUE ~ Age)) %>% 
#   arrange(Date, Age, Region, Measure) %>% 
#   group_by(Age, Region, Measure) %>% 
#   summarise(Value = cumsum(Value), Date = Date) %>% 
#   ungroup() %>% 
#   mutate(Date = ddmmyyyy(Date),
#          Country = "Denmark",
#          Code = case_when(Region == "Hovedstaden" ~ "DK-84",
#                           Region == "Midtjylland" ~ "DK-82",
#                           Region == "Nordjylland" ~ "DK-81",
#                           Region == "Syddanmark" ~ "DK-83",
#                           TRUE ~ "DK-85"),
#          Sex = "b",
#          AgeInt = case_when(Age == "90" ~ 15L,
#                             Age == "TOT" ~ NA_integer_,
#                             Age == "UNK" ~ NA_integer_,
#                             TRUE ~ 10L),
#          Metric = "Count") %>% 
#   sort_input_data()
# 
# 
# Vax_out_2022 <- bind_rows(processed_2022_all, processed_2022_region) %>% 
#   sort_input_data()
# 
# write_rds(Vax_out_2022, paste0(dir_n, ctr, ".rds"))

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


#JD: After 18.04. naming of the files changed, adapting the str_detect to the new format 
#otherwise new files get filtered out 

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
    
    log_update(pp = ctr, N = "Downloaded")
  } 
} else {
    log_update(pp = ctr, N = "NoUpdate")
}


# 
# db_vcc0 <- tibble()
# 
# if(dim(links_new_vacc)[1] > 0){
#    for(i in 1:dim(links_new_vacc)[1]){
#     
#     date_v <- links_new_vacc[i, 1] %>% dplyr::pull()
#     data_source_v <- paste0(dir_n, "Data_sources/", 
#                             ctr, "/", ctr, "_vaccines_", as.character(date_v), ".zip")
#     download.file(as.character(links_new_vacc[i, 2]), destfile = data_source_v, mode = "wb")
#     
#     db_v <- read.table(unz(data_source_v, "Vaccine_DB/Vaccine_region_alder_koen_vaccage.csv"), sep=";", header=TRUE)
#     #try(db_v <- read_csv(unz(data_source_v, "ArcGIS_dashboards_data/Vaccine_DB/Vaccinationer_region_aldgrp_koen.csv")))
#     
#     db_v2 <- db_v %>% 
#       rename(Age = 2,
#              Sex = 3,
#              Vaccination1 = 4,
#              Vaccination2 = 5,
#              Vaccination3 = 6,
#              Vaccination4 = 7) %>% 
#       gather(Vaccination1, Vaccination2, Vaccination3, Vaccination4, key = Measure, value = Value) %>% 
#       ## THESE DATA ARE BY REGION, SO WE SUM THE VALUES ## 
#       group_by(Age, Sex, Measure) %>% 
#       summarise(Value = sum(Value),.groups = "drop") %>% 
#       mutate(Sex = recode(Sex,
#                           "K" = "f",
#                           "M" = "m"),
#              Age = str_sub(Age, 1, 2),
#              Age = case_when(Age == "0-" ~ "0",
#                              is.na(Age) ~ "UNK",
#                              TRUE ~ Age),
#              Date = date_v)
#     
#     db_v3 <- 
#       db_v2 %>% 
#       bind_rows(
#         db_v2 %>% 
#           group_by(Sex, Measure, Date) %>% 
#           summarise(Value = sum(Value), .groups = "drop") %>% 
#           mutate(Age = "TOT")
#       ) %>% 
#       dplyr::filter(Age != "UNK")
#     
#     db_vcc1 <- db_vcc0 %>% 
#       bind_rows(db_v3)
#     
#   }
#  }
# 
# db_vcc <- tibble()
# 
# if(dim(links_new_vacc)[1] > 0 | dim(links_new_cases)[1] > 0){
#   db_vcc <- 
#     db_vcc1 %>% 
#     mutate(Date = ddmmyyyy(Date),
#            Country = "Denmark",
#            Code = "DK",
#            Region = "All",
#            AgeInt = case_when(Age == "90" ~ 15L, 
#                               Age == "TOT" ~ NA_integer_,
#                               Age == "UNK" ~ NA_integer_,
#                               TRUE ~ 10L),
#            Metric = "Count") 
# }
# 
# out <- 
#   bind_rows(db_n, db_vcc) %>% 
#   mutate(Date = ddmmyyyy(Date)) %>% 
#   sort_input_data() %>% 
#   distinct() # TR: should be without effect,
#             # and will not remove redundancies
            # if values are different

# TR: this pipeline ended with %>% unique. Is there not a better and more rigorous way to remove redundancies?
# unique 
  

###########################
#### Saving data in N: ####
###########################
#write_rds(out, paste0(dir_n, ctr, ".rds"))
#log_update(pp = ctr, N = nrow(out))


### Historical code ===========================


# mutate(Value = as.character(Value)) %>%
# mutate(Value = case_when((Code == "DK03.06.2021" & Age == "TOT" & Measure == "Deaths") ~ "2517",
#                           TRUE ~ Value)) %>% 
# mutate(Value = as.numeric(Value))


# links_v <- scraplinks(m_url_v) %>% 
#   filter(str_detect(link, "zip")) %>% 
#   separate(link, c("a", "b", "c", "d", "e", "f", "g", "h")) %>% 
#   mutate(Date = make_date(y = h, m = g, d = f)) %>% 
#   select(Date, url) %>% 
#   drop_na() 



# # Fixing issue of vaccines: 
# # ~~~~~~~~~~~~~~~~~~~~~~~~~
# # excluding total age, 'Vaccines' measure, adding age 0 (12.04.2021)
# temp_vacc <- db_n %>%
#   filter(Measure %in% c("Vaccination1", "Vaccination2"),
#          Age != "TOT",
#          Sex != "b") %>%
#   select(Date, Sex, Age, Measure, Value) %>% 
#   tidyr::complete(Date, Sex, Age, Measure, fill = list(Value = 0)) %>% 
#   arrange(Date, Measure, Sex, Age) %>% 
#   mutate(Date = ddmmyyyy(Date),
#          Country = "Denmark",
#          Code = paste0("DK", Date),
#          Region = "All",
#          AgeInt = case_when(Age == "90" ~ 15L, 
#                             Age == "TOT" ~ NA_integer_,
#                             Age == "UNK" ~ NA_integer_,
#                             TRUE ~ 10L),
#          Metric = "Count") %>% 
#   sort_input_data() %>% 
#   mutate(Date = dmy(Date))
#   
# db_n <- 
#   db_n %>% 
#   filter(!Measure %in% c("Vaccination1", "Vaccination2", "Vaccinations")) %>% 
#   bind_rows(temp_vacc) 

