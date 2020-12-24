
library(RSelenium)
library(tidyverse)
library(lubridate)


# driver$server$stop() 

path_chrome_dr <- "N:/COVerAGE-DB/Automation/chromedriver.exe"
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
startServer(args = c("-Dwebdriver.chrome.driver=N:/COVerAGE-DB/Automation/hydra/chromedriver.exe"))
driver <- RSelenium::rsDriver(browser = "chrome",
                              port = 4590L,
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

frame1 <- remote_driver$findElements("css", "iframe")
remote_driver$switchToFrame(frame1[[1]])

# button <- remote_driver$findElement(using = "xpath", '//*[@id="d1647fa3-f644-4145-b4a6-34fc1565c8d3"]/div[1]/div/div[48]/div/a/span[2]')
button <- remote_driver$findElement(using = "class", 'igc-data-download-text')

button$clickElement()

ctr <- "Iceland"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n <- "Data/"

data_source <- paste0(dir_n, ctr, "/", ctr, "_data_", today(), ".csv")
file.copy("C:/Users/kikep/Downloads/Sheet 1.csv", data_source)
file.remove("C:/Users/kikep/Downloads/Sheet 1.csv")

db <- read_csv(data_source)

db2 <- db %>% 
  select(Age = 1,
         Deaths = 2,
         Cases = 3) %>% 
  replace_na(list(Cases = 0, Deaths = 0)) %>% 
  gather(-Age, key = "Measure", value = "Value") %>% 
  separate(Age, c("Age", "trash"), sep = "-") %>% 
  mutate(Age = case_when(Age == "<29" ~ "0",
                         Age == "90+" ~ "90",
                         Age == "Alls" ~ "TOT",
                         TRUE ~ Age))


cprof <- getChromeProfile("C:\Program Files (x86)\Google\Chrome\Application\ Data", "Profile 1")
remDr <- remoteDriver(browserName = "chrome", extraCapabilities = cprof)

