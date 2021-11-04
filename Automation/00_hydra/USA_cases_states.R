
# This file is an outline of a proposed estimation protocol for US cases by age, sex, state

# step 1 download case individual file.


In= read.csv("https://data.cdc.gov/api/views/n8mc-b4w4/rows.csv?accessType=DOWNLOAD")
##only 2 million cases

# step 2 aggregate by state, age, sex, date (or month as it were).
#can decide if we want to filter by lab confirmed case and prob. case (current_status)
Out <-
  In %>%
  slice(1:2640947)%>%
  select(Date = case_month, 
         Sex = sex, 
         Age = age_group, 
         State = res_state)%>%
  mutate(Sex =  case_when(is.na(Sex) ~ "UNK",
                          Sex== "Unknown" ~ "UNK",
                          Sex== "Missing" ~ "UNK",
                          Sex== "Other" ~ "UNK",
                          Sex== "Male" ~ "m",
                          Sex== "Female"~"f",
                          TRUE ~ as.character(Sex)),
         Age = case_when (is.na(Age) ~ "UNK",
                          Age== "Unknown" ~" UNK",
                          TRUE~ as.character(Age)))%>%
  group_by(Date, Sex, Age, State) %>% 
  summarize(Value = n(), .groups = "drop")%>%
  tidyr::complete(Date, Sex, Age, State, fill = list(Value = 0)) %>% 
  arrange(Sex, Age, State, Date) %>% 
  group_by(Sex, Age, State) %>% 
  mutate(Value = cumsum(Value)) %>% 
  ungroup()

#2.1. make some plots to see how the data looks 

setwd("U:/COVerAgeDB/CDC_public")

doPlot= function(svc_name){
  temp_df = subset(Out, State == svc_name)
  Plot= ggplot(temp_df, aes(x =Date, y = Value, color = Age)) +geom_line() +ggtitle(svc_name)+ xlab("Cases by State")
  print(Plot)
  ggsave(sprintf("%s.jpeg", svc_name))
  
}


lapply(unique(Out$State), doPlot)

















# step 3 accumulate from the very beginning up to the most recent. Expecting monthly resolution

# step 4 declare a cutoff, potentially January 2021?? Namely, Jessica found oddities in this series in 2020, but maybe age pyramids will be stabilized by jan 2021? Do a check, and if necessary move to Feb or March 2021, depends what we see.

# step 5 we now have a cumulative series by age, sex, month, state. Convert each month-snapshot to an age-sex distribution summing to 1.

# step 6 interpolate these distributions to daily resolution. linear is fine. See approx()

# step 7 These can be formatted in the input format using Metric = "Fraction".

# step 8 download and append a dataset of cumulative case totals by state and date.

# fin. The default data processing pipeline will take care of the scaling.






















