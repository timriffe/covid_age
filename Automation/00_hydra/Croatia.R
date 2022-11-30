source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
# This is just to get the Croatia script started.
# install.packages("rjson")
library(rjson)
library(tidyverse)

calcAgeAbr <- function(Age){
  stopifnot(is.integer(Age))
  Abr <- Age - Age%%5
  Abr[Age %in% 1:4] <- 1
  Abr
}
# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "tim.riffe@gmail.com"
}

# info country and N drive address

ctr          <- "Croatia" # it's a placeholder
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"

# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))


#N:\COVerAGE-DB\Automation\Hydra\Data_sources\Croatia
jtext <- httr::content(GET("https://www.koronavirus.hr/json/?action=po_osobama"), 
                       as = "text", encoding = "UTF-8")

# MK: Seems since June 2022, the following link is not working, no data there. 
# jtext <- httr::content(GET( "https://www.koronavirus.hr/po_danima_zupanijama"), 
#                        as = "text", encoding = "UTF-8")
IN_json <- rjson::fromJSON(jtext)
IN <- dplyr::bind_rows(IN_json) 
# IN2 <- IN %>%   
# mutate(Zupanija = trimws(Zupanija, "r"),
#          Zupanija = iconv(Zupanija, from = "UTF-8", to = "ASCII//TRANSLIT"))
# 
# 
# 
# Regions <- tibble(Zupanija = c("Bjelovarsko-bilogorska", "Brodsko-posavska", "Dubrovacko-neretvanska", 
#                                "Grad Zagreb", "Istarska", "Karlovacka", "Koprivnicko-krizevacka", 
#                                "Krapinsko-zagorska", "Licko-senjska", "Medimurska", "Osjecko-baranjska", 
#                                "Pozesko-slavonska", "Primorsko-goranska", "Sibensko-kninska", 
#                                "Sisacko-moslavacka", "Splitsko-dalmatinska", "Varazdinska", 
#                                "Viroviticko-podravska", "Vukovarsko-srijemska", "Zadarska", 
#                                "Zagrebacka"),
# RegionCode = c("-07","-12","-19","-21","-18","-04","-06","-02",
#                "-09","-20","-14","-11","-08","-15","-03","-17",
#                "-05","-10","-16","-13","-01")) 



# IN %>% 
#   dplyr::pull(Zupanija) %>% 
#   unique() %>%
#   enc2utf8() %>% 
#   Encoding()
# IN %>% 
#   select(Zupanija) %>% 
#   distinct() %>% 
#   left_join(Regions)
# names(Zs) <- NULL

IN2 <-
  IN %>% 
  # dplyr::filter(Zupanija != "") %>% 
  # left_join(Regions, by = "Zupanija") %>% 
  select(Sex = spol, dob, Date = Datum) %>%  # Regions = Counties
  mutate(Date = lubridate::ymd(Date),
          Age = round(lubridate::decimal_date(Date) - (dob+.5)),
          Age = ifelse(Age > 100,100,Age),
          Age = as.integer(Age)) %>% 
  group_by(Sex, Date, Age) %>% 
  summarize(new = n(),.groups = "drop") %>% 
  mutate(Sex = case_when(Sex == "M" ~ "m", 
                         TRUE ~ "f"))



date_range <- IN2$Date %>% range()
dates_all  <- seq(date_range[1], date_range[2], by = "days")

ages_all <- 0:100 %>% as.integer()

out <-
  IN2 %>% 
  tidyr::complete(Date = dates_all, Sex, Age = ages_all, fill = list(new = 0)) %>% 
  mutate(Region = "All",
         AgeInt = ifelse(Age == 100L, 5L, 1L)) %>% 
  arrange(Sex, Age, Date) %>% 
  group_by(Sex, Age) %>% 
  mutate(Value = cumsum(new)) %>% 
  ungroup() %>% 
  mutate(Country = "Croatia",
         Measure = "Cases",
         Metric = "Count",
         Date = ddmmyyyy(Date)) %>% 
  # left_join(RegionCodes, by = "Region") %>% 
  mutate(Code = "HR") %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) %>% 
  group_by(Region, Sex, Age, Date) %>% 
  mutate(n = sum(Value)) %>% 
  ungroup() %>% 
  filter(n > 0) %>% 
  select(-n) %>% 
  sort_input_data()


#save output data

write_rds(out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(out)) 

#archive input data 

data_source <- paste0(dir_n, "Data_sources/", ctr, "/cases_age_",today(), ".csv")

write_csv(IN, data_source)


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








