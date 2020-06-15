library(ggplot2)
library(data.table)
library(plotly)
library(shiny)

country.names.10 <- c("Algeria","Argentina","Australia","Austria","Bangladesh","Belgium","Bolivia","Brazil","Bulgaria",
                   "Cameroon","Canada","Chile","China","Colombia","Cuba","Czechia","Denmark","Dominican Republic",
                   "Ecuador","El Salvador","England","Estonia","Eswatini","Ethiopia","Finland","France","Gambia",
                   "Germany","Greece","Honduras","India","Ireland","Israel","Italy","Jamaica","Japan","Kyrgyzstan",
                   "Mexico","Mozambique","Nepal","Netherlands","New Zealand","Nigeria","Northern Ireland","Norway",
                   "Pakistan","Panama","Philippines","Portugal","Romania","Scotland","Senegal","South Africa","South Korea",
                   "Spain","Sweden","Switzerland","Taiwan","UK","USA","Venezuela")

 shinyUI(
   
    fluidPage(
      titlePanel('COVerAGE-DashBoard'),
      
      tags$style(type = 'text/css', '.navbar { background-color: white}',
                 '.navbar-default .navbar-brand {
                             color: grey;
                             font-size: 13px}'),
      
      
        tabsetPanel(
          tabPanel("Overview",
                     mainPanel(
                       br(),
                       div(h3('The COVerAGE-DashBoard interactive tool presents x different visualizations to show 
                              COVID-19 cases, deaths, and tests by age and sex'),
                           style = "text-align:justify;"),
                       br(),
                       div(h3('Team'),
                           style = "text-align:justify;"),
                       div(h4("José Manuel Aburto, Enrique Acosta, Diego Alburez-Gutierrez, Anna Altová, Ugofilippo Baselini, 
                              Simona Bignami, Didier Breton, Jorge Cimentada, Emanuele del Fava, Viorela Diaconu, Jessica Donzowa, 
                              Christian Dudel, Toni Froehlich, Alain Gagnon, Mariana Garcia Cristómo, Armando González, Irwin Hecker, 
                              Chia Liu, Andrea Lozer, Mădălina Manea, Victor Manuel Garcia Guerrero, Ryohei Mogi, Saskia Morwinsky, 
                              Mikko Myrskylä, Marilia Nepomuceno, Natalie Nitsche, Anna Oksuzyan, Emmanuel Olamijuwon, Marius Pascariu, 
                              Filipe Ribeiro, Tim Riffe, Silvia Rizzi, Francisco Rowe, Jiaxin Shi, Rafael Silva, Cosmo Strozza, 
                              Catalina Torres, Sergi Trias, Fumiya Uchikoshi, Alyson van Raalte, Paola Vasquez, Estevão Vilela, 
                              Iván Williams, Virginia Zarulli"),
                           style = "text-align:justify;"),
                       br(),
                       div(h3('Suggested citation'),style = "text-align:justify;"),
                       div(h4('COVerAGE-Data Base. 2020'),
                           style = "text-align:justify;"),
                       br(),
                       div(h3("Should we include logos?"),style = "text-align:justify;"),
                       br()
                       ))
          ,

          
          tabPanel("Various indicators",
                   sidebarLayout(
                     sidebarPanel(
                       selectInput( 'country.ind','Country',country.names.10, selected = "Algeria"),
                       br(),
                       uiOutput('reactive.region'),
                       br(),
                       width = 2
                     ),
                     mainPanel(
                       tags$style(type="text/css",
                                  ".shiny-output-error { visibility: hidden; }",
                                  ".shiny-output-error:before { visibility: hidden; }"),
                       tabsetPanel(
                         tabPanel('Cases', plotlyOutput('cases.10',width = '100%'),
                                  hr()),
                         tabPanel('Tests', plotlyOutput('tests.10',width = '100%'),
                                  hr()),
                         tabPanel('Deaths', plotlyOutput('deaths.10',width = '100%'),
                                  hr()),
                         tabPanel('ASCFR', plotlyOutput('ascfr.10',width = '100%'),
                                  hr())
                         )))),
          
          tabPanel("Documentation",
                   tabsetPanel(
                     tabPanel('User manual',h3('Download use manual'), downloadLink("UserManual", "Manual")),
                     tabPanel('Data sources and methodology',h3('Download. Add the pdf extension when downloading.'), downloadLink("methods", "Source and methods"))
                   )
                   )
         
         
         )
      )
    )
  



  