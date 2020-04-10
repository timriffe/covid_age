
# prelims to get offsets


# FOR NOW WE PROCESS INPUTS THAT HAVE OFFSETS, see step 3
have_offsets <- Offsets %>% 
  pull(Country) %>% 
  unique()


inputCounts <- 
  inputCounts %>% 
  filter(Country %in% have_offsets)

# iL<- split(inputCounts, list(inputCounts$Country, 
#                              inputCounts$Code,
#                              inputCounts$Date,
#                              inputCounts$Sex,
#                              inputCounts$Measure),
#            drop = TRUE)
# for (i in 1:length(iL)){
#   chunk <- iL[[i]]
#   harmonize_age(chunk, Offsets, N = 5, OAnew = 100)
# }

outputCounts_5 <- 
  inputCounts %>% 
  group_by(Country, Code, Date, Sex, Measure) %>% 
  do(harmonize_age(chunk = .data, Offsets, N = 5, OAnew = 100)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure,
              values_from = Value) 
head(outputCounts_5)

spot_checks <- FALSE
if (spot_checks){
# Once-off diagnostic plot:
outputCounts_5 %>% 
  mutate(ASCFR = Deaths / Cases,
         ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
  filter(!is.na(ASCFR),
         Sex == "m") %>% 
  ggplot(aes(x=Age, y = ASCFR, group = interaction(Country, Code))) + 
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
}

outputCounts_10 <- 
  inputCounts %>% 
  group_by(Country, Code, Date, Sex, Measure) %>% 
  do(harmonize_age(chunk = .data, Offsets, N = 10, OAnew = 100)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Measure,
              values_from = Value) 
push_outputDB(outputCounts_5)

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


