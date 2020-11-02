
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
library(here)
source(here("R","00_Functions.R"))
inputDB   <- readRDS(here("Data","inputDB.rds"))
Output_10 <- readRDS(here("Data","Output_10.rds"))
Offsets   <- readRDS(here("Data","Offsets.rds"))
Metadata  <-readRDS(here("Data","metadata_important.rds"))
# I How aggressive is scaling? (also UNK rescaling) - time varying

# strategy:

# 1) get inputDB

# 1.1) filter to only rows of stated age (no UNK, TOT)
# 1.2) summarize TOT by Country, Region, Code (?), Date, Sex, Measure
# (we ignore metric conversions here, since Fractions are by definition rescaled
# and ASCFR conversions are in practice also all rescaled)

IDB_marginal_sums <- 
  inputDB %>% 
  filter(! Age %in% c("TOT","UNK"),
         Metric == "Count") %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Region, Code, Date, Sex, Measure) %>% 
  summarize(Value = sum(Value)) %>% 
  ungroup() %>% 
  group_by(Country, Region, Code, Date, Measure) %>% 
  do(add_b_margin(chunk = .data)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure, values_from=Value) %>% 
  arrange(Country, Region, Sex, Date)

# This lacks both-sex margins derived from sex-specific margins.

# 2) get Output_10, take marginal sums too.

Output_10_marginal_sums <- 
  Output_10 %>% 
  mutate(Date = dmy(Date)) %>% 
  group_by(Country, Region, Code, Date, Sex) %>% 
  summarize(CasesFinal = sum(Cases),
            DeathsFinal = sum(Deaths),
            TestsFinal = sum(Tests)) %>% 
  ungroup() %>% 
  arrange(Country, Region, Sex, Date)

# 3) merge Totals
# (2.1) has been rescaled, whereas (1.2) has not, so we can summarize as a fraction

Marginal_sums_check <-
  Output_10_marginal_sums %>% 
  left_join(IDB_marginal_sums) %>% 
  mutate(cases_known_age = Cases / CasesFinal,
         deaths_known_age = Deaths / DeathsFinal,
         tests_known_age = Tests / TestsFinal) %>% 
  select(Country,Region,Code,Date,Sex,cases_known_age,deaths_known_age,tests_known_age)

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
  filter(! Age %in% c("TOT","UNK")) %>% 
  group_by(Country,Region,Code,Date,Sex,Measure) %>% 
  summarize(N = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure, values_from=N) 
  
# III Open age

# 1) get inputDB:
# 1.1) select rows of known age
# 1.2) coerge Age to integer
# 1.2) select max Age per Country, Region, Code, Date, Sex, Measure

MaxAge <-
  inputDB %>% 
  filter(! Age %in% c("TOT","UNK")) %>% 
  mutate(Age = as.integer(Age)) %>% 
  group_by(Country,Region,Code,Date,Sex,Measure) %>% 
  summarize(MaxAge = max(Age)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure, values_from=MaxAge) 

# IV Offsets yes/no

# 1) Output_10, combinations of Country, Region, Sex
# 2) Offsets combinations of Country, Region, Sex
# 3) merge for binary indicator

n <- duplicated(Output_10[,c("Country","Region","Sex")])

SubPops <-
  Output_10 %>% 
  select(Country,Region,Sex) %>% 
  filter(!n)

n <- duplicated(Offsets[,c("Country","Region","Sex")])
SubPopOffsets <-
  Offsets %>% 
  select(Country,Region,Sex) %>% 
  filter(!n) %>% 
  mutate(Offset = TRUE)

SubPopsOffsetsIndicator <-
  SubPops %>% 
  left_join(SubPopOffsets) %>% 
  mutate(Offset = ifelse(is.na(Offset),FALSE,Offset))
  
# V Refreshing yes/no

rownames(Metadata)<- NULL
Metadata %>% 
  select(Country, `Region(s)`,`Retrospective corrections`) %>% 
  rename("Region" = `Region(s)`, "Corrected" = `Retrospective corrections`) %>% View() 

# read metadata_basic.rds, this should be compiled daily with the build,
# it comes from the metadata tabs


# VI Positivity (OWD) *

# 1) read in OWD data,
# 1.1) do we capture any tests that they don't have? If so, send them an email.
# 2) summarize Output_10 to totals
# 3) merge, calculate metric Cases / Tests


#   Non-monotonicity
# VII Bohk-completeness metric - National only, can wait

# needs to wait because need to gather location-sex-specific lifetables. WPP can work for countries,
# but would need to gather subnational. Might also want to provide this extra metric as output.

