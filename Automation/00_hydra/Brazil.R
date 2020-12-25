
library(RSelenium)
library(tidyverse)
library(lubridate)

ctr <- "Brazil"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n <- "Data/"

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

data_source1 <- paste0(dir_n, ctr, "/", ctr, "_data_deaths_", today(), ".csv")
file.copy("C:/Users/kikep/Downloads/obitos-2020.csv", data_source1, T)
file.remove("C:/Users/kikep/Downloads/obitos-2020.csv")

db_d <- read_csv(data_source1)
