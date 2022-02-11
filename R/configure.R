# first install most of the requisites
source("R/00_Functions.R")

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
# git remote set-url origin https://big_huge_github_path_you_just_made@github.com/YourAcct/covid_age.git
