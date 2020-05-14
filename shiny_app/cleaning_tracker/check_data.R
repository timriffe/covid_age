# --------------------------------------------------- #
# Author: Marius D. Pascariu
# Edited Tim Riffe, Jorge Cimentada
# Last update: Tue May  5 22:17:06 2020
# --------------------------------------------------- #
# remove(list = ls())
library(tidyverse)
library(testthat)


## input_data <-
##   read.csv("~/repositories/covid_age/data/inputdb.csv")

# 
# test_data <- input_data %>% 
#   mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
#          Code = paste(Short, Region, Date, Sex, Metric, Measure, sep = "-"))
# 
# 
# 

# value is just a signal for whether to return the rows
# where we find anomalous values or the actual anomalous value
# this is used across the tests often.
##' @title Test arbitrary expressions and return a custom error message
##' with the anomalies
##' @param error_message The standard error message. This message should
##' indicate precisely what is being tested.
##' @param test_expression This is the expressions that tests the specific
##' error. Should always return either TRUE or FALSE
##' @param anomaly_vals The values to return when the test fails.
##' For example, when testing whethere there is one unique country,
##' this parameter should contain the countries which
##' are not supposed to be there. This is then attached in \code{test_true}
##' to the error message such that the user doesn't have look anything
##' else other than the anomaly values.
##'
##' In some cases, it makes sense not to return the specific anomaly
##' values but the rows where the anomaly is found. For example,
##' when checking whether there are any duplicated values in
##' Code-Age, we return the rows where there are duplicates. For
##' that case, anomaly vals should always return either the anomaly
##' values or the rows where the anomaly is found.
##' @param value When returning rows specify FALSE, other TRUE. This
##' is just to include the word rows in the error message or not.
##' @return 
test_true <- function(error_message,
                      test_expression,
                      anomaly_vals,
                      value = TRUE) {

  val <- if (value) "values" else "rows"

  true <- test_expression
  if (!true) {
    err_msg <- paste0("Error: ",
                      error_message,
                      ". Found these anomalous ", val, ": ",
                      paste0(anomaly_vals, collapse = ", "))
    message(err_msg)
  } else {
    TRUE
  }
}

