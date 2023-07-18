# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# TR New: you must be in the repo environment 
library(here)
source(here("Automation/00_Functions_automation.R"))

# info country and N drive address
ctr <- "US_Wisconsin"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

# TR: pull urls from rubric instead 
rubric_i <- get_input_rubric() %>% filter(Short == "US_WI")
ss_i     <- rubric_i %>% dplyr::pull(Sheet)
ss_db    <- rubric_i %>% dplyr::pull(Source)

## Old code ==============
#db0 <- read_csv("https://opendata.arcgis.com/datasets/859602b5d427456f821de3830f89301c_11.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D")
# 
# 														POS_CUM_CONF	POS_NEW_CONF	POS_7DAYAVG_CONF	POS_CUM_PROB	POS_NEW_PROB	POS_7DAYAVG_PROB	DTH_CUM_CONF	DTH_NEW_CONF	DTH_7DAYAVG_CONF	DTH_CONF_Daily	DTH_CUM_PROB	DTH_NEW_PROB	DTH_7DAYAVG_PROB	DTH_PROB_Daily	POS_MALE_CP	POS_FEM_CP	POS_OTH_CP	Expr1	POS_0_9_CP	POS_10_19_CP	POS_20_29_CP	POS_30_39_CP	POS_40_49_CP	POS_50_59_CP	POS_60_69_CP	POS_70_79_CP	POS_80_89_CP	POS_90_CP	DTHS_FEM_CP	DTHS_MALE_CP	DTHS_OTH_CP	DTHS_0_9_CP	DTHS_10_19_CP	DTHS_20_29_CP	DTHS_30_39_CP	DTHS_40_49_CP	DTHS_50_59_CP	DTHS_60_69_CP	DTHS_70_79_CP	DTHS_80_89_CP	DTHS_90_CP	POS_AIAN_CP	POS_ASN_CP	POS_BLK_CP	POS_WHT_CP	POS_MLTOTH_CP	POS_UNK_CP	POS_E_HSP_CP	POS_E_NHSP_CP	POS_E_UNK_CP	DTH_AIAN_CP	DTH_ASN_CP	DTH_BLK_CP	DTH_WHT_CP	DTH_MLTOTH_CP	DTH_UNK_CP	DTH_E_HSP_CP	DTH_E_NHSP_CP	DTH_E_UNK_CP	POS_HC_Y_CP	POS_HC_N_CP	POS_HC_UNK_CP	HOSP_YES_CP	HOSP_NO_CP	HOSP_UNK_CP	IP_Y_0_9_CP	IP_Y_10_19_CP	IP_Y_20_29_CP	IP_Y_30_39_CP	IP_Y_40_49_CP	IP_Y_50_59_CP	IP_Y_60_69_CP	IP_Y_70_79_CP	IP_Y_80_89_CP	IP_Y_90_CP	IP_N_0_9_CP	IP_N_10_19_CP	IP_N_20_29_CP	IP_N_30_39_CP	IP_N_40_49_CP	IP_N_50_59_CP	IP_N_60_69_CP	IP_N_70_79_CP	IP_N_80_89_CP	IP_N_90_CP	IP_U_0_9_CP	IP_U_10_19_CP	IP_U_20_29_CP	IP_U_30_39_CP	IP_U_40_49_CP	IP_U_50_59_CP	IP_U_60_69_CP	IP_U_70_79_CP	IP_U_80_89_CP	IP_U_90_CP	IC_YES_CP	IC_Y_0_9_CP	IC_Y_10_19_CP	IC_Y_20_29_CP	IC_Y_30_39_CP	IC_Y_40_49_CP	IC_Y_50_59_CP	IC_Y_60_69_CP	IC_Y_70_79_CP	IC_Y_80_89_CP	IC_Y_90_CP	Date	GEO
# cols <- structure(list(cols = list(RptDt = structure(list(), class = c("collector_double", 
# "collector")), GEOID = structure(list(), class = c("collector_double",
# "collector")), GEOName = structure(list(), class = c("collector_character",
# "collector")), POS_CUM_CP = structure(list(), class = c("collector_double", 
# "collector")), POS_NEW_CP= structure(list(), class = c("collector_double",
# "collector")), POS_7DAYAVG_CP= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), DTH_CUM_CP= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), DTH_NEW_CP= structure(list(), class = c("collector_double", 
# "collector")), DTH_7DAYAVG_CP= structure(list(), class = c("collector_double",
# "collector")), DTH_OVER_30DAYS_CP= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), DTH_CP_Daily= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), NEG_CUM= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), NEG_NEW= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), NEG_7DAYAVG= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), TESTS_CUM= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), TESTS_NEW= structure(list(), class = c("collector_double",                                                                                                            
# "collector")), TESTS_7DAYAVG= structure(list(), class = c("collector_double",                                                                                                            
#                                                                                           
#                                                                                           
# "collector")), NEGATIVE = structure(list(), class = c("collector_double", 
# "collector")), POSITIVE = structure(list(), class = c("collector_double", 
# "collector")), HOSP_YES = structure(list(), class = c("collector_double", 
# "collector")), HOSP_NO = structure(list(), class = c("collector_double", 
# "collector")), HOSP_UNK = structure(list(), class = c("collector_double", 
# "collector")), POS_FEM = structure(list(), class = c("collector_double", 
# "collector")), POS_MALE = structure(list(), class = c("collector_double", 
# "collector")), POS_OTH = structure(list(), class = c("collector_double", 
# "collector")), POS_0_9 = structure(list(), class = c("collector_double", 
# "collector")), POS_10_19 = structure(list(), class = c("collector_double", 
# "collector")), POS_20_29 = structure(list(), class = c("collector_double", 
# "collector")), POS_30_39 = structure(list(), class = c("collector_double", 
# "collector")), POS_40_49 = structure(list(), class = c("collector_double", 
# "collector")), POS_50_59 = structure(list(), class = c("collector_double", 
# "collector")), POS_60_69 = structure(list(), class = c("collector_double", 
# "collector")), POS_70_79 = structure(list(), class = c("collector_double", 
# "collector")), POS_80_89 = structure(list(), class = c("collector_double", 
# "collector")), POS_90 = structure(list(), class = c("collector_double", 
# "collector")), DEATHS = structure(list(), class = c("collector_double", 
# "collector")), DTHS_FEM = structure(list(), class = c("collector_double", 
# "collector")), DTHS_MALE = structure(list(), class = c("collector_double", 
# "collector")), DTHS_OTH = structure(list(), class = c("collector_double", 
# "collector")), DTHS_0_9 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_10_19 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_20_29 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_30_39 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_40_49 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_50_59 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_60_69 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_70_79 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_80_89 = structure(list(), class = c("collector_double", 
# "collector")), DTHS_90 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_0_9 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_10_19 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_20_29 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_30_39 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_40_49 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_50_59 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_60_69 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_70_79 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_80_89 = structure(list(), class = c("collector_double", 
# "collector")), IP_Y_90 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_0_9 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_10_19 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_20_29 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_30_39 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_40_49 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_50_59 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_60_69 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_70_79 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_80_89 = structure(list(), class = c("collector_double", 
# "collector")), IP_N_90 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_0_9 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_10_19 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_20_29 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_30_39 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_40_49 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_50_59 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_60_69 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_70_79 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_80_89 = structure(list(), class = c("collector_double", 
# "collector")), IP_U_90 = structure(list(), class = c("collector_double", 
# "collector")), IC_YES = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_0_9 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_10_19 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_20_29 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_30_39 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_40_49 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_50_59 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_60_69 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_70_79 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_80_89 = structure(list(), class = c("collector_double", 
# "collector")), IC_Y_90 = structure(list(), class = c("collector_double", 
# "collector")), POS_AIAN = structure(list(), class = c("collector_double", 
# "collector")), POS_ASN = structure(list(), class = c("collector_double", 
# "collector")), POS_BLK = structure(list(), class = c("collector_double", 
# "collector")), POS_WHT = structure(list(), class = c("collector_double", 
# "collector")), POS_MLTOTH = structure(list(), class = c("collector_double", 
# "collector")), POS_UNK = structure(list(), class = c("collector_double", 
# "collector")), POS_E_HSP = structure(list(), class = c("collector_double", 
# "collector")), POS_E_NHSP = structure(list(), class = c("collector_double", 
# "collector")), POS_E_UNK = structure(list(), class = c("collector_double", 
# "collector")), DTH_AIAN = structure(list(), class = c("collector_double", 
# "collector")), DTH_ASN = structure(list(), class = c("collector_double", 
# "collector")), DTH_BLK = structure(list(), class = c("collector_double", 
# "collector")), DTH_WHT = structure(list(), class = c("collector_double", 
# "collector")), DTH_MLTOTH = structure(list(), class = c("collector_double", 
# "collector")), DTH_UNK = structure(list(), class = c("collector_double", 
# "collector")), DTH_E_HSP = structure(list(), class = c("collector_double", 
# "collector")), DTH_E_NHSP = structure(list(), class = c("collector_double", 
# "collector")), DTH_E_UNK = structure(list(), class = c("collector_double", 
# "collector")), POS_HC_Y = structure(list(), class = c("collector_double", 
# "collector")), POS_HC_N = structure(list(), class = c("collector_double", 
# "collector")), POS_HC_UNK = structure(list(), class = c("collector_double", 
# "collector")), DTH_NEW = structure(list(), class = c("collector_double", 
# "collector")), POS_NEW = structure(list(), class = c("collector_double", 
# "collector")), NEG_NEW = structure(list(), class = c("collector_double", 
# "collector")), TEST_NEW = structure(list(), class = c("collector_double", 
# "collector")), DATE = structure(list(), class = c("collector_character", 
# "collector"))), default = structure(list(), class = c("collector_guess", 
# "collector")), skip = 1), class = "col_spec")
# reading directly from the web
# https://data.dhsgis.wi.gov/datasets/covid-19-historical-data-table/data


