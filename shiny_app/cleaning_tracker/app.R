library(shiny)
library(dplyr)
## devtools::install_github("tidyverse/googlesheets4")
library(googlesheets4)

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = TRUE
)

source("./check_data.R")

gs4_auth(token = googledrive::drive_token())

get_input_rubric <- function(tab = "input"){
  ss_rubric <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit#gid=0"
  input_rubric <-
    range_read(ss_rubric, sheet = tab) %>% 
    filter(!is.na(Sheet)) %>%
    select(Country, Short, Region, Sheet) %>%
    mutate(id = paste0(Country, " - ", Region, " - ", Short))

  input_rubric
}

sheets_info <- get_input_rubric()

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Cleaning COVID data tracker"),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    selectInput("select_sheet",
                label = "Which sheet do you want to test?",
                choices = sheets_info$id),
    # Show a plot of the generated distribution
    mainPanel(
      verbatimTextOutput("log_errors")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$log_errors <- renderText({
    sheet_to_read <-
      sheets_info %>%
      filter(id == input$select_sheet) %>%
      pull(Sheet)

    ## x <- "https://docs.google.com/spreadsheets/d/196AFveABgUURRNeTEq2mixVZ0f4AccgDAf_oqrdBrBk/edit?usp=sharing"
    sheet_read <- read_sheet(sheet_to_read,
                             sheet = "database",
                             col_types = "cccccciccn")

    final_error <- run_checks(sheet_read, "./log.txt")

    glue::glue(paste0(final_error, collapse = "\n"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
