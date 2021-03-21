#.rs.restartR()


source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

change_here(wd_sched_detect())
logfile <- here::here("buildlog.md")
log_section("Commit dashboards and buildlog", append = TRUE, logfile = logfile)
library(usethis)
library(git2r)

# creds <- structure(list(username = Sys.getenv("GITHUB_USER"), 
#                         password = Sys.getenv("GITHUB_PASS")), 
#                    class = "cred_user_pass")

repo <- git2r::repository(here())
#init()
git2r::pull(repo,credentials = cred_token()) # possibly creds not making it this far?

a <- git2r::status()
if (length(a$unstaged) > 0){
  commit(repo, 
         message = "global commit", 
         all = TRUE)
}
git2r::push(repo,credentials = cred_token())


#rm(list=ls())
gc()

