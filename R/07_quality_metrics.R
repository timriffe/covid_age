source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

# some functions internal to this script
add_b_margin <- function(chunk){
  if (nrow(chunk) > 0){
      if (! "b" %in% chunk[["Sex"]] ){
        if (all(c("f","m") %in% chunk[["Sex"]])){
          b       <- chunk[1, ]
          b$Sex   <- "b"
          b$Value <- sum(chunk$Value)
          chunk   <- bind_rows(chunk,b) 
        }
      }
  }
  chunk
}


# Script should calculate

inputDB   <- data.table::fread(here::here("Data","inputDB_internal.csv"),encoding = "UTF-8")
Output_10 <- data.table::fread(here::here("Data","Output_10_internal.csv"),encoding = "UTF-8")
Offsets   <- readRDS(here::here("Data","Offsets.rds"))
Metadata  <- readRDS(here::here("Data","metadata_important.rds"))
# I How aggressive is scaling? (also UNK rescaling) - time varying
inputDB <- 
  inputDB %>% 
  filter(!is.na(Value))
# strategy:

# 1) get inputDB

# 1.1) filter to only rows of stated age (no UNK, TOT)
# 1.2) summarize TOT by Country, Region, Code (?), Date, Sex, Measure
# (we ignore metric conversions here, since Fractions are by definition rescaled
# and ASCFR conversions are in practice also all rescaled)

IDB_age_known <- 
  inputDB %>% 
  dplyr::filter(! Age %in% c("TOT","UNK"),
         Metric == "Count",
         Measure %in% c("Cases","Deaths","Tests")) %>% 
  mutate(Date = dmy(Date))
  
IDB_marginal_sums <- 
  IDB_age_known %>% 
  as.data.table() %>% 
  .[,.(Value=sum(Value)), by = .(Country, Region, Code, Date, Sex, Measure)] %>% 
  dcast(Country + Region+Code+ Date+  Measure~Sex, value.var = "Value") %>% 
  .[,b:=ifelse(is.na(b), f+m, b)] %>% 
  melt(measure.vars = c("b","f","m"),
       variable.name = "Sex",
       value.name = "Value") %>% 
  dcast(Country + Region+Code+ Date+  Sex~Measure, value.var = "Value") %>% 
  .[order(Country, Region, Sex, Date)]


# This lacks both-sex margins derived from sex-specific margins.

# 2) get Output_10, take marginal sums too.

Output_10_marginal_sums <- 
  Output_10 %>% 
  as.data.table() %>% 
  .[,Date := dmy(Date)] %>% 
  .[,.(CasesFinal = sum(Cases),
       DeathsFinal = sum(Deaths),
       TestsFinal = sum(Tests)),
    by = .(Country, Region, Code, Date, Sex)] %>% 
  .[order(Country, Region, Sex, Date)]


# 3) merge Totals
# (2.1) has been rescaled, whereas (1.2) has not, so we can summarize as a fraction

Marginal_sums_check <- 
  merge(Output_10_marginal_sums, IDB_marginal_sums) %>% 
  as.data.table() %>% 
  .[,.(cases_known_age = Cases / CasesFinal,
       deaths_known_age = Deaths / DeathsFinal,
       tests_known_age = Tests / TestsFinal), 
    by = .(Country,Region,Code,Date,Sex)] %>% 
  .[,cases_known_age := ifelse(is.infinite(cases_known_age),NA,cases_known_age)] %>% 
  .[,deaths_known_age := ifelse(is.infinite(deaths_known_age),NA,deaths_known_age)] %>% 
  .[,tests_known_age := ifelse(is.infinite(tests_known_age),NA,tests_known_age)] %>% 
  filter(!(is.na(cases_known_age) & is.na(deaths_known_age) & is.na(tests_known_age)))

  
#%>% 
 # .[!(is.na(cases_known_age) & is.na(deaths_known_age) & is.na(tests_known_age))]

#Marginal_sums_check[deaths_known_age > 1.1] 
# Marginal_sums_check %>% 
#   filter(Country == "France",
#          Region == "All",
#          Sex == "b") %>% 
#   ggplot(aes(x=Date,y=deaths_known_age)) + geom_line()

# Worldometers fraction can also be reported? But we might just want to rescale
# non-refreshing series to Worldometers totals anyway...

# II Number of age categories (N)


# 1) get inputDB:
# 1.1) select rows of known age
# 1.2) summarize n() by Country, Region, Code, Date, Sex, Measure

NAgeCategories <-
  inputDB %>% 
  mutate(Date = dmy(Date)) %>% 
  dplyr::filter(! Age %in% c("TOT","UNK")) %>% 
  group_by(Country,Region,Code,Date,Sex,Measure) %>% 
  summarize(N = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure, values_from=N) %>% 
  rename(cases_N_ages = Cases,
         deaths_N_ages = Deaths,
         tests_N_ages = Tests) %>% 
  dplyr::select(-ASCFR)
