library(here)
source(here("Automation/00_Functions_automation.R"))
#written by Rafael 
# edited by Jessica
# refactored by Tim (27 Nov, 2021)
lapply(c("tidyverse", "ggpubr", "gridExtra","readr", "googledrive", "googlesheets4"),
       library, character.only=TRUE)


if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address
ctr <- "Chile"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

################# #
# Cases file ####
################# #

# Full list of github hosted data products here: https://github.com/MinCiencia/Datos-COVID19

urlfile_c="https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto16/CasosGeneroEtario_std.csv" 

# Compare these. Does this one have more dates or is it just another format?
# urlfile_c2 <- "https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto16/CasosGeneroEtario.csv"
c_input <- read_csv(url(urlfile_c))
#head(c_input,10)
#tail(c_input,10)
c_input$`Sexo` %>% unique()

#To create data
Cases <- 
  c_input %>% 
  mutate(Date = ddmmyyyy(Fecha),
         Age = substr(`Grupo de edad`,1,2) %>% as.integer() %>% as.character(),
         Sex = tolower(Sexo),
         Measure = "Cases",
         Country = ctr,
         Region = "All",
         Metric = "Count",
         Code = paste0("CL",Date),
         AgeInt = ifelse(Age == "80", 25L,5L)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value = `Casos confirmados`) 

# Deaths #####

#read in deaths in a way that is not affected by changes in the date in link
#new data every thursday 

library(lubridate)
library(RCurl)
guess_chile_url <- function(days = 20){
  dates <- today() - 0:days
  yr    <- year(dates)
  mth   <- sprintf("%02d",month(dates))
  dy    <- sprintf("%02d",day(dates))
  maybe_urls <- paste0("https://repositoriodeis.minsal.cl/DatosAbiertos/VITALES/DEFUNCIONES_FUENTE_DEIS_2016_",yr,"_",dy,mth,yr,".zip")
  
  TF <- sapply(maybe_urls, RCurl::url.exists)
  
  if (!any(TF)){
    cat("none of the dates checked have a valid file,\nplease recheck the url to see if something changed")
    return(NULL)
  }
  
  # most recent date
  most_recent <- max(dates[TF])
  
  correct_url <- maybe_urls[dates == most_recent]
  correct_url
}
"https://repositoriodeis.minsal.cl/DatosAbiertos/VITALES/DEFUNCIONES_FUENTE_DEIS_2016_2021_18112021.zip"
"https://repositoriodeis.minsal.cl/DatosAbiertos/2021/11/DEFUNCIONES_FUENTE_DEIS_2016_2021_18112021.zip"
url_deaths= guess_chile_url()
name_deaths = str_split(url_deaths, pattern = "/") %>% unlist() %>% rev() %>% '['(1)
name_death_file= gsub(name_deaths,pattern="zip",replacement = "csv")

#download.file("http://deis.minsal.cl/wp-content/uploads/2021/03/DEFUNCIONES_FUENTE_DEIS_2016_2021_11032021.zip" # We have to update this link because its date changes every week.
#,temp
#, mode="wb") 
#unzip(data_source_zip, paste0(name_deaths,".csv"))
#dd <- read_delim("DEFUNCIONES_FUENTE_DEIS_2016_2021_11032021.csv", 
#";", escape_double = FALSE, col_names = FALSE, 
# locale = locale(encoding = "latin1"), 
# trim_ws = TRUE)
#file.remove(tmp)


data_source_zip <- paste0(dir_n, "Data_sources/", ctr, "/death_",today(), ".zip")
#download zip file 
options(timeout = 120)
download.file(url_deaths, destfile = data_source_zip,  method = "curl")

#read file from zipfile 
#dd_download= read.csv(unz(data_source_zip, name_death_file), sep = ";", header = FALSE)
# unzip(data_source_zip, files = "Diccionario de Datos BBDD-COVID19 liberada.xlsx")
# metadata <- readxl::read_excel("Diccionario de Datos BBDD-COVID19 liberada.xlsx",range = "B4:E31")
# file.remove("Diccionario de Datos BBDD-COVID19 liberada.xlsx")
# metadata
dd= read_delim(unz(data_source_zip, name_death_file), ";", escape_double = FALSE, col_names = FALSE, 
               locale = locale(encoding = "latin1"), 
               trim_ws = TRUE)

