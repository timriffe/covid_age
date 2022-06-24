##Netherlands Vaccination 2022

source("https://raw.githubusercontent.com/timriffe/covid_age/master/Automation/00_Functions_automation.R")
if (! "email" %in% ls()){
  email <- "maxi.s.kniffka@gmail.com"
}

# info country and N drive address
ctr    <- "Netherlands_Vaccine"
dir_n  <- "N:/COVerAGE-DB/Automation/Hydra/"
dir_n_source <- "N:/COVerAGE-DB/Automation/Netherlands"


# Drive credentials
drive_auth(email = Sys.getenv("email"))
gs4_auth(email = Sys.getenv("email"))



file.list <-list.files(path= dir_n_source, 
                pattern = ".xlsx",
                full.names = TRUE)


##################################################################
## Previously used for reading and merging all files ############# 
##################################################################

##(col_types = c("guess","guess","guess","numeric","numeric"))
#all_content_age_vaccine <-
#  df %>%
#  lapply(read_xlsx)
#
#all_filenames_age_vaccine <- df %>%
#  basename() %>%
#  as.list()
#
##include filename to get date from filename 
#all_lists <- mapply(c, all_content_age_vaccine, all_filenames_age_vaccine, SIMPLIFY = FALSE)
##vacc_in <- rbindlist(all_lists, fill = T)
#vacc_in$vacc1 <- format(round(as.numeric(vacc_in$`First dose`),1), small.mark=  ",")
#
#vacc <- vacc_in %>% 
#  select(`Target group`, `First dose`, `Second dose3`, `Total`, Date = `V1`, `Vaccinator`)
#names(vacc)[1] <- "Age"

# string_in_vacc <- unique(vacc$group)
# string_in_vacc[c(1,2,4:8,12:16,22:24,26:27,31,32,42,43,45,85:92)]

# vacc2 <- vacc %>% 
#   filter(!group %in% string_in_vacc[c(1,2,4:8,12:16,22:24,26:27,31,32,42,43,45,85:92)])

#names(vacc)[2] <- "Vaccination1"
#names(vacc)[3] <- "Vaccination2"
#names(vacc)[4] <- "Vaccinations"


df.list <- setNames(lapply(file.list, read_excel),  
                    lubridate::ymd(stringr::str_extract_all(file.list, '\\d+')))


## DIAGNOSTICS: for each 'list' get the variables names ##

length(unique(lapply(df.list, function(x) sort(tolower(names(x)))))) == 1
unique(lapply(df.list, function(x) sort(tolower(names(x)))))
files.names <- lapply(df.list, function(x) sort(tolower(names(x)))) 

### SINCE THESE ARE OF DIFFERENT LENGHT, WE MAXIMIZE LENGTH, ADD NAs AND COMBINE ###

maxlen <- max(lengths(files.names))
list_maximum <- lapply(files.names, function(lst){c(lst, rep(NA, maxlen - length(lst)))})
columns_prep <- lapply(list_maximum, unlist)
columnsnames_df <- as.data.frame(columns_prep) 

### COLUMNS NAMES EDIT TO REMOVE 'X' ###

colnames(columnsnames_df) <- gsub(pattern = "X", replacement = "", colnames(columnsnames_df))

### COLUMNS DIAGNOSTICS if all has the same values/ length ###

check <- columnsnames_df %>% 
  rowwise %>%
  mutate(same = n_distinct(unlist(cur_data())) == 1) %>%
  ungroup()


## BIND the list of tibbles, while keeping lists names as Date
## coalesce the problematic columns
## select the relevant

vacc <- bind_rows(df.list, .id="Date") %>% 
  mutate(`Start date` = coalesce(`Start date2`, `Start date`),
         `Total` = coalesce(`Total4`, `Total`),
         `Second dose` = coalesce(`Second dose3`, `Second dose`)) %>% 
  select(Age = contains("Target"),
        # `Start date`,
        Vaccination1 = `First dose`,
        Vaccination2 = `Second dose`,
        Vaccinations = `Total`, 
          Date,
        Vaccinator)



#vacc$Vaccination1 <- gsub(",", ".", vacc$Vaccination1)
#vacc$vacc1 <- as.numeric(vacc$Vaccination1) 
#vacc$Vaccination1 <- gsub("\\.", "", vacc$Vaccination1)
#vacc$vacc1 <- ifelse(is.na(vacc$vacc1), vacc$Vaccination1, vacc$vacc1)
#vacc$Vaccination1 <- as.numeric(vacc$vacc1)
#
#vacc$Vaccination2 <- gsub(",", ".", vacc$Vaccination2)
#vacc$vacc2 <- as.numeric(vacc$Vaccination2) * 1000
#vacc$Vaccination2 <- gsub("\\.", "", vacc$Vaccination2)
#vacc$vacc2 <- ifelse(is.na(vacc$vacc2), vacc$Vaccination2, vacc$vacc2)
#vacc$Vaccination2 <- as.numeric(vacc$vacc2)


