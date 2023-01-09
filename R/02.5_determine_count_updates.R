
##

# TODO
# This script will look on N for the most recent inputCounts.csv (or similar) file, 
# which will soon be built simultaneously with the inputDB.
# We then detect the date of the last output build and also pull the inputDB counts
# preceding it (or from a couple weeks prior).

# Country by country, we determine which subsets (unique combinations of location, date, sex, measure) have been 
# 1) newly created (easy) (compare with long output ids)
# 2) modified (compare with pre-age-harmonized counts)
# Probably (2) should be done to some arbitrary degree of precision, such as .5. This one could be computationally heavy, 
# but not necessarily if we round(Value) for the earlier and later files, and place side-by-side, we can check for equality,
# then determine update status in summarize(). This accounts for

# When then create an indicator file like so:

# Code | Sex | Date | Measure | update

# Update is logical, TRUE meaning that it was flagged as (1) or (2) and we should therefore age-harmonize it, 
# FALSE meaning we already have age-harmonized results for it, and should therefore use those instead.

# This is where we'll look for inputCounts.csv, which should have YYYY-MM-DD appended to file names.
dir.exists("N://COVerAGE-DB/Data/inputCounts-SnapShots")
# these can be compressed, but we will manually eliminate older unused ones. 

# --------------------------- #
# insert script prelims here  #
# --------------------------- #


# 1) get files

files_have <- dir("N://COVerAGE-DB/Data/inputCounts-SnapShots")

# test code, to be deleted
files_have <- c("inputCounts_2021-01-05.csv","inputCounts_2021-02-05.csv",
               "inputCounts_2021-02-15.csv","inputCounts_2021-03-05.csv",
               "inputCounts_2021-04-05.csv")

# extract dates
dates_have <- gsub(files_have,pattern = "inputCounts_",replacement = "") |>
  gsub(pattern = ".csv", replacement = "") %>% 
  parse_date()

# get most recent one
todays_file <- files_have[which.max(dates_have)]

# get date of most recent output build

date_pieces <-readLines("N://COVerAGE-DB/Data/Output_10.csv",n=2)[2] |>
  gsub(pattern = "Built: ", replace = "") |> 
  str_split(pattern = " ")

last_date <-
date_pieces[[1]][c(5,2,3)] |>
  paste(collapse = "-") |>
  as_date()


comparison_file <- files_have[which.max(dates_have[dates_have < last_date])]

# Of course comparison file should not be same as today's file!


# To be continued





