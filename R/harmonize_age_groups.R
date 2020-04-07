
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



x <- NYCage
y <- NYCpop
nlast <- 20
yhat <- pclm(x,y,nlast=nlast)$fitted

plot(0:84,yhat[1:85] - y[1:85])

NYCpop2 <- c(NYCpop[1:85],yhat[86:length(yhat)])

CC <- inputCounts %>% 
  filter(Code == "NYC06.04.2020",
         Measure == "Cases") %>% 
  pull(Value)

x <- inputCounts %>% 
  filter(Code == "NYC06.04.2020",
         Measure == "Cases") %>% 
  pull(Age) %>% 
  as.integer()
nlast <- 105 - x[length(x)]

Cx<- pclm(x,CC,nlast=nlast,offset = NYCpop2)$fitted
Cx <- Cx * NYCpop2
DD <- inputCounts %>% 
  filter(Code == "NYC06.04.2020",
         Measure == "Deaths") %>% 
  pull(Value)

Dx1 <- pclm(x,DD,nlast=nlast,offset = Cx)$fitted
Dx2 <- pclm(x,DD,nlast=nlast,offset = NYCpop2)$fitted

plot(0:104, Dx1 * Cx)
lines(0:104, Dx2 * NYCpop2)



# plot(0:104, NYCpop2)

# step 1: get single age offsets for each country.

library(HMDHFDplus)







