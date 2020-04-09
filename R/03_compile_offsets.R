
# Once-off offsets
# --------------------------------------
# Washington State
WApop <- c(453551,475580,478896,464081,492661,539615,522479,521493,
           465060,470565,461238,495654,479135,419113,327717,212066,130696,136810)
WAage <- (1:length(WApop) - 1) * 5

WAoffset <- tibble(Country = "USA_WA",
                   Year = 2020,
                   Age = WAage,
                   Sex = "b",
                   Population = WApop)

# --------------------------------------
# New York City (Cornell Projection, HT Denys Dukovnov)
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
NYCoffset <- tibble(Country = "USA_NYC",
                    Year = 2020,
                    Age = NYCage,
                    Sex = "b",
                    Population = NYCpop)

# HMD offsets:
hmdCountries <- c("KOR","FRATNP","DEUTNP","ITA","NLD","ESP","USA","BEL","CHE","SWE")
our_names    <- c("SouthKorea","France","Germany","Italy",
               "Netherlands","Spain","USA","Belgium","Switzerland","Sweden")
names(hmdCountries) <- our_names
names(our_names)    <- hmdCountries

library(HMDHFDplus)
HMDOffsets <- lapply(hmdCountries, function(XYZ,us,pw,our_names){
  X         <- readHMDweb(XYZ, "Population",us,pw)
  X$HMDcode <- XYZ
  X$Country <- our_names[XYZ]
  X
},
us, pw, our_names) %>% 
  bind_rows() %>% 
  select(Country, Year, Age, Female2, Male2, Total2) %>% 
  rename(f = Female2, m = Male2, b = Total2) %>% 
  group_by(Country) %>% 
  filter(Year == max(Year)) %>% 
  mutate(Year = Year + 1) %>% # implies Jan 1 pop
  pivot_longer(cols = 4:6, names_to = "Sex", values_to = "Population") %>% 
  ungroup() %>% 
  arrange(Country, Sex, Age) 


#-------------------------------------------------------------
# Compile Offset data object. single or 5-year age groups.   #
#-------------------------------------------------------------

# Offsets
Offsets <- HMDoffsets %>% 
  rbind(WAoffset) %>% 
  rbind(NYCoffset)









