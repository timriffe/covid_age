
# Once-off offsets

# --------------------------------------------#
# TR: some of these need to be moved to 2020! #
# TR: all subsets need a new Region column!   #
# --------------------------------------------#

# --------------------------------------
# China Offset from WPP2019:
# United Nations, Department of Economic and Social Affairs, Population Division (2019). World Population Prospects 2019, custom data acquired via website.
# it's a 2020 mid-year projection in 5-year age groups, good enough for now.

CNpop <- c(83932,86735,84263,82342,87158,97989,
128739,100091,96274,119838,123445,98740,77514,74150,
44950,26545,16181,7582,2305,475,75) * 1000
CNage <- (1:length(CNpop) - 1) * 5

CNoffset <- tibble(Country = "China",
                   Region = "All",
                   Year = 2020,
                   Age = CNage,
                   Sex = "b",
                   Population = CNpop)

# --------------------------------------
# Washington State
# These have a 2020 ref date. In 5-year age groups. Still on hunt for single ages.
WApop <- c(453551,475580,478896,464081,492661,539615,522479,521493,
           465060,470565,461238,495654,479135,419113,327717,212066,130696,136810)
WAage <- (1:length(WApop) - 1) * 5

WAoffset <- tibble(Country = "USA",
                   Region = "Washington",
                   Year = 2020,
                   Age = WAage,
                   Sex = "b",
                   Population = WApop)

# USA Needed still: Michigan, Louisiana, Illinois, Massechusetts (and maybe more)

# --------------------------------------
# New York City (Cornell Projection, HT Denys Dukovnov)
# these are 2020 ref date already, so good to go.
NYCpop <- c(119032, 116883, 114956, 112933, 110755, 110485, 107257, 106327, 
            104288, 104840, 97395, 93967, 94670, 93912, 92314, 92380, 92399, 
            92591, 90961, 89964, 94810, 97191, 103071, 117002, 130114, 141129, 
            148994, 154279, 160262, 167576, 170251, 161913, 156778, 150786, 
            145143, 142250, 133852, 132464, 130514, 125750, 128519, 121100, 
            115883, 113057, 108954, 111347, 105867, 104510, 105850, 110076, 
            113898, 106584, 104231, 102181, 104440, 110095, 109462, 107789, 
            104518, 104607, 108445, 102630, 100498, 99413, 96389, 96409, 
            89441, 83961, 79855, 77257, 77475, 72659, 70608, 69847, 57025, 
            54676, 49514, 48246, 43043, 39317, 38064, 34998, 33489, 30610, 
            28920, 186691)

NYCage <- 0:85
NYCoffset <- tibble(Country = "USA",
                    Region = "NYC",
                    Year = 2020,
                    Age = NYCage,
                    Sex = "b",
                    Population = NYCpop)

CAN_both <- function(X){
  X %>% 
  pivot_wider(names_from = Sex,
              values_from = Population) %>% 
  mutate(b = m + f) %>% 
  pivot_longer(c(f,m,b), 
               names_to = "Sex",
               values_to = "Population")
}

CanadaOffsets <- read_csv("Data/CanadaOffsets.csv") %>% 
  mutate(Population = Population * 1000) %>% 
  group_by(Country, Region) %>% 
  do( CAN_both(X = .data)) %>% 
  ungroup()

# -------------------- #
# ALso NEED Montreal!  #
# -------------------- #

# -------------------------------
# Taiwan Offsets:
TaiwanOffset <- 
read_csv("Data/TaiwanOffset.csv") %>% 
  pivot_longer(cols = 2:4,
               names_to = "Sex",
               values_to = "Population") %>% 
  mutate(Country = "Taiwan",
         Region = "All",
         Year = 2020) %>% 
  select(Country,Region, Year, Sex, Age, Population) %>% 
  arrange(Sex, Age)



# ---------------------------------------
# HMD offsets:
# ---------------------------------------
hmdCountries <- c("KOR","FRATNP","DEUTNP","ITA","NLD","ESP","USA","BEL","CHE","SWE","DNK","PRT","JPN","AUS","GBR_NP","GBR_SCO","IRL")
our_names    <- c("SouthKorea","France","Germany","Italy",
               "Netherlands","Spain","USA","Belgium","Switzerland","Sweden",
               "Denmark","Portugal","Japan","Australia","United Kingdom","Scotland","Ireland" )
names(hmdCountries) <- our_names
names(our_names)    <- hmdCountries

HMDOffsets <- lapply(hmdCountries, function(XYZ,us,pw,our_names){
  X         <- readHMDweb(XYZ, "Population",us,pw)
  X$HMDcode <- XYZ
  X$Country <- our_names[XYZ]
  X$Region <- "All"
  X
},
us, pw, our_names) %>% 
  bind_rows() %>% 
  select(Country, Region, Year, Age, Female2, Male2, Total2) %>% 
  rename(f = Female2, m = Male2, b = Total2) %>% 
  group_by(Country) %>% 
  filter(Year < 2020) %>% 
  filter(Year == max(Year)) %>% 
  mutate(Year = Year + 1) %>% # implies Jan 1 pop
  pivot_longer(cols = 5:7, names_to = "Sex", values_to = "Population") %>% 
  ungroup() %>% 
  arrange(Country, Region, Sex, Age) 


# ------------------------------------------------------- #
# Compile Offset data object. single or 5-year age groups #
# ------------------------------------------------------- #

# Offsets
Offsets <- HMDOffsets %>% 
  rbind(WAoffset) %>% 
  rbind(NYCoffset) %>% 
  rbind(CanadaOffsets) %>% 
  rbind(CNoffset) %>% 
  rbind(TaiwanOffset)


# ------------------------------------------------------- #
# pre-split offsets to standard age ranges                #
# ------------------------------------------------------- #

Offsets <- 
   Offsets %>% 
   group_by(Country, Region, Sex) %>% 
   do(harmonize_offset_age(chunk = .data)) %>% 
  ungroup()




