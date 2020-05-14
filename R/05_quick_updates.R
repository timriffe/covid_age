
source("R/00_Functions.R")
source("R_checks/inputDB_check.R")
# read in present inputDB
inputDB <- readRDS("Data/inputDB.rds")

# unrounded output files
output5  <- readRDS("Data/Output_5.rds")
output10 <- readRDS("Data/Output_10.rds")
# read in from Drive:
ShortCode <- "DK"
incoming  <- get_country_inputDB(ShortCode)

# slice off ShortCode
standby   <- inputDB %>% filter(Short == ShortCode)
inputDB   <- inputDB %>% filter(Short != ShortCode)

dim(standby)
dim(incoming)

# Once-off checks, a bit sloppy
run_checks(incoming, ShortCode)

# This uses no offsets. To be modified when we have
# a general offsets object.
harmonized5 <- process_counts(incoming, Offsets = NULL, N = 5)

# Visualize ASCFR implied

harmonized5 %>% 
  filter(Sex == "b") %>% 
  group_by(Date) %>% 
  mutate(n = sum(Deaths)) %>% 
  ungroup() %>% 
  # You can move n threshold u and down as cheap
  # way to see whether ugly lower age patterns just
  # due to small numbers
  filter(n > 100) %>% 
  mutate(ASCFR = Deaths / Cases,
         date = dmy(Date)) %>% 
  ggplot(aes(x = Age, y = ASCFR, group = Date, color = date)) +
  geom_line() + 
  scale_y_log10()

# Looks OK? DO more checks?

# Swap out in inputDB
inputDB <-
  rbind(inputDB, incoming) %>% 
  sort_input_data()

# Save inputDB
write_csv(inputDB, path = "Data/inputDB.csv")
saveRDS(inputDB, "Data/inputDB.rds")

# Swap out ShortCode in Output5
# ugh we don't have the same ShortCode. Need a nice lookup
# 
# if (!"Tests" %in% colnames(harmonized5)){
#   harmonized5 <- harmonized5 %>% mutate(Tests = NA)
# }
# 
# head(output5)
# output5 <- 
#   output5 %>% 
#   mutate(Short = add_Short(Code, Date)) %>% 
#   filter(Short != ShortCode) %>% 
#   select(!Short) %>% 
#   rbind(harmonized5) %>% 
#   sort_input_data()





