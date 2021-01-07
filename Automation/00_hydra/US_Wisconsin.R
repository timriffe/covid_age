# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# TR New: you must be in the repo environment 
source("Automation/00_Functions_automation.R")

# info country and N drive address
ctr <- "US_Wisconsin"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

drive_auth(email = email)
gs4_auth(email = email)
# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_WI")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)


db0 <- read_csv("https://opendata.arcgis.com/datasets/859602b5d427456f821de3830f89301c_11.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D")


cols <- structure(list(cols = list(OBJECTID = structure(list(), class = c("collector_double", 
"collector")), GEOID = structure(list(), class = c("collector_double",
"collector")), GEO = structure(list(), class = c("collector_character", 
"collector")), NAME = structure(list(), class = c("collector_character", 
"collector")), NEGATIVE = structure(list(), class = c("collector_double", 
"collector")), POSITIVE = structure(list(), class = c("collector_double", 
"collector")), HOSP_YES = structure(list(), class = c("collector_double", 
"collector")), HOSP_NO = structure(list(), class = c("collector_double", 
"collector")), HOSP_UNK = structure(list(), class = c("collector_double", 
"collector")), POS_FEM = structure(list(), class = c("collector_double", 
"collector")), POS_MALE = structure(list(), class = c("collector_double", 
"collector")), POS_OTH = structure(list(), class = c("collector_double", 
"collector")), POS_0_9 = structure(list(), class = c("collector_double", 
"collector")), POS_10_19 = structure(list(), class = c("collector_double", 
"collector")), POS_20_29 = structure(list(), class = c("collector_double", 
"collector")), POS_30_39 = structure(list(), class = c("collector_double", 
"collector")), POS_40_49 = structure(list(), class = c("collector_double", 
"collector")), POS_50_59 = structure(list(), class = c("collector_double", 
"collector")), POS_60_69 = structure(list(), class = c("collector_double", 
"collector")), POS_70_79 = structure(list(), class = c("collector_double", 
"collector")), POS_80_89 = structure(list(), class = c("collector_double", 
"collector")), POS_90 = structure(list(), class = c("collector_double", 
"collector")), DEATHS = structure(list(), class = c("collector_double", 
"collector")), DTHS_FEM = structure(list(), class = c("collector_double", 
"collector")), DTHS_MALE = structure(list(), class = c("collector_double", 
"collector")), DTHS_OTH = structure(list(), class = c("collector_double", 
"collector")), DTHS_0_9 = structure(list(), class = c("collector_double", 
"collector")), DTHS_10_19 = structure(list(), class = c("collector_double", 
"collector")), DTHS_20_29 = structure(list(), class = c("collector_double", 
"collector")), DTHS_30_39 = structure(list(), class = c("collector_double", 
"collector")), DTHS_40_49 = structure(list(), class = c("collector_double", 
"collector")), DTHS_50_59 = structure(list(), class = c("collector_double", 
"collector")), DTHS_60_69 = structure(list(), class = c("collector_double", 
"collector")), DTHS_70_79 = structure(list(), class = c("collector_double", 
"collector")), DTHS_80_89 = structure(list(), class = c("collector_double", 
"collector")), DTHS_90 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_0_9 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_10_19 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_20_29 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_30_39 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_40_49 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_50_59 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_60_69 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_70_79 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_80_89 = structure(list(), class = c("collector_double", 
"collector")), IP_Y_90 = structure(list(), class = c("collector_double", 
"collector")), IP_N_0_9 = structure(list(), class = c("collector_double", 
"collector")), IP_N_10_19 = structure(list(), class = c("collector_double", 
"collector")), IP_N_20_29 = structure(list(), class = c("collector_double", 
"collector")), IP_N_30_39 = structure(list(), class = c("collector_double", 
"collector")), IP_N_40_49 = structure(list(), class = c("collector_double", 
"collector")), IP_N_50_59 = structure(list(), class = c("collector_double", 
"collector")), IP_N_60_69 = structure(list(), class = c("collector_double", 
"collector")), IP_N_70_79 = structure(list(), class = c("collector_double", 
"collector")), IP_N_80_89 = structure(list(), class = c("collector_double", 
"collector")), IP_N_90 = structure(list(), class = c("collector_double", 
"collector")), IP_U_0_9 = structure(list(), class = c("collector_double", 
"collector")), IP_U_10_19 = structure(list(), class = c("collector_double", 
"collector")), IP_U_20_29 = structure(list(), class = c("collector_double", 
"collector")), IP_U_30_39 = structure(list(), class = c("collector_double", 
"collector")), IP_U_40_49 = structure(list(), class = c("collector_double", 
"collector")), IP_U_50_59 = structure(list(), class = c("collector_double", 
"collector")), IP_U_60_69 = structure(list(), class = c("collector_double", 
"collector")), IP_U_70_79 = structure(list(), class = c("collector_double", 
"collector")), IP_U_80_89 = structure(list(), class = c("collector_double", 
"collector")), IP_U_90 = structure(list(), class = c("collector_double", 
"collector")), IC_YES = structure(list(), class = c("collector_double", 
"collector")), IC_Y_0_9 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_10_19 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_20_29 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_30_39 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_40_49 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_50_59 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_60_69 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_70_79 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_80_89 = structure(list(), class = c("collector_double", 
"collector")), IC_Y_90 = structure(list(), class = c("collector_double", 
"collector")), POS_AIAN = structure(list(), class = c("collector_double", 
"collector")), POS_ASN = structure(list(), class = c("collector_double", 
"collector")), POS_BLK = structure(list(), class = c("collector_double", 
"collector")), POS_WHT = structure(list(), class = c("collector_double", 
"collector")), POS_MLTOTH = structure(list(), class = c("collector_double", 
"collector")), POS_UNK = structure(list(), class = c("collector_double", 
"collector")), POS_E_HSP = structure(list(), class = c("collector_double", 
"collector")), POS_E_NHSP = structure(list(), class = c("collector_double", 
"collector")), POS_E_UNK = structure(list(), class = c("collector_double", 
"collector")), DTH_AIAN = structure(list(), class = c("collector_double", 
"collector")), DTH_ASN = structure(list(), class = c("collector_double", 
"collector")), DTH_BLK = structure(list(), class = c("collector_double", 
"collector")), DTH_WHT = structure(list(), class = c("collector_double", 
"collector")), DTH_MLTOTH = structure(list(), class = c("collector_double", 
"collector")), DTH_UNK = structure(list(), class = c("collector_double", 
"collector")), DTH_E_HSP = structure(list(), class = c("collector_double", 
"collector")), DTH_E_NHSP = structure(list(), class = c("collector_double", 
"collector")), DTH_E_UNK = structure(list(), class = c("collector_double", 
"collector")), POS_HC_Y = structure(list(), class = c("collector_double", 
"collector")), POS_HC_N = structure(list(), class = c("collector_double", 
"collector")), POS_HC_UNK = structure(list(), class = c("collector_double", 
"collector")), DTH_NEW = structure(list(), class = c("collector_double", 
"collector")), POS_NEW = structure(list(), class = c("collector_double", 
"collector")), NEG_NEW = structure(list(), class = c("collector_double", 
"collector")), TEST_NEW = structure(list(), class = c("collector_double", 
"collector")), DATE = structure(list(), class = c("collector_character", 
"collector"))), default = structure(list(), class = c("collector_guess", 
"collector")), skip = 1), class = "col_spec")
# reading directly from the web
# https://data.dhsgis.wi.gov/datasets/covid-19-historical-data-table/data
db0 <- read_csv("https://opendata.arcgis.com/datasets/859602b5d427456f821de3830f89301c_11.csv",col_types =cols)

