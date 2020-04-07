
# prelims to get offsets
unique(inputDB$Country)
hmdCountries <- c("KOR","CAN","FRATNP","DEUTNP","ITA","NLD","ESP","USA","BEL","CHE")
our_names <- c("SouthKorea","Canada","France","Germany","Italy",
               "Netherlands","Spain","USA","Belgium","Switzerland")

WApop <- c(453551,475580,478896,464081,492661,539615,522479,521493,
465060,470565,461238,495654,479135,419113,327717,212066,130696,136810)
WAage <- (1:length(WApop) - 1) * 5

NYCpop <- read_csv("Data/NYC_proj_pop_2020_Cornell.csv") %>% 
  filter(Sex == "Total") %>% 
  pull(`2020 estimate`)
NYCage <- 0:85



library(tidyverse)

library(ungroup)
library(DemoTools)

plot(0:84,yhat[1:85] - y[1:85])


chunk <- inputCounts %>% filter(Code == "NYC06.04.2020",
                                Measure == "Deaths")
chunk <- inputCounts %>% filter(Code == "WA31.03.2020",
                                Measure == "Deaths")
harmonize_age <- function(chunk, pop, age_pop, N = 5, OAnew = 100){
  Age     <- chunk %>% pull(Age)
  AgeInt  <- chunk %>% pull(AgeInt)
  Value   <- chunk %>% pull(Value) 
  
  # maybe we don't need to do anything but lower the OAG?
  if (all(AgeInt == N) & max(Age) >= OAnew){
    Value  <- groupOAG(Value, Age, OAnew = OAnew)
    Age    <- Age[1:length(Value)]
    AgeInt <- AgeInt[1:length(Value)]
    return(select(chunk, Age, AgeInt, Value))
  }
  
  # otherwise get offset sorted out.
  if (max(age_pop) < 104 | !is_single(age_pop)){
    p1 <- pclm(y = pop, x = age_pop, nlast = 105-max(age_pop))$fitted
    if (is_single(age_pop)){
      ind            <- c(diff(age_pop)==1,FALSE)
      p1[which(ind)] <- pop[ind]
     
    } 
    pop            <- p1
    age_pop        <- 0:104
  }
  
  if (max(age_pop) > 104){
    pop      <- groupOAG(pop, age_pop, OAnew = 104)
    age_pop  <- names2age(pop)
  }
  
  V1      <- pclm(x = Age, y = Value, nlast = AgeInt[length(AgeInt)], offset = pop)$fitted * pop
  # plot(V1)
  # lines(rescaleAgeGroups(V1, rep(1,length(V1)), Value, AgeInt,splitfun=graduate_uniform) )
  # Important to rescale
  V1      <- rescaleAgeGroups(V1, rep(1,length(V1)), Value, AgeInt,splitfun=graduate_uniform)
  VN      <- groupAges(V1, age_pop, N = N, OAnew = OAnew)
  Age     <- names2age(VN)
  AgeInt  <- rep(N, length(VN))
  
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
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

library(HMDHFDplus)







