library(here)
source(here("R","00_Functions.R"))

# Set the time lag for reading in modified templates. 
# For now leave as-is.
hours <- Inf
# 

# TR: note, updating the inputDB is now on a separate 8-hour loop.
# This script assumes we have a nice stable inputDB to start with.
# all calculations happen on the FULL inputDB at this time. If this
# becomes inefficient we will move to only update pieces that were
# modified, which is not necessary at this time.

log_section("New build log", append = FALSE)

# ---------------------- #

# Harmonize Measure, Metric, and Scaling
source(here("R","02_harmonize_metrics.R"))

# ---------------------- #

# Offset compilation is manual and separate for now.

# ---------------------- #

# Harmonize Age groups
source(here("R","04_harmonize_age_groups.R"))

# ---------------------- #

# um, let's just do this Wed and Sun?
source(here("R","05_compile_metadata.R"))

# ---------------------- #

# Build dashboards
# Temporarily disabled on hydra because default run
# doesn't have pandoc?
source(here("R","06_data_dashes.R"))

# ---------------------- #

# Coverage Map

source(here("R","08_coverage_map.R"))

# ---------------------- #

# push to OSF

# Coverage Map
# getting 401 errors
source(here("R","09_push_osf.R"))

# ---------------------- #

# git commit artifacts
source(here("R","10_commit_files.R"))

# ---------------------- #

# update build log / comminucations
source(here("R","11_email_and_tweet.R"))

