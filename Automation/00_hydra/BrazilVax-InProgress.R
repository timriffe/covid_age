## BRAZIL VACCINATION DATA
## written by: Manal Kamal

source(here::here("Automation/00_Functions_automation.R"))

# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "mumanal.k@gmail.com"
}

# info country and N drive address
ctr          <- "Brazil" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/Data_sources/"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

#data1 <- fread("https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SIPNI/COVID/completo/part-00000-84966b70-9aca-47ea-8272-b79fc0c4d25c-c000.csv")

# 
# ## API
# 
# url <- "https://imunizacao-es.saude.gov.br/_search?scroll=1m"
#   
# user_url <- "immuncao_public"
# 
# pass_url <- "qlto5t&7r_@+#Tlstigi"
#   
# req <- GET(url, 
#            authenticate(user_url, pass_url, type = "basic"),
#            add_headers())
# 
# weboutput <- content(req)

vax.list <-list.files(
  path= paste0(dir_n, ctr),
  pattern = ".csv",
  full.names = TRUE)

vax_files <- data.frame(paths = vax.list) 

## read into dataframe with adding Date of each file

vax_df <- vax.list %>% 
  map_df(~fread(.))















