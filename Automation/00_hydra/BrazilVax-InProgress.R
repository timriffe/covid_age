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


## List the downloaded files 

vax.list <-list.files(
  path= paste0(dir_n, ctr),
  pattern = ".csv",
  full.names = TRUE)

vax_files <- data.frame(path = vax.list) %>% 
  mutate(number = row_number(),
         file_rds = paste0("BrazilVAX-Part", number))


## EXAMPLE ##

# data <- data.table::fread("N:/COVerAGE-DB/Automation/Hydra/Data_sources/Brazil/part-00000-7dd36c4d-562b-4f07-9ada-356ce3d5b157-c000.csv",
#                           select = c("vacina_dataAplicacao",
#                                      "paciente_idade",
#                                      "paciente_enumSexoBiologico",
#                                      "paciente_endereco_nmMunicipio",
#                                      "vacina_descricao_dose"))
# 
# data %>% count(vacina_descricao_dose)



## Loop to read each file from the path column in dataframe and write rds file for each,

vax_files %>% 
  {map2(.$path, .$file_rds, 
        function(x,y) fread(x, select = c("vacina_dataAplicacao",
                                          "paciente_idade",
                                          "paciente_enumSexoBiologico", 
                                          "paciente_endereco_nmMunicipio", 
                                          "vacina_descricao_dose")) %>% 
                              write_rds(paste0(dir_n, ctr, "/", y, ".rds")))}

## read the .rds files and bind in one dataset 

rds_files <- list.files(
  path= paste0(dir_n, ctr),
  pattern = ".rds",
  full.names = TRUE)

raw_data <- rds_files %>% 
  map_dfr(read_rds)


## also read the coding for doses == this file I made by translating the unique values using Google

vax_code <- read_excel(paste0(dir_n, ctr,"/BrazilVaxCoding.xlsx"), sheet = "Coding")

## process the data 

processed_data <- raw_data %>% 
  dplyr::rename(Date = vacina_dataAplicacao,
                Age = paciente_idade,
                Sex = paciente_enumSexoBiologico,
                Region = paciente_endereco_nmMunicipio,
                Original_dose = vacina_descricao_dose) %>% 
  dplyr::left_join(vax_code, by = c("Original_dose" = "Original")) %>% 
  dplyr::select(-Original_dose) %>% 
  dplyr::mutate(Sex = case_when(Sex == "M" ~ "m",
                                Sex == "F" ~ "f",
                                TRUE ~ "UNK"),
                Age = as.double(Age),
                Age = if_else(Age > 105, 105, Age),
               # Age = if_else(Age = NA, "UNK", Age),
                # Age = case_when(Age > 105 ~ 105,
                #                 Age < 0 ~ "UNK",
                #                 is.na(Age) ~ "UNK",
                #                 TRUE ~ Age),
                Date = ymd(Date))

x%>% 
  dplyr::group_by(Date, Age, Region, Sex, Dose) %>% 
  summarize(Value = n(), .groups = "drop")%>%
  tidyr::complete(Date, Sex, Age, Region, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, Region, Date) %>% 
  group_by(Sex, Age, Region, Dose) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()
                
raw_data %>% count(paciente_idade) %>% View()



