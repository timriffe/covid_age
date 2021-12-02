library(here)
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

source(here::here("R","00_Functions.R"))


# TR: note, updating the inputDB is now on a separate 8-hour loop.
# This script assumes we have a nice stable inputDB to start with.
# all calculations happen on the FULL inputDB at this time. If this
# becomes inefficient we will move to only update pieces that were
# modified, which is not necessary at this time.

log_section("New build log", append = FALSE)

# ---------------------- #

# Resolve overlapping sources
source(here("R","01.5_resolve_sources.R"))

# ---------------------- #

# Harmonize Measure, Metric, and Scaling
source(here("R","02_harmonize_metrics.R"))

# ---------------------- #

# 03 Offset compilation is manual and separate for now.

# ---------------------- #

# Harmonize Age groups

source(here("R","04_harmonize_age_groups.R"))

# ---------------------- #


if(wday(today()) == 1){
  
  # um, let's just do this Wed and Sun?
  source(here("R","05_compile_metadata.R"))
  
  # ---------------------- #
  
  
  # Build dashboards
  # Temporarily disabled on hydra because default run
  # doesn't have pandoc?
  source(here("R","06_data_dashes.R"))
  
    
  # ---------------------- #
  
  # Quality metrics
  
  source(here("R","07_quality_metrics.R"))

}

# ---------------------- #

# Coverage Map

source(here("R","08_coverage_map.R"))

# ---------------------- #

# push to OSF

source(here("R","09_push_osf.R"))

# ---------------------- #

# git commit artifacts
source(here("R","10_commit_files.R"))

# ---------------------- #

# update build log / communications
source(here("R","11_email_and_tweet.R"))