db <- db0 %>% 
  filter(GEOID == "55")

spec(db)

# impossible to parse the original date, which starts at 15.03.2020
date1 <- as_date("2020-03-15")
date_end <- as_date("2020-03-15") + as.numeric(count(db)-1)

# selecting variables and reshaping to long format
db2 <- db %>% 
  mutate(date_f = as_date(DATE),
         Tests = POSITIVE + NEGATIVE) %>% 
  select(date_f, POSITIVE, POS_FEM, POS_MALE, POS_0_9, POS_10_19, POS_20_29, 
         POS_30_39, POS_40_49, POS_50_59, POS_60_69, POS_70_79, 
         POS_80_89, POS_90, DEATHS, DTHS_FEM, DTHS_MALE, DTHS_0_9,
         DTHS_10_19, DTHS_20_29, DTHS_30_39, DTHS_40_49, DTHS_50_59, 
         DTHS_60_69, DTHS_70_79, DTHS_80_89, DTHS_90, Tests) %>% 
  gather(-date_f, key = var, value = Value) %>% 
  arrange(date_f) %>% 
  replace_na(list(Value = 0))

# filling age, sex, etc. (no data by age before the 29th of March)
out <- db2 %>% 
  mutate(Measure = case_when(str_sub(var, 1, 1) == "P" ~ "Cases", 
                             str_sub(var, 1, 1) == "D" ~ "Deaths", 
                             str_sub(var, 1, 1) == "T" ~ "Tests"),
         age1 = case_when(Measure == "Cases" ~ str_sub(var, 5, 6),
                         Measure == "Deaths" ~ str_sub(var, 6, 7),
                         TRUE ~ "TOT"),
         Age = case_when(age1 == "TI" | age1 == "FE" | age1 == "MA" | age1 == "S" | age1 == "TOT" ~ "TOT",
                         age1 == "0_" ~ "0",
                         TRUE ~ age1),
         AgeInt = case_when(Age == "TOT" ~ NA_real_, 
                            Age == "90" ~ 15,
                            TRUE ~ 10),
         Sex = case_when(age1 == "FE" ~ "f",
                         age1 == "MA" ~ "m",
                         TRUE ~ "b"),
         Country = "USA", 
         Region = "Wisconsin",
         Metric = "Count",
         Date = paste0(sprintf("%02d", day(date_f)), ".", sprintf("%02d", month(date_f)), year(date_f)),
         Code = paste0("US_WI_", Date)) %>% 
  filter(date_f >= as_date("2020-03-29")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))

data_source <- paste0(dir_n, 
                      "Data_sources/", 
                      ctr,
                      "/cases_deaths.csv")

write_csv(db0, data_source)

#ex_files <- c(paste0(PH_dir, files))

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")

zip::zipr(zipname,
          files = data_source, 
          recurse = TRUE, 
          compression_level = 9,
          include_directories = TRUE)

file.remove(data_source)