#####################################################################
### RE-FORMATTING NUMBERS & DATE ###
### REPLACING . in one entry 'vaccinations 2' in 09.03.2022, SO THAT NO MISLEADING DECIMALS ###

vacc <- vacc %>%
  mutate(Vaccination1 = str_replace_all(Vaccination1, c("," = "", "[.]" = "")),
         Vaccination1 = as.numeric(Vaccination1),
         Vaccination2 = str_replace_all(Vaccination2, c("," = "", "[.]" = "")),
         Vaccination2 = as.numeric(Vaccination2),
         Vaccinations = str_replace_all(Vaccinations, c("," = "", "[.]" = "")),
         Vaccinations = as.numeric(Vaccinations),
         Date = as.Date(Date, format="%Y-%m-%d"))
  


#vacc$Vaccinations <- gsub(",", ".", vacc$Vaccinations)
#vacc$vacc1 <- as.numeric(vacc$Vaccination1) * 1000


#vacc$Date = substr(vacc$Date,1,nchar(vacc$Date)-5)
#vacc$Date <- sub("............", "", vacc$Date)
#
#vacc$Date <-  as.Date(as.character(vacc$Date),format="%Y%m%d")


vacc2 <- vacc %>% 
  mutate(Age = case_when(
    Age == "5-113" ~ "5",
    Age == "12-17" ~ "12",
    Age == "18-25" ~ "18",
    Age == "26-30" ~ "26",
    Age == "31-35" ~ "31",
    Age == "36-40" ~ "36",
    Age == "41-45" ~ "41",
    Age == "46-50" ~ "46",
    Age == "51-55" ~ "51",
    Age == "56-60" ~ "56",
    Age == "61-65" ~ "61",
    Age == "66-70" ~ "66",
    Age == "71-75" ~ "71",
    Age == "76-80" ~ "76",
    Age == "81-85" ~ "81",
    Age == "86-90" ~ "86",
    Age == "91+" ~ "91",
    Age == "Unknown" ~ "UNK" )) %>% 
  mutate(AgeInt = case_when(
    Age == "5" ~ 7L,
    Age == "12" ~ 5L,
    Age == "18" ~ 8L,
    Age == "26" ~ 5L,
    Age == "31" ~ 5L,
    Age == "36" ~ 5L,
    Age == "41" ~ 5L,
    Age == "46" ~ 5L,
    Age == "51" ~ 5L,
    Age == "56" ~ 5L,
    Age == "61" ~ 5L,
    Age == "66" ~ 5L,
    Age == "71" ~ 5L,
    Age == "76" ~ 5L,
    Age == "81" ~ 5L,
    Age == "86" ~ 5L,
    Age == "91" ~ 14L)) %>% 
  select(Vaccination1, Vaccination2, Age, AgeInt, Date) %>%  
  filter(!is.na(Age))

## PIVOT_LONGER ##

vacc2 <- vacc2 %>% 
  pivot_longer(cols = starts_with("Vaccination"),
               names_to = "Measure",
               values_to = "Value") 

#names(vacc2)[4] <- "Measure"
#names(vacc2)[5] <- "Value"
vacc2 <- vacc2 %>% 
  mutate(
    Country = "Netherlands",
    Region = "All",
    Code = "NL",
    Metric = "Count",
    Sex = "b"
  ) 


small_ages1 <- vacc2 %>% 
  filter(Date == "2022-01-21",
          Age == "12") %>% 
  mutate(Age = "0",
         AgeInt = 12L,
         Value = 0)

small_ages2 <- vacc2 %>% 
  filter(Date > "2022-01-21",
         Age == "5") %>% 
  mutate(Age = "0",
         AgeInt = 5L,
         Value = 0)



vacc_2022 <- rbind(vacc2, small_ages1, small_ages2) %>% 
  mutate(Date = ymd(Date),
         Date = paste(sprintf("%02d",day(Date)),
                      sprintf("%02d",month(Date)),
                      year(Date),
                      sep=".")) %>% 
  sort_input_data()


vacc_2021 <- read_rds("N:/COVerAGE-DB/Automation/Netherlands/Vaccinations of 2021/Netherlands_Vaccine.rds") %>% 
  mutate(Value = case_when(
    is.na(Value) ~ 0,
    TRUE ~ Value
  )) 

vacc_out <- rbind(vacc_2021, vacc_2022) %>% 
  sort_input_data()


############save##########################

write_rds(vacc_out, paste0(dir_n, ctr, ".rds"))

log_update(pp = ctr, N = nrow(vacc_out))

