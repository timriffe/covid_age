source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
#source(here("Automation", "00_Functions_automation.R"))
# library(webshot)
#install_phantomjs()

if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# info country and N drive address
ctr <- "Finland"
sht <- "FI"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

rubric <- 
  get_input_rubric() %>% 
  filter(Short == sht)

ss_i  <- rubric$Sheet
ss_db <- rubric$Source

# rubric <- get_input_rubric() %>% 
#  filter(Country == "Finland")

#fi_deaths_png  <- paste0(dir_n,"Data_sources/",ctr,"/Finland_deaths_",today(),".png")

# First, get screen capture of Finland deaths, save local and to drive:

#xpath <- '//*[@id="portlet_com_liferay_journal_content_web_portlet_JournalContentPortlet_INSTANCE_8bWCjC9jscyt"]/div/div[2]/div/div[2]/p[16]/span[1]/span/span/span/i/span/span/span/img'

#arcgis_url <-"https://experience.arcgis.com/experience/92e9bb33fac744c9a084381fc35aa3c7"
# This one for giving a click inside the arcgis dashboard.
#xpath_ember184 <- "/html/body/div/div/div[2]/div/div/div/margin-container/full-container/div[20]/margin-container/full-container/div/nav/span[3]/a/div"

#webshot(fi_deaths_url,
        #file = fi_deaths_png,
        #delay = 2)
#drive_put(media = fi_deaths_png,
         #path = googledrive::as_id(ss_db))

# fi_deaths_url <-
#   read_html("https://thl.fi/en/web/infectious-diseases-and-vaccinations/what-s-new/coronavirus-covid-19-latest-updates/situation-update-on-coronavirus#Coronavirus-related_deaths") %>% 
#   html_nodes(xpath = xpath) %>% 
#   html_attr("src")
# fi_deaths_url <- paste0("https://thl.fi/", fi_deaths_url)
# 
# 
# webshot(fi_deaths_url,
#         file = fi_deaths_png,
#         delay = 2)
# drive_put(media = fi_deaths_png,
#           path = googledrive::as_id(ss_db))


deaths <- 
  read_delim("https://sampo.thl.fi/pivot/prod/en/epirapo/covid19case/fact_epirapo_covid19case.csv?row=sex-444328&column=ttr10yage-444309&filter=measure-492118&filter=dateweek20200101-509030&", delim = ";")

deaths2 <- 
  deaths %>% 
  mutate(Sex = case_when(Gender == "Women" ~ "f",
                         Gender == "Men" ~ "m",
                         Gender == "All sexes" ~ "b"),
         Age = str_sub(Age, 1, 2),
         Age = case_when(Age == "00" ~ "0",
                         Age == "Al" ~ "TOT",
                         TRUE ~ Age),
         val = val %>% as.double()) %>% 
  select(-Gender)

# sex distribution at young ages for imputation
sex_dist <- 
  deaths2 %>% 
  filter(Sex != "b",
         Age %in% c("30", "40")) %>% 
  mutate(val = ifelse(val == "..", "0", val),
         val = val %>% as.double()) %>% 
  group_by(Sex) %>% 
  summarise(val = sum(val)) %>% 
  ungroup() %>% 
  group_by() %>% 
  mutate(prop = val/sum(val)) %>% 
  select(-val)

# censored value in young ages
val_miss <- 
  deaths2 %>% 
  filter(Sex == "b") %>% 
  mutate(Age = ifelse(Age != "TOT", "no_tot", Age)) %>% 
  drop_na() %>% 
  group_by(Age) %>% 
  summarise(val = sum(val)) %>% 
  spread(Age, val) %>% 
  mutate(miss = TOT - no_tot) %>% 
  dplyr::pull(miss)

# ages to be dropped due to missing values
age_drop <- 
  deaths2 %>% 
  filter(Sex == "b",
         is.na(val),
         Age != "0") %>% 
  dplyr::pull(Age)

# dropping ages
deaths3 <- 
  deaths2 %>% 
  filter(Age != age_drop) %>% 
  mutate(val = ifelse(Sex == "b" & Age == "0", val_miss, val))


