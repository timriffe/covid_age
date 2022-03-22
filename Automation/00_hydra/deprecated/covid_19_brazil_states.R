
# We are collecting data from this website
# https://transparencia.registrocivil.org.br

# Library -----------------------------------------------------------------

library(httr)
library(tidyverse)
library(lubridate)
library(googlesheets4)

# Collecting --------------------------------------------------------------

# deaths that happenened in Brazil from Covid-19
# grouped by age (10 years group), gender and state.
# 
# this is an example
# "https://transparencia.registrocivil.org.br/api/covid?data_type=data_ocorrido&start_date=2020-01-01&end_date=2020-04-30&state=Todos&search=death-covid&groupBy=gender"
# but, for now we need a token to request the data

# getting the needed token

# AUTOMATIC
# login
# login_url <- "https://transparencia.registrocivil.org.br/registral-covid"
# Start with a fresh handle
# h <- curl::new_handle()
# Ask server
# request <- curl::curl_fetch_memory(login_url, handle = h)
# https://cran.r-project.org/web/packages/curl/vignettes/intro.html#reading_cookies
# cookies <- curl::handle_cookies(h)
# we need the "XRSF-TOKEN"
# token <- cookies$value[which(cookies$name == "XSRF-TOKEN")]

# MANUAL
# this token is correct
token <- "eyJpdiI6IjRlZzAwdEx2UzZZbUhWRk1STHNDU1E9PSIsInZhbHVlIjoiZWFONFE4U2tnRkZ4XC92amduaGRseDZrU3JuMldRNW0xUkZZOVRsUVlTUjlRWmVwNkVDSGdIbTF1WnQzOWVRZEUiLCJtYWMiOiIxMDhlNDBjNWY1YzdmMjY3ZjE2NzFjMGIwMDAxZjAwNDA1ZTM4M2YxYTkwZmJhYjFiOTA5ZDYyMzk4NTBlY2MyIn0="
# so, we need to iterate through only dates to get our data:
# number of daily deaths by gender, age group (10 years) and state
# since the first death in Brazil
current_day <- Sys.Date()
dates <- seq.Date(dmy("16/03/2020"), current_day, by = "day")

