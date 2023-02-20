## LEBANON VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Lebanon_vaccine" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_python <- "N:/COVerAGE-DB/Automation/Lebanon/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



## Part I: extract the last date from the .rds ====================

rdsData <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  unique()

rdsData_date <- rdsData %>% 
  dplyr::mutate(Date = dmy(Date)) %>% 
  dplyr::distinct(Date) %>% 
  dplyr::filter(Date == max(Date)) %>% 
  dplyr::pull(Date)

## Part II: extract the last date from the python downloaded excel files ====================

vax.list <-list.files(
  path= dir_n_python,
  pattern = ".csv",
  full.names = TRUE)


sourcedata_vax <- data.frame(file_name = vax.list) %>% 
  dplyr::mutate(date_prep = str_remove(file_name, dir_n_python),
                date_prep = str_extract(date_prep, "\\d+"),
                Date = ymd(date_prep)) 

sourcedate <- sourcedata_vax %>% 
  dplyr::distinct(Date) %>% 
  dplyr::filter(!is.na(Date)) %>% 
  dplyr::filter(Date == max(Date)) %>% 
  dplyr::pull(Date)



if(sourcedate > rdsData_date){
  
  data_raw <- sourcedata_vax %>% 
   # dplyr::filter(Date == max(Date)) %>% 
    dplyr::pull(file_name) %>% 
    purrr::set_names() %>% 
    purrr::map_dfr(read_csv, .id = "file_name") %>% 
    dplyr::mutate(date_prep = str_remove(file_name, dir_n_python),
                  date_prep = str_extract(date_prep, "\\d+"),
                  Date = ymd(date_prep)) %>% 
    dplyr::select(Date,
                  Age_prep = `Patient Date of Birth`,
                  Value = Count)
  
  
  processed_data <- data_raw %>% 
    ## Assuming Vaccination started 2021 ## 
    dplyr::mutate(Age_prep2 = 2021- Age_prep,
                  Age = case_when(Age_prep2 > 105 ~ 105,
                                        TRUE ~ Age_prep2)) %>% 
    dplyr::group_by(Date, Age) %>% 
    dplyr::summarise(Value = sum(Value)) %>% 
    dplyr::ungroup() %>% 
    dplyr::filter(!is.na(Date))
    
    
  dates_f <- seq(min(processed_data$Date), max(processed_data$Date), by = '1 day')
  ages <- 0:105
  
  pre_finaldf <- processed_data %>% 
    tidyr::complete(Age = ages, Date = dates_f, fill = list(Value = 0)) %>% 
    group_by(Age) %>% 
    mutate(Value = cumsum(Value)) %>% 
    ungroup() 
    
    finaldf <- pre_finaldf %>% 
      dplyr::mutate(AgeInt = 1L,
                    Date = ddmmyyyy(Date),
                    Age = as.character(Age),
                    Metric = "Count",
                    Sex = "b",
                    Measure = "Vaccinations",
                    Code = "LB",
                    Country = "Lebanon",
                    Region = "All") %>% 
    select(Country, Region, Code, Date, Sex, 
           Age, AgeInt, Metric, Measure, Value) %>% 
    sort_input_data()
  
  Out <- bind_rows(rdsData, finaldf) %>% 
    unique() %>% 
    sort_input_data()
  
  
  #save output 
  
  write_rds(Out, paste0(dir_n, ctr, ".rds"))
  
  log_update(pp = ctr, N = nrow(Out))
  
} else{
  
  log_update(pp = ctr, N = 0)
}

## END ## 






