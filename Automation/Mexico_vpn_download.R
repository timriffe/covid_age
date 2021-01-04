
# this script download Mexican data using vpn, to process it and saving it 
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")

# # reading data from the website ------------------------------------------------------ 
m_url <- "https://www.gob.mx/salud/documentos/datos-abiertos-152127"
html <- read_html(m_url)
# locating the links for the data
url1 <- html_nodes(html, xpath = '/html/body/main/div/div[1]/div[4]/div/table[2]/tbody/tr[1]/td[2]/a') %>%
  html_attr("href")


# downloading mexico data to nextcloud
dir <- "Data/Mexico/"
dir <- "C:/Users/kikep/Nextcloud/Projects/COVID_19/COVerAGE-DB/mexico/"
data_source <- paste0(dir, "mexico_data_", today(), ".zip")
download.file(url1, destfile = data_source)