## Reading the data ===========

db0 <- read_csv("https://opendata.arcgis.com/api/v3/datasets/531828fa923c490c8f1895db13d0040e_11/downloads/data?format=csv&spatialRefId=3857")

# db <- db0 %>% 
#   filter(GEOID == "55")
# 
# spec(db)
db <- db0 %>% 
  select(RptDt, POS_CUM_CP, TESTS_CUM, POS_FEM_CP, POS_MALE_CP, POS_0_9_CP, POS_10_19_CP, POS_20_29_CP, 
         POS_30_39_CP, POS_40_49_CP, POS_50_59_CP, POS_60_69_CP, POS_70_79_CP, 
         POS_80_89_CP, POS_90_CP)
db <- db %>% 
  pivot_longer(cols = -c("RptDt"),
               names_to = "variable",
               values_to = "Value")
db_out <- db %>% 
  mutate(Age = case_when(
    variable == "POS_CUM_CP" ~ "TOT",    
    variable == "TESTS_CUM" ~ "TOT",    
    variable == "POS_FEM_CP" ~ "TOT",   
    variable == "POS_MALE_CP" ~ "TOT",    
    variable == "POS_0_9_CP" ~ "0",  
    variable == "POS_10_19_CP" ~ "10",  
    variable == "POS_20_29_CP" ~ "20",  
    variable == "POS_30_39_CP" ~ "30", 
    variable == "POS_40_49_CP" ~ "40",  
    variable == "POS_50_59_CP" ~ "50",  
    variable == "POS_60_69_CP" ~ "60",  
    variable == "POS_70_79_CP" ~ "70",  
    variable == "POS_80_89_CP" ~ "80",     
    variable == "POS_90_CP" ~ "90"), 
    Measure = case_when(
      variable == "POS_CUM_CP" ~ "Cases",    
      variable == "TESTS_CUM" ~ "Tests",    
      variable == "POS_FEM_CP" ~ "Cases",   
      variable == "POS_MALE_CP" ~ "Cases",    
      variable == "POS_0_9_CP" ~ "Cases",  
      variable == "POS_10_19_CP" ~ "Cases",  
      variable == "POS_20_29_CP" ~ "Cases",  
      variable == "POS_30_39_CP" ~ "Cases", 
      variable == "POS_40_49_CP" ~ "Cases",  
      variable == "POS_50_59_CP" ~ "Cases",  
      variable == "POS_60_69_CP" ~ "Cases",  
      variable == "POS_70_79_CP" ~ "Cases",  
      variable == "POS_80_89_CP" ~ "Cases",     
      variable == "POS_90_CP" ~ "Cases"),
    Sex = case_when(
      variable == "POS_CUM_CP" ~ "b",    
      variable == "TESTS_CUM" ~ "b",    
      variable == "POS_FEM_CP" ~ "f",   
      variable == "POS_MALE_CP" ~ "m",    
      variable == "POS_0_9_CP" ~ "b",  
      variable == "POS_10_19_CP" ~ "b",  
      variable == "POS_20_29_CP" ~ "b",  
      variable == "POS_30_39_CP" ~ "b", 
      variable == "POS_40_49_CP" ~ "b",  
      variable == "POS_50_59_CP" ~ "b",  
      variable == "POS_60_69_CP" ~ "b",  
      variable == "POS_70_79_CP" ~ "b",  
      variable == "POS_80_89_CP" ~ "b",     
      variable == "POS_90_CP" ~ "b"),
    AgeInt = case_when(
      Age == "0" ~ 10L,
      Age == "10" ~ 10L,
      Age == "20" ~ 10L,
      Age == "30" ~ 10L,
      Age == "40" ~ 10L,
      Age == "50" ~ 10L,
      Age == "60" ~ 10L,
      Age == "70" ~ 10L,
      Age == "80" ~ 10L,
      Age == "90" ~ 15L
    ),
    Metric = "Count",
    Country = "USA",
    Region = "Wisconsin"
    ) %>% 
  filter(Measure == "Tests")