# III Open age

# 1) get inputDB:
# 1.1) select rows of known age
# 1.2) coerce Age to integer
# 1.3) select max Age per Country, Region, Code, Date, Sex, Measure

MaxAge <-
  inputDB %>% 
  dplyr::filter(! Age %in% c("TOT","UNK")) %>% 
  mutate(Age = as.integer(Age),
         Date = dmy(Date)) %>% 
  group_by(Country,Region,Code,Date,Sex,Measure) %>% 
  summarize(MaxAge = max(Age)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure, values_from=MaxAge) %>% 
  rename(cases_max_age = Cases,
         deaths_max_age = Deaths,
         tests_max_age = Tests) %>% 
  dplyr::select(-ASCFR)

# IV Offsets yes/no

# 1) Output_10, combinations of Country, Region, Sex
# 2) Offsets combinations of Country, Region, Sex
# 3) merge for binary indicator

n <- duplicated(Output_10[,c("Country","Region","Sex")])

SubPops <-
  Output_10 %>% 
  dplyr::select(Country,Region,Sex) %>% 
  dplyr::filter(!n)

n <- duplicated(Offsets[,c("Country","Region","Sex")])
SubPopOffsets <-
  Offsets %>% 
  dplyr::select(Country,Region,Sex) %>% 
  dplyr::filter(!n) %>% 
  mutate(Offset = TRUE)

SubPopsOffsetsIndicator <-
  SubPops %>% 
  left_join(SubPopOffsets) %>% 
  mutate(Offset = ifelse(is.na(Offset),FALSE,Offset))
  
# V Refreshing yes/no

# metadata needs some cleaning before this can integrate
#this may need an update?
# all_regions <- c("Mexico", "Peru", "Japan", "France", "Germany", "Colombia", 
#                  "Brazil", "Spain", "Czechia", "Belgium", "Netherlands", 
#                  "Paraguay")

rownames(Metadata)<- NULL
Corrections <-
Metadata %>% 
  dplyr::select(Country, `Region(s)`,`Retrospective corrections`) %>% 
  rename("Region" = `Region(s)`, "Corrected" = `Retrospective corrections`)# %>% View() 

# read metadata_basic.rds, this should be compiled daily with the build,
# it comes from the metadata tabs


# VI Positivity (OWD) *
OWD <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv",
                col_types= "cccDdddddddddddddddddddddddddddddcdddddddddddddddd") %>% 
  dplyr::filter(!is.na(iso_code)) %>% 
  dplyr::filter(! iso_code %in% c("OWID_KOS","OWID_WRL")) %>% 
  mutate(Code = countrycode(iso_code, 
                             origin = 'iso3c', 
                             destination = 'iso2c')) %>% 
  dplyr::select(Code, 
         Date = date, 
         total_cases, 
         total_tests, 
         new_cases_smoothed, 
         new_tests_smoothed) %>% 
  mutate(positivity_cumulative = total_cases / total_tests,
         positivity_new = new_cases_smoothed / new_tests_smoothed) %>% 
  dplyr::select(-total_cases, - total_tests, -new_cases_smoothed, -new_tests_smoothed) %>% 
  mutate(Region = "All")

cdbcountries <- inputDB %>% 
  dplyr::filter(Region == "All") %>% 
  group_by(Country) %>% 
  slice(1) %>% 
  dplyr::select(Country, Code)

OWD <- left_join(OWD, cdbcountries, by = "Code") 

# 1) read in OWD data,
# 1.1) do we capture any tests that they don't have? If so, send them an email.
# 2) summarize Output_10 to totals
# 3) merge, calculate metric Cases / Tests


# VII  Non-monotonicity


# VIII Bohk-completeness metric - National only, can wait

# needs to wait because need to gather location-sex-specific lifetables. WPP can work for countries,
# but would need to gather subnational. Might also want to provide this extra metric as output.



# Merge metrics into
# Country
# Country - Region
# Country - Region - Date (data only)

# Marginal_sums_check
# NAgeCategories
# MaxAge
# SubPopsOffsetsIndicator
Marginal_sums_check <-
  Marginal_sums_check %>% 
  dplyr::select(-Code)

FullIndicators <- 
  Marginal_sums_check %>% 
  left_join(Corrections) %>% 
  left_join(NAgeCategories) %>% 
  left_join(MaxAge) %>% 
  left_join(SubPopsOffsetsIndicator) %>% 
  left_join(OWD) 

# Marginal_sums_check %>% 
#   group_by(Country, Region) %>% 
#   

# public file, full precision.
header_msg <- paste("COVerAGE-DB selected data quality metrics:",timestamp(prefix = "", suffix = ""))
data.table::fwrite(as.list(header_msg), 
                   file = here::here("Data","qualityMetrics.csv"))
data.table::fwrite(FullIndicators, 
                   file = here::here("Data","qualityMetrics.csv"), 
                   append = TRUE, 
                   col.names = TRUE)