deaths_out <- 
  deaths3 %>% 
  filter(Age != age_drop) %>% 
  left_join(sex_dist) %>% 
  left_join(deaths3 %>% 
              filter(Sex == "b",
                     Age != age_drop) %>% 
              select(Age, val_tot = val)) %>% 
  mutate(val = ifelse(is.na(val), val_tot * prop, val),
         val = round(val)) %>% 
  select(-val_tot, -prop, Value = val) %>% 
  mutate(Measure = "Deaths",
         AgeInt = case_when(Age == "0" ~ as.numeric(lead(Age)) - as.numeric(Age),
                            Age == "80" ~ 25,
                            Age == "TOT" ~ NA_real_,
                            TRUE ~ 10),
         Country = "Finland",
         Code = "FI",
         Metric = "Count",
         Region = "All",
         Date = ddmmyyyy(today())) %>% 
  select(Country, Region, Code, Date, Sex, Age, 
         AgeInt, Metric, Measure, Value)


# -------------------------------------
# Now get cases:
fi_case_url <- "https://opendata.arcgis.com/datasets/aa28e00e8b8647deb3d2573b4d19f73c_0.csv"

CasesIN <- read_csv(fi_case_url) 
# tapauksia  cases
# miehia     male
# naisia     female
Cases <-
  CasesIN %>% 
  separate(date, 
           into = c("Date", NA),
           sep = " ") %>% 
  mutate(Date = ymd(Date)) %>% 
  filter(Date > dmy("01-02-2020")) %>% 
  pivot_longer(tapauksia:ika_80_,
               values_to = "Value",
               names_to = "Age") %>% 
  select(Date, Age, Value) %>% 
  mutate(
    Sex = case_when(
             Age == "miehia" ~ "m",
             Age == "naisia" ~ "f",
             TRUE ~ "b"),
    Age = tolower(Age),
    Age = recode(Age,
                 "miehia" = "TOT",
                 "naisia" = "TOT",
                 "tapauksia" = "TOT",
                 "ika_0_9" = "0",
                 "ika_10_19" = "10",
                 "ika_20_29" = "20",
                 "ika_30_39" = "30",
                 "ika_40_49" = "40",
                 "ika_50_59" = "50",
                 "ika_60_69" = "60",
                 "ika_70_79" = "70",
                 "ika_80_"  = "80" 
                 ) ) %>%
  group_by(Date,Sex,Age) %>% 
  summarize(Value = sum(Value), 
            .groups = "drop") %>% 
  mutate(
    AgeInt = case_when(
        Age == "80" ~ 25L,
        Age == "TOT" ~ NA_integer_,
        TRUE ~ 10L),
    Country = "Finland",
    Region = "All",
    Date = ddmmyyyy(Date),
    Code = paste0("FI"),
    Measure = "Cases",
    Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, 
         AgeInt, Metric, Measure, Value)
    

# importing stored data 
FI_in <- read_rds(paste0(dir_n, ctr, ".rds"))


FI_out <-
  FI_in %>% 
  # keeping deaths
  dplyr::filter(Measure != "Cases") %>% 
  # adding all cases and new deaths
  bind_rows(Cases,
            deaths_out) %>% 
  # remove duplicates, select larger value
  group_by(Region, Measure, Metric, Sex, Age, Date) %>% 
  mutate(isMax = Value == max(Value)) %>% 
  ungroup() %>% 
  dplyr::filter(isMax) %>% 
  sort_input_data() %>% 
  unique()


# # 
# FI_in <- get_country_inputDB("FI") %>% 
#   select(-Short) %>% 
#   sort_input_data()
# 
# # filter and merge
# FI_out <-
#   FI_in %>% 
#   dplyr::filter(Measure != "Cases") %>% 
#   bind_rows(Cases) %>% 
#   # remove duplicates, select larger value
#   group_by(Region, Measure, Metric, Sex, Age, Date) %>% 
#   mutate(isMax = Value == max(Value)) %>% 
#   ungroup() %>% 
#   dplyr::filter(isMax) %>% 
#   sort_input_data() 



############################################
#### saving database in N Drive ####
############################################
write_rds(FI_out, paste0(dir_n, ctr, ".rds"))

# push to drive
#write_sheet(FI_out,
#            ss = ss_i,
#            sheet = "database")

log_update("Finland", N = nrow(Cases))

############################################
#### uploading metadata to N Drive ####
############################################

data_cases <- paste0(dir_n, "Data_sources/", ctr, "/cases_",today(), ".csv")
data_deaths <- paste0(dir_n, "Data_sources/", ctr, "/deaths_",today(), ".csv")

write_csv(CasesIN, data_cases)
write_csv(deaths, data_deaths)

data_source <- c(data_cases, data_deaths)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_cases_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)