db_out$Date <- substr(db_out$RptDt, 1, nchar(db_out$RptDt)-12)
db_out <- db_out[-c(1, 2)]
names(db_out)[1] <- "Value"
db_out2 <- db_out %>% 
  mutate(Date = ymd(Date),
Date = paste(sprintf("%02d",day(Date)),    
             sprintf("%02d",month(Date)),  
             year(Date),sep="."),
Code = paste0("US-WI"))%>% 
  sort_input_data()

## Old code ===============

# impossible to parse the original date, which starts at 15.03.2020
# date1 <- as_date("2020-03-15")
# date_end <- as_date("2020-03-15") + as.numeric(count(db)-1)

# selecting variables and reshaping to long format
# db2 <- db %>% 
#   mutate(date_f = as_date(DATE),
#          Tests = POSITIVE + NEGATIVE) %>% 
#   date_f, POSITIVE, POS_FEM, POS_MALE, POS_0_9, POS_10_19, POS_20_29, 
#          POS_30_39, POS_40_49, POS_50_59, POS_60_69, POS_70_79, 
#          POS_80_89, POS_90, DEATHS, DTHS_FEM, DTHS_MALE, DTHS_0_9,
#          DTHS_10_19, DTHS_20_29, DTHS_30_39, DTHS_40_49, DTHS_50_59, 
#          DTHS_60_69, DTHS_70_79, DTHS_80_89, DTHS_90, Tests) %>% 
#   gather(-date_f, key = var, value = Value) %>% 
#   arrange(date_f) %>% 
#   replace_na(list(Value = 0))

