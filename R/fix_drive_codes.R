source("https://raw.githubusercontent.com/timriffe/covid_age/master/R/00_Functions.R")

rubric <- get_input_rubric() %>% 
  dplyr::filter(Loc == "d")

Lookup <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1gbP_TTqc96PxeZCpwKuZJB1sxxlfbBjlQj-oxXD2zAs/edit#gid=0")

ii <- 14
# Singapore not collected (5)
(loc <- rubric$Short[ii])


# for (loc in rubric$Short){

# get and fix database tab
X <- get_country_inputDB(loc) %>% 
  left_join(Lookup, by = c("Country","Region")) %>% 
  dplyr::select(-Code) %>% 
  rename(Code = `ISO 3166-2`) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)
X
# get url
ss <- rubric %>% dplyr::filter(Short == loc) %>% dplyr::pull(Sheet)

# open in browser
browseURL(ss)

# post new data
write_sheet(X, ss = ss, sheet = "database")


# detect template tab name
i_want_this_sheet <-
  gs4_get(ss)[["sheets"]][["name"]] %>% 
  grepl(pattern = "template", ignore.case = TRUE) %>% 
  which()

# detect nrow to skip
my_skippy <- 
  read_sheet(ss, sheet = i_want_this_sheet, range = "J1:J100") %>% 
  mutate(skippy = `...1` == "Value") %>% pull(skippy) %>% which() + 1

# grab data, parse
this_range <- paste0("A",my_skippy,":","J2000")
template_up <- 
  read_sheet(ss, 
             sheet = i_want_this_sheet, 
             range = this_range , 
             col_types = "cccCcciccd") %>% # "cccccciccd"
  # dplyr::select(1:10) %>% 
  dplyr::filter(!is.na(Country)) %>% 
  left_join(Lookup, by = c("Country","Region")) %>% 
  dplyr::select(-Code) %>% 
  rename(Code = `ISO 3166-2`) %>% 
  select(Country, Region, Code, Date, Sex, Age, AgeInt, Metric, Measure, Value)

# now locate the Date cell for formula creation:
the_date_row <- 
  read_sheet(ss, 
             sheet = i_want_this_sheet, 
             range = "A1:A20", 
             col_types = "c",
             col_names  = FALSE) %>% 
  dplyr::pull(`...1`) %>% `==`("Date") %>% which()

# now grab the date row and find the one that's a dmy date!
col_index <- read_sheet(ss, 
                        sheet = i_want_this_sheet, 
                        range = paste0("A",the_date_row,":","J",the_date_row), 
                        col_types = "c",
                        col_names  = FALSE) %>% 
  unlist() %>% 
  lubridate::dmy() %>% 
  is.na() %>% `!` %>% which()

# template object to post
template_up <- 
  template_up %>% 
  mutate(Date = gs4_formula(paste0("=$",LETTERS[col_index],"$",the_date_row)))

out_range <- paste0("A",my_skippy,":","J",nrow(template_up)+my_skippy)

# write, and visually check
range_write(ss,
            data = template_up,
            sheet = i_want_this_sheet,
            range = out_range)


# }