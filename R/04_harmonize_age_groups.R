
# prelims to get offsets



have_offsets <- Offsets %>% 
  pull(Country) %>% 
  unique()



harmonize_age <- function(chunk, Offsets, N = 5, OAnew = 100){
  Age     <- chunk %>% pull(Age)
  AgeInt  <- chunk %>% pull(AgeInt)
  Value   <- chunk %>% pull(Value) 
  
  .Country <- chunk %>% pull(Country) %>% "["(1)
  .Sex     <- chunk %>% pull(Sex) %>% "["(1)
  Offset   <- Offsets %>% 
                filter(Country == .Country,
                       Sex == .Sex)
  
  pop     <- Offset %>% pull(Population)
  age_pop <- Offset %>% pull(Age)
  # maybe we don't need to do anything but lower the OAG?
  if (all(AgeInt == N) & max(Age) >= OAnew){
    Value   <- groupOAG(Value, Age, OAnew = OAnew)
    Age     <- Age[1:length(Value)]
    AgeInt  <- AgeInt[1:length(Value)]
    return(select(chunk, Age, AgeInt, Value))
  }
  
  # otherwise get offset sorted out.
  if (max(age_pop) < 104 | !is_single(age_pop)){
    p1 <- pclm(y = pop, x = age_pop, nlast = 105-max(age_pop), control = list(lambda = 10))$fitted
    if (is_single(age_pop)){
      ind            <- c(diff(age_pop)==1,FALSE)
      p1[which(ind)] <- pop[ind]
     
    } 
    pop            <- p1
    age_pop        <- 0:104
  }
  
  if (max(age_pop) > 104){
    pop      <- groupOAG(pop, age_pop, OAnew = 104)
    age_pop  <- 0:104
  }
  
  # TR: I thought multiplying with offset would bring back to scale, but sum doesn't match.
  # so need to rescale in next step (pattern looks OK)
  V1      <- pclm(x = Age, 
                  y = Value, 
                  nlast = AgeInt[length(AgeInt)], 
                  offset = pop, control = list(lambda = 10))$fitted * pop
  # plot(V1)
  # lines(rescaleAgeGroups(V1, rep(1,length(V1)), Value, AgeInt,splitfun=graduate_uniform) )
  # Important to rescale
  V1      <- rescaleAgeGroups(V1, rep(1,length(V1)), Value, AgeInt,splitfun=graduate_uniform)
  VN      <- groupAges(V1, age_pop, N = N, OAnew = OAnew)
  Age     <- names2age(VN)
  AgeInt  <- rep(N, length(VN))
  
  tibble(Age = Age, AgeInt = AgeInt, Value = VN)
}

chunk <- inputCounts %>% 
  filter(Code == "ITbol06.04.2020",
         Measure == "Deaths",
         Sex == "b")

harmonize_age(chunk, Offsets)

inputCounts <- 
  inputCounts %>% 
  filter(Country %in% have_offsets)


hm <- 
  inputCounts %>% 
  group_by(Country, Code, Date, Sex, Measure) %>% 
  do(harmonize_age(chunk = .data, Offsets, N = 5, OAnew = 100)) %>% 
  ungroup()

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


