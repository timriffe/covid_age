#.rs.restartR()

log_section("Commit dashboards and buildlog", append = TRUE)
startup::startup()
library(usethis)
library(git2r)

repo <- init()

git2r::pull(credentials = creds)

commit(repo, 
       message = "global commit", 
       all = TRUE)

push(credentials = creds)


rm(list=ls())
gc()

