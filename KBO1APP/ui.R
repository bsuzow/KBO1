# BYS 3.1.18
# This is the user-interface definition of the Shiny web application that predicts the next word given a phrase.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# The app URL on the Rstudio Shiny server: https://bsuzow.shinyapps.io/KBO1APP/

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("What is the next word?"),
  
  
  sidebarLayout(
    sidebarPanel(
          br(),
          h4("Enter a phrase with at least 3 words."),
          p("Before entering any phrase, you will see 10 predicted words
             following the phrase 'World Hunger Is Serious...' as it is preset as the input
             for you to see the action"),
          
          textInput("searchTerms","Enter your phrase:", value="World Hunger Is Serious"),
          
          hr(),
          
          h5("Choose the number of next words predicted you want to see"),
          sliderInput("topNum",
                      "Number of predicted words:",
                      min = 5,
                      max = 50,
                      value = 10,
                      step = 1,
                      sep=""),
          
          submitButton("Submit"),
          
          br(),
          hr(),
          
          a(href="http://suzow.us","About this app"),
          br(),
          hr()
          # tags$div(""),
          # tags$a("", href="https://www.dummyurl"),
          # 
          
          # br(),
          # tags$p(" "),
          # tags$a("",href="https://www.dummyurl")
       
    ), # sidebarPanel
    
    # Show a plot of the generated distribution
    mainPanel(
       tabsetPanel(type="tabs",
                   
          tabPanel("Next Word Prediction",
             br(),
             htmlOutput("Top_words_text"),
             hr(),
             
             tableOutput("Top_words_table")
             
                            
          ) # tabPanel - Top10

          # tabPanel("Top 100 words predicted",
          #    br(),
          #    htmlOutput("Top100_words_text"),
          #    hr(),
          #    tableOutput("Top100_words_table")
          # 
          # ) # tablPanel - Top100
                   
       ) # tabsetPanel
    ) # mainPanel
  ) # sidebarLayout
))
