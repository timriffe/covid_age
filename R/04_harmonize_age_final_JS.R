## This script is a subscript of '04_harmonize_age_groups_changes.R'
## aims to start the harmonization using inputCounts.csv.
## Outputs: 5/10_internal.csv files.

## This script is written by Jonas Schöley.

### Constants #######################################################

#setwd('~/Dropbox/sci/2023-10-covharm/')

source(here::here("R/00_Functions.R"))
setwd(wd_sched_detect())
here::i_am("covid_age.Rproj")
startup::startup()

cnst <- list(
  batchsize = 1000,
  lambda = 1e5,
  omega = 100,
  nxout = 5,
  measures = c(c("Cases","Deaths","Tests","Vaccinations",
      "Vaccination1","Vaccination2", "Vaccination3", "Vaccination4",
      "Vaccination5", "Vaccination6", "VaccinationBooster")),
  nthreads = 11
)

path <- list()
path$input <- list(
  global = "R/00_Functions.R",
  offsets = "N://COVerAGE-DB/Data/offsets.rds",
  counts = "N://COVerAGE-DB/Data/inputCounts.csv"
)
path$output <- list(
  offsets = "N://COVerAGE-DB/Data/offsets.csv",
  counts = "N://COVerAGE-DB/Data/inputCounts.csv",
  log = 'N://COVerAGE-DB/Data/batch/pclm_log.txt',
  errorlog = 'N://COVerAGE-DB/Data/batch/error_log.txt',
  harmonized = 'N://COVerAGE-DB/Data/batch/'
)

## For some reason we weren't able to source from Tim's GitHub, so Tim copied all the functions
## in Functions.R file, and we use it here instead.
#source(here::here(path$input$global))

### Data loading ####################################################

Offsets <- as.data.table(readRDS(path$input$offsets))

inputCounts_raw <-
  data.table::fread(path$input$counts, encoding = "UTF-8")

inputCounts <-
  inputCounts_raw %>%
  # select the measures we want to harmonize
  collapse::fsubset(Measure %in% cnst$measures) %>%
  collapse::fselect(-Metric) %>%
  # filter out data post cutoff 31-03-2023
  collapse::fsubset(dmy(Date) <= ymd("2023-03-31")) %>%
  # order with strata moving slowest and age moving fastest
  collapse::roworder(Measure, Country, Region, Date, Sex, Age) %>%
  # group into single data series over age to be harmonized
  collapse::fgroup_by(Measure, Code, Sex, Date) %>%
  # subset to complete data series over age
  collapse::fmutate(complete = all(!is.na(Value))) %>%
  collapse::fsubset(complete == TRUE) %>%
  collapse::fselect(-complete) %>%
  collapse::fungroup()

# add id for individual data series
inputCounts$id <-
  inputCounts %>%
  collapse::fgroup_by(Measure, Code, Sex, Date) %>%
  collapse::GRPid()

# setup lookup table for ID <-> Strata
idLookup <-
  inputCounts %>%
  collapse::fselect(id, Measure, Code, Country, Region, Sex, Date) %>%
  unique()

#idLookup %>% data.table::fwrite(file = paste0(path$output$harmonized, "idLookup.csv"))

# subset input counts to minimal variables needed for harmonization
inputCounts <-
  inputCounts %>%
  collapse::fungroup() %>%
  collapse::fselect(id, Age, AgeInt, Value)

rm(inputCounts_raw)

### Harmonization ##########################################

ids <- unique(inputCounts$id)         # unique data series within measure
n_series <- length(ids)     # total number of series to harmonize within measure
n_batches <- ceiling(n_series/cnst$batchsize)

#
for (batch in 0:n_batches) {
  element_first = (batch*cnst$batchsize+1)
  element_last  = ((batch+1)*cnst$batchsize)
  if (element_last > n_series) { element_last = n_series }

  batch_ids <- ids[element_first:element_last]
  batch_elements <- which(inputCounts$id %in% batch_ids)
  xL <- split(inputCounts[batch_elements,],
              inputCounts[batch_elements,'id'])
  lapply(
    xL, FUN = function (x) {
      .measure <- idLookup[id == x$id[1],][['Measure']]
      .code <- idLookup[id == x$id[1],][['Code']]
      .sex <- idLookup[id == x$id[1],][['Sex']]
      .date <- idLookup[id == x$id[1],][['Date']]
      log_string <-
        paste(format(Sys.time(), '%Y-%m-%d %H:%M:%S'),
              ' Harmonize', 'batch ', batch, '/', n_batches, ':',
              .measure, .code, .sex, .date)
      cat(log_string, '\n', sep = '', file = path$output$log, append = TRUE)
      harmonizedCounts <-tryCatch(
        {
          harmonize_age_minimal(
            x, Offsets = Offsets, N = cnst$nxout,
            OAnew = cnst$omega, lambda = cnst$lambda,
            stratumlookup = idLookup)
        },
        error = function(e) {
          # On error, append the error message to the log file
          error_string <- paste(log_string, ':', e$message, '\n')
          write(error_string, file = path$output$errorlog, append = TRUE)
          NULL
        }
      )

      return(harmonizedCounts)
    }) |>
    data.table::rbindlist() |>
    ## join back the Country, Code, Region, Sex, Date, based on id
    dplyr::left_join(idLookup, by = "id") |> 
    saveRDS(file = paste0(path$output$harmonized,
                          'batch_', batch, 'of', n_batches, '.rds'))
}

