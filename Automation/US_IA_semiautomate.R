
# main url: "https://iowacovid19tracker.org/downloadable-data"
# Just to find a way to automatically download the full csv.

IA <- read_csv("Data/Statewide Age Group Demographics.csv")
IA %>% 
  select(Date, 
         starts_with("Deaths: Cumulative"), 
         starts_with("Positives: Cumulative")) %>% 
  pivot_longer(2:ncol(.), 
               names_to = "MeasureAge",
               values_to = "Value") %>% 
  filter(!is.na(Value),
         !grepl(MeasureAge,pattern = "&")) %>%
  mutate(MeasureAge = sub(MeasureAge, pattern = "Age Groups", replacement = "TOT")) %>% 
  separate(MeasureAge, 
           into = c("Measure", NA, "Age"),
           sep = " ") %>% 
  mutate(Date = mdy(Date),
         Age = recode(Age,
                      "0-17" = "0",
                      "18-40" = "18",
                      "41-60" = "41",
                      "61-80" = "61",
                      "81+" = "81",
                      "18-29" = "18",
                      "30-39" = "30",
                      "40-49" = "40",
                      "50-59" = "50",
                      "60-69" = "60",
                      "70-79" = "70",
                      "80+" = "80"),
         Measure = sub(Measure, pattern = ":", replacement = ""),
         Measure = ifelse(Measure == "Positives","Cases",Measure)) %>% 
  # group_by(Date, Measure) %>% 
  # summarize(TOT = Value[Age == "TOT"],
  #           MTOT = sum(Value[Age!="TOT"])) %>% 
  # mutate(Diff = TOT - MTOT)
  mutate(Country = "USA",
         Region = "Iowa",
         Date = paste(sprintf("%02d",day(Date)),    
               sprintf("%02d",month(Date)),  
               year(Date),sep="."),
         Metric = "Count",
         Code = paste0("US_IA_",Date)
  )
