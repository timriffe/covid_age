# dependency preamble
# ----------------------------------------------
# install pacman to streamline further package installation
if (!require("pacman", character.only = TRUE)){
  install.packages("pacman", dep = TRUE)
  if (!require("pacman", character.only = TRUE))
    stop("Package not found")
}

packages_CRAN <- c("tidyverse","lubridate","here","gargle","ungroup")

if(!sum(!p_isinstalled(packages_CRAN))==0){
  p_install(
    package = packages_CRAN[!p_isinstalled(packages_CRAN)], 
    character.only = TRUE
  )
}

gphgs <-c("googlesheets4")

# install from github if necessary
if (!p_isinstalled(gphgs)){
  library(remotes)
  install_github("tidyverse/googlesheets4")
}
# load the packages
p_load(packages_CRAN, character.only = TRUE)
p_load(gphgs, character.only = TRUE)

#--------------------------------------------------
sort_input_data <- function(X){
  X %>% 
  mutate(Date2 = dmy(Date)) %>% 
    arrange(Country,
            Date2,
            Sex, 
            Measure,
            Metric,
            Age) %>% 
    select(-Date2)
}

# -------------------------------------------------

get_input_rubric <- function(sheet = "input"){
  ss_rubric <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0"
  input_rubric <- sheets_read(ss_rubric, sheet = sheet) %>% 
    filter(!is.na(Sheet))
  input_rubric
}

compile_inputDB <- function(){

  rubric <- get_input_rubric(sheet = "input")

  input_list <- list()
  for (i in rubric$Short){
    (ss_i           <- rubric %>% filter(Short == i) %>% pull(Sheet))
    input_list[[i]] <- sheets_read(ss_i, sheet = "database", na = "NA", col_types= "ccccccccd")
  }
  # bind and sort:
  inputDB <- 
    input_list %>% 
    bind_rows() %>% 
    sort_input_data()
  
  inputDB
}

get_standby_inputDB <- function(){
  rubric <- get_input_rubric(sheet = "output")
  inputDB_ss <- 
    rubric %>% 
    filter(tab == "inputDB") %>% 
    pull(Sheet)
  standbyDB <- sheets_read(inputDB_ss, sheet = "inputDB", na = "NA", col_types= "ccccccccd")
  standbyDB
}

check_input_updates <- function(inputDB  = NULL, standbyDB = NULL){

  if (is.null(standbyDB)){
    standbyDB <- get_standby_inputDB()
  }
  if (is.null(inputDB)){
    inputDB <- compile_inputDB()
  }
  codes_have      <- standbyDB %>% pull(Code) %>% unique()
  codes_collected <- inputDB %>% pull(Code) %>% unique()
  
  new_codes <- setdiff(codes_have, codes_collected)
  if (length(new_codes)  > 0){
    cat(new_codes)
    nr <- nrow(standbyDB) - nrow(inputDB)
    cat(nr, "total new values collected")
  } else {
    cat("no new updates to add")
  }
}


# inspect_code(inputDB,"ES31.03.2020)
inspect_code <- function(DB, .Code){
  DB %>% 
    filter(Code == .Code) %>% 
    View()
}

