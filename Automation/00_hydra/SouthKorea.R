
source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}
# Drive credentials
drive_auth(email = email)
gs4_auth(email = email)

# info country and N drive address
ctr    <- "SouthKorea"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/SouthKorea"


# Data preparation --------------------------------------------------------
sk_url <-"http://ncov.mohw.go.kr/en/bdBoardList.do?brdId=16&brdGubun=161&dataGubun=&ncvContSeq=&contSeq=&board_id="

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
data_age <- 
  all_the_tables[age_table_i][[1]] %>% 
  mutate(`Confirmed(%)` = str_replace(`Confirmed(%)`, "\\s", "|")) %>% 
  separate(`Confirmed(%)`, into = c("Cases", NA), sep = "\\|") %>% 
  mutate(`Deaths(%)` = str_replace(`Deaths(%)`, "\\s", "|")) %>% 
  separate(`Deaths(%)`, into = c("Deaths", NA), sep = "\\|") %>% 
  mutate(Cases = str_replace(Cases, pattern = ",", replacement = ""),
         Deaths = str_replace(Deaths, pattern = ",", replacement = "") ) %>% 
  select(-`Fatality rate(%)`) %>% 
  rename(Age = Category) %>% 
  pivot_longer(Cases:Deaths, names_to = "Measure", values_to = "Value") %>% 
  mutate(Age = case_when(Age == "0-9" ~ "0",
                         Age == "10-19" ~ "10",
                         Age == "20-29" ~ "20",
                         Age == "30-39" ~ "30",
                         Age == "40-49" ~ "40",
                         Age == "50-59" ~ "50",
                         Age == "60-69" ~ "60",
                         Age == "70-79" ~ "70",
                         Age == "80yearsorolder" ~ "80")) %>% 
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
sex_table <- 
all_the_tables[gender_table_i][[1]] %>% 
  rename(Sex = Category, 
         Cases = `Confirmed(%)`,
         Deaths = `Deaths(%)`) %>%
  mutate(Cases = substr(Cases, 1, nchar(Cases) - 8),    # risky
         Deaths = substr(Deaths, 1, nchar(Deaths) - 8), # risky
         Cases = gsub(",", "", Cases) %>% as.numeric(),
         Deaths = gsub(",", "", Deaths) %>% as.numeric()) %>% 
 select(Sex, Cases, Deaths) %>% 
 pivot_longer(Cases:Deaths, 
              names_to = "Measure", 
              values_to = "Value") %>% 
 mutate(Sex = substr(Sex,1,1) %>% tolower(),
        Age = "TOT",
        AgeInt = NA_integer_,
        Metric = "Count",
        Date = ddmmyyyy(today()),
        Country = "South Korea",
        Region = "All",
        Code = paste("KR"))
  
cases_total <-
all_the_tables[total_cases_i][[1]] %>% 
  select(-`Daily New Cases`) %>% 
  mutate(Date = ymd(Date) %>% ddmmyyyy()) %>% 
  rename(Value = `Cumulative Number of Confirmed Cases`) %>% 
  mutate(Age = "TOT",Sex = "b",
         Country = "South Korea",
         Region = "All",
         Measure = "Cases",
         Metric = "Count",
         Code = paste0("KR"),
         AgeInt = NA_integer_,
         Value = as.numeric(Value))


new_data <- bind_rows(
  data_age,
  sex_table,
  cases_total
)

new_combos <- new_data %>% 
  select(Date, Sex, Age, Measure) %>% 
  distinct()

# this now pulls from N, rubric redirected
current_db <- read_rds(paste0(dir_n, ctr, ".rds"))

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

data_source <- paste0(dir_n, "Data_sources/", ctr,today(), ".csv")

write_csv(new_data, data_source)


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
