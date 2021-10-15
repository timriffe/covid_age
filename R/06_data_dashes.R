setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()
library(here)
source(here::here("R","00_Functions.R"))

logfile <- here::here("buildlog.md")
# availability dash
log_section("Building dashboards", append = TRUE, logfile = logfile)

  rmarkdown::render(here::here("MarkdownPages","DataAvail.Rmd"), output_file = here::here("docs","DataAvail.html"))
  rmarkdown::render(here::here("MarkdownPages","Sources.Rmd"), output_file = here::here("docs","DataSources.html"))
  # rmarkdown::render(here::here("MarkdownPages","PreProcessing.Rmd"), output_file = here::here("docs","DataSteps.html"))
 try(rmarkdown::render(here::here("MarkdownPages","GettingStarted.Rmd"), output_file = here::here("docs","GettingStarted.html")))
  

