#.rs.restartR()


change_here <- function(new_path){
  new_root <- here:::.root_env
  
  new_root$f <- function(...){file.path(new_path, ...)}
  
  assignInNamespace(".root_env", new_root, ns = "here")
}

change_here("C:/Users/riffe/Documents/covid_age")
startup::startup()
source(here("R","00_Functions.R"))
log_section("Commit dashboards and buildlog", append = TRUE, logfile = logfile)
library(usethis)
library(git2r)

repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = creds) # possibly creds not making it this far?

commit(repo, 
       message = "global commit", 
       all = TRUE)

git2r::push(repo,credentials = creds)


#rm(list=ls())
gc()

