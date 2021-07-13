
# This file is an outline of a proposed estimation protocol for US cases by age, sex, state

# step 1 download case individual file.

# step 2 aggregate by state, age, sex, date (or month as it were).

# step 3 accumulate from the very beginning up to the most recent. Expecting monthly resolution

# step 4 declare a cutoff, potentially January 2021?? Namely, Jessica found oddities in this series in 2020, but maybe age pyramids will be stabilized by jan 2021? Do a check, and if necessary move to Feb or March 2021, depends what we see.

# step 5 we now have a cumulative series by age, sex, month, state. Convert each month-snapshot to an age-sex distribution summing to 1.

# step 6 interpolate these distributions to daily resolution. linear is fine. See approx()

# step 7 These can be formatted in the input format using Metric = "Fraction".

# step 8 download and append a dataset of cumulative case totals by state and date.

# fin. The default data processing pipeline will take care of the scaling.






















