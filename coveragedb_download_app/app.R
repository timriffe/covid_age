#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(here)
source(here("R","00_Functions.R"))

library(shiny)
library(tidyverse)
library(lubridate)
library(readr)
library(covidAgeData)

if (!dir.exists("Data")){
  dir.create("Data")
}

# if (interactive()){
#     setwd("coveragedb_download_app")
# }
# this can be replaced with a local load if the app
# has access to N, or alternatively a local load could be put
# on a twice-daily timer, simply overwriting the file?
is_this_a_first_run <- !file.exists("Data/Output_10.zip")

if (!is_this_a_first_run){
  date_in <-readr::read_lines("Data/Output_10.zip",n_max=2) %>% 
      '['(2) %>% 
      str_split(pattern = ": ") %>% 
      '[['(1) %>% 
      '['(2) %>% 
      str_split(pattern=" ") %>% 
      '[['(1) %>% 
      '['(c(5,2,3)) %>% 
      paste(collapse="-") %>% 
      ymd()
} else {
    # just to make a placeholder
    date_in <- today()
}

if ((date_in < (today() - 1)) | is_this_a_first_run){
    O5  <- download_covid(data = "Output_5", dest = "Data")
    O10 <- download_covid(data = "Output_10", dest = "Data")
} else {
    cnames <-  c("Country","Region","Code","Date","Sex","Age","AgeInt","Cases","Deaths","Tests")
    O5  <- readr::read_csv("Data/Output_5.zip",
                    skip = 4,
                    col_names = cnames,
                    col_types = "ccccciiddd")
    O10  <- readr::read_csv("Data/Output_10.zip",
                    skip = 4,
                    col_names = cnames,
                    col_types = "ccccciiddd")
}


O5 <-
    O5 %>% 
    mutate(Date = lubridate::dmy(Date))
O10 <-
    O10 %>% 
    mutate(Date = lubridate::dmy(Date))


dateMin <- min(O10$Date)
dateMax <- today()

ctries <- O10$Country %>% unique() %>% sort()
#countries <- O10$Country %>% unique()

# Define UI for application 
ui <- fluidPage(
    
    headerPanel("COVerAGE-DB Downloader App"),
  
    # App title ----
    titlePanel("Download smaller subsets of the data based on limited filters"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Choose dataset ----
            selectInput("dataset", "Choose a dataset:",
                        choices = c("Output_5", "Output_10")),
            dateInput("date_min", "Earliest Date:",
                      startview = "year", min = dateMin, max = dateMax),
            dateInput("date_max", "Latest Date:",
                      startview = "year", min = dateMin, max = dateMax),
            selectInput("country_list","Select Countries",
                        ctries, 
                        multiple = TRUE),
            checkboxInput("national", label = "Only national-level data?", value = TRUE),
            # Button
            downloadButton("downloadData", "Download")
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            titlePanel("Glimpse of first several rows of selected data"),
            tableOutput("table")
            
        )
        
    )
)

# Define server logic 
server <- function(input, output) {
    
    # Reactive value for selected dataset ----
    datasetInput <- reactive({
        switch(input$dataset,
               "Output_5" = O5,
               "Output_10" = O10) %>% 
            dplyr::filter(Date >= input$date_min,
                          Date <= input$date_max,
                          Country %in% input$country_list,
                          ifelse(input$national,Region == "All",TRUE)) 
    })
    # show head of data
    datasetInputHead <- reactive({
      switch(input$dataset,
             "Output_5" = O5,
             "Output_10" = O10) %>% 
        dplyr::filter(Date >= input$date_min,
                      Date <= input$date_max,
                      Country %in% input$country_list,
                      ifelse(input$national,Region == "All",TRUE))  %>% 
        head(20)
    })
    # Table of selected dataset ----
     output$table <- renderTable({
       datasetInputHead()
     })
    
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$dataset, ".csv", sep = "")
        },
        content = function(file) {
            write.csv(datasetInput(), file, row.names = FALSE)
        }
    )
    
}
# Run the application 
shinyApp(ui = ui, server = server)
