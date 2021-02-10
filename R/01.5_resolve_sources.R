library(here)
source(here("R","00_Functions.R"))
logfile <- here("buildlog.md")

log_section("begin resolution of multiple sources per population", logfile = logfile)

idb <- readRDS("Data/inputDB.rds")

idb <- idb %>% 
  mutate(Date = dmy(Date),
         Date = ddmmyyyy(Date))

# Trying with the inputDB in OSF
# osf_retrieve_file("9dsfk") %>%
#   osf_download(conflicts = "overwrite",
#                path = "Data") 
# 
# # This reads it in
# idb <-  read_csv("Data/inputDB.zip",
#                  skip = 1,
#                  col_types = cols(.default = "c")) %>% 
#   mutate(Date = dmy(Date),
#          Date = ddmmyyyy(Date))

# -------------------------------------- #
# Resolve US CDC state sources           #
# -------------------------------------- #
# weekly
# deaths only
# always prefer CDC if there is overlap within a week.
# This might mean throwing out more than one day of 
# death data collected from the state. We should be
log_section("Resolve USA CDC overlaps", logfile = logfile)

# 1: subset idb to US states, deaths 

USA <- idb %>% 
  filter(Country == "USA",
         Region != "All",
         Region != "NYC",
         Measure == "Deaths")

# Remove that subset
idb <- idb %>% 
  filter(!(Country == "USA" &
           Region != "All" &
           Region != "NYC" &
           Measure == "Deaths"))

# 2: create isoweek column
USA<-
  USA %>% 
  mutate(Date = dmy(Date),
         week = week(Date),
         year = isoyear(Date)) 

# 3: create binary source column (CDC or no)
USA <- 
  USA %>% 
  mutate(isCDC = grepl(Code, pattern = "CDC"))

# 4: create column for overlap
USA <-
  USA %>% 
  group_by(Region, Sex, year, week) %>% 
  mutate(overlap = any(isCDC) & any(!isCDC)) %>% 
  ungroup()

# 5) remove overlap & !isCDC
USAout <- 
  USA %>% 
  filter(overlap & !isCDC)

USA <- 
  USA %>% 
  filter(!(overlap & !isCDC)) %>% 
  select(-isCDC, -overlap, -week, -year) %>% 
  mutate(Date = ddmmyyyy(Date),
         Code = gsub(Code, pattern = "CDC_", replacement = ""))

# 6) append
idb <-
  idb %>% 
  bind_rows(USA)

cat("USA CDC resolved\n",nrow(USAout),"rows removed\n", file = logfile, append = TRUE)

# -------------------------------------- #
# Resolve Brazil states                  #                
# -------------------------------------- #
# daily
# rule: always prefer TRC if there is overlap within a day
log_section("Resolve Brazil TRC overlaps", logfile = logfile)


BRA <- idb %>% 
  filter(Country == "Brazil")
n1 <- nrow(BRA)
idb <- 
  idb %>% 
  filter(Country != "Brazil")

# detect TRC
BRA <-
  BRA %>% 
  mutate(isTRC = grepl(Code, pattern = "TRC"))

# detect overlap
BRA <-
  BRA %>% 
  group_by(Region, Date, Sex, Measure) %>% 
  mutate(overlap = any(isTRC) & any(!isTRC)) %>% 
  ungroup()

# over overlap, remove !isTRC
BRAout <- 
  BRA %>% 
  filter(overlap & !isTRC)

BRA <-
  BRA %>% 
  filter(!(overlap & !isTRC)) %>% 
  select(-isTRC, -overlap) %>% 
  mutate(Code = gsub(Code, pattern = "TRC_", replacement = ""))

n2 <- nrow(BRA)

# append
idb <- idb %>% 
  bind_rows(BRA)
cat("Brazil TRC resolved\n",n1-n2,"rows removed\n", file = logfile, append = TRUE)


# -------------------------------------- #
# Resolve Italy bol / info               #
# -------------------------------------- #
# daily. 
# rule: discard 'info' for days in which they overlap
log_section("Resolve Italy Bollettino and Infografico", logfile = logfile)

IT <- idb %>% 
  filter(Country == "Italy",
         (grepl(Code, pattern = "info") | grepl(Code, pattern = "bol")))
