# deprecated
library(here)
source(here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address
ctr <- "ES_Basque_Country"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# get current state of database
PVin <- get_country_inputDB("ES_PV") #%>% 
  #select(-Short)

# get drive links
ES_PV_meta <- 
  get_input_rubric() %>% 
  filter(Short == "ES_PV")

# input template
ss_i <-
  ES_PV_meta %>% 
  dplyr::pull(Sheet)
# source data folder
ss_m <- ES_PV_meta %>% 
  dplyr::pull(Source)

# once-off fix to Code:
# 
# PVin <- PVin %>% 
#   mutate(Code = paste0("ES_PV_", Date)) %>% 
#   select(-Short)

# get file list from open web folder:
PVfiles <- readLines("https://opendata.euskadi.eus/contenidos/ds_informes_estudios/covid_19_2020/opendata/historico-situacion-epidemiologica.txt")

# Filter down to 'situacion-epidemiologica'
PVdownloads <- PVfiles[grepl(PVfiles,pattern="situacion-epidemiologica.xlsx")]

# examine the date pattern
# PVdownloads %>% 
#   gsub(pattern="https://opendata.euskadi.eus/contenidos/ds_informes_estudios/covid_19_2020/opendata/",replacement="") %>% 
#   gsub(pattern="/situacion-epidemiologica.xlsx",replacement = "")

# custom function to extract proper date from the url string.

PVdate <- function(xurl){
  pathdate <-
    xurl %>% 
    gsub(pattern="https://opendata.euskadi.eus/contenidos/ds_informes_estudios/covid_19_2020/opendata/",replacement="") %>% 
    gsub(pattern="/situacion-epidemiologica.xlsx",replacement = "")
  
  m <- substr(pathdate,start=1,stop=2)
  y <- substr(pathdate,start=3,stop=4) %>% 
    as.integer() %>% 
    '+'(2000)
  d <- substr(pathdate,start=6,stop=7)
  lubridate::ymd(paste(y,m,d,sep="."))
}

ES_PV_dir <- paste0(dir_n, "Data_sources/", ctr, "/")
# if (!dir.exists(ES_PV_dir)){
#   dir.create(ES_PV_dir)
# }

xurl <- "https://opendata.euskadi.eus/contenidos/ds_informes_estudios/covid_19_2020/opendata/1120/22/situacion-epidemiologica.xlsx"

# Download all situation report excel files
lapply(PVdownloads, function(xurl){
  refdate <- PVdate(xurl)
  destfile <- paste0(ES_PV_dir, "/situacion-epidemiologica",refdate,".xlsx")
  download.file(xurl, destfile = destfile, mode="wb")
})

# list of excel files
files <- dir(ES_PV_dir)
files <- files[grepl(files,pattern = ".xlsx")]

# read_excel(here("Data","ES_PV",files[1]),sheet = "03") %>% 
#   colnames()

# check correct columns present
all_colnames <- lapply(files, function(x){
  names_in <- read_excel(paste0(ES_PV_dir, x), sheet = "03", n_max = 12) %>% 
    colnames()
  all(c("Kasu positiboak / Positivos" , 
        "Hildakoak / Fallecidos(*)" ) %in% 
        names_in)
}) %>% unlist() 

# which files have age?
files_b <- files[all_colnames]

# and which have age and sex?
sex_colnames <-
  lapply(files, function(x){
    names_in <- read_excel(paste0(ES_PV_dir, x), sheet = "03",n_max = 12) %>% 
      colnames()
    all(c("Kasu positiboak / Positivos" , "Hildakoak / Fallecidos(*)","Emakumezkoak: Kasu positiboak / Mujeres: Positivos" ) %in% names_in)
  }) %>% unlist()

files_fm <- files[sex_colnames]

# ---------------------------------------------------
# Read in both-sex columns tables, and bind
# these are given in all dates
Tables_b <-
  lapply(files_b, function(x){
    Date <- gsub(pattern = "situacion-epidemiologica",replacement = "",x) %>% as_date()
    read_excel(paste0(ES_PV_dir, x),sheet = "03",n_max = 12) %>% 
      select(Age = `Adina / Edad`,
             Cases_b = `Kasu positiboak / Positivos`,
             Deaths_b = `Hildakoak / Fallecidos(*)`) %>% 
      mutate(Date = Date,
             Cases = suppressWarnings(as.integer(Cases_b)),
             Deaths = suppressWarnings(as.integer(Deaths_b)),
             Sex = "b") %>% 
      select(Date, Sex, Age, Cases, Deaths)
  }) %>% 
  bind_rows()

# report for sex-specific tables, which start at a later date 
Tables_m_f <- lapply(files_fm, function(x){
  Date <- gsub(pattern = "situacion-epidemiologica",
               replacement = "", 
               x) %>% 
    as_date()
  
  read_excel(paste0(ES_PV_dir, x),sheet = "03",n_max = 12) %>% 
    select(Age = `Adina / Edad`,
           Cases_f = `Emakumezkoak: Kasu positiboak / Mujeres: Positivos`,
           Cases_m = `Gizonezkoak: Kasu positiboak / Hombres: Positivos`,
           Deaths_f = `Emakumezkoak: Hildakoak / Mujeres: Fallecidos`,
           Deaths_m = `Gizonezkoak: Hildakoak / Hombres: Fallecidos`) %>% 
    mutate(Date = Date,
           Cases_f = suppressWarnings(as.integer(Cases_f)),
           Cases_m = suppressWarnings(as.integer(Cases_m)),
           Deaths_f = suppressWarnings(as.integer(Deaths_f)),
           Deaths_m = suppressWarnings(as.integer(Deaths_m))) %>% 
    pivot_longer(Cases_f:Deaths_m, 
                 names_to = "Measure_Sex", 
                 values_to = "Value") %>% 
    separate(Measure_Sex, into = c("Measure","Sex"), sep = "_")
}) %>% 
  bind_rows()

# t1 <- tibble(a=1:3,b=letters[1:3])
# t2 <- tibble(b = LETTERS[1:3],a=runif(3))
# 
# t1
# t2
# bind_rows(t1,t2)

Table <- 
  Tables_b %>% 
  pivot_longer(cols = Cases:Deaths,
               names_to = "Measure",
               values_to =  "Value") %>% 
  bind_rows(Tables_m_f) %>% 
  filter(Age != "No consta") %>% 
  separate(Age, into = c("Age",NA),sep="-") %>% 
  mutate(
    Age = case_when(
      Age == "Más de 90 edo gehiago"~"90",
      Age == "Mas de 90 edo gehiago"~"90",
      Age == "GUZTIRA / TOTAL"~"TOT",
      TRUE ~ gsub(Age,pattern=" ",replacement = "")), 
    AgeInt = case_when(
      Age == "90" ~ 15,
      Age == "TOT" ~ NA_real_,
      TRUE ~ 10)) 


# Get totals from first tab (includes PCR totals)
most_recent_for_totals <- rev(files)[1]

tbl_vars(TOT)
TOT <- 
  read_excel(paste0(ES_PV_dir, most_recent_for_totals),
             sheet = "01",
             skip = 1) %>% 
  select(Date = `Data / Fecha`,
         Tests = 'PCR-dun pertsona bakarrak / Personas únicas con PCR',
         Cases = `Kasu positiboak guztira / Casos positivos totales`,
         Deaths = `Hildakoak / Fallecidos`) %>% 
  filter(Date >= min(Table$Date),
         !is.na(Cases)) %>% 
  mutate(Date = ymd(Date),
         Age = "TOT",
         AgeInt = NA_real_,
         Sex = "b") %>% 
  pivot_longer(cols = Tests:Deaths,
               names_to = "Measure",
               values_to =  "Value")

# ---------------------------------------------- #

PVout <- 
  Table %>% 
  filter(! (Age == "TOT" & Sex == "b"),
         Date %in% TOT$Date) %>% # only matching dates?
  bind_rows(TOT) %>% 
  mutate(Date = paste(sprintf("%02d",day(Date)),    
                      sprintf("%02d",month(Date)),  
                      year(Date),sep="."),
         Code = paste0("ES-PV"),
         Metric = "Count",
         Country = "Spain",
         Region = "Basque Country") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Measure, Metric, Value)

# ---------------------------------------------- #

N <- nrow(PVout)

# ID unique combinations of Date, Sex, Measure in incoming and outgoing.

DSMout <- PVout %>% 
  mutate(id = paste(Date, Sex, Measure,sep="-")) %>% 
  dplyr::pull(id) %>% 
  unique()

# remove old values that have been recaptured
PVin <- PVin %>% 
  mutate(id = paste(Date, Sex, Measure,sep="-")) %>% 
  filter(!id %in% DSMout) %>% 
  select(-id)

# bind together
PVout <- 
  PVout %>% 
  bind_rows(PVin) %>% 
  sort_input_data() 

# write to drive
write_sheet(PVout,ss = ss_i, sheet = "database")

# log the update. N posts, even if the data are simply replaced with identical values
log_update(pp = "ES_Basque Country", N = N)

# For now just zip all the spreadsheets and upload as such
ex_files <- c(paste0(ES_PV_dir, files))

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zipr(zipname,
     files = ex_files, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

file.remove(ex_files)

gc()

