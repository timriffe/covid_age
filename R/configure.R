# first install most of the requisites
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()
# R session might need a restart at more than one point in this sequence

usethis::create_github_token()
gitcreds::gitcreds_set()
# credentials::set_github_pat(force_new=TRUE)
# ENVIRON needs variables set for
# GITHUB_PAT
# OSF_PAT
# R_REMOTES_NO_ERRORS_FROM_WARNINGS="true"
# email = "your.accounte@gmail.com"
# path_repo = "Your/MPIDR/Location/covid_age"
# usethis::edit_r_environ(scope = "user")
# usethis::edit_r_environ(scope = "project")

# What else is there to do?

# In terminal, type:
# git remote set-url origin https://github.com/YourAcct/covid_age.git



