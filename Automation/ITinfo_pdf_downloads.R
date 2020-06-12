library(tidyverse)
library(lubridate)

# concatenate names for the daily pdfs
march <- paste0("https://www.epicentro.iss.it/coronavirus/bollettino/Infografica_",17:31,"marzo%20ITA.pdf")
marchNames <- paste0("Infografica_",17:31,"marzo ITA.pdf")

april <- paste0("https://www.epicentro.iss.it/coronavirus/bollettino/Infografica_",1:dd,"aprile%20ITA.pdf")
aprilNames <- paste0("Infografica_",1:30,"aprile ITA.pdf")

# In June this will need to move :-/
dd <- today() %>% day()
may <- paste0("https://www.epicentro.iss.it/coronavirus/bollettino/Infografica_",1:dd,"maggio%20ITA.pdf")
mayNames <- paste0("Infografica_",1:dd,"maggio ITA.pdf")




urls <- c(march, april, may)
Names <- c(marchNames, aprilNames, mayNames)

# make a folder to save them to
dir.create("ITinfo_pdfs")
for (i in 1:length(urls)){
  # download and save in the folder
  download.file(urls[i], destfile = file.path("ITinfo_pdfs",Names[i]))
}


