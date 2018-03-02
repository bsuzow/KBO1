#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
source('NLP_KBO.R') 

# Define server logic required to draw a histogram


shinyServer(function(input, output) {
   
   # buildKBO() is a recursive function. The lower-order ngram table variable names get calculated inside the function
   # when no terms match input$searchTerms at the 'current' order of n-gram.  As such, the n-gram tables need to be defined 
   # at the parent environment for their referenceability.
   
   trBV1 <<- readRDS(file="trBV1.Rds")
   trBV2 <<- readRDS(file="trBV2.Rds")
   trBV3 <<- readRDS(file="trBV3.Rds")
   trBV4 <<- readRDS(file="trBV4.Rds")

   KBO.df = reactive({
      discount=.5
      df= buildKBO(input$searchTerms,nGram=trBV4,prior.nGram=trBV3, discount)
   })
   
   
   output$Top10_words_text = renderUI({
      
      HTML(
         paste0("The following words are predicted following ",input$searchTerms)
         
         )
   }) # Top10_words_text
   
   output$Top10_words_table = renderTable({
      Top10 = KBO.df()
      Top10 = head(Top10[order(-Top10$MLE),"term"],10)
      Top10
      
   })
   
   output$Top100_words_text = renderUI({
      
      HTML(
         paste0("The predicted words that made the top 100 list as the next word to the phrase ",input$searchTerms)
         
      )
   }) # Top10_words_text
   
   output$Top100_words_table = renderTable({
      Top100 = KBO.df()
      Top100 = head(Top100[order(-Top100$MLE),"term"],100)
      Top100
      
   })
   
})
