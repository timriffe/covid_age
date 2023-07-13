
##
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

# TR 13 July 2023, copied from 01_update_inputDB.R
Measures <- c("Cases","Deaths","Tests","ASCFR","Vaccinations",
              "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4", 
              "Vaccination5", "Vaccination6", "VaccinationBooster")

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
snapshot_dir <- "N://COVerAGE-DB/Data/inputCounts-SnapShots"
files_have <- dir(snapshot_dir)

# # test code, to be deleted
# files_have <- c("inputCounts_2021-01-05.csv","inputCounts_2021-02-05.csv",
#                "inputCounts_2021-02-15.csv","inputCounts_2021-03-05.csv",
#                "inputCounts_2021-04-05.csv")
# 
# # extract dates
dates_have <- gsub(files_have,pattern = "inputCounts_",replacement = "") |>
  gsub(pattern = ".csv", replacement = "") %>% 
  parse_date()

# get most recent one
todays_file <- files_have[which.max(dates_have)]

# get date of most recent output build, based on file
# modification rather than parsing the header...
o10path <- "N://COVerAGE-DB/Data/Output_10.csv"
last_date <-
  file.info(o10path)$mtime |> 
  as_date()

# when we have a longer time series we can change this to a strict < sign
old_file <- files_have[which.max(dates_have[dates_have <= last_date])]

# Of course comparison file should not be same as today's file!


# read in two files

tfile <- fread(file.path(snapshot_dir,todays_file))
ofile <- fread(file.path(snapshot_dir,old_file))
ooutput <- fread(o10path, skip = 3)

# first siphon off
# potentially add tidyfast and collapse to functions script!

# install.packages("tidyfast")
# install.package("collapse")

o_subsets <- 
  ooutput |>
  tidyfast::dt_pivot_longer(c(Cases,Deaths,Tests), 
                            names_to = "Measure", 
                            values_to = "Value", 
                            values_drop_na = TRUE) %>% 
  collapse::fselect(Code, Date, Sex, Measure) |>
  collapse::funique() |>
  collapse::fmutate(old = TRUE)
  
t_subsets <- 
  tfile |>
  collapse::fselect(Code, Date, Sex, Measure) |>
  collapse::funique() |>
  # only include those measures that we are currently age-harmonizing!
  # this should be modified when we include Vaccines
  collapse::fsubset(Measure %in% Measures)
  
new_to_harmonize <-
  # I know there's a data.table faster way to do this, but whatever
  left_join(t_subsets, o_subsets,  by = c("Code", "Date", "Sex", "Measure")) |>
  collapse::fmutate(old = data.table::fifelse(is.na(old),FALSE,old)) |>
  collapse::fsubset(!old)

# Note some of these will be previous harmonization failures, so this
# also serves as an indirect/inefficient catch on those


# Now round counts and select only subsets where at least one value changed.
# alternatively one could just compare daily sums...
o_subsets2 <-
  ofile %>% 
  collapse::fsubset(Measure %in% c("Cases","Deaths","Tests")) |>
  collapse::fmutate(value_old = round(Value)) |>
  collapse::fselect(Code, Date, Sex, Measure, Age, value_old)



t_subsets2 <-  
  tfile %>% 
  collapse::fsubset(Measure %in% Measures) |>
  collapse::fmutate(value_new = round(Value))  |>
  collapse::fselect(Code, Date, Sex, Measure, Age, value_new)

# Note we're comparing integers here
values_changes <-
  inner_join(o_subsets2, t_subsets2, by = c("Code", "Date", "Sex", "Measure", "Age")) |>
  collapse::fmutate(change = value_new - value_old) |>
  collapse::fsubset(change != 0)

# save these in case they are of diagnostic value
values_changes |>
  collapse::fmutate(old_date = last_date,
          new_date = max(dates_have)) |>
  write_csv(path = "N://COVerAGE-DB/Data/count_changes_forthcoming.csv")

  # we don't need to know which age it was, just that
  # there was a change in a subset...
reharmonize_subsets <- 
  values_changes |>
  collapse::fselect(Code, Date, Sex, Measure) |>
  collapse::funique()

subsets_to_harmonize <-
  bind_rows(reharmonize_subsets, new_to_harmonize) |>
  collapse::funique() |>
  collapse::fselect(-old)

# we only need to harmonize
100 * nrow(subsets_to_harmonize) / nrow(t_subsets)
# percent of subsets, much better!
write_csv(subsets_to_harmonize, file = "N://COVerAGE-DB/Data/subsets_to_harmonize.csv")

# save out the complement as well, for easier subsetting in step 4:
refresh_append <- 
  subsets_to_harmonize |>
  collapse::fmutate(refresh = TRUE)
subsets_keep_harmonizations <-
  o_subsets |>
  collapse::fselect(-old) |>
  left_join(refresh_append, by = c("Code","Date","Sex","Measure")) |>
  collapse::fmutate(refresh = !is.na(refresh),
                    keep = !refresh) |>
  collapse::fselect(-refresh)

write_csv(subsets_keep_harmonizations, file = "N://COVerAGE-DB/Data/subsets_keep_harmonizations.csv")



