library(here)
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")



# assigning Drive credentials in the case the script is verified manually  
if (!"email" %in% ls()){
  email <- "jessica_d.1994@yahoo.de"
}

# info country and N drive address
ctr          <- "US_Oregon_Vaccine" # it's a placeholder
dir_n_source <- "N:/COVerAGE-DB/Automation/Oregan-Vaccine"#get Muhammads saved data 
dir_n        <- "N:/COVerAGE-DB/Automation/Hydra/"


#In= read.csv(file= 'N:/COVerAGE-DB/Automation/Oregan-Vaccine/Demographics_crosstab20210504.csv',
          #fileEncoding="UCS-2LE", header = FALSE, sep = "\t") 


xlsx_dir <- (dir_n_source)

all_paths <-
list.files(path = xlsx_dir,
 pattern = "*.csv",
full.names = TRUE)

all_content <-
all_paths %>%
lapply(read.csv, fileEncoding="UCS-2LE", header = FALSE, sep = "\t")

all_filenames <- all_paths %>%
basename() %>%
as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

Age_in <- rbindlist(all_lists, fill = T)

#process

colnames(Age_in)[1] <- "Def"
colnames(Age_in)[2] <- "Age"
colnames(Age_in)[3] <- "Value"
colnames(Age_in)[4] <- "Date"


#Vaccines by Age 

Age_out= Age_in %>%
  subset(Def!= "Race")%>%
  subset(Def!= "Sex")%>%#remove race and sex
  subset(Def!= "Demographic Type")%>%
  select(-Def)%>%
  mutate(AgeInt = case_when(
    Age == "12 to 15" ~ 4L,
    Age == "<19" ~ 20L,
    Age == "16 to 19" ~ 4L,
    Age == "60 to 64" ~ 5L,
    Age == "65 to 69" ~ 5L,
    Age == "70 to 74" ~ 5L,
    Age == "75 to 79" ~ 5L,
    Age == "80+" ~ 25L,
    Age == " " ~ NA_integer_,
    TRUE ~ 10L))%>% 
  mutate(Age=recode(Age, 
                    `12 to 15`="12",
                    `<19`="0",
                    `16 to 19`="16",
                    `20 to 29`="20",
                    `30 to 39`="30",
                    `40 to 49`="40",
                    `50 to 59`="50",
                    `60 to 64`="60",
                    `65 to 69`="65",
                    `60 to 69`="60",
                    `70 to 74`="70",
                    `75 to 79`="75",
                    `70 to 79`="70",
                    `80+`="80",
                    ` `="TOT"))%>%
  separate(Date, c("1", "Date2"), "_")%>%
  separate(Date2, c("3", "Date3"), "b")%>%
  separate(Date3, c("Date4", "5"), "\\.")%>%
  select(Date= Date4, Value, Age, AgeInt)%>% 
  mutate(Value = as.numeric(gsub(",", "", Value)))%>%#remove commas from values 
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    Sex= "b") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_OR",Date),
    Country = "USA",
    Region = "Oregon",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)
  
  
  
#Vaccine by Sex 

Sex_out= Age_in %>%
  subset(Def== "Sex")%>%
  select(-Def)%>%
  mutate(Sex=recode(Age, 
                    `Female`="f",
                    `Male`="m",
                    `Unknown`="UNK"))%>%
  separate(Date, c("1", "Date2"), "_")%>%
  separate(Date2, c("3", "Date3"), "b")%>%
  separate(Date3, c("Date4", "5"), "\\.")%>%
  select(Date= Date4, Value, Sex)%>% 
  mutate(Value = as.numeric(gsub(",", "", Value)))%>%#remove commas from values 
  mutate(
    Measure = "Vaccinations",
    Metric = "Count",
    Age= "TOT",
    AgeInt=" ") %>% 
  mutate(
    Date = ymd(Date),
    Date = paste(sprintf("%02d",day(Date)),    
                 sprintf("%02d",month(Date)),  
                 year(Date),sep="."),
    Code = paste0("US_OR",Date),
    Country = "USA",
    Region = "Oregon",)%>% 
  select(Country, Region, Code, Date, Sex, 
         Age, AgeInt, Metric, Measure, Value)


#put together

Out= rbind(Age_out, Sex_out)

#save output data 
write_rds(Out, paste0(dir_n, ctr, ".rds"))
log_update(pp = ctr, N = nrow(Out))


# now archive

data_source <- paste0(dir_n, "Data_sources/", ctr, "/vaccine_age_",today(), ".csv")

write_csv(Age_in, data_source)

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



