# curl into httr:
# https://curl.trillworks.com/#r
headers <- c(
  # `X-XSRF-TOKEN` = token,
  # dont know if it is a private info
  `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
)

list_date <- list()
list_age <- list()
list_gender <- list()
list_death <- list()

# Brazilian states
df_states <- tibble(uf = c("AC", "AL", "AM", "AP",
                           "BA", "CE", "DF", "ES", 
                           "GO", "MA", "MG", "MS",
                           "MT", "PA", "PB", "PE",
                           "PI", "PR", "RJ", "RN", 
                           "RO", "RR", "RS", "SC", 
                           "SE", "SP", "TO"),
                    state = c("Acre", "Alagoas", "Amazonas", "Amapá",
                              "Bahia", "Ceará", "Distrito Federal", "Espírito Santo",
                              "Goiás", "Maranhão", "Minas Gerais", "Mato Grosso do Sul",
                              "Mato Grosso", "Pará", "Paraíba", "Pernambuco", 
                              "Piauí", "Paraná", "Rio de Janeiro", "Rio Grande do Norte",
                              "Rondônia", "Roraima", "Rio Grande do Sul", "Santa Catarina",
                              "Sergipe", "São Paulo", "Tocantis"))
install.packages("tictoc")
library(tictoc)
df <- tibble()
# i <- 3
# j <- 500
# k <- 8
# m <- 1
start_time <- Sys.time()
tic()
# for(i in 1:length(df_states$uf)) {
#   for(j in 1:length(dates)) {
for(i in 1:1) {
  for(j in 1:100) {
    
    # curl into httr
    # https://curl.trillworks.com/#r
    params <- list(
      `chart` = 'chartEspecial4',
      `data_type` = 'data_ocorrido',
      # we retrieving data day by day
      `start_date` = dates[j],
      `end_date` = dates[j],
      `state` = df_states$uf[i],
      `search` = 'death-covid',
      `causa` = 'insuficiencia_respiratoria',
      `groupBy` = 'gender'
    )
    
    response <- httr::GET(url = 'https://transparencia.registrocivil.org.br/api/covid', 
                          httr::add_headers(.headers=headers), 
                          query = params)
    
    raw_data <- httr::content(response)
    age_groups <- names(raw_data["chart"][[1]])
    
    for(k in 1:length(age_groups)) {
      
      genders <- names(raw_data["chart"][[1]][[k]])
      
      if(length(genders) != 0) {
        for(m in 1:length(genders)) {
          list_date <- append(list_date, as.character(dates[j]))
          list_age <- append(list_age, age_groups[k])
          list_gender <- append(list_gender, genders[m])
          
          # j: age group
          # k: gender F or M
          deaths <- raw_data["chart"][[1]][k][[1]][[m]]
          list_death <- append(list_death, deaths)
        }
      } 
    }
    
    df_temp <- tibble(list_date, list_age, list_gender, list_death) %>% 
      unnest(cols = c(list_date, list_age, list_gender, list_death)) %>% 
      mutate(state = df_states$state[i],
             uf = df_states$uf[i],
             list_date = as.character(list_date),
             list_age = as.character(list_age),
             list_gender = as.character(list_gender),
             list_death = as.integer(list_death))
    
    list_date <- list()
    list_age <- list()
    list_gender <- list()
    list_death <- list()
    
    df <- df %>% 
      bind_rows(df_temp)
    
    # Pause for 0.1 seconds
    Sys.sleep(0.5)
    
    cat("i: ", i, " j: ", j, "\n")
  }
}

end_time <- Sys.time()
duration <- end_time - start_time

# All combinations dataset ------------------------------------------------

# we create an all combinations dataset
# in order to proper make a daily accumulated 
# deaths dataset

df_combinations <- purrr::cross_df(
  .l = list(
    "uf" = df_states %>% select(uf) %>% unique() %>% pull(),
    "Date" = df %>% select(list_date) %>% unique() %>% pull(),
    "Sex" = df %>% select(list_gender) %>% unique() %>% pull(),
    "Age" = df %>% select(list_age) %>% unique() %>% pull())
)

df_combinations <- df_combinations %>% 
  mutate(Date = lubridate::as_date(Date))

# Output ------------------------------------------------------------------

# daily deaths
df_output <- df_combinations %>% 
  left_join(df %>% select(-state) %>% mutate(list_date = lubridate::as_date(list_date)), 
            by = c("uf" = "uf",
                   "Date" = "list_date", 
                   "Age" = "list_age", 
                   "Sex" = "list_gender")) %>% 
  mutate(Value = ifelse(is.na(list_death), 0, list_death)) %>% 
  left_join(df_states, by = c("uf")) %>% 
  select(-list_death)

# treating cases reported with gender 'I'  (ignored)
# create a category 'B' (both genders) that includes
# 'F', 'M', and 'I'
df_output <- df_output %>% 
  filter(Sex != "I") %>% 
  bind_rows(
    df_output %>%
      group_by(uf, state, Date, Age) %>% 
      summarise(Value = sum(Value)) %>% 
      mutate(Sex = "B") %>% 
      ungroup()
  )

# daily deaths accumulated
df_output_accumulated <-  df_output %>%
  arrange(uf, Sex, Age, Date) %>% 
  group_by(uf, state, Sex, Age) %>% 
  mutate(Value_accumulated = cumsum(Value))

# Fixing columns ----------------------------------------------------------

# daily deaths accumulated
df_output_accumulated <- df_output_accumulated %>% 
  ungroup() %>% 
  mutate(Age = case_when(
    Age == "< 9" ~ "0",
    Age == "> 100" ~ "100",
    TRUE ~ str_extract(Age, pattern = "^\\d{2}"))
  ) %>% 
  mutate(Age = as.integer(Age)) %>% 
  arrange(Date, Sex, Age) %>% 
  separate(col = Date, into = c("year", "month", "day"), sep = "-", remove = FALSE) %>% 
  unite(col = Date, c("day", "month", "year"), sep = ".", remove = TRUE) %>% 
  mutate(Sex = case_when(
    Sex == "F" ~ "f",
    Sex == "M" ~ "m",
    Sex == "B" ~ "b")) %>% 
  mutate(Country = "Brazil",
         AgeInt = ifelse(Age == "100", 5, 10),
         Metric = "Count",
         Measure = "Deaths",
         Code = paste0("BR_", uf, Date))

df_output_accumulated <- df_output_accumulated %>% 
  select(Country, Region = state, Code, Date,
         Sex, Age, AgeInt, Metric, Measure,
         Value = Value_accumulated)

# Writing - Function ------------------------------------------------------

region_vec <- df_output_accumulated %>% 
  pull(Region) %>% 
  unique()

sheets_link <- c("https://docs.google.com/spreadsheets/d/1mE7DUe96SxRA2nDTZePdTEGDh801WsU_d-mOA_4iSDY/edit?ts=602aa544#gid=0",
                 "https://docs.google.com/spreadsheets/d/1j185PhoBuXmUW3ZKGqh3_2kcaolyEggChAfNi8cpkKQ/edit?ts=604f10a6#gid=0",
                 "https://docs.google.com/spreadsheets/d/1p4IkI713sHHW6eU_v18bI6YHcVdfRHYkJKIoFIU69wM/edit?ts=5ecbc7ba#gid=0",
                 "https://docs.google.com/spreadsheets/d/1R2qFWFkmM0SsaV0ArebzcPEIwtCec55XEuSu3K9eR_Y/edit?ts=602b7495#gid=0",
                 "https://docs.google.com/spreadsheets/d/1cyEG0VDO0ziS-k_iiEA65WWXeGCwWnEaqQKIOhLYYBY/edit?ts=602b74a0#gid=0",
                 "https://docs.google.com/spreadsheets/d/1ryQlSSFMnR77a_ndQc03flUm4yzZOWqcnCq4sZPd5bs/edit?ts=602b74aa#gid=0",
                 "https://docs.google.com/spreadsheets/d/1_UEdoR6DwMjT1A4hc-Ldhwk5uFr1o1QbDhLTXhrgMsU/edit?ts=602b74ba#gid=0",
                 "https://docs.google.com/spreadsheets/d/1O176SzDuQf22y4unIaXVAdW8GbC42z2k7xt4DRhwaVk/edit?ts=602b74c4#gid=0",
                 "https://docs.google.com/spreadsheets/d/1EzAvnikKl-i0Vl7uzE8rzgW0uMuKEv7ojRIXC4xlYsw/edit?ts=602b74ce#gid=0",
                 "https://docs.google.com/spreadsheets/d/1ErFLT3sq6aWpkHEqMVXCZuOh1pCmxxeydwMsE1GZu_s/edit?ts=602b74d8#gid=0",
                 "https://docs.google.com/spreadsheets/d/1wTCB5Z4OTqSJ2mmnfzWBfIsR-VvcM8yhfnB3BIIaCK8/edit?ts=5ecbc7cf",
                 "https://docs.google.com/spreadsheets/d/1JE8b_wOhA-sgswCWYgZKVIGVUwTT1uzj9iXH1udahp8/edit?ts=602b74e4#gid=0",
                 "https://docs.google.com/spreadsheets/d/1EqEnXjfbupQnK1dzRnDDPk4M2lQ8ImeMC8qemIC2Uqw/edit?ts=602b74f0#gid=0",
                 "https://docs.google.com/spreadsheets/d/1ZBBz1lO8a-iBL906BmoNDeY18AHWIPTmhf65R7SJ9VU/edit?ts=602b74f9#gid=0",
                 "https://docs.google.com/spreadsheets/d/1id0DDmBRXUQ7DkR6SqCPswkt-neZqBt5jjqi3ENBkdo/edit?ts=602b7503#gid=0",
                 "https://docs.google.com/spreadsheets/d/1O9-pNt8hnxWPoForCvmT0XVEiH6kOtYNgmBvUZ_Bj84/edit?ts=602b750e#gid=0",
                 "https://docs.google.com/spreadsheets/d/142FgWd9Ugb1ljmOnCJ0wmRYLMFRBvn_MokUGybkQHN4/edit?ts=602b7518#gid=0",
                 "https://docs.google.com/spreadsheets/d/19NdXWeHRnuHqrRfvgxuvBSum4oNyHCBgeCBazE8-cQw/edit?ts=602b7521#gid=0",
                 "https://docs.google.com/spreadsheets/d/1jzaO8p3h8m6H-APYQxU_Ggwk4XjzkH8sRtYN0i-l3iE/edit?ts=5ecbc7e6#gid=1079196673",
                 "https://docs.google.com/spreadsheets/d/1KPyfQ_j5zwsi_E009hS5Q6UlsFCqkVRiAd-12cubU7M/edit?ts=602b752b#gid=0",
                 "https://docs.google.com/spreadsheets/d/1mUzsJHfGbwXWX_K41TLUqKO1gzhSYHDx3om1nt8gJpE/edit?ts=602b7535#gid=0",
                 "https://docs.google.com/spreadsheets/d/1yaLBgFQyGNpF1xtQuDCRgibVDkDFN5RSdtT50_6PccQ/edit?ts=602b753f#gid=0",
                 "https://docs.google.com/spreadsheets/d/1gnt97pyA5CrcuLPeMWZKFyH6UHDcgP9f2is1x6uAX-A/edit?usp=sharing_eil&ts=5ecbc7f8&urp=gmail_link",
                 "https://docs.google.com/spreadsheets/d/1pP8vUl3Df9z6OIblrXJInxE-vK-vLoLeNG-lgHqasvw/edit?ts=602b754a#gid=0",
                 "https://docs.google.com/spreadsheets/d/1grUXhcbKBhgszBbdCA67-AypnmuIyeCJCdZ92w6C0B8/edit?ts=602b7556#gid=0",
                 "https://docs.google.com/spreadsheets/d/1xfV80Pk52ThcDrW7tzj4ku50ahs-nnG-LVDZkQLUZw4/edit?ts=602b7560#gid=0",
                 "https://docs.google.com/spreadsheets/d/1JzviN3ByS1106NdLdFnaADinYKMcSsinC4hxiwyR1iQ/edit?ts=602b7569#gid=0")

write_in_sheets <- function(df, region, sheet_link) {
  
  # this join is intended to produce a data frame
  # of deaths in a particular state starting 
  # in the first death recorded in that state, and not
  # in Brazil
  df_out <- df %>% 
    filter(Region == region) %>% 
    semi_join(
      df %>% 
        filter(Region == region) %>% 
        group_by(Date) %>% 
        summarise(Value = sum(Value)) %>% 
        filter(Value > 0),
      by = c("Date"))
  
  # daily deaths accumulated
  # writing in google sheets
  sheet_write(df_out, 
              ss = sheet_link, 
              sheet = "database")
}

for(i in 1:length(region_vec)) {
  cat("região: ", region_vec[i], "\n")
  write_in_sheets(df = df_output_accumulated,
                  region = region_vec[i],
                  sheet_link = sheets_link[i])
}
