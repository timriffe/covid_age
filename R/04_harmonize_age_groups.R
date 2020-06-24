#.rs.restartR()
rm(list=ls());gc()
source(here("R","00_Functions.R"))
# prelims to get offsets

n.cores     <- round(6 + (detectCores() - 8)/8)

inputCounts <- readRDS(here("Data","inputCounts.rds"))
Offsets     <- readRDS(here("Data","Offsets.rds"))

inputCounts <- 
  inputCounts %>% 
  arrange(Country, Region, Measure, Sex, Age)

iL <- split(inputCounts,
              list(inputCounts$Code,
                   inputCounts$Sex,
                   inputCounts$Measure),
              drop =TRUE)

# different lambdas
# iLout100 <- mclapply(iL, 
#                      harmonize_age_p,
#                      Offsets = Offsets,
#                      N = 5,
#                      OAnew = 100,
#                      lambda = 100,
#                      mc.cores = 6)
log_section("Age harmonization", append = TRUE)
 
iLout1e5 <- mclapply(iL, 
                      FUN = try_step,
                      process_function = harmonize_age_p,
                      byvars = c("Code","Sex","Measure"),
                      Offsets = Offsets,
                      N = 5,
                      OAnew = 100,
                      lambda = 1e5,
                      mc.cores = 6)

outputCounts_5_1e5 <-
  iLout1e5 %>% 
  #iLout[-n] %>% 
  rbindlist() %>% 
  mutate(Value = ifelse(is.nan(Value),0,Value)) %>% 
  group_by(Code, Measure) %>% 
  # Newly added
  do(rescale_sexes_post(chunk = .data)) %>% 
  ungroup() %>%
  pivot_wider(names_from = Measure,
              values_from = Value) %>% 
  mutate(date = dmy(Date)) %>% 
  arrange(Country, Region, date, Sex, Age) %>% 
  select(-date) 

outputCounts_5_1e5_rounded <- 
  outputCounts_5_1e5 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1),
         Tests = round(Tests,1))

# Write output, public file

header_msg <- paste("Counts of Cases, Deaths, and Tests in harmonized 5-year age groups\nBuilt:",timestamp(prefix="",suffix=""),"\nReproducible with: ",paste0("https://github.com/timriffe/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))
write_lines(header_msg, path = here("Data","Output_5.csv"))
write_csv(outputCounts_5_1e5_rounded, path = here("Data","Output_5.csv"), append = TRUE, col_names = TRUE)

# Binary
saveRDS(outputCounts_5_1e5, here("Data","Output_5.rds"))


# Repeat for 10-year age groups
 outputCounts_10 <- 
  outputCounts_5_1e5 %>% 
  mutate(Age = Age - Age %% 10) %>% 
  group_by(Country, Region, Code, Date, Sex, Age) %>% 
  summarize(Cases = sum(Cases),
            Deaths = sum(Deaths),
            Tests = sum(Tests)) %>% 
  ungroup() %>% 
  mutate(AgeInt = ifelse(Age == 100, 5, 10)) 
outputCounts_10 <- outputCounts_10[, colnames(outputCounts_5_1e5)]

# round output for csv
outputCounts_10_rounded <- 
  outputCounts_10 %>% 
  mutate(Cases = round(Cases,1),
         Deaths = round(Deaths,1),
         Tests = round(Tests,1))

header_msg <- paste("Counts of Cases, Deaths, and Tests in harmonized 10-year age groups\nBuilt:",timestamp(prefix="",suffix=""),"\nReproducible with: ",paste0("https://github.com/timriffe/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))
write_lines(header_msg, path = "Data/Output_10.csv")
write_csv(outputCounts_10_rounded, path = "Data/Output_10.csv", append = TRUE, col_names = TRUE)

saveRDS(outputCounts_10, "Data/Output_10.rds")


spot_checks <- FALSE
if (spot_checks){
# Once-off diagnostic plot:

ASCFR5 <- 
outputCounts_5_1e5 %>% 
    group_by(Country, Region, Code, Sex) %>% 
    mutate(D = sum(Deaths)) %>% 
    ungroup() %>% 
    mutate(ASCFR = Deaths / Cases,
           ASCFR = na_if(ASCFR, Deaths == 0)) %>% 
    filter(!is.na(ASCFR),
           Sex == "b",
           D >= 100) 
ASCFR5 %>% 
  ggplot(aes(x=Age, y = ASCFR, group = interaction(Country, Region, Code))) + 
  geom_line(alpha=.05) + 
  scale_y_log10() + 
  xlim(20,100) + 
  geom_quantile(ASCFR5,
                mapping=aes(x=Age, y = ASCFR), 
                method = "rqss",
                quantiles=c(.025,.25,.5,.75,.975), 
                lambda = 2,
                inherit.aes = FALSE,
                color = "tomato",
                size = 1)

ASCFR5 %>% 
  filter(
         ASCFR > 1e3)

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

do.this <- FALSE
if (do.this){
  CodesToSample <-
  outputCounts_5_100 %>% 
    mutate(Short = paste(Country, 
                         Region,
                         Sex,
                         Date,
                         sep = "-")) %>%
    group_by(Country, Region, Sex, Date) %>% 
    mutate(N = sum(Deaths)) %>% 
    filter(N >= 100) %>% 
    pull(Short) %>% unique()
  
  SpotChecks <- sample(CodesToSample,500,replace=FALSE)
  
  compare_lambdas <- function(Short, X100, X1e5, X1e6){
    X100 <-
      X100 %>% 
      mutate(.Short = paste(Country, 
                           Region,
                           Sex,
                           Date,
                           sep = "-"),
             lambda = 100)
    X1e5 <-
      X1e5 %>% 
      mutate(.Short = paste(Country, 
                           Region,
                           Sex,
                           Date,
                           sep = "-"),
             lambda = 1e5)
    
    X1e6 <-
      X1e6 %>% 
      mutate(.Short = paste(Country, 
                          Region,
                          Sex,
                          Date,
                          sep = "-"),
             lambda = 1e6)
    
    X100       <- X100 %>% filter(.Short == Short)
    X1e5       <- X1e5 %>% filter(.Short == Short)
    X1e6       <- X1e6 %>% filter(.Short == Short)
    DatCompare <- list(X100,X1e5,X1e6) %>% bind_rows()
  
    DatCompare %>% 
      mutate(CFR = Deaths / Cases) %>% 
      ggplot(aes(x=Age, y = CFR, color = as.factor(lambda), group = lambda)) + 
      geom_line()+
      scale_y_log10()+
      ggtitle(Short)
    
    }
  for (i in 26:500){
    cat(i,"\n")
  print(compare_lambdas("Greece-All-b-11.05.2020",
                  outputCounts_5_100,
                  outputCounts_5_1e5,
                  outputCounts_5_1e6))
  Sys.sleep(1.5)
  }
  
}
