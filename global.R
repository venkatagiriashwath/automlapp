library(shiny)
library(shinyWidgets)
library(h2o)
library(ggplot2)
library(plotly)
library(DT)
library(shinyjs)
library(esquisse)

predictors <- NULL
responses <- NULL
df <- NULL
predict_df <- NULL
colnames <- NULL
prediction_condition <- NULL 
glm_model <- NULL
predicted_table_output <- NULL
attribute_df <- NULL


read_file <- function(file_datapath, file_header, file_sep, file_quote){
  df <- read.csv(file_datapath,
                 header = file_header,
                 sep = file_sep,
                 quote = file_quote)
  return(df)
}

get_extension <- function(filename){
  
  split <- unlist(strsplit(filename,"\\."))
  split_length <- length(unlist(strsplit(filename,"\\.")))
  return(split[split_length])
}

remove_list_element <- function(old_list, list_element){
  new_list <- NULL
  iter_old <- 1
  iter_new <- 1
  
  repeat{
    
    if(old_list[iter_old] != list_element)
    {
      new_list[iter_new] <- old_list[iter_old] 
      iter_new <- iter_new+1
      iter_old <- iter_old+1
    }
    else
      iter_old <- iter_old+1
    
    if(iter_old > length(old_list))
      break
  }
  
  return(new_list)
}

attribute_df_gen <- function(){
  column <- colnames(df)
  class_name <- unlist(unname(lapply(df, class)))
  attribute_df <<- data.frame(cbind(column, class_name))
  attribute_df$column <<- as.character(attribute_df$column)
  attribute_df$class_name <<- as.character(attribute_df$class_name)
} 

change_attribute_value <- function(row_index, selected_attribute)
{
  
  column_name <- attribute_df[row_index, 1]
  attribute_df[row_index, 2] <<- selected_attribute
  
  if(selected_attribute == "character")
    df[[column_name]] <<- as.character(df[[column_name]])
  
  else if(selected_attribute == "numeric")
    df[[column_name]] <<- as.numeric(df[[column_name]])
  
  else if(selected_attribute == "factor")
    df[[column_name]] <<- as.factor(df[[column_name]])
  
  else if(selected_attribute == "Date")
    df[[column_name]] <<- as.Date(df[[column_name]])

}

autoMLleaderboard <- function(train_test_split, max_no_models, seed_value, no_of_folds, maximum_time){
  h2o_dataframe <- as.h2o(df, destination_frame = "h2o_dataframe")
  df_split <- h2o.splitFrame(data = h2o_dataframe, ratios = train_test_split/100.0)
  df_train <- df_split[[1]]
  df_test  <- df_split[[2]]
  aml <- h2o.automl(x=predictors, y=responses, training_frame = df_train, max_models= max_no_models, seed= seed_value, nfolds = no_of_folds, max_runtime_secs = maximum_time)
  lb <- aml@leaderboard
  lb <- as.data.frame(lb)
  return(lb)
}

autoMLpredict <- function(lb, index){
  df_test <- as.h2o(predict_df, destination_frame = "df_test")
  model_list <- lb$model_id
  model <- h2o.getModel(model_list[index])
  prediction_values <- h2o.predict(model, df_test)
  prediction_table <- cbind(predict_df, as.data.frame(prediction_values))
  return(prediction_table)
}

# linear.regression <- function(train_test_split){
#   set.seed(90)
#   h2o_df <- as.h2o(df, destination_frame = "h2o_df")
#   # data_frame[-1] <- data_frame[-1]*100
#   
#   #Creating data partition based on split value given
#   
#   df_split <- h2o.splitFrame(data = h2o_df, ratios = train_test_split/100.0)
#   df_train <- df_split[[1]]
#   df_test <- df_split[[2]]
#   
#   
#   #Executing the Linear Model based on training set
#   glm_model <<- h2o.glm(training_frame = df_train, x = predictors, y = responses, family="gaussian", max_runtime_secs = 30, standardize = TRUE)
#   
#   #Predicting Y based on the linear model giving X_test as input
#   glm_pred <- h2o.predict(object = glm_model, newdata = df_test)
#   
#   glm_perf <- h2o.performance(model = glm_model, newdata = df_test)
#   
#   # Comparing predicted Y and actual Y(y_test)
#   mse <- h2o.mse(object = glm_perf)
#   rmse <- sqrt(mse)
#   mae <- h2o.mae(object = glm_perf)
#   
#   # plot(df_test$predictors[1], df_test$response, pch=19, xlab = "Predictors", ylab = "Response")
#   # plot(glm_model)
#   
#   return(list(rmse, mse, mae))
# }
