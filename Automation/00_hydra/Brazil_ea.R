
# We are collecting data from this website
# https://transparencia.registrocivil.org.br

# Library -----------------------------------------------------------------

library(httr)
library(tidyverse)
library(lubridate)

current_day <- Sys.Date()
dates <- seq.Date(dmy("16/03/2020"), current_day, by = "day")

headers <- c(
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

df <- tibble()
start_time <- Sys.time()
for(i in 1:1) {
# for(i in 1:length(df_states$uf)) {
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
    
    raw2 <- do.call("rbind", unlist(raw_data[[1]], recursive = FALSE)) 
    
    df <- 
      df %>% 
      bind_rows(tibble(age_sex = c(row.names(raw2)),
                       dts = as.numeric(raw2),
                       date = dates[j],
                       state = df_states$uf[i]))
    cat("i: ", i, " j: ", j, "\n")
  }
}
end_time <- Sys.time()
duration <- end_time - start_time 
duration
df2 <- 
  df %>% 
  mutate(age_sex = str_replace_all(age_sex, " ", ""),
         test = str_length(age_sex),
         sex = str_sub(age_sex, str_length(age_sex)),
         age = str_sub(age_sex, 1, 2),
         age = recode(age,
                      "<9" = "0",
                      ">1" = "100"))

    
    
    
    
    