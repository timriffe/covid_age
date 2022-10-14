## AUSTRALIA EPI-DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Australia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_python <- "N:/COVerAGE-DB/Automation/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## Description: 

## Australia cases & deaths data were collected manually until 12.04.2022 (inclusive) in the input template. 
## In April 2022, a python script is written to automate downloading these data in Australia folder as .xlsx
## So, the purpose of this script is to read the data from Input template on the GD and read the .csv files that 
## have been downloaded since 14.04.2022 and merge both in one output as .rds file on N. 

## Data until 12.04.2022 from Google Drive:
# 

at_rubric <- get_input_rubric() %>%
  dplyr::filter(Short == "AU")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)


db_drive <- read_sheet(ss = ss_i, sheet = "database")


## Since I don't want to repeat this whole process, we will append the data on daily basis,
## Also, to make sure that the python automated script is working ##
## Though I keep the code above for reference if any issues! 


# reading data from Australia stored in N drive
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#db_n <- read_rds(paste0(dir_n, ctr, ".rds")) 


## Data from 14.04.2022 from Python automated .xlsx files 

## load the xlsx files... 

epi.list <-list.files(
  path= paste0(dir_n_python, ctr),
  pattern = ".xlsx",
  full.names = TRUE)

## CASES ## 

cases_files <- data.frame(cases_paths = epi.list) %>% 
  filter(str_detect(cases_paths, "Cases")) %>% 
  mutate(Date = str_extract_all(cases_paths, ("\\d+")),
         Date = ymd(Date)) 

## read into dataframe with adding Date of each file

cases_df <- cases_files %>% 
  # filter for the maximum file (possibly the same day as of today) # 
 # dplyr::filter(Date == max(Date)) %>% 
  {map2_dfr(.$cases_paths, .$Date, function(x,y) read_excel(x) %>% mutate(Date=y))}


## DEATHS ## 

deaths_files <- data.frame(deaths_paths = epi.list) %>% 
  filter(str_detect(deaths_paths, "Deathes")) %>% 
  mutate(Date = str_extract_all(deaths_paths, ("\\d+")),
         Date = ymd(Date))

## read into dataframe with adding Date of each file

deaths_df <- deaths_files %>% 
  # filter for the maximum file (possibly the same day as of today) # 
 # dplyr::filter(Date == max(Date)) %>% 
  {map2_dfr(.$deaths_paths, .$Date, function(x,y) read_excel(x) %>% mutate(Date=y))}


## MERGE both cases_df and deaths_df and add Measure column as .id 
## Also Processing ## 

epi_data <- dplyr::bind_rows("Cases" = cases_df, 
                             "Deaths" = deaths_df, 
                             .id = "Measure") %>% 
  tidyr::pivot_longer(cols = c("Male", "Female"),
                      names_to = "Sex",
                      values_to = "Value") %>% 
  tidyr::separate(`Age Group`, 
                  into = c("Age", "UpperLimit"),
  ## separate column based on two seprators; here: - +
                  sep = "[+-]") %>% 
  dplyr::mutate(AgeInt = case_when(Age == "90" ~ 15L,
                                   TRUE ~ 10L),
                Sex = case_when(Sex == "Male" ~ "m",
                                Sex == "Female" ~ "f"),
                Value = str_remove_all(Value, ","),
                Value = as.integer(Value))


python_data <- epi_data %>% 
  dplyr::mutate(
    Metric = "Count",
    Date = ddmmyyyy(Date),
    Code = paste0("AU"),
    Country = "Australia",
    Region = "All",
    Age = as.character(Age)) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, 
                Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


## Append to historical data on drive, append to "db_drive" 

## When using historical data on drive, append to "db_drive"
out <- bind_rows(db_drive, python_data)

#out <- bind_rows(db_n, python_data) 


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 


## END ## 
