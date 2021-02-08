
library(RSelenium)
library(tidyverse)
library(lubridate)

ctr <- "Iceland"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n <- "Data/"



<<<<<<< HEAD
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4601L,
=======
path_chrome_dr <- "N:/COVerAGE-DB/Automation/chromedriver.exe"
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
startServer(args = c("-Dwebdriver.chrome.driver=N:/COVerAGE-DB/Automation/hydra/chromedriver.exe"))
driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4590L,
>>>>>>> 4e23c54c37fa421a2384a64ffb59b2b3c7590686
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



driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4591L,
                              chromever =
                                system2(command = "wmic",
                                        args = 'datafile where name="N:/COVerAGE-DB/Automation/hydra/chromedriver.exe" get Version /value',
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
                                as.character(),
                              check = TRUE)

driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4579L,
                              chromever = "86.0.4240.198")



driver <- rsDriver(browser=c("chrome"),
                   chromever = "86.0.4240.198")

driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4582L,
                              chromever =
                                ☻)

remote_driver <- driver[["client"]]
remote_driver$navigate("https://www.covid.is/data")
# remote_driver$navigate('https://e.infogram.com/deaf4fd6-0ce9-4b82-97ae-11e34a045060?parent_url=https%3A%2F%2Fwww.covid.is%2Fdata&amp;src=embed#async_embed%22')

Sys.sleep(3)

frame1 <- remote_driver$findElements("css", "iframe")
remote_driver$switchToFrame(frame1[[1]])

# button <- remote_driver$findElement(using = "xpath", '//*[@id="d1647fa3-f644-4145-b4a6-34fc1565c8d3"]/div[1]/div/div[48]/div/a/span[2]')
# button <- remote_driver$findElement(using = "class", 'igc-data-download-text')
# button$clickElement()
button <- remote_driver$findElement(using = "xpath", '/html/body/div[2]/div/div[1]/div[1]/div[1]/div/div/div/div[1]/div/div[46]/div/a/span[2]')
button$clickElement()

data_source1 <- paste0(dir_n, ctr, "/", ctr, "_data_cases_", today(), ".csv")
file.copy("C:/Users/kikep/Downloads/Sheet 1.csv", data_source1, T)
file.remove("C:/Users/kikep/Downloads/Sheet 1.csv")


button <- remote_driver$findElement(using = "xpath", '/html/body/div[2]/div/div[1]/div[1]/div[1]/div/div/div/div[1]/div/div[48]/div/a/span[2]')
button$clickElement()

<<<<<<< HEAD
data_source2 <- paste0(dir_n, ctr, "/", ctr, "_data_cases_deaths_", today(), ".csv")
file.copy("C:/Users/kikep/Downloads/Sheet 1.csv", data_source2)
file.remove("C:/Users/kikep/Downloads/Sheet 1.csv")

=======
cprof <- getChromeProfile("C:\Program Files (x86)\Google\Chrome\Application\ Data", "Profile 1")
remDr <- remoteDriver(browserName = "chrome", extraCapabilities = cprof)
>>>>>>> 4e23c54c37fa421a2384a64ffb59b2b3c7590686

# 
# 
# 
# 
# cat("done with 1!!!!!!!!!!!!!")
# 
# rm(list=ls())
# gc()
# 
# system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
# driver <- RSelenium::rsDriver(browser = "chrome",
#                               port = 4601L,
#                               chromever =
#                                 system2(command = "wmic",
#                                         args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
#                                         stdout = TRUE,
#                                         stderr = TRUE) %>%
#                                 stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
#                                 magrittr::extract(!is.na(.)) %>%
#                                 stringr::str_replace_all(pattern = "\\.",
#                                                          replacement = "\\\\.") %>%
#                                 paste0("^",  .) %>%
#                                 stringr::str_subset(string =
#                                                       binman::list_versions(appname = "chromedriver") %>%
#                                                       dplyr::last()) %>% 
#                                 as.numeric_version() %>%
#                                 max() %>%
#                                 as.character())
# 
# remote_driver <- driver[["client"]] 
# remote_driver$navigate("https://www.covid.is/data")
# 
# Sys.sleep(3)
# 
# frame1 <- remote_driver$findElements("css", "iframe")
# remote_driver$switchToFrame(frame1[[1]])
# 
# button <- remote_driver$findElement(using = "xpath", '/html/body/div[2]/div/div[1]/div[1]/div[1]/div/div/div/div[1]/div/div[46]/div/a/span[2]')
# button$clickElement()
# button <- remote_driver$findElement(using = "xpath", '/html/body/div[2]/div/div[1]/div[1]/div[1]/div/div/div/div[1]/div/div[48]/div/a/span[2]')
# button$clickElement()
# # Sys.sleep(3)
# data_source2 <- paste0(dir_n, ctr, "/", ctr, "_data_cases_deaths_", today(), ".csv")
# file.copy("C:/Users/kikep/Downloads/Sheet 1.csv", data_source2)
# file.remove("C:/Users/kikep/Downloads/Sheet 1.csv")
# 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # data_source <- paste0(dir_n, ctr, "/", ctr, "_data_", today(), ".csv")
# # file.copy("C:/Users/kikep/Downloads/Sheet 1.csv", data_source)
# # file.remove("C:/Users/kikep/Downloads/Sheet 1.csv")
# # 
# # db <- read_csv(data_source)
# # 
# # db2 <- db %>% 
# #   select(Age = 1,
# #          Deaths = 2,
# #          Cases = 3) %>% 
# #   replace_na(list(Cases = 0, Deaths = 0)) %>% 
# #   gather(-Age, key = "Measure", value = "Value") %>% 
# #   separate(Age, c("Age", "trash"), sep = "-") %>% 
# #   mutate(Age = case_when(Age == "<29" ~ "0",
# #                          Age == "90+" ~ "90",
# #                          Age == "Alls" ~ "TOT",
# #                          TRUE ~ Age)) %>% 
# #   select(-trash)
# # 
# # 
# # driver$server$stop() 
# # rm(remote_driver)
# # gc()
# # driver <- remoteDriver(remoteServerAddr = "localhost" 
# #                        , port = 4445L
# #                        , browserName = "chrome"
# # )
# # 
# # 
# # 
# # 
# # (browser = "chrome",
# #                               port = 4601L,
# #                               chromever =
# #                                 system2(command = "wmic",
# #                                         args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
# #                                         stdout = TRUE,
# #                                         stderr = TRUE) %>%
# #                                 stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
# #                                 magrittr::extract(!is.na(.)) %>%
# #                                 stringr::str_replace_all(pattern = "\\.",
# #                                                          replacement = "\\\\.") %>%
# #                                 paste0("^",  .) %>%
# #                                 stringr::str_subset(string =
# #                                                       binman::list_versions(appname = "chromedriver") %>%
# #                                                       dplyr::last()) %>% 
# #                                 as.numeric_version() %>%
# #                                 max() %>%
# #                                 as.character())
