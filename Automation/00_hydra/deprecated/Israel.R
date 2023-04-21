## ISRAEL EPI-DATA AND VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Israel" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

## dataset for epi-and vaccination data

## SOURCE of the datasets: https://data.gov.il/dataset/covid-19
## this is a bit strange that the .csv traditional download/ read method did not work!
# so shift to API method instead
# data_url <- "https://data.gov.il/dataset/covid-19/resource/89f61e3a-4866-4bbf-bcc1-9734e5fee58e"
# 
# csv_url <- "http://data.gov.il/dataset/covid-19/resource/89f61e3a-4866-4bbf-bcc1-9734e5fee58e/download/corona_age_and_gender_ver_00346.csv"
# raw_data <- download.file(url = csv_url, 
#                           destfile = data_source,
#                           mode = "wb")

## Documentation: https://data.gov.il/dataset/covid-19/resource/93d0df92-8245-466f-8e96-99f2f3f2e4f9/download/readme-.pdf

dates <- seq(from = as.Date("2020/03/15"), to = today(), by = "7 days") %>% 
  length()

limits <- dates*50

api <- paste0("https://data.gov.il/api/3/action/datastore_search?resource_id=89f61e3a-4866-4bbf-bcc1-9734e5fee58e&", 
              "limit=", limits)


raw_data <- jsonlite::fromJSON(api)[["result"]][["records"]] %>% 
    dplyr::select(
    Date = last_week_day,
    Age = age_group,
    Sex = gender,
    Tests = weekly_tests_num,
    Cases = weekly_cases,
    Deaths = weekly_deceased,
    Vaccination1 = weekly_first_dose, 
    Vaccination2 = weekly_second_dose,
    Vaccination3 = weekly_third_dose,
    Vaccination4 = weekly_fourth_dose
  ) 

## TO avoid writing the hebrew characters in R since it does not read in automation, 
## we extract unique values and inner join
## to check on the work, review the data after inner_join; 
## 1st case is male, 2nd is unknown, 3rd is female.
sex_hebrew <- unique(raw_data$Sex)

sex <- c("m", "UNK", "f")
sex_df <- data.frame(hebrew = sex_hebrew,
                     english = sex)


# Since these are newly weekly data, we will sum up to cumulative

processed_data <- raw_data %>% 
  dplyr::inner_join(sex_df, by = c("Sex" = "hebrew")) %>% 
  dplyr::select(-Sex, Sex = english) %>% 
  dplyr::mutate(
    Date = ymd(Date),
    Cases = str_remove_all(Cases, pattern = "<|.0"),
    Deaths = str_remove_all(Deaths, pattern = "<|.0"),
    Tests = str_remove_all(Tests, pattern = "<|.0"),
    Vaccination1 = str_remove_all(Vaccination1, pattern = "<|.0"),
    Vaccination2 = str_remove_all(Vaccination2, pattern = "<|.0"),
    Vaccination3 = str_remove_all(Vaccination3, pattern = "<|.0"),
    Vaccination4 = str_remove_all(Vaccination4, pattern = "<|.0")
    # across(.cols = Tests:Vaccination4, 
    #        .fns = as.numeric)
  )  %>% 
  tidyr::pivot_longer(
    cols = Tests:Vaccination4,
    names_to = "Measure",
    values_to = "Value"
  ) %>%
  dplyr::mutate(Value = as.numeric(Value),
                Value = replace_na(Value, 0)) %>% 
  dplyr::group_by(Age, Sex, Measure, .drop = TRUE) %>% 
  dplyr::mutate(Value = cumsum(Value)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(
    AgeInt = case_when(Age == "0-19" ~ 0L,
                       Age == "20-24" ~ 5L,
                       Age == "25-29" ~ 5L,
                       Age == "30-34" ~ 5L,
                       Age == "35-39" ~ 5L,
                       Age == "40-44" ~ 5L,
                       Age == "45-49" ~ 5L,
                       Age == "50-54" ~ 5L,
                       Age == "55-59" ~ 5L,
                       Age == "60-64" ~ 5L,
                       Age == "65-69" ~ 5L,
                       Age == "70-74" ~ 5L,
                       Age == "75-79" ~ 5L,
                       Age == "80+" ~ 25L,
                       Age == "NULL" ~ NA_integer_),
    Age = case_when(Age == "0-19" ~ "0",
                    Age == "20-24" ~ "20",
                    Age == "25-29" ~ "25",
                    Age == "30-34" ~ "30",
                    Age == "35-39" ~ "35",
                    Age == "40-44" ~ "40",
                    Age == "45-49" ~ "45",
                    Age == "50-54" ~ "50",
                    Age == "55-59" ~ "55",
                    Age == "60-64" ~ "60",
                    Age == "65-69" ~ "65",
                    Age == "70-74" ~ "70",
                    Age == "75-79" ~ "75",
                    Age == "80+" ~ "80",
                    Age == "NULL" ~ "UNK"))


out <- processed_data %>% 
  dplyr::mutate(
    Metric = "Count",
    Date = ddmmyyyy(Date),
    Code = paste0("IL"),
    Country = "Israel",
    Region = "All",
    Age = as.character(Age)) %>% 
  dplyr::select(Country, Region, Code, Date, Sex, 
                Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

#log_update(pp = ctr, N = nrow(out)) 


#zip input data file 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/data_", today(), ".csv")

write.csv(raw_data, data_source)


zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname, 
          data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

#END

## Quality checks ##

# processed_data %>% 
#   ggplot(aes(x = Date, y = Value)) +
#   geom_point() +
#   facet_wrap(~ Measure, scales = "free_y")
