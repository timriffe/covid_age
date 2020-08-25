
# Ideally this would generate an email, but it looks tricky to configure. 
# Can think about tweeting out daily stats when we get a twitter account.


library(lubridate)
library(googlesheets4)
library(tidyverse)
library(here)

logfile <- here("buildlog.md")
log_section("update build series log", append = TRUE, logfile = logfile)


Date <- lubridate::today()
idb  <- readRDS(here("Data","inputDB.rds"))
o5   <- readRDS(here("Data","Output_5.rds"))

append_this <- tibble(Date = Date,
                      `Rows (inputDB)` = nrow(idb),
                      `Rows (output5)` = nrow(o5),
                      `Countries (inputDB)` = length(unique(idb$Country)),
                      `Countries (output5)` = length(unique(o5$Country)),
                      `Populations (inputDB)` = length(unique(paste(o5$Country,o5$Region))),
                      `Populations (output5)` = length(unique(paste(o5$Country,o5$Region))))
gs4_auth(email = "tim.riffe@gmail.com")
# Let's have the newest on the top:
ss <- "https://docs.google.com/spreadsheets/d/1X2H6sBH63pRt6JxUduvJ8rjp90O0GQb5WcgB_fVyAmk/edit#gid=0"
IN <- read_sheet(ss, sheet = "build log", col_types = "Diiiiii")

OUT <- bind_rows(append_this, IN)

write_sheet(OUT, ss = ss, sheet = "build log")

# we can then set up this sheet to send notification when updated.

