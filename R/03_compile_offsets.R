source("R/00_Functions.R")
# Once-off offsets. This code can be run from time to time. It does not need to be run at each
# database build.

# this might take 5-10 minutes now,
# but when we get more offsets collected it 
# will have to slow down
Offsets <- compile_offsetsDB()

Offsets %>% pull(Population)

Offsets %>% filter(is.na(Population)) %>% View()

Offsets <- 
  Offsets %>% 
  mutate(Age = as.integer(Age)) %>% 
  group_by(Country, Region, Sex) %>% 
  do(harmonize_offset_age(chunk = .data)) %>% 
  # This is where date synchronization (projection) goes
  # So, FR write a function that anticipates a chunk of data
  # in standard single ages. We need to have Date as an attribute of
  # the data moving forward. This goes here.  
  ungroup()

# save out
saveRDS(Offsets,"Data/Offsets.rds")

# as csv
header_msg <- paste("Population offsets used for splitting:",timestamp(prefix="",suffix=""))
write_lines(header_msg, path = "Data/offsets.csv")
Offsets %>% 
  mutate(Population = round(Population)) %>% 
write_csv(path = "Data/offsets.csv", append = TRUE, col_names = TRUE)










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




