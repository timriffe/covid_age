
load('Plot_Data.RData') #load('shiny_app_2/Plot_Data.RData')

shinyServer(
  function(input, output) {
    
    
    region <- reactive(unique(Plot_data_10[Country %in% input$country.ind]$Region))
    
    output$reactive.region <- renderUI({
      selectInput('region.ind','Region',choices = region())
    })
    
    
    output$deaths.10 <- renderPlotly({
     
      country    <- input$country.ind #country <- 'USA'
      region     <- input$region.ind #region <- 'All'

      Data       <- Plot_data_10[Country %in% country & Region %in% region]

       fig <- ggplot(Data,aes(x=date,y = Deaths, col = Sex, Country = Country, Region = Region, Age = Age, Date = date)) +
         geom_point()+
         theme_bw()+
         facet_grid(Age~Sex,scales = 'free_y')+
         labs(x = "Date", y = NULL,size=10)+
         theme(legend.position='none')
         
       fig <-ggplotly(fig,width = 900, height = 1200,tooltip = c('Country', 'Region', 'Age', 'Date', 'Deaths'))
      
      ggplotly(fig) %>%
        config(modeBarButtonsToRemove= list('toImage',
                                            'sendDataToCloud',
                                            'hoverClosestCartesian',
                                            'hoverCompareCartesian','autoScale2d'),displaylogo= FALSE)
      
      
    })
    
    output$cases.10 <- renderPlotly({
      
      country    <- input$country.ind #country <- 'USA'
      region     <- input$region.ind #region <- 'All'
      
      Data       <- Plot_data_10[Country %in% country & Region %in% region]
      
      fig <- ggplot(Data,aes(x=date,y = Cases, col = Sex, Country = Country, Region = Region, Age = Age, Date = date)) +
        geom_point()+
        theme_bw()+
        facet_grid(Age~Sex,scales = 'free_y')+
        labs(x = "Date", y = NULL,size=10)+
        theme(legend.position='none')
      
      fig <-ggplotly(fig,width = 900, height = 1200,tooltip = c('Country', 'Region', 'Age', 'Date', 'Cases'))
      
      ggplotly(fig) %>%
        config(modeBarButtonsToRemove= list('toImage',
                                            'sendDataToCloud',
                                            'hoverClosestCartesian',
                                            'hoverCompareCartesian','autoScale2d'),displaylogo= FALSE)
      
      
    })
    
    output$tests.10 <- renderPlotly({
      
      country    <- input$country.ind #country <- 'USA'
      region     <- input$region.ind #region <- 'All'
      
      Data       <- Plot_data_10[Country %in% country & Region %in% region]
      
      fig <- ggplot(Data,aes(x=date,y = Tests, col = Sex, Country = Country, Region = Region, Age = Age, Date = date)) +
        geom_point()+
        theme_bw()+
        facet_grid(Age~Sex,scales = 'free_y')+
        labs(x = "Date", y = NULL,size=10)+
        theme(legend.position='none')
      
      fig <-ggplotly(fig,width = 900, height = 1200,tooltip = c('Country', 'Region', 'Age', 'Date', 'Tests'))
      
      ggplotly(fig) %>%
        config(modeBarButtonsToRemove= list('toImage',
                                            'sendDataToCloud',
                                            'hoverClosestCartesian',
                                            'hoverCompareCartesian','autoScale2d'),displaylogo= FALSE)
      
      
    })
    
    output$ascfr.10 <- renderPlotly({
      
      country    <- input$country.ind #country <- 'USA'
      region     <- input$region.ind #region <- 'California'
      
      Data       <- Plot_data_10[Country %in% country & Region %in% region]
      
      fig <- ggplot(Data,aes(x=Age,y = ASCFR, col = date, Country = Country, Region = Region, Age = Age, Date = date)) +
        geom_point()+
        theme_bw()+
        facet_grid(~Sex,scales = 'free_y')+
        labs(x = "Date", y = NULL,size=10)+
        theme(legend.position='none')
      
      fig <-ggplotly(fig,width = 500, height = 500,tooltip = c('Country', 'Region', 'Age', 'Date', 'ASCFR'))
      
      ggplotly(fig) %>%
        config(modeBarButtonsToRemove= list('toImage',
                                            'sendDataToCloud',
                                            'hoverClosestCartesian',
                                            'hoverCompareCartesian','autoScale2d'),displaylogo= FALSE)
      
      
    })
})
    

