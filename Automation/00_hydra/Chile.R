library(here)
source(here("Automation/00_Functions_automation.R"))
#written by Rafael 
lapply(c("tidyverse", "ggpubr", "gridExtra","readr", "googledrive", "googlesheets4"),
       library, character.only=TRUE)


if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address
ctr <- "Chile"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"




# Casos totales

#gs4_auth(email="")

# ###################################################### #
#  To take cases and deaths not available from GITHUB ####
# ##################################################### #

a1 <- range_read(ss= "https://docs.google.com/spreadsheets/d/1pM7PYqTUv7VYp3oOo6am7p6kKn_hQVntmk4QH9SYsKk/edit?usp=sharing",
                 sheet = "database_old.a")



#1 # To call my g-count

# Cases

c1 <- a1 %>% filter(Measure == "Cases")

c1 <- c1 %>%  filter(Date %in% unique(c1$Date[c(1:172)]))

#table(c1$Date, c1$Measure)

# Deaths

d1 <- a1 %>% filter(Measure == "Deaths")
d1 <- d1 %>%  filter(Date %in% unique(d1$Date[c(1:280)]))

#table(d1$Date, d1$Measure)


################# #
# Cases file ####
################# #


# Last upload = 13.10.2020

urlfile_c="https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto16/CasosGeneroEtario_std.csv" 

c_input <- read_csv(url(urlfile_c))
#head(c_input,10)
#tail(c_input,10)


#To create data
c <- c_input %>% separate(Fecha, c("Y","M", "D"), sep = "(-)")



c$Date <- paste(c$D,c$M,c$Y, sep = ".")

c$Age <- ifelse(c$`Grupo de edad` == "00 - 04 años", 0,
                ifelse(c$`Grupo de edad` == "05 - 09 años", 5,
                       ifelse(c$`Grupo de edad` == "10 - 14 años",10,
                              ifelse(c$`Grupo de edad` == "15 - 19 años", 15,
                                     ifelse(c$`Grupo de edad` == "20 - 24 años", 20,
                                            ifelse(c$`Grupo de edad` == "25 - 29 años", 25,
                                                   ifelse(c$`Grupo de edad` == "30 - 34 años", 30,
                                                          ifelse(c$`Grupo de edad` == "35 - 39 años", 35,
                                                                 ifelse(c$`Grupo de edad` == "40 - 44 años", 40,
                                                                        ifelse(c$`Grupo de edad` == "45 - 49 años", 45,
                                                                               ifelse(c$`Grupo de edad` == "50 - 54 años", 50,
                                                                                      ifelse(c$`Grupo de edad` == "55 - 59 años", 55,
                                                                                             ifelse(c$`Grupo de edad` == "60 - 64 años", 60,
                                                                                                    ifelse(c$`Grupo de edad` == "65 - 69 años", 65,
                                                                                                           ifelse(c$`Grupo de edad` == "70 - 74 años", 70,
                                                                                                                  ifelse(c$`Grupo de edad` == "75 - 79 años", 75,
                                                                                                                         ifelse(c$`Grupo de edad` == "80 y más años", 80, NA
                                                                                                                         )))))))))))))))))


c$AgeInt <- ifelse(c$`Grupo de edad` != "80 y más años", 5, 25)

c$Country <-  "Chile"

c$Region <- "All"

c$Code <- paste("CL", c$Date, sep = "")

c$Metric <- "Count"

c$Measure <- "Cases"

c <- c %>% rename(Value = `Casos confirmados`)

c$Sexo <- as.factor(c$Sexo)

c <-  c %>% mutate(Sexo=recode(Sexo, "M"="m", "F"="f"))

# Pivoting to create col: b
cw <- c %>% pivot_wider(names_from = Sexo, values_from = Value)
#str(cw)

cw$b <- cw$m + cw$f

