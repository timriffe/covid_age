
# We are collecting data from this website
# https://transparencia.registrocivil.org.br

# library(httr)
source("Automation/00_Functions_automation.R")
if (!"email" %in% ls()){
  email <- "kikepaila@gmail.com"
}

# info country and N drive address
ctr <- "Brazil"
dir_n <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


dates <- seq.Date(dmy("16/03/2020"), today(), by = "day")

# if(day(today()) %in% c(4, 14, 24)){
#   dates <- seq.Date(dmy("16/03/2020"), today(), by = "day")
# }else{
#   dates <- seq.Date(today() - months(1), today(), by = "day")
# }  

headers <- c(
  `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
)

# Brazilian states
df_states <- tibble(uf = c("all", "AC", "AL", "AM", "AP",
                           "BA", "CE", "DF", "ES", 
                           "GO", "MA", "MG", "MS",
                           "MT", "PA", "PB", "PE",
                           "PI", "PR", "RJ", "RN", 
                           "RO", "RR", "RS", "SC", 
                           "SE", "SP", "TO"),
                    state = c("All", "Acre", "Alagoas", "Amazonas", "Amapá",
                              "Bahia", "Ceará", "Distrito Federal", "Espírito Santo",
                              "Goiás", "Maranhão", "Minas Gerais", "Mato Grosso do Sul",
                              "Mato Grosso", "Pará", "Paraíba", "Pernambuco", 
                              "Piauí", "Paraná", "Rio de Janeiro", "Rio Grande do Norte",
                              "Rondônia", "Roraima", "Rio Grande do Sul", "Santa Catarina",
                              "Sergipe", "São Paulo", "Tocantis"))

# df_states <- tibble(uf = c("all", "AC"),
#                     state = c("All", "Acre"))

df <- tibble()
start_time <- Sys.time()
for(i in 1:length(df_states$uf)) {
  for(j in 1:length(dates)) {
    
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
    
    raw2 <- do.call("rbind", unlist(raw_data[[1]], recursive = FALSE)) 
    
    df <- 
      df %>% 
      bind_rows(tibble(age_sex = c(row.names(raw2)),
                       new = as.numeric(raw2),
                       date = dates[j],
                       uf = df_states$uf[i]))
    cat("State: ", df_states$state[i], " Date: ", as.character(dates[j]), "\n")
  }
}
end_time <- Sys.time()
duration <- end_time - start_time 
duration

df2 <- 
  df %>% 
  mutate(age_sex = str_replace_all(age_sex, " ", ""),
         sex = str_sub(age_sex, str_length(age_sex)),
         age = str_sub(age_sex, 1, 2)) %>% 
  mutate(age = case_when(age == "<9" ~ "0",
                         age == ">1" ~ "100",
                         TRUE ~ age),
         sex = str_to_lower(sex)) %>% 
  select(-age_sex) %>% 
  tidyr::complete(uf, date, sex, age, fill = list(new = 0))

df3 <- 
  df2 %>% 
  group_by(uf, date, age) %>% 
  summarise(new = sum(new)) %>% 
  ungroup() %>% 
  mutate(sex = "b") %>% 
  bind_rows(df2 %>% 
              filter(sex != "i"))

out <- 
  df3 %>% 
  group_by(uf, sex, age) %>% 
  mutate(Value = cumsum(new)) %>%
  ungroup() %>% 
  select(-new) %>% 
  left_join(df_states) %>% 
  mutate(Code = ifelse(state == "All", "BR", paste0("BR-", uf))) %>%
  rename(Region = state,
         Sex = sex,
         Age = age,
         Date = date) %>% 
  arrange(Date, Region, Sex, suppressWarnings(as.integer(Age))) %>% 
  mutate(Country = "Brazil",
         AgeInt = ifelse(Age == "100", 5, lead(as.numeric(Age)) - as.numeric(Age)),
         Measure = "Deaths",
         Metric = "Count",
         Date = ddmmyyyy(Date)) %>% 
  sort_input_data()

############################################
#### saving database in N Drive ####
############################################
write_rds(out, paste0(dir_n, ctr, ".rds"))

# updating hydra dashboard
log_update(pp = ctr, N = nrow(out))