n1 <- nrow(IT)
idb <- 
  idb %>% 
  filter(!(
    Country == "Italy" & (grepl(Code, pattern = "bol") | grepl(Code, pattern = "info"))
  ))

# Bolettino id variable
IT <- 
  IT %>% 
  mutate(isBOL = grepl(Code, pattern = "bol"))

# overlap variable
IT <-
  IT %>% 
  group_by(Date) %>% 
  mutate(overlap = any(isBOL) & any(!isBOL)) %>% 
  ungroup()

# remove overlapy & !isBOL
ITout <- 
  IT %>% 
  filter(overlap & !isBOL)

IT <-
  IT %>% 
  filter(!(overlap & !isBOL)) %>% 
  select(-isBOL, -overlap) %>% 
  # rewrite Code
  mutate(Code = paste0("IT",Date)) 
n2 <- nrow(IT)
# append
idb <-
  idb %>% 
  bind_rows(IT)
cat("Italy resolved\n",n1-n2,"rows removed\n", file = logfile, append = TRUE)


# -------------------------------------- #
# Resolve ECDC                           #
# -------------------------------------- #
# weekly.
# rule: always prefer national source if there is overlap within a week.
# This might mean throwing out more than one day of 
# death data collected from the state. 
log_section("Resolve ECDC overlaps", logfile = logfile)


ever_ecdc_countries <-
  idb %>% 
  filter(grepl(Code, pattern = "ECDC")) %>% 
  dplyr::pull(Country) %>% 
  unique()
 
ECDC <- idb %>% 
  filter(Country %in% ever_ecdc_countries & Region == "All")
n1   <- nrow(ECDC)

idb <-
  idb %>% 
  filter(!(Country %in% ever_ecdc_countries & Region == "All"))

# define week and isoyear
ECDC <-
  ECDC %>% 
  mutate(Date = dmy(Date),
         week = week(Date),
         year = isoyear(Date)) 

# id ECDC
ECDC <-
  ECDC %>% 
  mutate(isECDC = grepl(Code, pattern = "ECDC_"))

# when checking need to also add both- sex ECDC for those countries
# where we only collect both-sex data (Finland)
ECDCb <-
  ECDC %>% 
  filter(isECDC) %>% 
  pivot_wider(names_from = "Sex", values_from = "Value") %>% 
  mutate(b = f + m) %>% 
  pivot_longer(cols = c("m","f","b"),names_to = "Sex", values_to = "Value") %>% 
  filter(Sex == "b")
  
ECDC <- ECDC %>% 
  bind_rows(ECDCb)

# overlap within week?
# by Country, year, week, Sex, Measure

ECDC <-
  ECDC %>% 
  group_by(Country, year, week, Sex, Measure) %>% 
  mutate(overlap = any(isECDC) & any(!isECDC)) %>% 
  ungroup()

# if there is overlap, then keep !isECDC
ECDCout <- 
  ECDC %>% 
  filter(overlap & isECDC)

ECDC <- 
  ECDC %>% 
  filter(!(overlap & isECDC))

# remove extra columns, recode Date
ECDC <- 
  ECDC %>% 
  mutate(Date = ddmmyyyy(Date)) %>% 
  select(-year, -week, -overlap, -isECDC) %>% 
  mutate(Code = gsub(Code, pattern = "ECDC_", replacement = ""))
n2 <- nrow(ECDC)
# Append:
idb <-
  idb %>% 
  bind_rows(ECDC)
cat("ECDC resolved\n",n1-n2,"rows removed\n", file = logfile, append = TRUE)

# --------------------------------------------------- #
# here, Code column should no longer identify source. #
# --------------------------------------------------- #

saveRDS(idb,file= "Data/inputDBresolved.rds")

# idb <-
#   idb %>% 
#   mutate(Short = add_Short(Code, Date))
# 
# idb$Short %>% unique() %>% sort() %>% View()
# 
# idb %>% 
#   group_by(Country, Region, Date, Sex, Measure, Age) %>% 
#   summarize(n=n(), .groups = "drop") %>% 
#   filter(n > 1)

# idb %>% 
#   filter(Region == "Wisconsin") %>% 
#   dplyr::pull(Date) %>% 
#   unique()


# end