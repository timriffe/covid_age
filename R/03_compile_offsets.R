### Functions & Settings ############################################
logfile <- "buildlog.md"
# Detect cores
n.cores     <- 8

source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

### Compile offsets #################################################

# Log
log_section("Compile offsets from Drive",logfile=logfile)


# Compile
Offsets <- compile_offsetsDB()



### Harmonize offsets ###############################################

# Log
log_section("Harmonize offsets",logfile=logfile)

# AgeInt has to be 1 or larger
Offsets <-
  Offsets %>% 
  mutate(AgeInt = ifelse(AgeInt == 0, 1, AgeInt))

# Age has to be integer
Offsets <- 
  Offsets %>% 
  mutate(Age = as.integer(Age))

# Split offsets by country/region/sex
oL <-split(Offsets, 
           list(Offsets$Country,Offsets$Region,Offsets$Sex), 
           drop = TRUE)

# Parallelized harmonization
oL1 <- mclapply(
         oL,
         try_step,
         process_function = harmonize_offset_age_p,
         byvars = c("Country","Region","Sex"),
         mc.cores=n.cores )

# Combine offsets in data frame
Offsets <-
  oL1 %>% 
  rbindlist() %>% 
  as.data.frame()



### Saving ##########################################################

# save out
saveRDS(Offsets,here("Data","Offsets.rds"))

# Save as csv
header_msg <- paste("Population offsets used for splitting:",
                    timestamp(prefix="",suffix=""))
write_lines(header_msg, file = here("Data","offsets.csv"))
Offsets %>% 
  mutate(Population = round(Population)) %>% 
write_csv(file = here("Data","offsets.csv"), append = TRUE, col_names = TRUE)

# clean up:
