source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
#source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")
#source(here("Automation", "00_Functions_automation.R"))
# library(webshot)
#install_phantomjs()

if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
gs4_auth(email = email)
drive_auth(email = email)

ctr <- "Finland"
sht <- "FI"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

rubric <- get_input_rubric() %>% 
     filter(Short == sht)

ss_i  <- rubric$Sheet
ss_db <- rubric$Source

rubric <- get_input_rubric() %>% 
  filter(Country == "Finland")

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
    Code = paste0("FI",Date),
    Measure = "Cases",
    Metric = "Count") %>% 
  select(Country, Region, Code, Date, Sex, Age, 
         AgeInt, Metric, Measure, Value)
    

# 
FI_in <- get_country_inputDB("FI") %>% 
  select(-Short) %>% 
  sort_input_data()

# filter and merge
FI_out <-
  FI_in %>% 
  filter(Measure != "Cases") %>% 
  bind_rows(Cases) %>% 
  sort_input_data()

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

write_csv(Cases, data_cases )

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_cases_",
                  today(), 
                  ".zip")

zipr(zipname, 
     data_cases, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_cases)







