
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")


data_url <- "https://cnecovid.isciii.es/covid19/resources/casos_hosp_uci_def_sexo_edad_provres.csv"


IN <- read_csv(data_url)

dim(IN)
glimpse(IN)
IN$grupo_edad %>% unique()

ES_Age <-
  IN %>% 
  select(Short = provincia_iso, 
         Sex = sexo, 
         Age = grupo_edad,
         Date = fecha,
         Cases = num_casos,
         Deaths = num_def) %>% 
  mutate(Short = ifelse(is.na(Short),"NA",Short),
    Region = recode(Short,
                      "A" = "Alicante",
                      "AB" = "Albacete",
                      "AL" = "Almeria",
                      "AV" = "Avila",
                      "B" = "Barcelona",
                      "BA" = "Badajoz",
                      "BI" = "Bizkaia",
                      "BU" = "Burgos",
                      "C" = "A Coruña",
                      "CA" = "Cadiz",
                      "CC" = "Caceres",
                      "CE" = "Ceuta",
                      "CO" = "Cordoba",
                      "CR" = "Ciudad Real",
                      "CS" = "Castellon",
                      "CU" = "Cuenca", 
                      "GC" = "Las Palmas", 
                      "GI" = "Girona", 
                      "GR" = "Granada", 
                      "GU" = "Guadalajara", 
                      "H" = "Huelva",  
                      "HU" = "Huesca",
                      "J" = "Jaen",  
                      "L" = "Lleida",  
                      "LE" = "Leon", 
                      "LO" = "La Rioja", 
                      "LU" = "Lugo", 
                      "M" = "Madrid",  
                      "MA" = "Malaga", 
                      "ME" = "Melilla", 
                      "MU" = "Murcia", 
                      "NA" = "Navarra",   
                      "O" = "Asturias",  
                      "OR" = "Ourense", 
                      "P" = "Palencia",  
                      "PM" = "Illes Balears", 
                      "PO" = "Pontevedra", 
                      "S" = "Cantabria",  
                      "SA" = "Salamanc", 
                      "SE" = "Sevilla", 
                      "SG" = "Segovia", 
                      "SO" = "Soria", 
                      "SS" = "Guipuzkoa",
                      "T" = "Tarragona",  
                      "TE" = "Teruel", 
                      "TF" = "Santa Cruz de Tenerife", 
                      "TO" = "Toledo", 
                      "V" = "Valencia",  
                      "VA" = "Valladolid", 
                      "VI" = "Araba", 
                      "Z" = "Zaragoza",  
                      "ZA" = "Zamora",
                      "NC" = "UNK"),
         Age = recode(Age,
                      "0-9" = "0",
                      "10-19" = "10",
                      "20-29" = "20",
                      "30-39" = "30",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80+" = "80",
                      "NC" = "UNK"),
         Sex = recode(Sex,
                      "H" = "m",
                      "M" = "f",
                      "NC" = "UNK"),
    Date = ddmmyyyy(Date),
    Country = "Spain",
    Code = paste("ES",Short,Date,sep="_"),
    Metric = "Count",
    AgeInt = case_when(
      Age == "80" ~ 25L,
      Age == "UNK" ~ NA_integer_,
      TRUE ~ 10L
    )) %>% 
  pivot_longer(Cases:Deaths, 
             names_to = "Measure", 
             values_to = "Value") %>% 
  mutate(date = dmy(Date)) %>% 
  arrange(Region, Sex, Measure, Age, date) %>% 
  group_by(Region, Sex, Measure, Age) %>% 
  mutate(Value = cumsum(Value)) %>% 
  # remove region-days with zero cumulative cases.
  group_by(Region, Date) %>% 
  mutate(N = sum(Value)) %>% 
  ungroup() %>% 
  filter(N > 20) %>%
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  sort_input_data() 
  
  
  

ES_Age %>% 
  filter(Region == "Madrid", 
         Measure == "Deaths") %>% 
  group_by(Date) %>% 
  summarize(Value = sum(Value)) %>% 
  ggplot(aes(x=dmy(Date),y=Value)) + geom_line()
  
  