# Pivoting to have a tidy format
ct <- cw %>% pivot_longer(cols = 13:15, names_to = "Sex", values_to = "Value")

# Estimating the % by age and sex
ct <- ct %>% group_by(Date, Sex) %>% mutate(tot = sum(Value)) %>% ungroup()

ct$perc <- ct$Value / ct$tot *100 # By age and sex

ct <- ct %>% group_by(Date, Sex) %>% mutate(tot.p = sum(perc)) %>% arrange(M, D, desc(Sex)) %>% ungroup()

# 1 # my g-count
# To create a DB in COVerAge format
c2 <- ct[, c("Country", "Region", "Code", "Date", "Sex", "Age", "AgeInt", "Metric", "Measure", "Value")]

c3 <- rbind(c1,c2)


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
  maybe_urls <- paste0("http://deis.minsal.cl/wp-content/uploads/",
                       yr,"/",mth,"/DEFUNCIONES_FUENTE_DEIS_2016_",yr,"_",dy,mth,yr,".zip")
  
  TF <- sapply(maybe_urls, url.exists)
  
  if (!any(TF)){
    cat("none of the dates checked have a valid file,\nplease recheck the url to see if something changed")
    return(NULL)
  }
  
  # most recent date
  most_recent <- max(dates[TF])
  
  correct_url <- maybe_urls[dates == most_recent]
  correct_url
}

url_deaths= guess_chile_url()
name_deaths= substr(url_deaths, 50, 91)
name_death_file= paste0(name_deaths, ".csv")

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
download.file(url_deaths, destfile = data_source_zip, mode = "wb")

#read file from zipfile 
#dd_download= read.csv(unz(data_source_zip, name_death_file), sep = ";", header = FALSE)

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
dd1 <- dd %>% 
  filter(ANO_DEF == 2020 & CODIGO_SUBCATEGORIA_DIAG1 == "U071" | ANO_DEF == 2020 & CODIGO_SUBCATEGORIA_DIAG1 == "U072" | ANO_DEF == 2021 & CODIGO_SUBCATEGORIA_DIAG1 == "U071" | ANO_DEF == 2021 & CODIGO_SUBCATEGORIA_DIAG1 == "U072") %>% 
  mutate(EDAD_CANT = ifelse(EDAD_TIPO>1,0,EDAD_CANT), # if >1 == age in days or months
         age.g = ifelse(EDAD_CANT==0, "< 1",
                        ifelse(EDAD_CANT>=1 & EDAD_CANT<5, "1 a 4",
                               ifelse(EDAD_CANT>=5 & EDAD_CANT<10, "5 a 9",
                                      ifelse(EDAD_CANT>=10 & EDAD_CANT<15, "10 a 14",
                                             ifelse(EDAD_CANT>=15 & EDAD_CANT<20,"15 a 19",
                                                    ifelse(EDAD_CANT>=20 & EDAD_CANT<25, "20 a 24",
                                                           ifelse(EDAD_CANT>=25 & EDAD_CANT<30, "25 a 29",
                                                                  ifelse(EDAD_CANT>=30 & EDAD_CANT<35, "30 a 34",
                                                                         ifelse(EDAD_CANT>=35 & EDAD_CANT<40, "35 a 39",
                                                                                ifelse(EDAD_CANT>=40 & EDAD_CANT<45, "40 a 44",
                                                                                       ifelse(EDAD_CANT>=45 & EDAD_CANT<50, "45 a 49",
                                                                                              ifelse(EDAD_CANT>=50 & EDAD_CANT<55, "50 a 54",
                                                                                                     ifelse(EDAD_CANT>=55 & EDAD_CANT<60, "55 a 59",
                                                                                                            ifelse(EDAD_CANT>=60 & EDAD_CANT<65,"60 a 64",
                                                                                                                   ifelse(EDAD_CANT>=65 & EDAD_CANT<70,"65 a 69",
                                                                                                                          ifelse(EDAD_CANT>=70 & EDAD_CANT<75, "70 a 74",
                                                                                                                                 ifelse(EDAD_CANT>=75 & EDAD_CANT<80, "75 a 79",
                                                                                                                                        ifelse(EDAD_CANT>=80 & EDAD_CANT<85, "80 a 84",
                                                                                                                                               ifelse(EDAD_CANT>=85 & EDAD_CANT<90, "85 a 89",
                                                                                                                                                      ifelse(EDAD_CANT>=90 & EDAD_CANT<95, "90 a 94",
                                                                                                                                                             ifelse(EDAD_CANT>=95 & EDAD_CANT<100,"95 a 99",
                                                                                                                                                                    ifelse(EDAD_CANT>=100 & EDAD_CANT<200, "100 +", NA
                                                                                                                                                                    )))))))))))))))))))))),
         age.g = as.factor(age.g),
         CODIGO_SUBCATEGORIA_DIAG1 = as.factor(CODIGO_SUBCATEGORIA_DIAG1),
         GLOSA_SEXO = as.factor(GLOSA_SEXO),
         age.g = fct_relevel(age.g,
                             "< 1", "1 a 4", "5 a 9", "10 a 14", "15 a 19", "20 a 24",
                             "25 a 29", "30 a 34", "35 a 39", "40 a 44", "45 a 49",
                             "50 a 54", "55 a 59", "60 a 64", "65 a 69",
                             "70 a 74", "75 a 79", "80 a 84", "85 a 89",
                             "90 a 94", "95 a 99","100 +"),
         CODIGO_SUBCATEGORIA_DIAG1 = fct_relevel(CODIGO_SUBCATEGORIA_DIAG1, "U072", "U071")) %>% 
  rename(CODIGO_GRUPO = CODIGO_SUBCATEGORIA_DIAG1)


