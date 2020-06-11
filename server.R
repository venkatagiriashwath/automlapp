h2o.init()

server <- function(input, output, session)
{ 
  observeEvent({
    input$tableButton}, {
      
      output$tableOutput <- renderUI({
        box(
          # Output: Data file ----
          div(style = 'overflow-x: scroll; max-height: 50vh; overflow-y: auto;',
              DT::dataTableOutput("contents"))
        )
      })
      
      output$contents <- DT::renderDataTable({
        req(input$file1)
        df <<- read_file(input$file1$datapath, input$header, input$sep, input$quote)
        
        if(input$disp == "head") {
          return(head(df))
        }
        else {
          return(df)
        }
      })
      
      output$attributeTableOutput <- DT::renderDataTable({
        attribute_df_gen()
        datatable(attribute_df, selection = "single")
      })
      
      observeEvent({
        input$attributechangeButton
      },{
        change_attribute_value(input$attributeTableOutput_rows_selected, isolate({input$attributeButtons}))
        
        output$attributeTableOutput <- DT::renderDataTable({
          attribute_df_gen()
          datatable(attribute_df, selection = "single")
        })
        
        })
      
      output$visualiseButton <- renderUI({
          actionButton("esquisseButton", "Visualise!")
      })
      
      # output$responseButtons <- renderUI({
      #   colnames <<- colnames(df)
      #   radioButtons("response_choice", "Responses", choices = colnames)
      # })
      # 
      # output$predictorButtons <- renderUI({
      #   colnames <<- colnames(df)
      #   checkboxGroupInput("predictor_choices", "Predictors", choices = colnames)
      # })
      
      output$automlresponseButtons <- renderUI({
        colnames <<- colnames(df)
        selectizeInput("automl_response_choices", "Responses", choices = colnames)
      })
      
      output$automlpredictorButtons <- renderUI({
        colnames <<- colnames(df)
        selectizeInput("automl_predictor_choices", "Predictors", multiple = TRUE, choices = colnames)
      })
      
      observeEvent({
        input$response_choice
      },{
        x <- remove_list_element(colnames, input$response_choice[1])
        
        updateCheckboxGroupInput(session, "predictor_choices",
                                 label = "Updated predictors",
                                 choices = x 
        )
      })
      
    })
  
  observeEvent({
    input$esquisseButton
  }, 
  {
    updateTabItems(session, "sidebar", selected = "visualisation")
    callModule(module = esquisserServer, id = "esquisse")
  }) 
  
  observeEvent({
    input$automlButton
  },
  
  {
    automlsplit <- isolate({input$automlsplit})
    
    predictors <<- input$automl_predictor_choices
    responses <<- input$automl_response_choices
    
    leaderboard <- autoMLleaderboard(automlsplit, input$maxmodels, input$seedvalue, input$nfolds, input$maxresponsetime*60.0)
    
    output$leaderboard <- DT::renderDataTable({
      datatable(leaderboard, selection = 'single')
    })
                 
    observeEvent({input$leaderboard_rows_selected
      input$modelpredictButton},
                 { 
                   updateTabItems(session, "sidebar", selected = "prediction")
                   
                   observeEvent({
                     input$tableButton1
                   },{
                     
                   output$tableOutput1 <- renderUI({
                       # Output: Data file ----
                              div(style = 'overflow-x: scroll; max-height: 50vh; overflow-y: auto;',
                                  DT::dataTableOutput("contents1"))
                   })
                   
                   output$contents1 <- DT::renderDataTable({
                     
                     req(input$file2)
                     predict_df <<- read_file(input$file2$datapath, input$header1, input$sep1, input$quote1)
                     
                     if(input$disp1 == "head") {
                       return(head(predict_df))
                     }
                     else {
                       return(predict_df)
                     }
                   })
                   observeEvent({
                     input$predictTableButton
                   }, {
                     updateTabsetPanel(session, "prediction_table_tab", "tab2")
                   output$predicted_table <- DT::renderDataTable({
                     predicted_table_output <<- autoMLpredict(leaderboard, input$leaderboard_rows_selected)
                   })

                        output$downloadpredictionButton <- downloadHandler(
                        filename = function() {
                          filename_split <- unlist(strsplit(input$file2$name,'[.]'))
                          f_length <- length(filename_split)
                          filename_without_csv <- paste(filename_split[1:f_length-1], collapse = ".")
                          paste(filename_without_csv, "prediction.csv", sep = "_")
                        },
                        
                        content = function(file) {
                          write.csv(predicted_table_output, file, row.names = FALSE)
                        }
                     )
                   })
                     })
                 })
  })
  
  # observeEvent({input$predictButton
  # },{
  #   splitter <- isolate({input$splitter})
  #   
  #   predictors <<- input$predictor_choices
  #   responses <<- input$response_choice
  #   
  #   list.values <- linear.regression(splitter)
  #   
  #   output$rmse.print <- renderText({sprintf("RMSE= %f", as.numeric(list.values[1]))})
  #   output$mse.print <- renderText({sprintf("MSE= %f", as.numeric(list.values[2]))})
  #   output$mae.print <- renderText({sprintf("MAE= %f", as.numeric(list.values[3]))})
  #   
  #   uis <- NULL
  #   
  #   output$predictor_text_inputs <- renderUI({
  #     predictors_count <- 1:length(predictors)
  #     for (i in seq(predictors)){
  #       uis[[i]] <- textInput(predictors[i], predictors[i], value=0)
  #     }
  #     uis
  #   })
  #   
  # }
  # )
  
#   observeEvent({input$predict_value},
#                { 
#                  output$predicted_value <- renderText({
#                    data_frame <- NULL
#                    for(i in seq(predictors))
#                    {
#                      data_frame[[predictors[i]]] <- as.numeric(input[[predictors[i]]])
#                    }
#                    data_frame <- t(data_frame)
#                    data_frame <- data.frame(data_frame)
#                    h2o_dataframe <- as.h2o(data_frame, destination_frame = "h2o_dataframe")
#                    glm_prediction <- as.data.frame(h2o.predict(object = glm_model, newdata = h2o_dataframe))
#                    sprintf("%s: %f",responses, glm_prediction[[1]])
#                  })
#                })
}
