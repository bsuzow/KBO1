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
  titlePanel("What is the next word? - Under Construction"),
  
  
  sidebarLayout(
    sidebarPanel(
          br(),
          
          textInput("searchTerms","Enter your phrase"),
          
          submitButton("Submit"),
          
          br(),
          hr(),
          
          a(href="http://suzow.us","About this app"),
          br(),
          hr()
          # tags$div("These estimates are based on"),
          # tags$a("the Migration and Remittances 
          #        Factbook 2016, which includes new bilateral data on migration stocks, 
          #        World Bank.  ", href="https://www.worldbank.org/prospects/migrationandremittances"),
          # 
          
          # br(),
          # tags$p("The database of the UN Population Division (UNPD) is the most comprehensive 
          #        source of information on international migrant stocks for the period 1960–2013. "),
          # tags$a("Read more ...",href="https://www.knomad.org/data/faqs")
       
    ), # sidebarPanel
    
    # Show a plot of the generated distribution
    mainPanel(
       tabsetPanel(type="tabs",
          tabPanel("Top 10 words predicted to follow the phrase you entered",
             br(),
             htmlOutput("Top10_words_text"),
             hr(),
             tableOutput("Top10_words_table")
                            
          ), # tabPanel - Top10

          tabPanel("Top 100 words predicted",
             br(),
             htmlOutput("Top100_words_text"),
             hr(),
             tableOutput("Top100_words_table")

          ) # tablPanel - Top100
                   
       ) # tabsetPanel
    ) # mainPanel
  ) # sidebarLayout
))
