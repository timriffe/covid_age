### Validate PCLM #############################################################

  ### Last changed: 2020-04-29 14:04:28 CEST


### Packages, functions, offsets ##############################################

  source("R/00_Functions.R")
  source("R/03_compile_offsets.R")


### Read data #################################################################

  # Read data
  inputDB <- read_csv("Data/inputDB.csv")
  
  # Select countries
  inputDB <- inputDB %>% filter(Country%in%c("Colombia","Mexico","Netherlands"))
  
  # Remove some stuff
  inputDB <- inputDB %>% filter(Metric=="Count")
  
  # Prepare data
  # TR: this will overwrite the above-filtered inputDB...
  # making inputCounts the full one?
  source("R/02_harmonize_metrics.R")
  

### Create three (potentially) coarsened data sets ############################
  
  # Copies
  dat_5  <- inputCounts 
  dat_10 <- inputCounts
  dat_20 <- inputCounts 
  
  # Recode 5-year categories
  values <- c(0,seq(5,110,by=5))
  for(value in values) {
    #if("TOT"%in%paste(value:(value+4))) break
    dat_5$Age[dat_5$Age%in%value:(value+4)] <- value
  }
  
  # Aggregate
  dat5 <- dat_5 %>% group_by(Country,Region,Code,Date,Age,Metric,Measure,Short,Sex) %>%
            summarize(Value = sum(Value),AgeInt = sum(AgeInt))

  # Recode 10-year categories
  values <- seq(0,110,by=10)
  for(value in values) {
    dat_10$Age[dat_10$Age%in%value:(value+9)] <- value
    
  }

  # Aggregate
  dat10 <- dat_10 %>% group_by(Country,Region,Code,Date,Age,Metric,Measure,Short,Sex) %>%
    summarize(Value = sum(Value),AgeInt = sum(AgeInt))

  # Recode 20-year categories
  values <- seq(0,120,by=20)
  for(value in values) {
    dat_20$Age[dat_20$Age%in%value:(value+19)] <- value
    
  }
  
  # Aggregate
  dat20 <- dat_20 %>% group_by(Country,Region,Code,Date,Age,Metric,Measure,Short,Sex) %>%
    summarize(Value = sum(Value),AgeInt = sum(AgeInt))

  
### Generate 5 year estimates #################################################
  
  # 5-year estimates from 10-year data
  outputCounts_5_10 <- 
    dat10 %>% 
    sort_input_data() %>% 
    group_by(Country, Region, Code, Date, Sex, Measure, Metric) %>% 
    do(harmonize_age(chunk = .data, Offsets, N = 5, OAnew = 100)) %>% 
    ungroup() %>% 
    pivot_wider(names_from = Measure,
                values_from = Value) 
  
  outputCounts_5_10 <- outputCounts_5_10 %>% 
    mutate(Cases = ifelse(is.nan(Cases),0, Cases),
           Deaths = ifelse(is.nan(Deaths),0, Deaths))
  
  # 5-year estimates from 20-year data
  outputCounts_5_20 <- 
    dat20 %>% 
    sort_input_data() %>% 
    group_by(Country, Region, Code, Date, Sex, Measure,Metric) %>% 
    do(harmonize_age(chunk = .data, Offsets, N = 5, OAnew = 100)) %>% 
    ungroup() %>% 
    pivot_wider(names_from = Measure,
                values_from = Value) 
  
  outputCounts_5_20 <- outputCounts_5_20 %>% 
    mutate(Cases = ifelse(is.nan(Cases),0, Cases),
           Deaths = ifelse(is.nan(Deaths),0, Deaths))
  
  
### Generate 5 year estimates #################################################
  
  # 10-year estimates from 20-year data
  outputCounts_10_20 <- 
    dat20 %>% 
    sort_input_data() %>% 
    group_by(Country, Region, Code, Date, Sex, Measure, Metric) %>% 
    do(harmonize_age(chunk = .data, Offsets, N = 10, OAnew = 100)) %>% 
    ungroup() %>% 
    pivot_wider(names_from = Measure,
                values_from = Value) 
  
  outputCounts_10_20 <- outputCounts_10_20 %>% 
    mutate(Cases = ifelse(is.nan(Cases),0, Cases),
           Deaths = ifelse(is.nan(Deaths),0, Deaths))
  
  
