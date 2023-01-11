## Spain EPI-DATA
## written by: Enrique Acosta


# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

source(here::here("Automation/00_Functions_automation.R"))

ctr <- "Spain"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"


drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## SOURCE <- "https://cnecovid.isciii.es/covid19/#documentaci%C3%B3n-y-datos"

## PDF reports (in case needed): https://www.isciii.es/QueHacemos/Servicios/VigilanciaSaludPublicaRENAVE/EnfermedadesTransmisibles/Paginas/-COVID-19.-Informes-previos.aspx

## MK: 11.11.2022: as published on the dashboard, Due to the change in the COVID-19 Surveillance and Control Strategy, 
## as of March 28, 2022, only cases of COVID-19 in the population aged 60 and over are shown in this panel.


## 01- DOWNLOAD THE DATA AND MERGE THE DATASETS AS THE MANIPULATION REQUIRES CUMSUM ## 

## This is the url for the data by Age and region until 27.03.2022, inclusive; 


url_1 <- "https://cnecovid.isciii.es/covid19/resources/casos_hosp_uci_def_sexo_edad_provres.csv"

raw_data <- read_csv(url_1)


# Cases & Deaths; aged 60 and above (due to change in Surveillance as mentioned above, after 27.03.2022)

url_2 <- "https://cnecovid.isciii.es/covid19/resources/casos_hosp_uci_def_sexo_edad_provres_60_mas.csv"

raw_60 <- read_csv(url_2) %>% 
  dplyr::filter(fecha > "2022-03-27")


## MERGE ALL RAW DATA 

raw_all <- dplyr::bind_rows(raw_data, raw_60)


## 02- PROCESSING THE DATA 

processed_data <- raw_all %>% 
  select(Short = provincia_iso, 
         Sex = sexo, 
         Age = grupo_edad,
         Date = fecha,
         Cases = num_casos,
         Deaths = num_def) %>% 
  mutate(Short = ifelse(is.na(Short),"NA",Short),
         Short = ifelse(Short == "NC", "UNK+", Short),
         Region = recode(Short,
                         "A" = "Alicante",      
                         "AB" = "Albacete",
                         "AL" = "Almeria",
                         "AV" = "Avila",
                         "B" = "Barcelona",
                         "BA" = "Badajoz",
                         "BI" = "Bizkaia",
                         "BU" = "Burgos",
                         "C" = "A Coruña",
                         "CA" = "Cadiz",
                         "CC" = "Caceres",
                         "CE" = "Ceuta",
                         "CO" = "Cordoba",
                         "CR" = "Ciudad Real",
                         "CS" = "Castellon",
                         "CU" = "Cuenca", 
                         "GC" = "Las Palmas", 
                         "GI" = "Girona",      
                         "GR" = "Granada", 
                         "GU" = "Guadalajara", 
                         "H" = "Huelva",  
                         "HU" = "Huesca",
                         "J" = "Jaen",  
                         "L" = "Lleida",  
                         "LE" = "Leon", 
                         "LO" = "La Rioja", 
                         "LU" = "Lugo", 
                         "M" = "Madrid",  
                         "MA" = "Malaga", 
                         "ME" = "Melilla", 
                         "MU" = "Murcia", 
                         "NA" = "Navarra",   
                         "O" = "Asturias",  
                         "OR" = "Ourense", 
                         "P" = "Palencia",  
                         "PM" = "Illes Balears", 
                         "PO" = "Pontevedra", 
                         "S" = "Cantabria",  
                         "SA" = "Salamanca", 
                         "SE" = "Sevilla", 
                         "SG" = "Segovia", 
                         "SO" = "Soria", 
                         "SS" = "Guipuzkoa",
                         "T" = "Tarragona",  
                         "TE" = "Teruel", 
                         "TF" = "Santa Cruz de Tenerife", 
                         "TO" = "Toledo", 
                         "V" = "Valencia",  
                         "VA" = "Valladolid", 
                         "VI" = "Araba", 
                         "Z" = "Zaragoza",  
                         "ZA" = "Zamora",
                         "UNK+" = "UNK",
                          "ML" = "Melilla"),
         Age = recode(Age,
                      "0-9" = "0",
                      "10-19" = "10",
                      "20-29" = "20",
                      "30-39" = "30",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80+" = "80",
                      "NC" = "UNK"),
         Sex = recode(Sex,
                      "H" = "m",
                      "M" = "f",
                      "NC" = "UNK"),
         #Date = ddmmyyyy(Date),
         Country = "Spain",
         Code = paste("ES",Short,sep="-"),
         Metric = "Count",
         AgeInt = case_when(
           Age == "80" ~ 25L,
           Age == "UNK" ~ NA_integer_,
           TRUE ~ 10L
         )) %>% 
  pivot_longer(Cases:Deaths, 
               names_to = "Measure", 
               values_to = "Value") %>% 
  #mutate(date = dmy(Date)) %>% 
  arrange(Region, Sex, Measure, Age, Date) %>% 
  group_by(Region, Sex, Measure, Age) %>% 
  mutate(Value = cumsum(Value)) %>%
  ungroup() %>% 
  # remove region-days with zero cumulative cases.
  group_by(Region, Date) %>% 
  mutate(N = sum(Value)) %>% 
  ungroup() %>% 
  filter(N > 20) %>%
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  mutate(Date = ddmmyyyy(Date)) %>% 
  sort_input_data() 


all_spain <- processed_data %>% 
  group_by(Country, Date, Sex, Age, AgeInt, Metric, Measure) %>% 
  summarise(Value = sum(Value), .groups = "drop") %>% 
  mutate(Region = "All",
         Code = paste("ES")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


## 03- OUTPUT & saving the ORIGINAL DATASET 

Out <- bind_rows(processed_data, all_spain) %>% 
  sort_input_data()


# saving data into N drive
write_rds(Out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(Out))


## Save the source file as zip file 

data_source <- paste0(dir_n, "Data_sources/", ctr)

excels_df <- data.frame(url = c(url_1, url_2),
                        Date = c("2022-03-27", "2022-03-28")) %>% 
  dplyr::mutate(destinations = paste0(data_source, "/", Date, ".csv"))

excels_df %>% 
   {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}

data_source_combined <- excels_df %>% 
  dplyr::pull(destinations)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source_combined, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source_combined)


## END ## 

## Historical code =====================
# out$Region %>% unique()

# Drive credentials
# drive_auth(email = email,
#            scopes = c("https://www.googleapis.com/auth/spreadsheets",
#                                "https://www.googleapis.com/auth/drive"))
# gs4_auth(email = email,
#          scopes = c("https://www.googleapis.com/auth/spreadsheets",
#                     "https://www.googleapis.com/auth/drive"))
# 

# dim(IN)
# glimpse(IN)
# IN$grupo_edad %>% unique()
# unique(IN$sexo) 
# geo_ss <- "https://docs.google.com/spreadsheets/d/1gbP_TTqc96PxeZCpwKuZJB1sxxlfbBjlQj-oxXD2zAs/edit#gid=0"
# geo_lookup <- read_sheet(ss = geo_ss) %>% 
#   mutate(Code = coalesce(`ISO 3166-2`, `Internal Code`)) %>% 
#   dplyr::filter(!is.na(Code))

# out %>% 
#   filter(Region == "Madrid", 
#          Measure == "Deaths") %>% 
#   group_by(Date) %>% 
#   summarize(Value = sum(Value)) %>% 
#   ggplot(aes(x=dmy(Date),y=Value)) + geom_line()
#   
  

