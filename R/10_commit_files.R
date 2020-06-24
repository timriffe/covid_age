

log_section("Commit dashboards and buildlog", append = TRUE)
library(usethis)
library(git2r)
repo <- init()
commit(repo, message = "global commit", all = TRUE)

push()


git_credentials(auth_token = github_token())
