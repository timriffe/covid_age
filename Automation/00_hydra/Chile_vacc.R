library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Chile"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "CL")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)

# obtaining cases and deaths data from Drive
db_drive <- 
  get_country_inputDB("CL") %>% 
  select(-Short)


# vaccination data
##################

vacc <- read_csv("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto76/rango_etario_std.csv")

vacc2 <- 
  vacc %>% 
  rename(Age = 1,
         Date = Fecha,
         Value = Cantidad,
         Measure = Dosis) %>% 
  mutate(Age = ifelse(Age == "Total", "TOT", str_sub(Age, 1, 2)),
         Measure = recode(Measure,
                          "Primera" = "Vaccination1",
                          "Segunda" = "Vaccination2"))

ages <- c(unique(vacc2$Age), "0")

vacc3 <- 
  vacc2 %>% 
  tidyr::complete(Age = ages, Measure, Date, fill = list(Value = 0)) %>% 
  filter(!Date %in% vacc_drive) %>% 
  mutate(Country = "Chile",
         Region = "CL",
         Date = ddmmyyyy(Date),
         Code = paste0("CL", Date),
         AgeInt = case_when(Age == "0" ~ "15",
                            Age == "15" ~ "3",
                            Age == "18" ~ "22",
                            Age == "70" ~ "3",
                            Age == "73" ~ "2",
                            Age == "75" ~ "3",
                            Age == "78" ~ "3",
                            Age == "81" ~ "4",
                            Age == "87" ~ "3",
                            Age == "90" ~ "15",
                            Age == "TOT" ~ "",
                            TRUE ~ "10"),
         AgeInt = as.integer(AgeInt),
         Metric = "Count",
         Sex = "b") 

# bind_rows(db_drive2) %>%
out <- db_drive %>% 
  filter(!Measure %in% c("Vaccination1", "Vaccination2")) %>% 
  bind_rows(vacc3) %>% 
  sort_input_data()

################################
#### Saving data in N drive ####
################################
write_rds(out, paste0(dir_n, ctr, ".rds"))
# This command append new rows at the end of the sheet
log_update(pp = "Chile_vaccines", N = nrow(vacc3))

############################################
#### uploading metadata to N Drive ####
############################################

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccines_age_",today(), ".csv")

write_csv(vacc, data_source)