### Merge with true data ######################################################
  
  library(reshape2)
  
  # Tidy up: 5-year estimates from 10-year intervals
  outputCounts_5_10 <- outputCounts_5_10 %>% 
    melt(id.vars=c("Country","Region","Code","Date",
                   "Sex","Age","AgeInt","Metric"))
  outputCounts_5_10 <- outputCounts_5_10 %>% rename("Measure"="variable",
                                                    "Value_fit"="value")  

  # Tidy up: 5-year estimates from 20-year intervals
  outputCounts_5_20 <- outputCounts_5_20 %>% 
    melt(id.vars=c("Country","Region","Code","Date",
                   "Sex","Age","AgeInt","Metric"))
  outputCounts_5_20 <- outputCounts_5_20 %>% rename("Measure"="variable",
                                                    "Value_fit"="value")  
  
  # Merge with true data - 5 year intervals
  dat5_10 <- right_join(dat5,outputCounts_5_10)
  dat5_20 <- right_join(dat5,outputCounts_5_20)
  
  # Tidy up: 10-year estimates from 20-year intervals
  outputCounts_10_20 <- outputCounts_10_20 %>% 
                        melt(id.vars=c("Country","Region","Code","Date",
                                       "Sex","Age","AgeInt","Metric"))
  outputCounts_10_20 <- outputCounts_10_20 %>% rename("Measure"="variable",
                                                      "Value_fit"="value")

  # Merge 10 year intervals
  dat10_20 <- right_join(dat10,outputCounts_10_20)
  

### Check results #############################################################
  
  # Function for dissimilarity index
  diss_index <- function(chunk) {
    dis1 <- chunk$Value
    dis2 <- chunk$Value_fit
    
    if(any(is.na(dis1))) {
      dis2[min(which(is.na(dis1)))-1] <- dis2[min(which(is.na(dis1)))-1]+sum(dis2[is.na(dis1)])
      dis2[is.na(dis1)] <- 0
      dis1[is.na(dis1)] <- 0
      
    }
    
    dis1 <- dis1/sum(dis1)
    dis2 <- dis2/sum(dis2)
    
    dis <- sum(abs(dis1-dis2))*0.5

    dis
    
  }
  
  # Get diss index
  dis_5_10 <- dat5_10 %>% group_by(Country,Region,Code,Date,Metric,Measure,Short,Sex) %>%
    mutate(d=diss_index(chunk=.data))
  dis_5_10 <- na.omit(dis_5_10)
  dis_5_10 <- dis_5_10 %>% distinct(Country,Code,Date,Measure,Sex,d)
  
  # Get diss index
  dis_5_20 <- dat5_20 %>% group_by(Country,Region,Code,Date,Metric,Measure,Short,Sex) %>%
    mutate(d=diss_index(chunk=.data))
  dis_5_20 <- na.omit(dis_5_20)
  dis_5_20 <- dis_5_20 %>% distinct(Country,Code,Date,Measure,Sex,d)
  
  # Get diss index
  dis_10_20 <- dat10_20 %>% group_by(Country,Region,Code,Date,Metric,Measure,Short,Sex) %>%
               mutate(d=diss_index(chunk=.data))
  dis_10_20 <- na.omit(dis_10_20)
  dis_10_20 <- dis_10_20 %>% distinct(Country,Code,Date,Measure,Sex,d)
  
  # Get date
  dis_5_10$Date <- as.Date(dis_5_10$Date,format="%d.%m.%y")
  dis_5_20$Date <- as.Date(dis_5_20$Date,format="%d.%m.%y")
  dis_10_20$Date <- as.Date(dis_10_20$Date,format="%d.%m.%y")
  
  # Quantiles
  quantile(dis_5_10$d[dis_5_10$Date>"2020-04-01" & dis_5_10$Region=="All"],probs=c(0.5,0.9,0.95))
  quantile(dis_5_20$d[dis_5_20$Date>"2020-04-01" & dis_5_20$Region=="All"],probs=c(0.5,0.9,0.95))
  quantile(dis_10_20$d[dis_10_20$Date>"2020-04-01" & dis_10_20$Region=="All"],probs=c(0.5,0.9,0.95))
  