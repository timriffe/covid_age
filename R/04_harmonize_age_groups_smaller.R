
### Clean up & functions ############################################
source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

# what I want:
# n.cores <- round(6 + (detectCores() - 8)/5)

# what appears to work
n.cores  <- 3 # override

# test size
how_many_chunks_needed_to_test <- 500
### Load data #######################################################

# Count data
inputCounts <-  readRDS("N://COVerAGE-DB/Data/inputCounts.rds")
inputCounts$Metric <- NULL
 
# Offsets
Offsets     <- readRDS("N://COVerAGE-DB/Data/Offsets.rds")
# print(object.size(Offsets),units = "Mb")
# 2.1 Mb
# Sort count data, add group ids.

inputCounts <- 
  inputCounts %>% 
  arrange(Country, Region, Date, Measure, Sex, Age) %>% 
  group_by(Code, Sex, Measure, Date) %>% 
  mutate(id = cur_group_id()) %>% 
  ungroup() %>% 
  filter(id < how_many_chunks_needed_to_test) 


# split into n.cores chunks

n_cores <- c(3,6,12,24)
timings <- list()

for (i in 1:4){
inputCounts <-
  inputCounts %>% 
  mutate(core_id = sample(1:n_cores[i],
                          size = 1,
                          replace = TRUE))

# Split counts into big chunks
iL <- split(inputCounts,
            inputCounts$core_id,
            drop = TRUE)

timings[[i]] <- system.time({
  cl <- makeCluster(n_cores[i])
  clusterEvalQ(cl,
               {source("R/00_Functions.R");
                 Offsets = readRDS("Data/Offsets.rds"); # i don't know how else to 
                                                        # pre-load this object, but this works
                 N=5;
                 lambda = 1e5; 
                 OAnew = 100})
  #clusterEvalQ(cl,ls())
  iLout1e5 <-parLapply(cl, 
            iL, 
            harmonize_age_p_bigchunks, 
            Offsets = Offsets, 
            N = 5,          # technically no need to preload these pars above I think
            lambda = 1e5, 
            OAnew = 100)
  stopCluster(cl)
})
}
# lines after this not relevant. This is the big piece


# timings parallelsugar::mclapply()

timings2 <- list()

for (i in 1:4){
  inputCounts <-
    inputCounts %>% 
    mutate(core_id = sample(1:n_cores[i],
                            size = 1,
                            replace = TRUE))
  
  # Split counts into big chunks
  iL <- split(inputCounts,
              inputCounts$core_id,
              drop = TRUE)
  
  timings2[[i]] <- system.time({
  
    #clusterEvalQ(cl,ls())
    iLout1e5 <-parallelsugar::mclapply(
                         iL, 
                         harmonize_age_p_bigchunks, 
                         Offsets = Offsets, 
                         N = 5,          # technically no need to preload these pars above I think
                         lambda = 1e5, 
                         OAnew = 100,
                         mc.cores = n_cores[i])
  })
}



# Here's a minimal example:
# sleep functions scale as we want with cores

sleepy_fun <- function(x){
  Sys.sleep(5)
}
library(parallelsugar)

n_cores <- c(3,6,12,24)

test_resuts <- list()
for (i in 1:length(n_cores)){
  test_resuts[[i]] <- system.time(mclapply(1:24,
                                   sleepy_fun,
                                   mc.cores = n_cores[i]))
}
test_resuts

# --------------------
# mini problem nr 2, also scales w cores just fine.
sim_comp_fun <- function(x){
  N <- 1e5
  p <- 0
  for (i in 1:N){
    if (p > 0){
      p <- p - runif(1)
    } else {
      p <- p + runif(1)
    }
  }
  Sys.sleep(3)
  p
}


n_cores <- c(3,6,12,24)

test_resuts <- list()
for (i in 1:length(n_cores)){
  test_resuts[[i]] <- system.time(mclapply(1:24,
                                           sim_comp_fun,
                                           mc.cores = n_cores[i]))
}
test_resuts


sim_comp_fun2 <- function(Y,Z){
  
  N <- 1e4
  p <- 0
  for (i in 1:N){
    if (p > 0){
      p <- p - runif(1) * Z[i] + Y[i]
    } else {
      p <- p + runif(1) * Z[i] + Y[i]
    }
  }
  
  Sys.sleep(3)
  p
}


n_cores <- c(3,6,12,24)

Yl <- list()
for (i in 1:24){
  Yl[[i]] <- runif(1e4)
}
Z <- runif(1e4)



test_resuts <- list()
for (i in 1:length(n_cores)){
  test_resuts[[i]] <- system.time(mclapply(Yl,
                                           sim_comp_fun2,
                                           Z = Z,
                                           mc.cores = n_cores[i]))
}
test_resuts




