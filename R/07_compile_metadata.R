
# 1) which files have metadata tab.
library(here)
source(here("R","00_Functions.R"))
library(googlesheets4)
library(tidyverse)
library(readr)
library(lubridate)
library(ggplot2)
library(osfr)

if (interactive()){
  osf_retrieve_file("8uk9n") %>%
    osf_download(path = "Data",
               conflicts = "overwrite") 
}
# This reads it in
inputDB <-  read_csv(here("Data","inputDB.csv"),
                     skip = 1,
                     col_types = "cccccciccdc")


# we get this to extract which Metrics are captured for each source.

gs4_auth(email = "tim.riffe@gmail.com")

ss_rubric <- "https://docs.google.com/spreadsheets/d/1IDQkit829LrUShH-NpeprDus20b6bso7FAOkpYvDHi4/edit#gid=0"
rubric <- read_sheet(ss_rubric, sheet = "input") %>% 
  filter(!is.na(Sheet),
         Rows > 0)

metadata_tabs <- list()
for (i in 1:nrow(rubric)){
   ss <- rubric %>% pull(Sheet) %>% '['(i)
   metadata_tabs[[i]] <- try(read_sheet(ss, sheet = "metadata", col_types = "ccc"))
   Sys.sleep(1)
}

errors <- lapply(metadata_tabs, function(x){
  class(x)[1] == "try-error"
}) %>% unlist()

rubric$Short[errors]
metadata_tabs <- metadata_tabs[!errors]

saveRDS(metadata_tabs,here("Data","metadata_tabs.rds"))


# TODO: make sure that the Short Codes collected in the metadata tabs match the Short
# codes used in the database.

vars.dash <- c( "Country", 
               "Region(s)",
               "Author",
               "Main website",
               "Retrospective corrections",
               "Date of start of data series (data captured for this project)",
               "Date of end of data series",
               "CASES - Definition",
               "CASES - Coverage",
               "CASES - Date of events",
               "DEATHS - Definition",
               "DEATHS - Coverage",
               "DEATHS - Date of events"
               )
metadata_tabs <- readRDS(here("Data","metadata_tabs.rds"))
X <- metadata_tabs[[1]]

metadata_basic <- 
  metadata_tabs %>% 
  lapply(function(X){
    cnames <- c("Country","Region(s)","Author","Main website")
    X <- X %>% 
      filter(Field %in%cnames) 
    out <- data.frame(t(X[, 2]))
    colnames(out) <- cnames
    out
  }) %>% bind_rows()


library(googlesheets4)
write_sheet(metadata_basic, ss = "https://docs.google.com/spreadsheets/d/1ik5RNGYP0uB9TIrV5vVF7ixYJ9y9P4N7oW9a-9Cqw6M/edit#gid=0", sheet = "metadata_basic")


saveRDS(metadata_basic, file = here("Data","metadata_basic.rds"))
# ----------------
do_this <- FALSE
if (do_this){
metadata_table <- lapply(metadata_tabs, function(X, vars.dash){
  dash.vars <-
    X %>% 
    filter(Field %in% vars.dash) %>% 
    select(Answer)
  
  this.row <- as.matrix(dash.vars) %>% 
    t() %>% 
    as.data.frame(stringsAsFactors = FALSE)
  colnames(this.row) <- vars.dash
  this.row
},vars.dash=vars.dash) %>% 
  bind_rows() %>% 
  arrange(Country, `Region(s)`)

tab1 <- metadata_table %>% 
  select(Country, 
         `Region(s)`,
         Author, 
         `Main website`,
         Corrected = `Retrospective corrections`,
         `Series start` = `Date of start of data series (data captured for this project)`,
         `Series end` = `Date of end of data series`)


# TODO:
# add new field, Metrics that contains the unique metrics captured for cases and for deaths.
# for CA_BC ASCFR go to DEATHS, but for ITinfo ASCFR (Ratios) go to Cases.

# TODO:
# for Fraction and Ratio metrics, is the collected data rounded or not?

tab2 <- metadata_table %>% 
  select(Country, 
         `Region(s)`,
         Definition = `CASES - Definition`,
         Coverage = `CASES - Coverage`,
         `Date of events` = `CASES - Date of events`)

tab3 <- metadata_table %>% 
  select(Country, 
         `Region(s)`,
         Definition = `DEATHS - Definition`,
         Coverage = `DEATHS - Coverage`,
         `Date of events` = `DEATHS - Date of events`)


saveRDS(metadata_tabs,file = here("Data","metadata_tabs.rds"))
saveRDS(metadata_table,file = here("Data","metadata_table.rds"))
saveRDS(tab1,file = here("Data","tab1.rds"))
saveRDS(tab2,file = here("Data","tab2.rds"))
saveRDS(tab3,file = here("Data","tab3.rds"))


}






