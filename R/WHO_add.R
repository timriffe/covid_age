
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")


# these come from here: https://www.who.int/data/data-collection-tools/who-mortality-database
icd_base_url <-"https://cdn.who.int/media/docs/default-source/world-health-data-platform/mortality-raw-data/"
icd_files    <- c("mort_country_codes.zip","morticd10_part1.zip","morticd10_part2.zip",
                  "morticd10_part3.zip","morticd10_part4.zip","morticd10_part5.zip")
for (i in 1:length(icd_files)){
  url_i   <- paste0(icd_base_url,icd_files[i])
  local_i <- file.path("Data",icd_files[i])
  download.file(url_i, destfile = local_i, overwrite = TRUE)
}

# a lookup table to match country names to codes
ctry_names <- read_csv(file.path("Data","mort_country_codes.zip")) %>% 
  rename(Country = country)

icd_all    <- list()
icd_files2 <- icd_files[-1]
#ICD download each of the 5 files
for (i in 1:length(icd_files2)){
  icd_i <- read_csv(file.path("Data",icd_files2[i]),
                    col_types = cols(Admin1 = col_character(),SubDiv = col_character(),
                                     List = col_character(), Cause = col_character(), 
                                     Frmat = col_character(), IM_Frmat = col_character(),
                                     .default = col_double())) %>% 
    left_join(ctry_names, by = "Country") %>% 
    dplyr::filter(Sex %in% c(1,2)) 
  
  icd_all[[i]] <- icd_i
}

# stick together
c19 <- bind_rows(icd_all) %>% 
  dplyr::filter(grepl(Cause, pattern = "U07"))
rm(icd_all)
gc()
c19$name %>% unique()

c19 <- c19 %>% 
  dplyr::filter(!name %in% c("Slovenia","Austria","Estonia","Iceland",
                              "United States of America", "Mexico","United Kingdom, England and Wales",
                              "United Kingdom, Scotland", "Spain"  ,"Germany","Netherlands","Australia",
                              "Czech Republic","Costa Rica"))
c19$Sex %>% unique()

# googlesheets4::sheets_create(), then googledriv::drive_mv()

# destination folder:
folder_ss <- "https://drive.google.com/drive/folders/1tsEx9xbRZhQOuegfGuWi-h1t_6_zzpJ1"
c19 %>% 
  group_by(name) %>% 
  mutate(n = Cause %>% unique() %>% length()) %>% 
  dplyr::filter(n == 2) %>% 
  View()

out <- 
c19 %>% 
  pivot_longer(contains("Deaths"), names_to = "Age", values_to = "Value") %>% 
  mutate(Age = gsub(Age, pattern = "Deaths", replacement = ""),
         Age = case_when(Age == "1" ~ "TOT",
                         Age == "2" ~ "0",
                         Age == "3" ~ "1",
                         Age == "4" ~ "2",
                         Age == "5" ~ "3",
                         Age == "6" ~ "4",
                         Age == "7" ~ "5",
                         Age == "8" ~ "10",
                         Age == "9" ~ "15",
                         Age == "10" ~ "20",
                         Age == "11" ~ "25",
                         Age == "12" ~ "30",
                         Age == "13" ~ "35",
                         Age == "14" ~ "40",
                         Age == "15" ~ "45",
                         Age == "16" ~ "50",
                         Age == "17" ~ "55",
                         Age == "18" ~ "60",
                         Age == "19" ~ "65",
                         Age == "20" ~ "70",
                         Age == "21" ~ "75",
                         Age == "22" ~ "80",
                         Age == "23" ~ "85",
                         Age == "24" ~ "90",
                         Age == "25" ~ "95",
                         Age == "26" ~ "UNK",
                         TRUE ~ NA_character_
                         )) %>% 
  dplyr::filter(!is.na(Value)) %>% 
  group_by(name, Year, Sex, Frmat, Age) %>% 
  summarize(Value = sum(Value), .groups = "drop") %>% 
  select(Country = name, Year, Sex, Frmat, Age, Value) %>% 
  mutate(Region = "All",
         Sex = case_when(Sex == 1 ~ "m",
                         Sex == 2 ~ "f"),
         Date = paste0("31.12.",Year),
         AgeInt = case_when(Age %in% as.character(0:4) ~ 1L,
                            Frmat == "00" & Age == "95" ~ 10L,
                            Frmat == "01" & Age == "85" ~ 20L,
                            Frmat == "03" & Age == "75" ~ 30L,
                            Age == "TOT" ~ NA_integer_,
                            Age == "UNK" ~ NA_integer_,
                            TRUE ~ 5L),
         Metric = "Count",
         Measure = "Deaths",
         Code = case_when(Country == "Serbia" ~ "RS",
                          Country == "North Macedonia" ~ "MK",
                          Country == "Bosnia and Herzegovina" ~ "BA",
                          Country == "Qatar" ~ "QA",
                          Country == "Latvia" ~ "LV",
                          Country == "Georgia" ~ "GE",
                          Country == "Mauritius" ~ "MU",
                          Country == "Oman" ~ "OM",
                          Country == "Kazakhstan" ~ "KZ",
                          Country == "Guatemala" ~ "GT",
                          Country == "United Arab Emirates" ~ "AE",
                          Country == "Lithuania" ~ "LT")) %>% 
  select(Country,	Region,	Code,	Date,	Sex,	Age,	AgeInt,	Metric,	Measure,	Value) %>% 
  sort_input_data() %>% 
  dplyr::filter(!(Age == "UNK" & Value == 0))


rubric <- get_input_rubric() %>% 
  dplyr::filter(grepl(Short, pattern = "WHO"))

rubric

countries <- out$Country %>% unique()
countries %>% sort()
for (i in 1:length(countries)){
  ss_i <- rubric %>% 
    dplyr::filter(Country == countries[i]) %>% 
    dplyr::pull(Sheet)
  out_i <- out %>% dplyr::filter(Country == countries[i])
  write_sheet(out_i, ss= ss_i, sheet = "database")
}   
