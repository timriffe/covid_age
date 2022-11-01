## Australia VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr     <- "AustraliaVax" # it's a placeholder
ctr_rds <- "Australia_vaccine"
dir_n   <- "N:/COVerAGE-DB/Automation/Hydra/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



## Source_website <- "https://www.health.gov.au/resources/collections/covid-19-vaccination-vaccination-data"

## Brief: Australia data used to be collected from 'refreshed' link, check script 'Australia_vaccine.R'. 
## This link is not updated since 23.07.2022- instead, the authorities published the data in Excel sheets by day
## since 5 Sep 2021 (data for 4 Sep 2021) and then by week in late 2022. 
## So, I here add the historical data (since 30.06.2021 till 03.09.2021), download the published excel files, 
## process the data & merge. 


## Part I: Historical Data: extract the data before 04.09.2021 from the .rds ====================

## This is for the historical data (we may need this if any issue with the dataset later)

# archiveddata <- read_rds(paste0(dir_n, ctr_rds, ".rds")) %>% 
#   dplyr::mutate(Date = dmy(Date)) %>% 
#   dplyr::filter(Date < "2021-09-04",
#                 Value != "0") %>% 
#   dplyr::mutate(Date = ddmmyyyy(Date))





## Part I.a: extract the last date from the .rds ====================

rdsData <- read_rds(paste0(dir_n, ctr_rds, ".rds")) 

rdsData_date <- rdsData %>% 
  dplyr::mutate(Date = dmy(Date)) %>% 
  dplyr::distinct(Date) %>% 
  dplyr::filter(Date == max(Date)) %>% 
  dplyr::pull(Date)


## Part II. Download the Excel files since 05.09.2021 or the most recent ===================
## Note: (data as of 04.09.2021, as in Usage note)


url_page <- "https://www.health.gov.au/resources/collections/covid-19-vaccination-vaccination-data"

#page <- xml2::read_html(url_page)

urls <- rvest::read_html("https://www.health.gov.au/resources/collections/covid-19-vaccination-vaccination-data#october-2022") %>% 
  rvest::html_nodes("a ") %>% 
  rvest::html_attr('href') 


urls <- scraplinks(url_page)

urls_df <- data.frame(excels_url = urls,
                      baselink = "https://www.health.gov.au") %>%
                      filter(str_detect(excels_url, "/resources/publications/covid-19-vaccination")) %>%
                      distinct(excels_url, baselink) %>% 
  dplyr::mutate(html_page = paste0(baselink, excels_url),
                date_prep = str_remove(excels_url, "/resources/publications/covid-19-vaccination-vaccination-data-"),
                date_prep = str_remove(date_prep, "-0"),
                date = dmy(date_prep),
                Date = date - 1) %>% 
  dplyr::select(html_page, Date) %>% 
  ## get the last published url ## 
  dplyr::filter(Date == max(Date))


urls_list <- urls_df %>% 
  dplyr::pull(html_page)

urls_date <- urls_df %>% 
  dplyr::pull(Date)


if(urls_date > rdsData_date){

  
  extract_excel <- function(link){
    scraplinks(link) %>% 
      dplyr::filter(str_detect(url, ".xlsx")) 
  }
  
  excel_df <- urls_df %>% 
    {map2_dfr(.$html_page, .$Date, function(x,y) extract_excel(x) %>% mutate(Date=y))}


excel_df %>% 
  dplyr::mutate(base_destination = paste0(dir_n, "Data_sources/", ctr),
                destinations = paste0(base_destination, "/", Date, ".xlsx")) %>% 
  {map2(.$url, .$destinations, ~ download.file(url = .x, destfile = .y, mode="wb"))}


vax.list <-list.files(
  path= paste0(dir_n, "Data_sources/", ctr),
  pattern = ".xlsx",
  full.names = TRUE)

## this was for the purpsoe of the missing data files ##
# sourcedata_vax <- vax.list %>% 
#   set_names() %>% 
#   map_dfr(~read_excel(., col_types = c("text", "numeric")),
#           .id = "file_name") %>% 
#   dplyr::mutate(date_prep = str_remove(file_name, paste0(dir_n, "Data_sources/", ctr, "/")),
#                 date_prep = str_remove(date_prep, ".xlsx"),
#                 Date = ymd(date_prep)) 


sourcedata_vax <- data.frame(file_name = vax.list) %>% 
  dplyr::mutate(date_prep = str_remove(file_name, paste0(dir_n, "Data_sources/", ctr, "/")),
                date_prep = str_remove(date_prep, ".xlsx"),
                Date = ymd(date_prep)) %>% 
  dplyr::filter(Date == max(Date)) %>% 
  dplyr::pull(file_name) %>% 
  purrr::set_names() %>% 
  purrr::map_dfr(~read_excel(., col_types = c("text", "numeric")), .id = "file_name") %>% 
  dplyr::mutate(date_prep = str_remove(file_name, paste0(dir_n, "Data_sources/", ctr, "/")),
                date_prep = str_remove(date_prep, ".xlsx"),
                Date = ymd(date_prep)) 


# data_raw <- sourcedata_vax %>% 
#   dplyr::select(Date, 
#                 Measure = `Measure Name`,
#                 Measure_fill = `...1`,
#                 Value)

data_raw <- sourcedata_vax %>% 
  dplyr::select(Date, 
                Measure = `...1`,
                Value)


processed_data <- data_raw %>% 
  dplyr::filter(str_detect(Measure, "Age group"),
                !str_detect(Measure, "Population")) %>% 
  dplyr::mutate(Measure = str_remove(Measure, "Age group -")) %>% 
  tidyr::separate(Measure, into = c("Age_prep", "Sex_prep", "Measure_prep"),
                  sep = " - ") %>% 
  dplyr::mutate(Measure = case_when(str_detect(Measure_prep, "fully") ~ "Vaccination2",
                                    str_detect(Measure_prep, "2") ~ "Vaccination2",
                                    str_detect(Measure_prep, "1") ~ "Vaccination1",
                                    str_detect(Sex_prep, "fully") ~ "Vaccination2",
                                    str_detect(Sex_prep, "2") ~ "Vaccination2",
                                    str_detect(Sex_prep, "1") ~ "Vaccination1",
                                    str_detect(Age_prep, "fully") ~ "Vaccination2"),
                Sex = case_when(str_detect(Sex_prep, "F") ~ "f",
                                str_detect(Sex_prep, "M") ~ "m",
                                TRUE ~ "b")) %>% 
  tidyr::separate(Age_prep, into = c("Age", "bla"), sep = "[+-]") %>% 
  dplyr::mutate(Age = as.integer(Age),
                AgeInt = case_when(Age == "12" ~ 4L,
                                   Age == "16" ~ 4L,
                                   Age == "95" ~ 10L,
                                   TRUE ~ 5L),
                Date = ddmmyyyy(Date),
                Age = as.character(Age),
                AgeInt = as.character(AgeInt),
                Metric = "Count",
                Code = "AU",
                Country = "Australia",
                Region = "All") %>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data()
  


# Out <- bind_rows(archiveddata, processed_data) %>% 
#   sort_input_data()


Out <- bind_rows(rdsData, processed_data) %>% 
  sort_input_data()


#save output 

write_rds(Out, paste0(dir_n, ctr_rds, ".rds"))

log_update(pp = ctr, N = nrow(Out))

} else{
  
  log_update(pp = ctr, N = 0)
}

## END ## 

