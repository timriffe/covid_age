source(here("R","00_Functions.R"))
# availability dash
log_section("Building dashboards", append = TRUE, logfile = logfile)

  rmarkdown::render(here::here("MarkdownPages","DataAvail.Rmd"), output_file = here::here("docs","DataAvail.html"))
  rmarkdown::render(here::here("MarkdownPages","PreProcessing.Rmd"), output_file = here::here("docs","DataSteps.html"))
 rmarkdown::render(here::here("MarkdownPages","GettingStarted.Rmd"), output_file = here::here("docs","GettingStarted.html"))
  

