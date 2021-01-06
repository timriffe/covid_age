source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
library(RSelenium)
library(rvest)

email <- "kikepaila@gmail.com"

ctr <- "Brazil"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n <- "Data/"

# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "BR_all")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

# donloading file
url <- "https://transparencia.registrocivil.org.br/dados-covid-download"

system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4601L,
                              chromever =
                                system2(command = "wmic",
                                        args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
                                        stdout = TRUE,
                                        stderr = TRUE) %>%
                                stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
                                magrittr::extract(!is.na(.)) %>%
                                stringr::str_replace_all(pattern = "\\.",
                                                         replacement = "\\\\.") %>%
                                paste0("^",  .) %>%
                                stringr::str_subset(string =
                                                      binman::list_versions(appname = "chromedriver") %>%
                                                      dplyr::last()) %>% 
                                as.numeric_version() %>%
                                max() %>%
                                as.character())

remote_driver <- driver[["client"]] 
remote_driver$navigate(url)
# locate button and click it
button <- remote_driver$findElement(using = "xpath", '//*[@id="app"]/div[2]/div/div/div[2]/div/div[2]/div[2]/div[2]/a')
button$clickElement()

date_lb <- remote_driver$findElement(using = "xpath", '//*[@id="app"]/div[2]/div/div/div[2]/div/div[2]/div[2]/div[2]/p/p[1]')
date_lb2 <- date_lb$findElement(using='css selector',"body")$getElementText()[[1]]
date_f <- str_sub(date_lb2, -10) %>% dmy()

data_source1 <- paste0(dir_n, ctr, "/", ctr, "_data_deaths_", today(), ".csv")
file.copy("C:/Users/kikep/Downloads/obitos-2020.csv", data_source1, T)
file.remove("C:/Users/kikep/Downloads/obitos-2020.csv")

db <- read_csv(data_source1)

db2 <- 
  db %>% 
  select(reg = uf,
         Cause = tipo_doenca,
         Age = faixa_etaria,
         Sex = sexo,
         Value = total)

db3 <- 
  db2 %>% 
  filter(Cause == "COVID") %>% 
  select(reg, Age, Sex, Value) %>% 
  group_by(reg, Age, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  separate(Age, c("Age", "trash"), sep = " - ") %>% 
  mutate(Age = case_when(Age == "< 9" ~ "0",
                         Age == "> 100" ~ "100",
                         Age == "N/I" ~ "UNK",
                         TRUE ~ Age),
         Sex = case_when(Sex == "F" ~ "f",
                         Sex == "M" ~ "m",
                         Sex == "I" ~ "i")) %>% 
  select(-trash)
         
  
db_sex <- db3 %>% 
  group_by(reg, Age) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Sex = "b") %>% 
  filter(Age != "UNK")

db_age <- db3 %>% 
  group_by(reg, Sex) %>% 
  summarise(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Age = "TOT") %>% 
  filter(Sex != "i")

out <- db3 %>% 
  filter(Sex != "i" & Age != "UNK") %>% 
  bind_rows(db_age, db_sex) %>% 
  mutate(date_f = date_f,
         Country = "Brazil",
         Region = case_when(reg == 'AC' ~ 'Acre',
                            reg == 'AL' ~ 'Alagoas',
                            reg == 'AP' ~ 'Amapa',
                            reg == 'AM' ~ 'Amazonas',
                            reg == 'BA' ~ 'Bahia',
                            reg == 'CE' ~ 'Ceara',
                            reg == 'DF' ~ 'Distrito Federal',
                            reg == 'ES' ~ 'Espirito Santo',
                            reg == 'GO' ~ 'Goias',
                            reg == 'MA' ~ 'Maranhao',
                            reg == 'MT' ~ 'Mato Grosso',
                            reg == 'MS' ~ 'Mato Grosso do Sul',
                            reg == 'MG' ~ 'Minas Gerais',
                            reg == 'PA' ~ 'Para',
                            reg == 'PB' ~ 'Paraiba',
                            reg == 'PR' ~ 'Parana',
                            reg == 'PE' ~ 'Pernambuco',
                            reg == 'PI' ~ 'Piaui',
                            reg == 'RJ' ~ 'Rio de Janeiro',
                            reg == 'RN' ~ 'Rio Grande do Norte',
                            reg == 'RS' ~ 'Rio Grande do Sul',
                            reg == 'RO' ~ 'Rondonia',
                            reg == 'RR' ~ 'Roraima',
                            reg == 'SC' ~ 'Santa Catarina',
                            reg == 'SP' ~ 'Sao Paulo',
                            reg == 'SE' ~ 'Sergipe',
                            reg == 'TO' ~ 'Tocantins',
                            TRUE ~ "other"),
         Date = paste(sprintf("%02d",day(date_f)),
                      sprintf("%02d",month(date_f)),
                      year(date_f),
                      sep="."),
         Code = paste0("BR_", reg, Date),
         AgeInt = case_when(Age == "100" ~ 5,
                            Age == "TOT" ~ NA_real_,
                            TRUE ~ 10),
         Metric = "Count",
         Measure = "Deaths") %>%
  arrange(Region, date_f, Measure, Sex, suppressWarnings(as.integer(Age))) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)


############################################
#### uploading database to Google Drive ####
############################################

sheet_append(out,
            ss = ss_i,
            sheet = "database")
log_update(pp = ctr, N = nrow(out))


sheet_name <- paste0(ctr, "_all_deaths_", today())
meta <- drive_create(sheet_name,
             path = ss_db, 
             type = "spreadsheet",
             overwrite = TRUE)

write_sheet(db,
            ss = meta$id,
            sheet = "data")

sheet_delete(meta$id, "Sheet1")





