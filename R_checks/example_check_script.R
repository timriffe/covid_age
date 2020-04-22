
# load checker functions
source(here("R_checks/inputDB_check.R"))

inputDB <- read_csv("Data/inputDB.csv")

my_codes <- c("DE","ITbol","ITinfo","ES")

run_checks(inputDB, my_codes)

