
source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


# info country and N drive address
ctr    <- "SouthKorea"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/SouthKorea"

## MK: 22.09.2022: Downloading the excel CASES data file (from Korean version of website) for reference

## Source Website <- "https://ncov.kdca.go.kr/?brdId=16&brdGubun=161&dataGubun=&ncvContSeq=&contSeq=&board_id="

data_source <- paste0(dir_n, "Data_sources/", ctr, "/ExcelReferenceData/cases_",today(), ".xlsx")

#korea_url <- "http://ncov.mohw.go.kr/"
korea_url <- "http://ncov.kdca.go.kr/"

url_scrape <- read_html(korea_url) %>% 
  html_nodes("a ") %>% 
  html_attr('href')
  
cases_url <- data.frame(link = url_scrape) %>% 
  filter(str_detect(link, "download")) %>% 
  mutate(link = paste0(link)) %>%
#  mutate(link = paste0(korea_url, link)) %>% 
  dplyr::pull()


download.file(cases_url, destfile = data_source, mode = "wb")

## Cases by Age == sheet 2

Cases_Age <- read_excel(data_source, sheet = 2) %>% 
  slice(-1)

Age_names <- c("Date", "Cases_TOT", "Cases_0",
               "Cases_10", "Cases_20", "Cases_30",
               "Cases_40", "Cases_50", "Cases_60",
               "Cases_70", "Cases_80")

names(Cases_Age) <- Age_names

Cases_Age2 <- Cases_Age %>% 
  mutate(Date = as.numeric(Date),
         Date = as.Date(Date, origin = "1899-12-30"),
         across(.cols = -c("Date"), as.integer),
         across(.cols = -c("Date"), ~replace_na(., 0))) %>% 
  filter(!is.na(Date))


