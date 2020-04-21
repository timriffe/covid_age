
# prelims to get offsets


 # # FOR NOW WE PROCESS INPUTS THAT HAVE OFFSETS, see step 3
 # (have_offsets <- Offsets %>% 
 #   mutate(code = paste(Country,Region,sep="-")) %>% 
 #   pull(code) %>% 
 #   unique())
 # 
 # 
 # inputs_to_split <- 
 #   inputCounts %>% 
 #   mutate(code = paste(Country,Region,sep="-")) %>% 
 #   filter(code %in% have_offsets, 
 #          Country != "Denmark")
 #  

# inputCounts <- inputCounts %>% filter(Country !="Denmark")
# iL <- split(inputCounts,
#             list(inputCounts$Code,
#                  inputCounts$Sex,
#                  inputCounts$Measure),
#             drop =TRUE)
# iLout <- list()
# for (i in 1:length(iL)){
#   chunk <- iL[[i]]
#   iLout[[i]] <- try(harmonize_age(chunk, Offsets = Offsets, N = 5, OAnew = 100))
# }
# n <- lapply(iLout,function(x){class(x)[1] == "try-error"}) %>% unlist() %>% which()


outputCounts_5 <- 
  inputCounts %>% 
  sort_input_data() %>% 
  group_by(Country, Region, Code, Date, Sex, Measure) %>% 
  do(harmonize_age(chunk = .data, Offsets, N = 5, OAnew = 100)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure,
              values_from = Value) 

outputCounts_5 <- outputCounts_5 %>% 
  mutate(Cases = ifelse(is.nan(Cases),0, Cases),
         Deaths = ifelse(is.nan(Deaths),0, Deaths),
         Tests = ifelse(is.nan(Tests),0, Tests))

# round output for csv
outputCounts_5_rounded <- 
  outputCounts_5 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1))

write_csv(outputCounts_5_rounded, path = "Data/Output_5.csv")
saveRDS(outputCounts_5, "Data/Output_5.rds")


# Repeat for 10-year age groups
 outputCounts_10 <- 
  outputCounts_5 %>% 
  mutate(Age = Age - Age %% 10) %>% 
  group_by(Country, Region, Code, Date, Sex, Age) %>% 
  summarize(Cases = sum(Cases),
            Deaths = sum(Deaths),
            Tests = sum(Tests)) %>% 
  ungroup() %>% 
  mutate(AgeInt = ifelse(Age == 100, 5, 10)) 
outputCounts_10 <- outputCounts_10[, colnames(outputCounts_5)]

# round output for csv
outputCounts_10_rounded <- 
  outputCounts_10 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1))

write_csv(outputCounts_10_rounded, path = "Data/Output_10.csv")
saveRDS(outputCounts_10, "Data/Output_10.rds")



spot_checks <- FALSE
if (spot_checks){
# Once-off diagnostic plot:
  
  
# populations with > 100 deaths,
# but no deaths in ages > 70 is weird.
  outputCounts_10 %>% 
    group_by(Country, Region, Code, Sex) %>% 
    mutate(D = sum(Deaths),
           D70 = sum(Deaths[Age >=70])) %>% 
    ungroup() %>% 
    filter(D >= 100,
           D70 == 0) %>%
    View()
  outputCounts_10 %>% pull(Age) %>% table()
  outputCounts_10 %>% filter(is.na(Deaths)) %>% View()
  
  
outputCounts_5 %>% 
    group_by(Country, Region, Code, Sex) %>% 
    mutate(D = sum(Deaths)) %>% 
    ungroup() %>% 
    filter(D >= 100) %>% 
    mutate(ASCFR = Deaths / Cases,
           ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
    filter(!is.na(ASCFR),
           Sex == "f",
           D >= 100) %>% 
  ggplot(aes(x=Age, y = ASCFR, color = Country, group = interaction(Country, Region, Code))) + 
  geom_line(alpha=.4) + 
 scale_y_log10() + 
  xlim(40,100)

outputCounts_5 %>% 
  mutate(ASCFR = Deaths / Cases,
         ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
  filter(Age == 40,
         !is.na(ASCFR),
         ASCFR > 1e-2)
outputCounts_5 %>% 
  mutate(ASCFR = Deaths / Cases,
         ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
  filter(Age == 60,
         is.na(ASCFR))

outputCounts_5 %>% 
  group_by(Country, Region, Code, Sex) %>% 
  mutate(D = sum(Deaths)) %>% 
  ungroup() %>% 
  filter(D >= 100) %>% 
  mutate(ASCFR = Deaths / Cases,
         ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
  filter(!is.na(ASCFR),
         Sex == "f",
         D >= 100) %>% 
  filter(Age==40,
         ASCFR > .01)

#####
Test <- outputCounts_5 %>% 
  pivot_longer(cols=c(Cases,Deaths),
               names_to = "Measure",
               values_to = "Value") %>% 
  group_by(Country, Code, Date, Sex, Measure) %>% 
  summarize(TOTout = sum(Value)) %>% 
  ungroup()

inputCounts %>% 
  group_by(Country, Code, Date, Sex, Measure) %>% 
  summarize(TOTin = sum(Value)) %>% 
  ungroup() %>% 
  left_join(Test) %>% 
  mutate(Diff = TOTout - TOTin) %>% 
  pull(Diff) %>% 
  summary()
}

# 
# NYCpop2 <- c(NYCpop[1:85],yhat[86:length(yhat)])
# 
# CC <- inputCounts %>% 
#   filter(Code == "NYC06.04.2020",
#          Measure == "Cases") %>% 
#   pull(Value)
# 
# x <- inputCounts %>% 
#   filter(Code == "NYC06.04.2020",
#          Measure == "Cases") %>% 
#   pull(Age) %>% 
#   as.integer()
# nlast <- 105 - x[length(x)]
# 
# Cx<- pclm(x,CC,nlast=nlast,offset = NYCpop2)$fitted
# Cx <- Cx * NYCpop2
# DD <- inputCounts %>% 
#   filter(Code == "NYC06.04.2020",
#          Measure == "Deaths") %>% 
#   pull(Value)
# 
# #Dx1 <- pclm(x,DD,nlast=nlast,offset = Cx)$fitted
# Dx2 <- pclm(x,DD,nlast=nlast,offset = NYCpop2)$fitted
# 
# plot(0:104, Dx1 * Cx)
# lines(0:104, Dx2 * NYCpop2)

# plot(0:104, NYCpop2)

# step 1: get single age offsets for each country.


