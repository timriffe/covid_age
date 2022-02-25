##costa rica vaccines
source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}
# info country and N drive address
ctr    <- "Costa_Rica_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Costa Rica"
# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))

previous <- read_rds(paste0(dir_n, "Togo.rds")) %>% 
  mutate(Date = dmy(Date)) %>% 
  filter(Date <= "2022-01-19")

##get the new data that is automated

all_paths <-
  list.files(path = dir_n_source,
             pattern = ".xlsx",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read_xlsx)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

#include filename to get date from filename 
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

vacc_in <- rbindlist(all_lists, fill = T) 

names(vacc_in)[1] <- "Age"
vacc_in <- melt(vacc_in, id=c("Age", "V1"))
names(vacc_in)[3] <- "Measure"
names(vacc_in)[4] <- "Value"
vacc_out <- vacc_in %>% 
  mutate (Date = substr(V1, 13,20),
          Date = as.Date(as.character(Date),format="%Y%m%d"),
          Country = "Costa Rica",
          Region = "All",
          Code = "CR",
            Sex = "b",
          Age = case_when(
            Age == "12 a 19 aos" ~ "12",
            Age == "20 a 39 aos" ~ "20",
            Age == "40 a 57 aos" ~ "40",
            Age == "5 a 11 aos" ~ "5",
            Age == "58 aos y ms" ~ "58",
            Age == "Total" ~ "TOT"
          ),
          AgeInt = case_when(
            Age == "12" ~ 8L,
            Age == "20" ~ 20L,
            Age == "40" ~ 20L,
            Age == "58" ~ 47L,
            Age == "5" ~ 7L),
          Metric = "Count",
          Measure = case_when(
            Measure == "PRIMERA" ~ "Vaccination1",
            Measure == "SEGUNDA" ~ "Vaccination2",
            Measure == "TERCERA" ~ "Vaccination3",
            Measure == "TOTAL" ~ "Vaccinations"
          ),
          Value = as.numeric(gsub("\\.", "", Value)),
          Date = ymd(Date),
          Date = paste(sprintf("%02d",day(Date)),
                       sprintf("%02d",month(Date)),
                       year(Date),
                       sep=".")) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value) 

##get data stored on drive

rubric <- get_input_rubric() %>% filter(Short == "CR")

ss_i <- rubric %>% 
  dplyr::pull(Sheet)

ss_db <- rubric %>% 
  dplyr::pull(Source)

In_drive <-  read_sheet(ss = ss_i, sheet = "database")




##combining
out <- rbind(In_drive, vacc_out) %>% 
  sort_input_data()


write_rds(out, paste0(dir_n, "Costa_Rica_Vaccine.rds"))
log_update(pp = ctr, N = nrow(out))

###
data_source <- paste0(dir_n, "Data_sources/", ctr, "/vacc_",today(), ".xlsx")

write_csv(vacc_in, data_source)

zipname <- paste0(dir_n, 
                  "Data_sources/", 
                  ctr,
                  "/", 
                  ctr,
                  "_data_",
                  today(), 
                  ".zip")


zipr(zipname, 
     data_source, 
     recurse = TRUE, 
     compression_level = 9,
     include_directories = TRUE)

# clean up file chaff
file.remove(data_source)


