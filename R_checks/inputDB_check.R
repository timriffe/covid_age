library(tidyverse)
library(testthat)
source(here::here("R_checks/check_consistency.R"))
# ------------------------------------------
#' Bulk checks on inputDB
#' 
#' @param data Dataset to be tested. This would correspond to 
#' 1 country-region-date-sex-Metric-Measure
bulk_checks <- function(data) {
  d = data
  age_range = 0:105
  
  with(d[1,],paste(Short, Region, Date, Sex, Metric, Measure, sep = "-")) %>% 
    message()
  
  # 1. can't have NAs in Value column
  test_that("Can't have NAs in Value column", {
    expect_false(
      any(is.na(d$Value))
    )
  })
  
  # 2. All Country and entries in a subset must be identical and equal to 
  # the Country entry in rubric
  test_that("All Country and entries in a subset must be identical and equal to the Country entry in rubric", {
    expect_true(
      all(as.character(d$Country) == d$Country[1])
    )
  })
  
  # 3. Age (chr) can only be coercible to integer or "UNK" or "TOT", no NAs
  # TR: chokes on leading 0s.
  test_that("Age (chr) can only be coercible to integer or 'UNK' or 'TOT', no NAs", {
    expect_true(
      all(d$Age %in% c(age_range, "TOT", "UNK"))
    )
  })
  
  # 4. AgeInt can only be coercible to integer or NA (maybe we should just read 
  # it in as integer?)
  
  # TR: this chokes if there are leading 0s for age (weird I know)
  # Maybe the better check is that for each Age that is not UNK or TOT
  # AgeInt coerces to integer without NAs. Note, for this group_by()
  # level, it's possible to have TOT and only TOT in a 1-row subset.
  # so this needs to be qualified some. My try:
  
  test_that("AgeInt can only be coercible to integer or NA", {
    expect_true(
      is.integer(d$AgeInt)
    )
  })
  
  # 5. AgeInt can only be NA for UNK or TOT

  if (any(d$Age %in% c("UNK", "TOT"))){
    test_that("AgeInt can only be NA for UNK or TOT", {
      expect_true(
        all(is.na(d[d$Age %in% c("UNK", "TOT"), ]$AgeInt))
      )
    })
  }

  # 6. AgeInt must sum to 105
  if (nrow(d) == 1) {
    test_that("AgeInt must sum to 105", {
      expect_true(is.na(d$AgeInt))
    })
  } else {
    
    test_that("AgeInt must sum to 105", {
      expect_equal(
        sum(d$AgeInt, na.rm = TRUE),
        105
      )
    })
    
    # 7. Age(i) + AgeInt(i) must equal Age(i+1)
    x <- d$Age[d$Age %in% age_range] %>% 
      as.character() %>% 
      as.integer() %>% 
      diff()
    
    len_x <- length(x)
    #
    test_that("Age range must be continuosly covered with neither gaps nor overlap", {
      expect_identical(
        d$AgeInt[1:len_x],
        x
      )
    })

  }
  
  
  
  # 8. Sex can only be "f", "m", or "b"
  test_that("Sex can only be 'f', 'm', 'b', or 'UNK'", {
    expect_true(
      all(d$Sex %in% c("m", "f", "b", "UNK"))
    )
  })
  
  # 9. Date must be "DD.MM.YYYY", which will work with lubridate::dmy().
  # we already converted the Date to the %d.%m.%Y format. If the data is 
  # wrongly added an NA is returned
  test_that("Date must be 'DD.MM.YYYY'", {
    expect_false(
      any(is.na(d$Date))
    )
  })
  
  # 10. Date cannot be before 1/12/2019 and can't be later than today
  # Build time range
  dt <- seq(as.Date("2019-12-01"), 
            by = "day", 
            length.out = as.double(difftime(Sys.Date(), as.Date("2019-12-01")) + 1)
  )
  
  test_that("Date can't be before 1/12/2019 and can't be later than today", {
    expect_true(
      all(d$Date %in% dt)
    )
  })
  
  # 11. Metric can only be "Count", "Fraction", or "Ratio" (so far)
  test_that('Metric can only be "Count", "Fraction", or "Ratio" (so far)', {
    expect_true(
      all(d$Metric %in% c("Count", "Fraction", "Ratio"))
    )
  })
  
  # 12. Measure can only be "Cases", "Deaths", "Tests", or "ASCFR" (so far)
  test_that('Measure can only be "Cases", "Deaths", "Tests", or "ASCFR" (so far)', {
    expect_true(
      all(d$Measure %in% c("Cases", "Deaths", "Tests", "ASCFR"))
    )
  })
  
  # 13. Code must be a concatenation of Short and Date
  # I do not think a code is necessary in the collected data. This can be built 
  # later in the scripts. Moreover, we might decide to change the format.
  # The less details are collected the less chances of typos.
  
  # 14. No negatives in Value column
  test_that('No negatives in Value column', {
    expect_true(
      all(d$Value >= 0)
    )
  })
  
  # 15. duplicated group-by variables (Each combo of Code, Sex, Age, 
  # Measure can only be present once) - we have had instances of double-entry 
  # already. See duplicated()
  test_that('Duplicated group-by variables (Each combo of Code, Sex, Age, Measure can only be present once)', {
    expect_false(
      any(duplicated(paste(d$Code, d$Age)))
    )
  })
  
} # end bulk_checks()
# ------------------------------------------
# Log parser
parse_log <- function(file = "Data/log.txt"){
  Log         <- read_lines(file)
  Errors      <- grepl(Log, pattern = "Error : ") %>% which()
  if (length(Errors) == 0){
    Log <- c(Log[1:3], 
             praise::praise(), 
             "No errors! Do a happy dance!\n")
    write_lines(Log, path = file)
  } else {
    Log[Errors] <- paste(Log[Errors], "\n")
    write_lines(Log[sort(c(1,2,3,Errors, Errors-1))], path = file)
  }
}


# ------------------------------------------
# RUN VALIDATION HERE

prep_data_check <- function(input_data, ShortCodes){
  input_data %>% 
    filter(Short %in% ShortCodes) %>% 
    mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
           Code = paste(Short, Region, Date, Sex, Metric, Measure, sep = "-"))
}

run_checks <- function(inputDB, ShortCodes, logfile = "R_checks/log.txt"){
  test_data   <- prep_data_check(inputDB, ShortCodes)
  entry_codes <- as.character(unique(test_data$Code))
  if (file.exists(logfile)) file.remove(logfile)
  
  cat("Bulk checks performed on:", paste(ShortCodes, collapse = ", "),
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
  
  utils::capture.output(
    message("\n\nConsistency checks performed on count data\n\n"),
    file = logfile,
    type = "message",
    append = TRUE
  )
  
  utils::capture.output(
    check_consistency(inputDB),
    file = logfile,
    type = "message",
    append = TRUE
  )
  
  parse_log(logfile)
  
  cat("Done!, please check the file",logfile,"for any error messages")
}




