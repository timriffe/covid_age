

log_section("Commit dashboards and buildlog", append = TRUE)

library(usethis)
library(git2r)

repo <- init()

git2r::pull(credentials = creds)

commit(repo, 
       message = "global commit", 
       all = TRUE,
       committer = paste("COVerAGE-DB auto builder",timestamp()))

push(credentials = creds)


