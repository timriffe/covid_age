
source(here("R","00_Functions.R"))
logfile <- here("buildlog.md")

idb <- readRDS("Data/inputDB.rds")

# -------------------------------------- #
# Resolve US CDC state sources           #
# -------------------------------------- #
# weekly
# deaths only
# always prefer CDC if there is overlap within a week.
# This might mean throwing out more than one day of 
# death data collected from the state. We should be

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
  mutate(Date = ddmmyyyy(Date))

# 6) append

idb <-
  idb %>% 
  bind_rows(USA)

# -------------------------------------- #
# Resolve Brazil states                  #                
# -------------------------------------- #
# daily

BRA <- idb %>% 
  filter(Country == "Brazil")

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
BRA <-
  BRA %>% 
  filter(!(overlap & !isTRC)) %>% 
  select(-isTRC, -overlap)

# append

idb <- idb %>% 
  bind_rows(BRA)


# -------------------------------------- #
# Resolve Italy bol / info               #
# -------------------------------------- #
# daily

# -------------------------------------- #
# Resolve ECDC                           #
# -------------------------------------- #
# weekly.



# here, Code column should no longer identify source.
# end