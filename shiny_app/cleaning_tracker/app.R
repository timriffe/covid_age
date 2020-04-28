library(shiny)
library(dplyr)
## devtools::install_github("tidyverse/googlesheets4")
library(googlesheets4)
library(plotly)
source("./check_data.R")
gs4_deauth()

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
## output_csv <- read.csv("https://raw.githubusercontent.com/timriffe/covid_age/master/Data/Output_10.csv")

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
      tabsetPanel(type = "tabs",
                  tabPanel("Bulk checks", verbatimTextOutput("log_errors"))
                  ## tabPanel("Death anomalies", plotlyOutput("death_counts"))
                  )
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

    ## sheet_to_read <- "https://docs.google.com/spreadsheets/d/15kat5Qddi11WhUPBW3Kj3faAmhuWkgtQzioaHvAGZI0/edit?usp=sharing"
    ## sheet_to_read <- sheets_info %>% filter(Country == "Estonia") %>% pull(Sheet)
    ## sheet_to_read <- sheets_info %>% filter(Country == "Spain", Short == "ES") %>% pull(Sheet)
    sheet_read <- read_sheet(sheet_to_read,
                             sheet = "database",
                             col_types = "cccccciccn")

    final_error <- run_checks(sheet_read, "./log.txt")

    glue::glue(paste0(final_error, collapse = "\n"))
  })

  ## output$death_counts <- renderPlotly({
    
  ##   res <-
  ##     output_csv %>%
  ##     mutate(country_id = paste0(Country, " - ", Region, " - ", gsub("[0-9]+|\\.", "", Code)),
  ##            Date = as.Date(Date, format = "%d.%m.%Y")) %>%
  ##     ## filter(country_id == input$select_sheet) %>% 
  ##     filter(country_id == "Spain - All - ES") %>%
  ##     as_tibble()

  ##     res_negative <-
  ##       res %>%
  ##       filter(Age == 10, Sex == "m") %>%
  ##       group_by(Sex) %>% 
  ##       mutate(lag_deaths = lag(Deaths),
  ##              diff_deaths = Deaths - lag_deaths) %>%
  ##       ## select(Deaths, lag_deaths, diff_deaths) %>%
  ##       ## print(n = Inf)
  ##       filter(diff_deaths < 0)

  ##   p1 <-
  ##     res %>% 
  ##     ggplot(aes(Date, Deaths, linetype = Sex)) +
  ##     geom_line() +
  ##     geom_point(data = res_negative, aes(label = Code), color = "red", size = 1) +
  ##     facet_wrap(~ Age, scales = "free_y") +
  ##     ggtitle(label = NULL, subtitle = paste0("**Only dates between ", min(res$Date), " and ", max(res$Date), "**")) +
  ##     theme_bw() +
  ##     theme(axis.text.x = element_text(angle = 90))

  ##     ggplotly(p1)
  ## })
}

# Run the application 
shinyApp(ui = ui, server = server)