# filling age, sex, etc. (no data by age before the 29th of March)
# out <- db2 %>% 
#   mutate(Measure = case_when(str_sub(var, 1, 1) == "P" ~ "Cases", 
#                              str_sub(var, 1, 1) == "D" ~ "Deaths", 
#                              str_sub(var, 1, 1) == "T" ~ "Tests"),
#          age1 = case_when(Measure == "Cases" ~ str_sub(var, 5, 6),
#                          Measure == "Deaths" ~ str_sub(var, 6, 7),
#                          TRUE ~ "TOT"),
#          Age = case_when(age1 == "TI" | age1 == "FE" | age1 == "MA" | age1 == "S" | age1 == "TOT" ~ "TOT",
#                          age1 == "0_" ~ "0",
#                          TRUE ~ age1),
#          AgeInt = case_when(Age == "TOT" ~ NA_real_, 
#                             Age == "90" ~ 15,
#                             TRUE ~ 10),
#          Sex = case_when(age1 == "FE" ~ "f",
#                          age1 == "MA" ~ "m",
#                          TRUE ~ "b"),
#          Country = "USA", 
#          Region = "Wisconsin",
#          Metric = "Count",
#          Date = ddmmyyyy(date_f),
#          Code = paste0("US_WI_", Date)) %>% 
#   filter(date_f >= as_date("2020-03-29")) %>% 
#   sort_input_data()

############################################
#### saving database in N Drive ####
############################################
write_rds(db_out2, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
#log_update(pp = ctr, N = nrow(db_out2))

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

