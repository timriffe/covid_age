library(tidyverse)
library(lubridate)

# get yesterday
hoy <- Sys.Date()
ayer <- paste0(year(hoy-1),
               str_pad(month(hoy-1),2,"left",0) ,
               str_pad(day(hoy-1),2,"left",0))

# download zip from covidstat server and unzip
file <- paste0("https://covidstats.com.ar/archivos/coverage-db/",ayer,"-argentina.csv.zip")
download.file(file, "file.zip")
unzip("file.zip")

# read data
db <- read.table(paste0(ayer,"-argentina.csv"),sep=",",encoding = "UTF-8",skip = 1) %>% 
      setNames(c("Country","Region","Code","Date","Sex","Age","AgeInt","Metric","Measure","Value"))

# split All and provinces
dbT <- db %>% filter(Region=="All")
dbP <- db %>% filter(Region!="All")
  # check
  # db %>% filter(Region=="All",Date=="22.05.2021") %>% group_by(Measure) %>% summarise(N=sum(Value))
  # db %>% filter(Region!="All",Date=="22.05.2021") %>% group_by(Measure) %>% summarise(N=sum(Value))

# write in gsheet
library(googlesheets4)
ar_url <- c("https://docs.google.com/spreadsheets/d/1yHuwowX-0blpf2Um8aqEC2SWZARRYSH4ImeZMvgb58c/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1oamC3cqGBxYu00zjD3LYJPDQyF_INSlYVs6MgxWrCKk/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1kCaK5ix3r9Ksay75Wh_hq9UIemjWBc5sfYe48AfW3cQ/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1z8b8waPpQOY0jjxkBJinDdpJRoj5xvXwd9wo0zavbOw/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1r8u_pk2Jr2BSF6n_OzkxQ7FvjYNtv0kPjQcodq4hUFI/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1F10dmxRaMjDZV42XulaZuJDgBGO9k6VV5UPA_qc7usY/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1RuyNIUs-htCQ1CMA_RKpHwbQnM8WVlPFlk-6XL0V9KQ/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1vvwBSoAQESEUhhrZr30CZApYw4Ssk6SsW5RZ15IJfas/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1sH6IppMLWoY6KFxa527IlVS3HKO43anEObhbSuOoLnQ/edit#gid=1479453705",
            "https://docs.google.com/spreadsheets/d/1HF8lIcbHEFisrQMn4ivscGQKPjLue9b2z7pf9Lmrtxo/edit#gid=1479453705")

# Total
  # start=Sys.time() # aprox 1.5 hours
write_sheet(dbT %>% slice(1:100000), ar_url[1], sheet = "database")
write_sheet(dbT %>% slice(100001:nrow(dbT)), ar_url[2], sheet = "database")
#Provinces
regiones = unique(dbP$Region)
for(i in 1:8){
  # i = 1
  dbPi = dbP %>% filter(Region %in% regiones[3*(i-1)+1:3])
  write_sheet(dbPi, ar_url[2+i], sheet = "database")
  print(i)
  Sys.sleep(100)
}
  # end=Sys.time()
  # end-start