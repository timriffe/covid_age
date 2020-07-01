#.rs.restartR()

log_section("Commit dashboards and buildlog", append = TRUE, logfile = logfile)
startup::startup()
library(usethis)
library(git2r)

repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = creds)

commit(repo, 
       message = "global commit", 
       all = TRUE)

git2r::push(repo,credentials = creds)


rm(list=ls())
gc()

