#Auto ML Application

##Overview
The ML Studio is a platform for data visualisation, statistical modelling and predictions using machine learning algorithms. It is based on Shiny and the shinydashboard interface, with esquisse interactive data visualisation, DT HTML tables and H2O machine learning algorithms. The studio provides accessibility to the layman to comprehend data better, with limited or no coding knowledge.

##Features
###Data Management
- Ability to load the data from a CSV file
- Ability to modify the attributes of variables
- Ability to choose the data to visualise amongst the loaded data, for visualisation

###Interactive data visualisation 
This is done with the esquisse package, and includes:
- Ability to draw bar plots, curves, scatter plots, histograms, boxplot and sf objects
- Options for fill, colour, size, group and facet
- Ability to tweak the legends, labels, data displayed
- Ability to export the R code for the produced graph

###Modelling
- Ability to accept predictors and responses
- Ability to accept user-defined inputs, including train/test split, maximum models generated, maximum response time, seed value and number of folds
- Ability to run AutoML based on the parameters defined
- Ability to display a table containing the AutoML models available, in a ranked order
- Ability for the user to choose the model preferred for prediction

###Prediction
- Ability to upload a test set to perform prediction on
- Ability to display the predictions in tabular format
- Ability to download the prediction in CSV format
 
##Software Requirements 
- RStudio
- library(shinydashboard)
- library(shiny)
- library(shinyWidgets)
- library(h2o)
- library(ggplot2)
- library(plotly)
- library(DT)
- library(shinyjs)
- library(esquisse)
