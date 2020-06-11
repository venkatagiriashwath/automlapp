library(shinydashboard)

  header <- dashboardHeader(title="ML Studio")
  
  sidebar <- dashboardSidebar(
    sidebarMenu(id = "sidebar",
      menuItem("Data", tabName = "data", icon = icon("table"), startExpanded = TRUE,
               menuSubItem("Load", tabName = "data_load"),
               menuSubItem("Prep", tabName = "data_prep")),
      menuItem("Visualisation", tabName = "visualisation", icon = icon("chart-bar")),
      menuItem("Modelling", tabName = "modelling", icon = icon("cogs")),
      menuItem("Prediction", tabName = "prediction", icon = icon("lightbulb"))
    )
  )
  
  body <- dashboardBody(
    fluidPage(
      tags$style("html, body {overflow: visible !important;"),
    tabItems(
      tabItem(
        tabName = "data_load",
          box(
            title = tags$b("Upload Data"),
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = TRUE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Checkbox if file has header ----
            checkboxInput("header", "Header", TRUE),
            
            # Input: Select separator ----
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ",", inline = T),
            
            # Input: Select quotes ----
            radioButtons("quote", "Quote",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'", inline = T),
                         selected = '"', inline = T),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Select number of rows to display ----
            radioButtons("disp", "Display",
                         choices = c(Head = "head",
                                     All = "all"),
                         selected = "head", inline = T),
            actionButton("tableButton","Submit")
          ),
          
        uiOutput("tableOutput")
          
      ),
      
      tabItem(
        tabName = "data_prep",
        box(
          div(style = 'overflow-x: scroll; max-height: 50vh; overflow-y: auto;', 
              DT::dataTableOutput("attributeTableOutput"))
        ),
        box(
          radioButtons("attributeButtons", "Change attribute:", list("numeric" = "numeric", "factor" = "factor", "character" = "character", "Date" = "Date")),
          tags$hr(),
          actionButton("attributechangeButton", "Change attribute!")
        ),
        uiOutput("visualiseButton")
      ),
      
      tabItem(
        tabName = "visualisation",
                tags$div( # needs to be in fixed height container
                  style = "position: fixed; top: 0; bottom: 0; right: 0; left: 0;",
               esquisserUI(id = "esquisse"))
           ),
      
      tabItem(
        tabName = "modelling",
               conditionalPanel(condition = "input.tableButton",
                                  titlePanel(h1("AutoML")),
                                
                                box(
                                    uiOutput("automlresponseButtons"),
                                    uiOutput("automlpredictorButtons"),
                                    sliderInput("automlsplit", h3("Train/Test Split"),
                                                min = 50, max=95, value = 75),
                                    sliderInput("maxmodels", h3("Maximum models"), min = 1, max = 10, value = 2),
                                    sliderInput("maxresponsetime", h3("Maximum response time (Minutes)"), min = 1, max = 60, value = 1),
                                    sliderInput("seedvalue", h3("Seed value"), min = 1, max = 1000, value = 1),
                                    sliderInput("nfolds", h3("Number of folds"), min = 2, max = 10, value = 1),
                                    actionButton("automlButton","Run AutoML!")
                                  ),
                                  box(
                                    div(style = 'overflow-x: scroll; max-height: 50vh; overflow-y: auto;',
                                        DT::dataTableOutput("leaderboard")),
                                    tags$hr(),
                                    actionButton("modelpredictButton", "Predict!")
                                    )
                                )
               ),
      tabItem(
        tabName = "prediction",
        conditionalPanel(condition = "input.modelpredictButton",
                         titlePanel("Prediction"),
                           box(
                           title = tags$b("Upload Data"),
                           # Input: Select a file ----
                           fileInput("file2", "Choose CSV File",
                                     multiple = TRUE,
                                     accept = c("text/csv",
                                                "text/comma-separated-values,text/plain",
                                                ".csv")),
                           
                           # Horizontal line ----
                           tags$hr(),
                           
                           # Input: Checkbox if file has header ----
                           checkboxInput("header1", "Header", TRUE),
                           
                           # Input: Select separator ----
                           radioButtons("sep1", "Separator",
                                        choices = c(Comma = ",",
                                                    Semicolon = ";",
                                                    Tab = "\t"),
                                        selected = ",", inline = T),
                           
                           # Input: Select quotes ----
                           radioButtons("quote1", "Quote",
                                        choices = c(None = "",
                                                    "Double Quote" = '"',
                                                    "Single Quote" = "'"),
                                        selected = '"', inline = T),
                           
                           # Horizontal line ----
                           tags$hr(),
                           
                           # Input: Select number of rows to display ----
                           radioButtons("disp1", "Display",
                                        choices = c(Head = "head",
                                                    All = "all"),
                                        selected = "head", inline = T),
                           actionButton("tableButton1","Submit")
                           ),
                         tabBox(id="prediction_table_tab",
                                selected = "tab1",
                                tabPanel("tab1", tags$b("Table for prediction:"),
                                         tags$hr(),
                                         uiOutput("tableOutput1"),
                                         tags$hr(),
                                         actionButton("predictTableButton", "Predict values!")
                                ),
                                
                                tabPanel("tab2", tags$b("Predicted Table:"),
                                         tags$hr(),
                                         conditionalPanel(condition = "input.predictTableButton",
                                                          
                                                          div(style = 'overflow-x: scroll; max-height: 50vh; overflow-y: auto;',
                                                              DT::dataTableOutput("predicted_table")),
                                                          tags$hr(),
                                                          downloadButton("downloadpredictionButton", "Download as CSV")
                                            )
                         )
        )
        )
      )
    )
    )
  )

dashboardPage(header,sidebar,body)