levels(dd1$age.g)
levels(dd1$CODIGO_GRUPO)
table(dd1$age.g,dd1$EDAD_TIPO) # 0 == Desconocida

# CreatiNg a report of deaths using DEIS data for CONFIRMED CASES
dd2 <- dd1 %>% 
  filter(CODIGO_GRUPO == "U071") %>% 
  select(c("age.g","GLOSA_SEXO","FECHA_DEF")) %>% 
  mutate(FECHA_DEF = as.Date(FECHA_DEF, "%Y-%m-%d")) %>% 
  arrange(FECHA_DEF)

glimpse(dd2)

ddt1 <- as.data.frame(xtabs(~ age.g+GLOSA_SEXO+FECHA_DEF, data=dd2)) #Subset only analytical variable to COVerAge
View(ddt1) 

ddt2 <- pivot_wider(ddt1, names_from= GLOSA_SEXO, 
                    values_from = Freq)

ddt2$Total <- ddt2$Hombre + ddt2$Mujer
View(ddt2) 
ddt2r <- ddt2 %>% rename(m = Hombre,
                         f = Mujer,
                         b = Total,
                         date = FECHA_DEF) 
names(ddt2r)

ddt3 <- pivot_longer(ddt2r,
                     cols = 3:5, 
                     names_to = "sex",
                     values_to = "freq")

View(ddt3)

ddt4 <- ddt3 %>% group_by(sex, age.g) %>% arrange(date) %>% mutate(cum = cumsum(freq)) # Total del día por sexo y edad

ddt4 <- ddt4 %>% group_by(date, sex) %>% arrange(date, sex) %>% mutate(totday = sum(cum)) # Total del día por sexo
View(ddt4)

# Creating COVerAGE data from "ddt4"

dd5 <- ddt4 %>% separate(date, c("Y","M", "D"), sep = "(-)")
glimpse(dd5)

dd5$Date <- paste(dd5$D,dd5$M,dd5$Y, sep = ".")
glimpse(dd5)

