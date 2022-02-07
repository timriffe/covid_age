#deaths regional chile 

######this can go into the chile script once it was checked######



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

data_source_zip <- paste0(dir_n, "Data_sources/", ctr, "/death",today(), ".zip")
#download zip file 
download.file(url_deaths, destfile = data_source_zip, mode = "wb")

#read file from zipfile 
dd= read_delim(unz(data_source_zip, name_death_file), ";", escape_double = FALSE, col_names = FALSE, 
               locale = locale(encoding = "latin1"), 
               trim_ws = TRUE)


#dd1= deaths filtered by causes of deaths,only covid, has regional information 

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

glimpse(dd)  

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


###########################modifications for keeping regions##################################
# CreatiNg a report of deaths using DEIS data for CONFIRMED CASES
#keeping regions 
dd2_reg <- dd1 %>% 
  filter(CODIGO_GRUPO == "U071") %>% 
  select(c("age.g","GLOSA_SEXO","FECHA_DEF","GLOSA_REG_RES")) %>% 
  mutate(FECHA_DEF = as.Date(FECHA_DEF, "%Y-%m-%d")) %>% 
  arrange(FECHA_DEF)

#Subset only analytical variable to COVerAge
ddt1_reg <- as.data.frame(xtabs(~ age.g+GLOSA_SEXO+FECHA_DEF+GLOSA_REG_RES, data=dd2_reg)) 
 
ddt2_reg <- pivot_wider(ddt1_reg, names_from= GLOSA_SEXO, 
                    values_from = Freq)

ddt2_reg$Total <- ddt2_reg$Hombre + ddt2_reg$Mujer
 
ddt2r_reg <- ddt2_reg %>% rename(m = Hombre,
                         f = Mujer,
                         b = Total,
                         date = FECHA_DEF,
                         Region=GLOSA_REG_RES) 

ddt3_reg <- pivot_longer(ddt2r_reg,
                     cols = 4:6, 
                     names_to = "sex",
                     values_to = "freq")



ddt4_reg <- ddt3_reg %>% group_by(sex, age.g,Region) %>% arrange(date) %>% mutate(cum = cumsum(freq)) # Total del día por sexo y edad y region

ddt4_reg <- ddt4_reg %>% group_by(date, sex, Region) %>% arrange(date, sex,Region) %>% mutate(totday = sum(cum)) # Total del día por sexo


# Creating COVerAGE data from "ddt4_reg"

dd5_reg <- ddt4_reg %>% separate(date, c("Y","M", "D"), sep = "(-)")


dd5_reg$Date <- paste(dd5_reg$D,dd5_reg$M,dd5_reg$Y, sep = ".")


levels(as.factor(dd5_reg$age.g))
dd5_reg$Age <- ifelse(dd5_reg$age.g=="< 1",0,
                  ifelse(dd5_reg$age.g=="1 a 4",1,
                         ifelse(dd5_reg$age.g=="5 a 9",5,
                                ifelse(dd5_reg$age.g=="10 a 14",10,
                                       ifelse(dd5_reg$age.g=="15 a 19",15,
                                              ifelse(dd5_reg$age.g=="20 a 24",20,
                                                     ifelse(dd5_reg$age.g=="25 a 29",25,
                                                            ifelse(dd5_reg$age.g=="30 a 34",30,
                                                                   ifelse(dd5_reg$age.g=="35 a 39",35,
                                                                          ifelse(dd5_reg$age.g=="40 a 44",40,
                                                                                 ifelse(dd5_reg$age.g=="45 a 49",45,
                                                                                        ifelse(dd5_reg$age.g=="50 a 54",50,
                                                                                               ifelse(dd5_reg$age.g=="55 a 59",55,
                                                                                                      ifelse(dd5_reg$age.g=="60 a 64",60,
                                                                                                             ifelse(dd5_reg$age.g=="65 a 69",65,
                                                                                                                    ifelse(dd5_reg$age.g=="70 a 74",70,
                                                                                                                           ifelse(dd5_reg$age.g=="75 a 79",75,
                                                                                                                                  ifelse(dd5_reg$age.g=="80 a 84",80,
                                                                                                                                         ifelse(dd5_reg$age.g=="85 a 89",85,
                                                                                                                                                ifelse(dd5_reg$age.g=="90 a 94",90,
                                                                                                                                                       ifelse(dd5_reg$age.g=="95 a 99",95,
                                                                                                                                                              ifelse(dd5_reg$age.g=="100 +",100,
                                                                                                                                                                     NA))))))))))))))))))))))

levels(as.factor(dd5_reg$Age))


dd5_reg$AgeInt <- ifelse(dd5_reg$Age<1,1,
                     ifelse(dd5_reg$Age==1,4,5))



dd5_reg$Country <-"Chile"

#Name Regions 
#adding iso code for regions 
dd5_reg= dd5_reg %>%
  mutate(Region=recode(Region, 
                    `Ignorada`= "UNK",
                    `De Aisén del Gral. C. Ibáñez del Campo`= "AI",
                    `De Arica y Parinacota`= "AP",
                    `De Coquimbo`= "CO",
                    `De Los Lagos`= "LL",
                    `De Magallanes y de La Antártica Chilena`= "MA",
                    `De Tarapacá`="TA",
                    `Del Bíobío`="BI",
                    `Del Maule`= "ML",
                    `Metropolitana de Santiago`="RM",
                    `De Antofagasta`="AN",
                    `De Atacama`="AT",
                    `De La Araucanía`="AR",
                    `De Los Ríos`="LR",
                    `De Ñuble`="NB",
                    `De Valparaíso`="VS",
                    `Del Libertador B. O'Higgins`="LI"))
                    
                    
                    
dd5_reg$Code <- paste("CL", dd5_reg$Region, sep = "-")

dd5_reg$Metric <- "Count"

dd5_reg$Measure <- "Deaths"

dd5_reg <- dd5_reg %>% rename(Value = cum)
dd5_reg <- dd5_reg %>% rename(Sex = sex)



# To create a DB in COVerAge format - only confirmed cases
#deaths on national level 
dd6_reg <- 
  dd5_reg %>% 
  select("Country", "Region", "Code", "Date", "Sex", "Age", "AgeInt", "Metric", "Measure", "Value") %>% 
  arrange(as.Date(Date, "%d.%m.%Y"))


#put togehter with national case and death data 

cd <- rbind(c3,dd6,dd6_reg ) # Cases & Deaths from DEIS

