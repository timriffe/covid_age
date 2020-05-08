
# CONSISTENCY CHECKS

check_consistency <- function(data) {
  
  test_that(
  paste("When sex-specific count data are given,",
        "'both' sex must be greater or higher than 'm' and 'f"), {
    
    d <- data %>% 
      filter(Metric == "Count") %>% 
      mutate(Date = as.Date(Date, format = "%d.%m.%Y"),
             Code = paste(Short, Region, Date, Measure, Age, sep = "-")) %>% 
      pivot_wider(names_from = Sex, 
                  values_from = Value) %>% 
      mutate(b_gt_f = b >= f,                # b greater or equal than f
             b_gt_m = b >= m,                # b greater or equal than m
             valid = b_gt_f & b_gt_m) %>% 
      filter(valid == FALSE)
    
    expect_true(nrow(d) == 0, label = d$Code)  
  })
}

# inputDB <- read_csv("Data/inputDB.csv")
# check_consistency(inputDB),