# Note:

# Shiny App:

# select countries and metadata variables.





# sheet_tabs <- list()
# for (i in 1:nrow(rubric)){
#   ss <- rubric %>% pull(Sheet) %>% '['(i)
#   sheet_tabs[[i]] <- gs4_get(ss)
# }
# 
# get_sheet_names <- function(sheets_metadata){
#   sheets_metadata %>% '[['("sheets") %>% pull(name)
# }
# 
# 
# has_source_metadata <- function(sheets_metadata){
#   tabs<- sheets_metadata %>% '[['("sheets") %>% pull(name)
#   "metadata" %in% tabs
# }
# 
# names(sheet_tabs) <- rubric$Short
# metas <- lapply(sheet_tabs, get_sheet_names) %>% 
#   lapply(grepl,pattern="meta") %>% 
#   lapply(any) %>% unlist()
# metas[!metas]
# 
# 
# metadata_sheets <- lapply(sheet_tabs, has_source_metadata) %>% unlist()
# metadata_sheets[metadata_sheets]


# template_ss <- "https://docs.google.com/spreadsheets/d/15HktFkvdmxZ36nHzAfFqAa63rPWnbyP2BFjVsMNBVZs/edit#gid=889172199"

# create_meta <- metas[!metas]
# for (i in 1:length(create_meta)){
#   # get destination ss
#   ss <- rubric %>% 
#     filter(Short == names(create_meta)[i]) %>%  
#     pull(Sheet) 
#   
#   # any sheet named metadata?
#   has_meta <- 
#     gs4_get(ss) %>% 
#     '[['("sheets") %>% 
#     pull(name) %>% 
#     '=='("metadata") %>% 
#     any()
#   
#   if (!has_meta){
#     sheet_copy(from_ss = template_ss,
#                from_sheet = "metadata",
#                to_ss = ss,
#                to_sheet = "metadata")
#   }
# }
# 
# 
# for (i in 1:nrow(rubric)){
#   ss <- rubric %>% pull(Sheet) %>% '['(i)
#   
#   sheet_copy(from_ss = ss,
#              from_sheet = "metadata",
#              to_ss = ss,
#              to_sheet = "metadata_old")
# }
# 


# ss_v2 <- "https://docs.google.com/spreadsheets/d/15HktFkvdmxZ36nHzAfFqAa63rPWnbyP2BFjVsMNBVZs/edit#gid=575566620"
# 
# for (i in 1:nrow(rubric)){
#   ss <- rubric %>% pull(Sheet) %>% '['(i)
#   sheet_delete(ss, sheet = "metadata")
#   sheet_copy(from_ss = ss_v2,
#              from_sheet = "metadata",
#              to_ss = ss,
#              to_sheet = "metadata")
# }






# new_template_ss <- "https://docs.google.com/spreadsheets/d/1G9Fo2by_r7jLWfpge7XEAxKN7v9ckexZZOHLl52hbVQ/edit#gid=1301732609"
# 
# template <- read_sheet(new_template_ss, sheet = "metadata")
# write_sheet(template, new_template_ss, sheet = "attempt2")
# 
# metadata_tabs <- list()
# for (i in 1:nrow(rubric)){
#   ss <- rubric %>% pull(Sheet) %>% '['(i)
#   metadata_tabs[[i]] <- read_sheet(ss, sheet = "metadata_old")
#   metadata_tabs[[i]]$Answer <- lapply(metadata_tabs[[i]]$Answer,
#                                       function(x){
#                                         if(is.null(x)){return(NA)} else {return(x)}
#                                       })
#   metadata_tabs[[i]]$Answer <- unlist( metadata_tabs[[i]]$Answer)
#   basic   <- metadata_tabs[[i]]$Answer[1:3] 
#   default <- unlist(rubric[i,c("Short","Country","Region")])
#   impute  <- ifelse(is.na(basic),default,basic)
#   metadata_tabs[[i]]$Answer[1:3] <- impute
#   r16     <- data.frame(Answer=metadata_tabs[[i]]$Answer[1:15])
#   range_write(ss,
#               data = r16,
#               sheet = "metadata",
#               range = "B1:B16",
#               reformat = FALSE)
#   Sys.sleep(10)
#   
# }
# names(metadata_tabs) <- rubric$Short
# lapply(metadata_tabs,colnames)

############################
# Write loop that copies the first 16 Answer values from 
# metadata_old to metadata.
# also the last two values.






