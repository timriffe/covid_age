
# 1) which files have metadata tab.
source("R/00_Functions.R")
library(googlesheets4)
rubric <- get_input_rubric("input")

sheet_tabs <- list()
for (i in 1:nrow(rubric)){
  ss <- rubric %>% pull(Sheet) %>% '['(i)
  sheet_tabs[[i]] <- gs4_get(ss)
}


has_source_metadata <- function(sheets_metadata){
  tabs<- sheets_metadata %>% '[['("sheets") %>% pull(name)
  "metadata" %in% tabs
}
names(sheet_tabs) <- rubric$Short
metadata_sheets <- lapply(sheet_tabs, has_source_metadata) %>% unlist()
metadata_sheets[metadata_sheets]
