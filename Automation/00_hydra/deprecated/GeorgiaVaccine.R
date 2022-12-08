## Georgia Vaccination-DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Georgia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_python <- "N:/COVerAGE-DB/Automation/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


## Description: 

## Georgia Vaccination data were collected manually until 30.01.2022 (inclusive) in the input template. 
## In February 2022, a python script is written to automate downloading these data in Georgia folder as .xlsx
## So, the purpose of this script is to read the data from Input template on the GD and read the .xlsx files that 
## have been downloaded since 28.02.2022 and merge both in one output as .rds file on N. 

## Data until 31.01.2022 from Google Drive:
# 
at_rubric <- get_input_rubric() %>%
  dplyr::filter(Short == "GE")
ss_i   <- at_rubric %>% dplyr::pull(Sheet)
ss_db  <- at_rubric %>% dplyr::pull(Source)


db_drive <- read_sheet(ss = ss_i, sheet = "database")
# 

## Since I don't want to repeat this whole process, we will append the data on daily basis,
## Also, to make sure that the python automated script is working ##
## Though I keep the code above for reference if any issues! 


## Data from 14.04.2022 from Python automated .xlsx files 

## load the xlsx files... 

epi.list <-list.files(
  path= paste0(dir_n_python, ctr),
  pattern = ".xlsx",
  full.names = TRUE)

## VACCINATION ## 

vax_files <- data.frame(VAX_paths = epi.list) %>% 
  mutate(Date = str_extract_all(VAX_paths, ("\\d+")),
         Date = ymd(Date)) 

## read into dataframe with adding Date of each file

vax_df <- vax_files %>% 
  {map2_dfr(.$VAX_paths, .$Date, function(x,y) read_excel(x) %>% mutate(Date=y))}


## PROCESSING ##

AgeGroup <- c("12-15", "16-17", "18-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75+")


processed_data <- vax_df %>%
  dplyr::select(Date, 
                Age = "0", 
                Vaccination1 = "1",
                Vaccination2 = "2",
                Vaccination3 = "3") %>% 
  dplyr::filter(Age %in% AgeGroup) %>% 
  tidyr::pivot_longer(cols = -c("Date", "Age"),
                      names_to = "Measure",
                      values_to = "Value") %>% 
  tidyr::separate(Age, into = c("Age", "nothing"), sep = "[-+]") %>% 
  dplyr::mutate(AgeInt = case_when(Age == "75" ~ 30L,
                                   Age == "12" ~ 4L,
                                   Age == "16" ~ 2L,
                                   Age == "18" ~ 32L,
                                   Age == "50" ~ 5L,
                                   Age == "55" ~ 5L,
                                   Age == "60" ~ 5L,
                                   Age == "65" ~ 5L,
                                   Age == "70" ~ 5L)) 
  
  
## FINAL OUTPUT ## 

out <- processed_data %>% 
  dplyr::mutate(Sex = "b",
                Metric = "Count",
                Date = ddmmyyyy(Date),
                Code = paste0("GE"),
                Country = "Georgia",
                Region = "All",
                Age = as.character(Age),
                Value = as.double(Value)) %>% 
## Bind the processed data with the data from manual collection (from Drive)
  bind_rows(db_drive) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, 
                Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()



#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(out)) 


## END ## 
