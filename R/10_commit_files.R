#.rs.restartR()


source("~/.Rprofile")
source(here("R","00_Functions.R"))
logfile <- here("buildlog.md")
log_section("Commit dashboards and buildlog", append = TRUE, logfile = logfile)
library(usethis)
library(git2r)

creds <- structure(list(username = Sys.getenv("GITHUB_USER"), 
                        password = Sys.getenv("GITHUB_PASS")), 
                   class = "cred_user_pass")

repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = creds) # possibly creds not making it this far?

commit(repo, 
       message = "global commit", 
       all = TRUE)

git2r::push(repo,credentials = creds)


#rm(list=ls())
gc()