levels(as.factor(dd5$age.g))
dd5$Age <- ifelse(dd5$age.g=="< 1",0,
                  ifelse(dd5$age.g=="1 a 4",1,
                         ifelse(dd5$age.g=="5 a 9",5,
                                ifelse(dd5$age.g=="10 a 14",10,
                                       ifelse(dd5$age.g=="15 a 19",15,
                                              ifelse(dd5$age.g=="20 a 24",20,
                                                     ifelse(dd5$age.g=="25 a 29",25,
                                                            ifelse(dd5$age.g=="30 a 34",30,
                                                                   ifelse(dd5$age.g=="35 a 39",35,
                                                                          ifelse(dd5$age.g=="40 a 44",40,
                                                                                 ifelse(dd5$age.g=="45 a 49",45,
                                                                                        ifelse(dd5$age.g=="50 a 54",50,
                                                                                               ifelse(dd5$age.g=="55 a 59",55,
                                                                                                      ifelse(dd5$age.g=="60 a 64",60,
                                                                                                             ifelse(dd5$age.g=="65 a 69",65,
                                                                                                                    ifelse(dd5$age.g=="70 a 74",70,
                                                                                                                           ifelse(dd5$age.g=="75 a 79",75,
                                                                                                                                  ifelse(dd5$age.g=="80 a 84",80,
                                                                                                                                         ifelse(dd5$age.g=="85 a 89",85,
                                                                                                                                                ifelse(dd5$age.g=="90 a 94",90,
                                                                                                                                                       ifelse(dd5$age.g=="95 a 99",95,
                                                                                                                                                              ifelse(dd5$age.g=="100 +",100,
                                                                                                                                                                     NA))))))))))))))))))))))

levels(as.factor(dd5$Age))
glimpse(dd5)

dd5$AgeInt <- ifelse(dd5$Age<1,1,
                     ifelse(dd5$Age==1,4,5))

glimpse(dd5)

dd5$Country <-"Chile"

dd5$Region <- "All"

dd5$Code <- paste("CL", dd5$Date, sep = "")

dd5$Metric <- "Count"

dd5$Measure <- "Deaths"

dd5 <- dd5 %>% rename(Value = cum)
dd5 <- dd5 %>% rename(Sex = sex)

glimpse(dd5)

# To create a DB in COVerAge format - only confirmed cases
dd6 <- 
  dd5 %>% 
  select("Country", "Region", "Code", "Date", "Sex", "Age", "AgeInt", "Metric", "Measure", "Value") %>% 
  arrange(as.Date(Date, "%d.%m.%Y"))

glimpse(dd6)  

#To save on COVerAGE-BD folder
dd7 <- 
  dd1 %>% 
  filter(CODIGO_GRUPO == "U071")

cd <- rbind(c3,dd6) # Cases & Deaths from DEIS

# To save in G-Sheets
#sheet_write(cd, 
           # ss= "https://docs.google.com/spreadsheets/d/1pM7PYqTUv7VYp3oOo6am7p6kKn_hQVntmk4QH9SYsKk/edit?usp=sharing",
            #sheet = "database")

#save output on N 

write_rds(cd, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(cd))

#archive data 

#write_csv(dd7, 
#path = "/Volumes/GoogleDrive/.shortcut-targets-by-id/1yeNvTKti7N5vIF3-2XbsQuMeFvzCrmAs/COVID_DATA/02_documentation/metadata/Chile/CL_Deaths_deis_all_region_municipality.csv")

#To save on COVerAGE-BD folder
#write_csv(c, 
#path = "/Volumes/GoogleDrive/.shortcut-targets-by-id/1yeNvTKti7N5vIF3-2XbsQuMeFvzCrmAs/COVID_DATA/02_documentation/metadata/Chile/CL_Cases.csv")



data_source_1 <- paste0(dir_n, "Data_sources/", ctr, "/death_age_",today(), ".csv")
data_source_2 <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")


write_csv(dd7, data_source_1)
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