Cases_Ageprocessed <-  Cases_Age2 %>% 
  arrange(Date) %>% 
  pivot_longer(cols = -c(Date),
               names_to = c("Measure", "Age"),
               names_sep = "_",
               values_to = "Value") %>% 
  tidyr::complete(Age, Measure,
                  Date = seq(min(Cases_Age2$Date), max(Cases_Age2$Date), by = "day"),
                  fill = list(Value = 0)) %>% 
  pivot_wider(names_from = "Age", values_from = "Value") %>% 
  mutate(across(.cols = -c("Date", "Measure"), ~ cumsum(.x))) %>% 
  pivot_longer(cols = -c("Date", "Measure"),
               names_to = c("Age"),
               values_to = "Value") %>% 
  mutate(Metric = "Count") %>% 
  mutate(Country = "South Korea",
         Region = "All",
         Date = ddmmyyyy(Date),
         Code = paste("KR"),
         Sex = "b",
         AgeInt = case_when(Age %in% c("0", "10", "20", "30", "40", "50", "60", "70") ~ 10L,
                            Age == "80" ~ 25L),
         Value = as.numeric(Value)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>%
  sort_input_data()


## Cases by Sex (totals) == sheet 3

Cases_Sex <- read_excel(data_source, sheet = 3) %>% 
  slice(-1)


Sex_names <- c("Date", "Cases_TOT", "Cases_m",
               "Cases_f")

names(Cases_Sex) <- Sex_names

Cases_Sex2 <- Cases_Sex %>% 
  mutate(Date = as.numeric(Date),
         Date = as.Date(Date, origin = "1899-12-30"),
         across(.cols = -c("Date"), as.integer),
         across(.cols = -c("Date"), ~replace_na(., 0))) %>% 
  filter(!is.na(Date))


Cases_Sexprocessed <-  Cases_Sex2 %>% 
  arrange(Date) %>% 
  select(-Cases_TOT) %>% 
  pivot_longer(cols = -c(Date),
               names_to = c("Measure", "Sex"),
               names_sep = "_",
               values_to = "Value") %>% 
  tidyr::complete(Sex, Measure,
                  Date = seq(min(Cases_Sex2$Date), max(Cases_Sex2$Date), by = "day"),
                  fill = list(Value = 0)) %>% 
  pivot_wider(names_from = "Sex", values_from = "Value") %>% 
  mutate(across(.cols = -c("Date", "Measure"), ~ cumsum(.x))) %>% 
  pivot_longer(cols = -c("Date", "Measure"),
               names_to = c("Sex"),
               values_to = "Value") %>% 
  mutate(Metric = "Count") %>% 
  mutate(Country = "South Korea",
         Region = "All",
         Date = ddmmyyyy(Date),
         Code = paste("KR"),
         Age = "TOT",
         AgeInt = NA_integer_,
         Value = as.numeric(Value)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>%
  sort_input_data()


cases_all <- bind_rows(Cases_Ageprocessed, Cases_Sexprocessed)



# Deaths Data preparation --------------------------------------------------------
#sk_url <-"http://ncov.mohw.go.kr/en/bdBoardList.do?brdId=16&brdGubun=161&dataGubun=&ncvContSeq=&contSeq=&board_id="

sk_url <- "http://ncov.kdca.go.kr/en/bdBoardList.do?brdId=16&brdGubun=161&dataGubun=&ncvContSeq=&contSeq=&board_id="
html <-read_html(sk_url)

all_the_tables <- html %>% 
  html_table(fill = TRUE, 
             header=TRUE, 
             convert = FALSE)

# which are the respective age and gender tables?
age_table_i    <- all_the_tables %>%  
  lapply(function(X){any(X[[1]] == "0-9")}) %>% 
  unlist()

gender_table_i <- all_the_tables %>%  
  lapply(function(X){any(X[[1]] == "Male")}) %>%
  unlist()

total_cases_i <- all_the_tables %>% 
  lapply(function(x){
    all(c("Cumulative Number of Confirmed Cases","Daily New Cases") %in% colnames(x))
  }) %>% 
  unlist()

# process age table

age_original <- all_the_tables[age_table_i][[1]]

data_age <- 
  all_the_tables[age_table_i][[1]] %>% 
  mutate(`Confirmed(%)` = str_replace(`Confirmed(%)`, "\\s", "|")) %>% 
  separate(`Confirmed(%)`, into = c("Cases", NA), sep = "\\|") %>% 
  mutate(`Deaths(%)` = str_replace(`Deaths(%)`, "\\s", "|")) %>% 
  separate(`Deaths(%)`, into = c("Deaths", NA), sep = "\\|") %>% 
  mutate(Cases = str_replace_all(Cases, pattern = ",", replacement = ""),
         Deaths = str_replace_all(Deaths, pattern = ",", replacement = "")) %>% 
  select(-`Fatality rate(%)`) %>% 
  rename(Age = Category) %>% 
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  ## MK 22.09.2022: since we collect the cases data from Excel, I filtered out Cases from here ## 
  filter(Measure != "Cases") %>% 
  mutate(Age = case_when(Age == "0-9" ~ "0",
                         Age == "10-19" ~ "10",
                         Age == "20-29" ~ "20",
                         Age == "30-39" ~ "30",
                         Age == "40-49" ~ "40",
                         Age == "50-59" ~ "50",
                         Age == "60-69" ~ "60",
                         Age == "70-79" ~ "70",
                         Age == "80 years or older" ~ "80")) %>% 
  mutate(Metric = "Count") %>% 
  mutate(Country = "South Korea",
         Region = "All",
         Date = ddmmyyyy(today()),
         Code = paste("KR"),
         Sex = "b",
         AgeInt = case_when(Age %in% c("0", "10", "20", "30", "40", "50", "60", "70") ~ 10L,
                                      Age == "80" ~ 25L),
         Value = as.numeric(Value)) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  arrange(Age)

# gender totals:
# TR: for parsing Cases and Deaths I tried n ways to split on the space, and
# wasn't able to get the regex to work, so I ended up using character positions...

sex_original <- all_the_tables[gender_table_i][[1]]

sex_table <- 
all_the_tables[gender_table_i][[1]] %>% 
  rename(Sex = Category, 
         Cases = `Confirmed(%)`,
         Deaths = `Deaths(%)`) %>%
  mutate(Cases = parse_number(Cases), 
         Deaths = parse_number(Deaths)) %>% 
  # mutate(Cases = substr(Cases, 1, nchar(Cases) - 8),    # risky
  #        Deaths = substr(Deaths, 1, nchar(Deaths) - 8), # risky
  #        Cases = gsub(",", "", Cases) %>% as.numeric(),
  #        Deaths = gsub(",", "", Deaths) %>% as.numeric()) %>% 
 select(Sex, Cases, Deaths) %>% 
 pivot_longer(Cases:Deaths, 
              names_to = "Measure", 
              values_to = "Value") %>% 
  ## MK 22.09.2022: since we collect the cases data from Excel, I filtered out Cases from here ## 
 filter(Measure != "Cases") %>% 
 mutate(Sex = substr(Sex,1,1) %>% tolower(),
        Age = "TOT",
        AgeInt = NA_integer_,
        Metric = "Count",
        Date = ddmmyyyy(today()),
        Country = "South Korea",
        Region = "All",
        Code = paste("KR"))

# total_original <- all_the_tables[total_cases_i][[1]]
# 
# cases_total <-
# all_the_tables[total_cases_i][[1]] %>% 
#   select(-`Daily New Cases`) %>% 
#   mutate(Date = ymd(Date) %>% ddmmyyyy()) %>% 
#   rename(Value = `Cumulative Number of Confirmed Cases`) %>% 
#   mutate(Age = "TOT",Sex = "b",
#          Country = "South Korea",
#          Region = "All",
#          Measure = "Cases",
#          Metric = "Count",
#          Code = paste0("KR"),
#          AgeInt = NA_integer_,
#          Value = as.numeric(Value))


new_data <- bind_rows(
  data_age,
  sex_table,
  cases_all
 # cases_total
)

new_combos <- new_data %>% 
  select(Date, Sex, Age, Measure) %>% 
  distinct()

# this now pulls from N, rubric redirected
current_db <- read_rds(paste0(dir_n, ctr, ".rds")) %>% 
  filter(Measure != "Cases") #|> 
  # sounds there were some errors in Sex, Age coding in March 2023
  # mutate(Age = case_when(is.na(Age) ~ "80",
  #                        Sex == "0" ~ "0",
  #                        Sex == "1" ~ "10",
  #                        Sex == "2" ~ "20",
  #                        Sex == "3" ~ "30",
  #                        Sex == "4" ~ "40",
  #                        Sex == "5" ~ "50",
  #                        Sex == "6" ~ "60",
  #                        Sex == "7" ~ "70",
  #                        Sex == "8" ~ "80",
  #                        TRUE ~ Age),
  #        AgeInt = case_when(Age == "80" ~ 25L,
  #                           Sex == "0" ~ 10L,
  #                           Sex == "1" ~ 10L,
  #                           Sex == "2" ~ 10L,
  #                           Sex == "3" ~ 10L,
  #                           Sex == "4" ~ 10L,
  #                           Sex == "5" ~ 10L,
  #                           Sex == "6" ~ 10L,
  #                           Sex == "7" ~ 10L,
  #                           Sex == "8" ~ 25L,
  #                           TRUE ~ AgeInt),
  #        Sex = case_when(Sex %in% c("0", "1", "2", "3",
  #                                   "4", "5", "6", "7", "8") ~ "b",
  #                        TRUE ~ Sex)) |> 
  # unique()



current_combos <- current_db %>% 
  select(Date, Sex, Age, Measure) %>% 
  distinct()

current_keep <- anti_join(
                          current_combos, 
                          new_combos,
                          by = c("Date", "Sex", "Age", "Measure")) 
current_db <- inner_join(current_db, 
                         current_keep,  
                         by = c("Date", "Sex", "Age", "Measure") )
db_out <- bind_rows(current_db, new_data) %>% 
  sort_input_data()

# Data push ---------------------------------------------------------------
# ss_kr <- get_input_rubric() %>% 
#   dplyr::filter(Short == "KR") %>% 
#   dplyr::pull(Sheet)


# sheet_write(db_out, 
#             ss = ss_kr, 
#             sheet = "database")

write_rds(db_out,  paste0(dir_n, ctr, ".rds"))

log_update("SouthKorea", N = nrow(new_data))

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", "SouthKorea/",today(), ".xlsx")

data_today <- list("Age" = age_original, 
                   "Sex" = sex_original,
                   "Cases" = cases_all) 



writexl::write_xlsx(data_today, data_source)


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
