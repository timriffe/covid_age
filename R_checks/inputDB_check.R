# --------------------------------------------------- #
# Author: Marius D. Pascariu
# Last update: Wed Apr 22 17:03:19 2020
# --------------------------------------------------- #
# remove(list = ls())
library(tidyverse)
library(testthat)


# input_data <- read.csv("Data/inputDB.csv")
# 
# test_data <- input_data %>% 
#   mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
#          Code = paste(Short, Region, Date, Sex, Metric, Measure, sep = "-"))
# 
# 
# 

# ------------------------------------------
#' Bulk checks on inputDB
#' 
#' @param data Dataset to be tested. This would corespond to 
#' 1 country-region-date-sex-Metric-Measure
bulk_checks <- function(data) {
  d = data
  age_range = 0:105

  with(d[1,],paste(Short, Region, Date, Sex, Metric, Measure, sep = "-")) %>% 
    message()
  
# 1. can't have NAs in Value column
expect_false(
  any(is.na(d$Value))
  )

# 2. All Country and entries in a subset must be identical and equal to 
# the Country entry in rubric
expect_true(
  all(as.character(d$Country) == d$Country[1])
  )

# 3. Age (chr) can only be coercible to integer or "UNK" or "TOT", no NAs
expect_true(
  all(d$Age %in% c(age_range, "TOT", "UNK"))
  )

# 4. AgeInt can only be coercible to integer or NA (maybe we should just read 
# it in as integer?)
expect_true(
  is.integer(d$AgeInt)
  )

# 5. AgeInt can only be NA for UNK or TOT
expect_true(
  all(is.na(d[d$Age %in% c("UNK", "TOT"), ]$AgeInt))
  )

# 6. AgeInt must sum to 105
if (nrow(d) == 1) {
  expect_true(is.na(d$AgeInt))

  } else {
    
  expect_equal(
    sum(d$AgeInt, na.rm = TRUE),
    105
  )
    # 7. Age(i) + AgeInt(i) must equal Age(i+1)
  x <- d$Age[d$Age %in% age_range] %>% 
  as.character() %>% 
  as.integer() %>% 
  diff()
  
  len_x <- length(x)

  expect_identical(
    d$AgeInt[1:len_x],
    x
  )
}



# 8. Sex can only be "f", "m", or "b"
expect_true(
  all(d$Sex %in% c("m", "f", "b", "UNK"))
)

# 9. Date must be "DD.MM.YYYY", which will work with lubridate::dmy().
# we already converted the Date to the %d.%m.%Y format. If the datat is 
# wrongly added an NA is returned
expect_false(
  any(is.na(d$Date))
)

# 10. Date can't be before 1/12/2019 and can't be later than today

# Build time range
dt <- seq(as.Date("2019-12-01"), 
    by = "day", 
    length.out = as.double(difftime(Sys.Date(), as.Date("2019-12-01")) + 1)
)

expect_true(
  all(d$Date %in% dt)
)

# 11. Metric can only be "Count", "Fraction", or "Ratio" (so far)
expect_true(
  all(d$Metric %in% c("Count", "Fraction", "Ratio"))
  )

# 12. Measure can only be "Cases", "Deaths", "Tests", or "ASCFR" (so far)
expect_true(
  all(d$Measure %in% c("Cases", "Deaths", "Tests", "ASCFR"))
  )

# 13. Code must be a concatenation of Short and Date
# I don't think a code is necessary in the colected data. This can be build 
# later on in the scripts. Moreover, we might decided to change the format.
# The less details are collected the less chances of typos.

# 14. No negatives in Value column
expect_true(
  all(d$Value >= 0)
  )

# 15. duplicated group-by variables (Each combo of Code, Sex, Age, 
# Measure can only be present once) - we've had instances of double-entry 
# already. See duplicated()
expect_false(
  any(duplicated(paste(d$Code, d$Age)))
  )

} # end bulk_checks()
# ------------------------------------------
# Log parser
parse_log <- function(file = "Data/log.txt"){
  Log         <- read_lines(file)
  Errors      <- grepl(Log, pattern = "Error : ") %>% which()
  if (length(Errors) == 0){
    Log <- c(Log[1:3], "No errors! Do a happy dance!\n")
    write_lines(Log, path = file)
  } else {
    Log[Errors] <- paste(Log[Errors], "\n")
    write_lines(Log[sort(c(1,2,3,Errors, Errors-1))], path = file)
  }
}


# ------------------------------------------
# RUN VALIDATION HERE

prep_data_check <- function(inputDB, ShortCodes){
  input_data %>% 
    filter(Short %in% ShortCodes) %>% 
    mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
           Code = paste(Short, Region, Date, Sex, Metric, Measure, sep = "-"))
}

run_checks <- function(inputDB, ShortCodes, logfile = "R_checks/log.txt"){
  test_data   <- prep_data_check(inputDB, ShortCodes)
  entry_codes <- as.character(unique(test_data$Code))
  if (file.exists(logfile)) file.remove(logfile)
  
  cat("Bulk checks performed on:",paste(ShortCodes, collapse = ", "),
      "\n",suppressMessages(timestamp()),"\n\n", file = logfile)
  
  for (k in entry_codes) {
    utils::capture.output(
      try(bulk_checks(
        data = test_data %>% 
          filter(Code == k))),
      file = logfile,
      type = "message",
      append = TRUE
    )
  }
  
  parse_log(logfile)
  
  cat("Done!, please check the file",logfile,"for any error messages")
}

# run_checks(inputDB, "CO")

# Dataset failing
# d <- test_data %>% 
#   filter(Code == "CA_BC-British Columbia-2020-04-15-b-Count-Deaths")
# d



  