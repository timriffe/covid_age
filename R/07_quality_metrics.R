
# Script should calculate

# I How aggressive is scaling? (also UNK rescaling) - time varying

# strategy:

# 1) get inputDB

# 1.1) filter to only rows of stated age (no UNK, TOT)
# 1.2) summarize TOT by Country, Region, Code (?), Date, Sex, Measure

# 2) get Output_10

# 2.1) summarize TOT by Country, Region, Code (?), Date, Sex

# 3) merge Totals

# (2.1) has been rescaled, whereas (1.2) has not, so we can summarize as a fraction

# Worldometers fraction can also be reported? But we might just want to rescale
# non-refreshing series to Worldometers totals anyway...

# II Number of age categories (N)

# 1) get inputDB:
# 1.1) select rows of known age
# 1.2) summarize n() by Country, Region, Code, Date, Sex, Measure

# III Open age

# 1) get inputDB:
# 1.1) select rows of known age
# 1.2) coerge Age to integer
# 1.2) select max Age per Country, Region, Code, Date, Sex, Measure

# IV Offsets yes/no

# 1) Output_10, combinations of Country, Region
# 2) Offsets combinations of Country, Region
# 3) merge for binary indicator

# V Refreshing yes/no

# read metadata_basic.rds, this should be compiled daily with the build,
# it comes from the metadata tabs


# VI Positivity (OWD) *

# 1) read in OWD data,
# 1.1) do we capture any tests that they don't have? If so, send them an email.
# 2) summarize Output_10 to totals
# 3) merge, calculate metric Cases / Tests


#   Non-monotonicity
# VII Bohk-completeness metric - National only, can wait

# needs to wait because need to gather location-sex-specific lifetables. WPP can work for countries,
# but would need to gather subnational. Might also want to provide this extra metric as output.