colnames(dd) <- c("ANO_DEF"
                  ,"FECHA_DEF"
                  ,"GLOSA_SEXO"
                  ,"EDAD_TIPO"
                  ,"EDAD_CANT"
                  ,"CODIGO_COMUNA_RESIDENCIA"
                  ,"GLOSA_COMUNA_RESIDENCIA"
                  ,"GLOSA_REG_RES"
                  ,"DIAG1"
                  ,"CAPITULO_DIAG1"
                  ,"GLOSA_CAPITULO_DIAG1"
                  ,"CODIGO_GRUPO_DIAG1"
                  ,"GLOSA_GRUPO_DIAG1"
                  ,"CODIGO_CATEGORIA_DIAG1"
                  ,"GLOSA_CATEGORIA_DIAG1"
                  ,"CODIGO_SUBCATEGORIA_DIAG1"
                  ,"GLOSA_SUBCATEGORIA_DIAG1"
                  ,"DIAG2"
                  ,"CAPITULO_DIAG2"
                  ,"GLOSA_CAPITULO_DIAG2"
                  ,"CODIGO_GRUPO_DIAG2"
                  ,"GLOSA_GRUPO_DIAG2"
                  ,"CODIGO_CATEGORIA_DIAG2"
                  ,"GLOSA_CATEGORIA_DIAG2"
                  ,"CODIGO_SUBCATEGORIA_DIAG2"
                  ,"GLOSA_SUBCATEGORIA_DIAG2"
                  ,"LUGAR_DEFUNCION"#july data has this new column 
)

#glimpse(dd)  

# dd$ <- substr(dd$FECHA_DEF, 7,10)
# dd$ANO_DEF <- as.double(dd$ANO_DEF)
# glimpse(dd)

# Covid19 confirmados y sospechosos

x <- 0:10
between(x,1,9)

dd1 <- dd %>% 
  filter(ANO_DEF >= 2020 & CODIGO_SUBCATEGORIA_DIAG1 == "U071") %>% 
  mutate(EDAD_CANT = ifelse(EDAD_TIPO>1,0,EDAD_CANT), # if >1 == age in days or months
         Age = case_when(EDAD_CANT == 0 ~ "0",
                         between(EDAD_CANT,1,4) ~ "1",
                         between(EDAD_CANT, 100,200) ~ "100",
                         EDAD_CANT > 200 ~ "UNK",
                         TRUE ~ (EDAD_CANT - EDAD_CANT %% 5) %>% as.character()),
         Sex = case_when(GLOSA_SEXO == "Hombre" ~ "m",
                         GLOSA_SEXO == "Mujer" ~ "f",
                         TRUE ~ "UNK")) %>% 
  count(Date = FECHA_DEF, Sex, Age) 

all_dates <- seq(min(dd1$Date), max(dd1$Date),by ="days")
all_ages  <-dd1$Age %>% unique() 
all_sexes <- c("m","f","UNK")

Deaths <-
  dd1 %>% 
  tidyr::complete(Date = all_dates,
           Age = all_ages,
           Sex = all_sexes,
           fill = list(n = 0)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(n)) %>% 
  ungroup() %>% 
  select(-n) %>% 
  mutate(Country = ctr,
         Region = "All",
         Measure = "Deaths",
         Metric = "Count",
         Date = ddmmyyyy(Date),
         Code = paste0("CL",Date),
         AgeInt = case_when(Age == "0" ~ 1L,
                            Age == "1" ~ 4L,
                            Age == "UNK" ~ NA_integer_,
                            TRUE ~ 5L)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  filter(! (Sex == "UNK" & Value == 0),
         ! (Age == "UNK" & Value == 0))


out <- bind_rows(Cases, Deaths) %>% 
  sort_input_data()

dim(out)

#save output on N 

write_rds(out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(out))

#archive data 


data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")

dd_archive <- dd %>% 
  filter(ANO_DEF >= 2020,
         CODIGO_SUBCATEGORIA_DIAG1 == "U071")
write_csv(dd_archive, data_source_1)
write_csv(c_input, data_source_2)


data_source <- c(data_source_1, data_source_2)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)