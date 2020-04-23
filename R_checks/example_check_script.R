
# load checker functions
source(here("R_checks/inputDB_check.R"))

inputDB <- read_csv("Data/inputDB.csv")

# --------------------------------------
# run checks on selected inputs
# possibly relevent for quality controlers
my_codes <- c("DE","ITbol","ITinfo","ES")
run_checks(inputDB, my_codes)


# --------------------------------------
# or do them all?
# necessary in order to do a batch build
my_codes <- inputDB %>% pull(Short) %>% unique()
run_checks(inputDB, my_codes)