# ------------------------------------------
#' Bulk checks on inputDB
#' 
#' @param data Dataset to be tested. This would corespond to 
#' 1 country-region-date-sex-Metric-Measure
bulk_checks <- function(data) {
  d = data
  age_range = 0:105
  
  # 1. can't have NAs in Value column
  test_true(
    error_message = "Shouldn't have NAs in Value column. Should these be 0s?",
    test_expression = !any(is.na(d$Value)),
    anomaly_vals = which(is.na(d$Value)),
    value = FALSE
  )

  # 2. Countries must be unique values
  test_true(
    error_message = "There can't be any row in 'Country' with missing values",
    test_expression = !any(is.na(d$Country)),
    anomaly_vals = which(is.na(d$Country)),
    value = FALSE
  )

  test_true(
    error_message = "The country column must only contain the unique value of the current country",
    test_expression = all(as.character(d$Country) == d$Country[1], na.rm = TRUE),
    anomaly_vals = unique(d$Country)
  )

  # 3. Age variable must only have integer values between 0:105 and UNK or TOT
  test_true(
    error_message = "Age (chr) can only have integers 0:105 or 'UNK' or 'TOT'. No NAs permitted",
    test_expression = all(d$Age %in% c(as.character(age_range), "TOT", "UNK")),
    anomaly_vals = unique(setdiff(d$Age, c(as.character(age_range), "TOT", "UNK")))
  )

  # 4. AgeInt can only be coercible to integer or NA (maybe we should just read 
  # it in as integer?)
  test_that("AgeInt can only be integer or NA", {
    expect_true(
      is.integer(d$AgeInt)
    )
  })

  # 5. Age can only be NA for when AgeInt is UNK or TOT
  test_true(
    error_message = "AgeInt can only be NA when Age is UNK or TOT",
    test_expression = all(is.na(d[d$Age %in% c("UNK", "TOT"), ]$AgeInt)),
    anomaly_vals = which(!is.na(d[d$Age %in% c("UNK", "TOT"), ]$AgeInt)),
    value = FALSE
  )

  # 6. AgeInt must sum to 105
  res <-
    d %>%
    # Only when Age is not the total, for which AgeInt is empty and usualy
    # is just a row for male/female
    filter(!is.na(AgeInt),
           Sex != "UNK") %>% 
    group_by(Code) %>%
    summarize(res = sum(AgeInt, na.rm = TRUE) == 105)

  values_failed <-
    res %>%
    filter(!res) %>%
    mutate(id = paste0("\n  * ", Code)) %>%
    pull(id)

  test_true(
    error_message = "AgeInt must sum up to 105 for every Region-Date-Sex-Metric-Measure combination",
    test_expression = all(res$res),
    anomaly_vals = values_failed
  )

  # 7. `Age` column must only have 10 year gaps for every Region-Date-Sex-Metric-Measure combination
  res <-
    d %>% 
    filter(Age %in% 0:105,
           Sex != "UNK") %>% # TR: UNK Sex doesn't need to pad 0s
    mutate(
      Age = as.integer(Age),
      AgeInt = as.integer(AgeInt),
      Age1 = Age + AgeInt
    )

  # TR: Metric listed in message, not grouped on Metric however
  all_res <-
    res %>%
    group_by(Code, Sex, Measure) %>%
    summarize(res = all(Age[-1] == Age1[-length(Age1)]))

  values_failed <-
    all_res %>%
    filter(!res) %>%
    mutate(id = paste0("\n  * ", Code)) %>%
    pull(id)

  test_true(
    error_message = "`Age` + `AgeInt` must equal the next `Age`, no gaps or overlapping allowed (for each Region-Date-Sex-Metric-Measure combination)",
    test_expression = all(all_res$res),
    anomaly_vals = values_failed
  )

  # 8. Sex can only be "f", "m", or "b"
  test_true(
    error_message = "Sex can only be f, m, b or UNK",
    test_expression = all(d$Sex %in% c("m", "f", "b", "UNK")),
    anomaly_vals = unique(setdiff(d$Sex, c("m", "f", "b", "UNK")))
  )

  # 9. Date must be "DD.MM.YYYY", which will work with lubridate::dmy().
  # we already converted the Date to the %d.%m.%Y format. If the datat is 
  # wrongly added an NA is returned
  test_true(
    error_message = "Date must be in 'DD.MM.YYYY' format.",
    test_expression = !any(is.na(d$Date)),
    anomaly_vals = which(is.na(d$Date)),
    value = FALSE
  )

  # 10. Date can't be before 1/12/2019 and can't be later than today
  # Build time range
  dt <- seq(as.Date("2019-12-01"), 
            by = "day", 
            length.out = as.double(difftime(Sys.Date(), as.Date("2019-12-01")) + 1)
            )

  # Here I return the rows rather than the dates because setdiff would convert
  # dates to numbers and I don't want to make things more verbose.
  test_true(
    error_message = "Date can't be before 1/12/2019 and can't be later than today",
    test_expression = all(d$Date %in% dt),
    anomaly_vals = which(!d$Date %in% dt),
    value = FALSE
  )

  # 11. Metric can only be "Count", "Fraction", or "Ratio" (so far)
  test_true(
    error_message = 'Metric can only be "Count", "Fraction", or "Ratio" (so far)',
    test_expression = all(d$Metric %in% c("Count", "Fraction", "Ratio")),
    anomaly_vals = setdiff(d$Metric, c("Count", "Fraction", "Ratio"))
  )

  # 12. Measure can only be "Cases", "Deaths", "Tests", or "ASCFR" (so far)
  test_true(
    error_message = 'Measure can only be "Cases", "Deaths", "Tests", or "ASCFR" (so far)',
    test_expression = all(d$Measure %in% c("Cases", "Deaths", "Tests", "ASCFR")),
    anomaly_vals = setdiff(d$Measure, c("Cases", "Deaths", "Tests", "ASCFR"))
  )

  # 13. Code must be a concatenation of Short and Date
  # I don't think a code is necessary in the colected data. This can be build 
  # later on in the scripts. Moreover, we might decided to change the format.
  # The less details are collected the less chances of typos.
  test_true(
    error_message = "No NAs in Value column allowed",
    test_expression = all(!is.na(d$Value)),
    anomaly_vals = which(is.na(d$Value)),
    value = FALSE
  )

  # 14. No negatives in Value column
  value_col <- d$Value[!is.na(d$Value)]
  test_true(
    error_message = "No negatives in Value column allowed",
    test_expression = all(value_col >= 0),
    anomaly_vals = value_col[!value_col >= 0]
  )

  # 15. duplicated group-by variables (Each combo of Code, Sex, Age, 
  # Measure can only be present once) - we've had instances of double-entry 
  # already. See duplicated()
  test_true(
    error_message = 'Duplicated group-by variables (Each combo of Code, Sex, Age, Measure can only be present once) ',
    test_expression = !any(duplicated(paste(d$Code, d$Age))),
    anomaly_vals = which(duplicated(paste(d$Code, d$Age))),
    value = FALSE
  )

}

# ------------------------------------------
# Log parser
parse_log <- function(file = "Data/log.txt") {
  Log         <- read_lines(file)
  Errors      <- grepl(Log, pattern = "Error: | \\*") %>% which()

  if (length(Errors) == 0) {
    Log <- c(Log[1:3], "No errors! Do a happy dance!\n")
    write_lines(Log, path = file)
  }
  ## } else {
  ##   Log[Errors] <- paste(Log[Errors], "\n")
  ##   final_error <- Log[sort(c(1,2,3,Errors))]
  ##   write_lines(final_error, path = file)
  ## }
  Log
}


# ------------------------------------------
# RUN VALIDATION HERE

prep_data_check <- function(input_data) {
  input_data %>% 
    ## filter(Short %in% ShortCodes) %>% 
    mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
           Code = paste(Region, Date, Sex, Metric, Measure, sep = "-"))
}

run_checks <- function(inputDB, logfile = "R_checks/log.txt") {
  test_data   <- prep_data_check(inputDB)
  entry_codes <- as.character(unique(test_data$Code))
  if (file.exists(logfile)) file.remove(logfile)
  
  cat("Bulk checks performed on:",
      "\n",
      suppressMessages(timestamp()),
      "\n\n",
      file = logfile)
  
  utils::capture.output(
    bulk_checks(data = test_data),
    file = logfile,
    type = "message",
    append = TRUE
  )
  
  final_error <- parse_log(logfile)
  
  cat("Done!, please check the file",logfile,"for any error messages")

  final_error
}

# run_checks(inputDB, "CO")

# Dataset failing
# d <- test_data %>% 
#   filter(Code == "CA_BC-British Columbia-2020-04-15-b-Count-Deaths")
# d
