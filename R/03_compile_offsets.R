
# Once-off offsets

Offsets <- compile_offsetsDB()

Offsets %>% pull(Population)

Offsets %>% filter(is.na(Population))

Offsets <- 
  Offsets %>% 
  mutate(Age = as.integer(Age)) %>% 
  group_by(Country, Region, Sex) %>% 
  do(harmonize_offset_age(chunk = .data)) %>% 
  ungroup()















# ---------------------------------------
# HMD offsets:
# ---------------------------------------
# hmdCountries <- c("DNK","USA","CHE","SWE","PRT","AUS","GBR_NP","GBR_SCO","IRL")
# our_names    <- c("Denmark","USA","Switzerland","Sweden",
#                "Portugal","Australia","United Kingdom","Scotland","Ireland" )
# names(hmdCountries) <- our_names
# names(our_names)    <- hmdCountries
# 
# HMDOffsets <- lapply(hmdCountries, function(XYZ,us,pw,our_names){
#   X         <- readHMDweb(XYZ, "Population",us,pw)
#   X$HMDcode <- XYZ
#   X$Country <- our_names[XYZ]
#   X$Region <- "All"
#   X
# },
# us, pw, our_names) %>% 
#   bind_rows() %>% 
#   select(Country, Region, Year, Age, Female2, Male2, Total2) %>% 
#   rename(f = Female2, m = Male2, b = Total2) %>% 
#   group_by(Country) %>% 
#   filter(Year < 2020) %>% 
#   filter(Year == max(Year)) %>% 
#   mutate(Year = Year + 1) %>% # implies Jan 1 pop
#   pivot_longer(cols = 5:7, names_to = "Sex", values_to = "Population") %>% 
#   ungroup() %>% 
#   arrange(Country, Region, Sex, Age) 


# ------------------------------------------------------- #
# Compile Offset data object. single or 5-year age groups #
# ------------------------------------------------------- #

# Offsets
# Offsets <- HMDOffsets %>% 
#   rbind(WAoffset) %>% 
#   rbind(NYCoffset) %>% 
#   rbind(CanadaOffsets) %>% 
#   rbind(CNoffset) %>% 
#   rbind(TaiwanOffset)


# ------------------------------------------------------- #
# pre-split offsets to standard age ranges                #
# ------------------------------------------------------- #

# Offsets <- 
#    Offsets %>% 
#    group_by(Country, Region, Sex) %>% 
#    do(harmonize_offset_age(chunk = .data)) %>% 
#   ungroup()