#########################################################################

## read all batch rds files 
files_list <- list.files(
  path= paste0(path$output$harmonized),
  pattern = ".rds",
  full.names = TRUE)

out5 <- files_list |> 
  map_dfr(readRDS)

## write/ save the output files

# Get into one data set
data.table::fwrite(out5, file = "N://COVerAGE-DB/Data/Output_5_before_sex_scaling_etc.csv")
rm(iL);rm(iLout1e5)

ids_out  <- out5$id %>% unique() %>% sort()
failures <- ids_in[!ids_in %in% ids_out]

HarmonizationFailures <-
  inputCounts %>%
  filter(id %in% failures)

data.table::fwrite(HarmonizationFailures, file = "N://COVerAGE-DB/Data/HarmonizationFailures.csv")
# saveRDS(HarmonizationFailures, file = here::here("Data","HarmonizationFailures.rds"))

outputCounts_5_1e5 <-
  out5 %>%
  as.data.table() %>%
  .[, Value := nafill(Value, nan = NA, fill = 1)] %>%
  .[, rescale_sexes_post(chunk = .SD), keyby = .(Country, Region, Code, Date, Measure, AgeInt)] %>%
  as_tibble() %>%
  # pivot_wider(names_from = "Measure", values_from = "Value") %>%
  # dplyr::select(Country, Region, Code, Date, Sex, Age, AgeInt, Cases, Deaths, Tests) %>%
  # arrange(Country, Region, dmy(Date), Sex, Age) |>
  # NEW, to avoid redundant harmonization
  bind_rows(OutputCounts_keep) |>
  arrange(Country, Region, Date, Measure, Sex, Age)

data.table::fwrite(outputCounts_5_1e5, file = "N://COVerAGE-DB/Data/Output_5_internal.csv")

# Round to full integers (update)
outputCounts_5_1e5_rounded <-
  outputCounts_5_1e5 %>%
  mutate(Value = round(Value,1))
#Deaths = round(Deaths,1),
#Tests = round(Tests,1))

# Save csv
header_msg1 <- "Counts of all measures in harmonized 5-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))

#write_lines(header_msg, path = here("Data","Output_5.csv"))
#write_csv(outputCounts_5_1e5_rounded, path = here("Data","Output_5.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1),
                   file = "N://COVerAGE-DB/Data/Output_5.csv")
data.table::fwrite(as.list(header_msg2),
                   file = "N://COVerAGE-DB/Data/Output_5.csv",
                   append = TRUE)
data.table::fwrite(as.list(header_msg3),
                   file = "N://COVerAGE-DB/Data/Output_5.csv",
                   append = TRUE)
data.table::fwrite(outputCounts_5_1e5_rounded,
                   file = "N://COVerAGE-DB/Data/Output_5.csv",
                   append = TRUE, col.names = TRUE)

### Age harmonization: 10-year age groups ###########################

# Get 10-year groups from 5-year groups
outputCounts_10 <-
  #  Take 5-year groups
  outputCounts_5_1e5 %>%
  # Replace numbers ending in 5
  collapse::fmutate(Age = Age - Age %% 10) %>%
  # Sum
  collapse::fgroup_by(Country, Region, Code, Date, Sex, Measure, Age) %>%
  collapse::fsummarize(Value = sum(Value),
            keep.group_vars = FALSE) %>%
  # Replace age interval values
  collapse::fmutate(AgeInt = ifelse(Age == 100, 5, 10))

outputCounts_10 <- outputCounts_10[, colnames(outputCounts_5_1e5)]

# round output for csv
outputCounts_10_rounded <-
  outputCounts_10 %>%
  mutate(Value = round(Value,1))
# Deaths = round(Deaths,1),
# Tests = round(Tests,1))

# Save CSV
header_msg1 <- "Counts of all measures in harmonized 10-year age groups"
header_msg2 <- paste("Built:",timestamp(prefix="",suffix=""))
header_msg3 <- paste("Reproducible with: ",paste0("https://github.com/", Sys.getenv("git_handle"), "/covid_age/commit/",system("git rev-parse HEAD", intern=TRUE)))


#write_lines(header_msg, path = here("Data","Output_10.csv"))
#write_csv(outputCounts_10_rounded, path = here("Data","Output_10.csv"), append = TRUE, col_names = TRUE)
data.table::fwrite(as.list(header_msg1),
                   file = "N://COVerAGE-DB/Data/Output_10.csv")
data.table::fwrite(as.list(header_msg2),
                   file = "N://COVerAGE-DB/Data/Output_10.csv",
                   append = TRUE)
data.table::fwrite(as.list(header_msg3),
                   file = "N://COVerAGE-DB/Data/Output_10.csv",
                   append = TRUE)

data.table::fwrite(outputCounts_10_rounded,
                   file = "N://COVerAGE-DB/Data/Output_10.csv",
                   append = TRUE, col.names = TRUE)

# Save binary

# saveRDS(outputCounts_10, here::here("Data","Output_10.rds"))
data.table::fwrite(outputCounts_10, file = "N://COVerAGE-DB/Data/Output_10_internal.csv")
