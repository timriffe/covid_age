source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Mexico"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# Loading data from nextcloud
#############################
source_dir <- "U:/nextcloud/Projects/COVID_19/COVerAGE-DB/mexico"
file_names <- list.files(source_dir, pattern = "\\.zip$")

ctr_dir <- paste0(dir_n, "Data_sources/", ctr)
file_names_already <- list.files(ctr_dir, pattern = "\\.zip$")

# only coping new data 
new_data <- file_names[!(file_names %in% file_names_already)]
dest_dir <- paste0(dir_n, "Data_sources/", ctr, "/", new_data)
file.copy(paste0(source_dir, "/", new_data), dest_dir, T)


if (identical(new_data, character(0))){
  print("no new updates")
  log_update(pp = ctr, N = 0)
  
} else {
  # choosing the last date to update the database
  all_dates <- ymd(str_sub(new_data, 13, 22))
  last_date <- max(all_dates) 
  data_source <- paste0(source_dir, "/mexico_data_", last_date, ".zip")
  
  db <- 
    read_csv(data_source)
  
  unique(db$SEXO)
  unique(db$EDAD)
  unique(db$ENTIDAD_RES) %>% as.numeric() %>% sort()
  table(db$ENTIDAD_RES)
  
  # filter confirmed cases and standardize data ----------------------------------------
  
  db_t <- db %>% 
    filter(TOMA_MUESTRA_LAB == 1) %>% 
    rename(Age = EDAD,
           date_t = FECHA_INGRESO) %>% 
    mutate(Sex = case_when(SEXO == 1 ~ "f",
                           SEXO == 2 ~ "m",
                           T ~ "UNK"),
           Age = ifelse(Age >= 100, 100, Age),
           Region = case_when(
             ENTIDAD_RES == '01' ~ 'Aguascalientes',
             ENTIDAD_RES == '02' ~ 'Baja California',
             ENTIDAD_RES == '03' ~ 'Baja California Sur',
             ENTIDAD_RES == '04' ~ 'Campeche',
             ENTIDAD_RES == '05' ~ 'Coahuila de Zaragoza',
             ENTIDAD_RES == '06' ~ 'Colima',
             ENTIDAD_RES == '07' ~ 'Chiapas',
             ENTIDAD_RES == '08' ~ 'Chihuahua',
             ENTIDAD_RES == '09' ~ 'Ciudad de Mexico',
             ENTIDAD_RES == '10' ~ 'Durango',
             ENTIDAD_RES == '11' ~ 'Guanajuato',
             ENTIDAD_RES == '12' ~ 'Guerrero',
             ENTIDAD_RES == '13' ~ 'Hidalgo',
             ENTIDAD_RES == '14' ~ 'Jalisco',
             ENTIDAD_RES == '15' ~ 'Mexico',
             ENTIDAD_RES == '16' ~ 'Michoacan de Ocampo',
             ENTIDAD_RES == '17' ~ 'Morelos',
             ENTIDAD_RES == '18' ~ 'Nayarit',
             ENTIDAD_RES == '19' ~ 'Nuevo Leon',
             ENTIDAD_RES == '20' ~ 'Oaxaca',
             ENTIDAD_RES == '21' ~ 'Puebla',
             ENTIDAD_RES == '22' ~ 'Queretaro',
             ENTIDAD_RES == '23' ~ 'Quintana Roo',
             ENTIDAD_RES == '24' ~ 'San Luis Potosi',
             ENTIDAD_RES == '25' ~ 'Sinaloa',
             ENTIDAD_RES == '26' ~ 'Sonora',
             ENTIDAD_RES == '27' ~ 'Tabasco',
             ENTIDAD_RES == '28' ~ 'Tamaulipas',
             ENTIDAD_RES == '29' ~ 'Tlaxcala',
             ENTIDAD_RES == '30' ~ 'Veracruz de Ignacio de la Llave',
             ENTIDAD_RES == '31' ~ 'Yucatan',
             ENTIDAD_RES == '32' ~ 'Zacatecas',
             TRUE ~ 'Other'
           )) %>% 
    group_by(Sex, Age, date_t, Region) %>% 
    summarise(new = sum(n())) %>% 
    ungroup() 
  
  
  db2 <- db %>% 
    filter(CLASIFICACION_FINAL <= 3) %>% 
    rename(Age = EDAD,
           date_c = FECHA_SINTOMAS,
           date_d = FECHA_DEF) %>% 
    mutate(Sex = case_when(SEXO == 1 ~ "f",
                           SEXO == 2 ~ "m",
                           T ~ "UNK"),
           Age = ifelse(Age >= 100, 100, Age),
           Region = case_when(
             ENTIDAD_RES == '01' ~ 'Aguascalientes',
             ENTIDAD_RES == '02' ~ 'Baja California',
             ENTIDAD_RES == '03' ~ 'Baja California Sur',
             ENTIDAD_RES == '04' ~ 'Campeche',
             ENTIDAD_RES == '05' ~ 'Coahuila de Zaragoza',
             ENTIDAD_RES == '06' ~ 'Colima',
             ENTIDAD_RES == '07' ~ 'Chiapas',
             ENTIDAD_RES == '08' ~ 'Chihuahua',
             ENTIDAD_RES == '09' ~ 'Ciudad de Mexico',
             ENTIDAD_RES == '10' ~ 'Durango',
             ENTIDAD_RES == '11' ~ 'Guanajuato',
             ENTIDAD_RES == '12' ~ 'Guerrero',
             ENTIDAD_RES == '13' ~ 'Hidalgo',
             ENTIDAD_RES == '14' ~ 'Jalisco',
             ENTIDAD_RES == '15' ~ 'Mexico',
             ENTIDAD_RES == '16' ~ 'Michoacan de Ocampo',
             ENTIDAD_RES == '17' ~ 'Morelos',
             ENTIDAD_RES == '18' ~ 'Nayarit',
             ENTIDAD_RES == '19' ~ 'Nuevo Leon',
             ENTIDAD_RES == '20' ~ 'Oaxaca',
             ENTIDAD_RES == '21' ~ 'Puebla',
             ENTIDAD_RES == '22' ~ 'Queretaro',
             ENTIDAD_RES == '23' ~ 'Quintana Roo',
             ENTIDAD_RES == '24' ~ 'San Luis Potosi',
             ENTIDAD_RES == '25' ~ 'Sinaloa',
             ENTIDAD_RES == '26' ~ 'Sonora',
             ENTIDAD_RES == '27' ~ 'Tabasco',
             ENTIDAD_RES == '28' ~ 'Tamaulipas',
             ENTIDAD_RES == '29' ~ 'Tlaxcala',
             ENTIDAD_RES == '30' ~ 'Veracruz de Ignacio de la Llave',
             ENTIDAD_RES == '31' ~ 'Yucatan',
             ENTIDAD_RES == '32' ~ 'Zacatecas',
             TRUE ~ 'Other'
           )) %>% 
    select(Sex, Age, date_c, date_d, Region) 
  
  unique(db2$Region)
  
  db_d <- db2 %>% 
    filter(!is.na(date_d))
  
  db_c <- db2 %>% 
    filter(!is.na(date_c))
  
  ages <- seq(0, 100, 1)
  
  dates_d <- seq(min(db_d$date_d), max(max(db_d$date_d), max(db_c$date_c)), by = '1 day')
  
  dates_c <- seq(min(db_c$date_c), max(max(db_d$date_d), max(db_c$date_c)), by = '1 day')
  
  dates_t <- seq(ymd("2020-03-01"), max(db_t$date_t), by = '1 day')
  
  
  
  
  # deaths ---------------------------------------------------------------------------
  
  db_d2 <- db_d %>% 
    group_by(Region, Sex, Age, date_d) %>% 
    summarise(new = n()) %>% 
    ungroup()
  
  db_d3 <- db_d2 %>% 
    tidyr::complete(Region, Sex, Age = ages, date_d = dates_d, fill = list(new = 0)) %>% 
    group_by(Region, Sex, Age) %>% 
    mutate(Value = cumsum(new),
           Age = as.character(Age),
           Measure = "Deaths") %>% 
    rename(date_f = date_d) %>% 
    select(-new)
  
  # cases ---------------------------------------------------------------------------
  
  db_c2 <- db_c %>% 
    group_by(Region, Sex, Age, date_c) %>% 
    summarise(new = n()) %>% 
    ungroup()
  
  db_c3 <- db_c2 %>% 
    tidyr::complete(Region, Sex, Age = ages, date_c = dates_c, fill = list(new = 0)) %>% 
    group_by(Region, Sex, Age) %>% 
    mutate(Value = cumsum(new),
           Age = as.character(Age),
           Measure = "Cases") %>% 
    rename(date_f = date_c) %>% 
    select(-new)
  
  # tests ---------------------------------------------------------------------------
  
  db_t2 <- db_t %>% 
    tidyr::complete(Region, Sex, Age = ages, date_t = dates_t, fill = list(new = 0)) %>% 
    group_by(Region, Sex, Age) %>% 
    mutate(Value = cumsum(new),
           Age = as.character(Age),
           Measure = "Tests") %>% 
    rename(date_f = date_t) %>% 
    select(-new)
  
  # template for database -------------------------------------------------------
  db_dc <- bind_rows(db_d3, db_c3, db_t2)
  
  db_mx <- db_dc %>% 
    group_by(date_f, Sex, Age, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Region = "All")
  
  # 5-year age intervals for regional data -------------------------------
  
  db_dc2 <- db_dc %>% 
    mutate(Age2 = as.character(floor(as.numeric(Age)/5) * 5)) %>% 
    group_by(date_f, Region, Sex, Age2, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    arrange(date_f, Region, Measure, Sex, suppressWarnings(as.integer(Age2))) %>% 
    ungroup() %>% 
    rename(Age = Age2)
  # ----------------------------------------------------------------------
  
  db_mx_comp <- bind_rows(db_dc2, db_mx)
  
  db_tot_age <- db_mx_comp %>% 
    group_by(Region, date_f, Sex, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Age = "TOT")
  
  db_tot <- db_mx_comp %>% 
    group_by(Region, date_f, Measure) %>% 
    summarise(Value = sum(Value)) %>% 
    ungroup() %>% 
    mutate(Sex = "b",
           Age = "TOT")
  
  db_inc <- db_tot %>% 
    filter(Measure == "Deaths",
           Value >= 50) %>% 
    group_by(Region) %>% 
    summarise(date_start = ymd(min(date_f)))
  
  db_all <- bind_rows(db_mx_comp, db_tot_age, db_tot)
  
  db_all2 <- db_all %>% 
    left_join(db_inc) %>% 
    drop_na() %>% 
    filter((Region == "All" & date_f >= "2020-03-20") | date_f >= date_start)
  
  out <- db_all2 %>% 
    mutate(Country = "Mexico",
           AgeInt = case_when(Region == "All" & !(Age %in% c("TOT", "100")) ~ 1,
                              Region != "All" & !(Age %in% c("0", "1", "TOT")) ~ 5,
                              Region != "All" & Age == "0" ~ 1,
                              Region != "All" & Age == "1" ~ 4,
                              Age == "100" ~ 5,
                              Age == "TOT" ~ NA_real_),
           Date = paste(sprintf("%02d",day(date_f)),
                        sprintf("%02d",month(date_f)),
                        year(date_f),
                        sep="."),
           iso = case_when(
             Region == 'All' ~ 'MX',
             Region == 'Ciudad de Mexico' ~ 'MX-CMX',
             Region == 'Aguascalientes' ~ 'MX-AGU',
             Region == 'Baja California' ~ 'MX-BCN',
             Region == 'Baja California Sur' ~ 'MX-BCS',
             Region == 'Campeche' ~ 'MX-CAM',
             Region == 'Coahuila de Zaragoza' ~ 'MX-COA',
             Region == 'Colima' ~ 'MX-COL',
             Region == 'Chiapas' ~ 'MX-CHP',
             Region == 'Chihuahua' ~ 'MX-CHH',
             Region == 'Durango' ~ 'MX-DUR',
             Region == 'Guanajuato' ~ 'MX-GUA',
             Region == 'Guerrero' ~ 'MX-GRO',
             Region == 'Hidalgo' ~ 'MX-HID',
             Region == 'Jalisco' ~ 'MX-JAL',
             Region == 'Mexico' ~ 'MX-MEX',
             Region == 'Michoacan de Ocampo' ~ 'MX-MIC',
             Region == 'Morelos' ~ 'MX-MOR',
             Region == 'Nayarit' ~ 'MX-NAY',
             Region == 'Nuevo Leon' ~ 'MX-NLE',
             Region == 'Oaxaca' ~ 'MX-OAX',
             Region == 'Puebla' ~ 'MX-PUE',
             Region == 'Queretaro' ~ 'MX-QUE',
             Region == 'Quintana Roo' ~ 'MX-ROO',
             Region == 'San Luis Potosi' ~ 'MX-SLP',
             Region == 'Sinaloa' ~ 'MX-SIN',
             Region == 'Sonora' ~ 'MX-SON',
             Region == 'Tabasco' ~ 'MX-TAB',
             Region == 'Tamaulipas' ~ 'MX-TAM',
             Region == 'Tlaxcala' ~ 'MX-TLA',
             Region == 'Veracruz de Ignacio de la Llave' ~ 'MX-VER',
             Region == 'Yucatan' ~ 'MX-YUC',
             Region == 'Zacatecas' ~ 'MX-ZAC',
             TRUE ~ "MX-UNK+"
           ),
           Code = paste0(iso),
           Metric = "Count") %>% 
    arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
    select(Country, Region, Code,  Date, Sex, Age, AgeInt, Metric, Measure, Value)
  
  #########################
  # Saving output in N:/ drive 
  ############################
  
  write_rds(out, paste0(dir_n, ctr, ".rds"))
  
  # updating hydra dashboard
  log_update(pp = ctr, N = nrow(out))
  
  file.remove(paste0(source_dir, "/", file_names))
}
