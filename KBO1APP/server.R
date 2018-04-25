# BYS 3.1.18
# This is the server.R for the What is the next word shiny app.
#
# BYL 3.12.18
# The quanteda package installation hung on my Shiny server.  Thus, the references to the package
# and its tokens functions are replaced with alternative code.

library(shiny)
library(dplyr)
source('NLP_KBO.R') 

# Define server logic required to draw a histogram


shinyServer(function(input, output) {
   
   # buildKBO() is a recursive function. The lower-order ngram table variable names get calculated inside the function
   # when no terms match input$searchTerms at the 'current' order of n-gram.  As such, the n-gram tables need to be defined 
   # at the parent environment for their referenceability.
   
   stopwordDF = read.csv("stopword.csv")
   
   trBV1 <<- readRDS(file="trBV1.Rds")
   trBV2 <<- readRDS(file="trBV2.Rds")
   trBV3 <<- readRDS(file="trBV3.Rds")
   trBV4 <<- readRDS(file="trBV4.Rds")  
   
   stopwords.vec = as.character(stopwordDF$x)
   
   searchTerms = reactive({
      
      Terms = tolower(input$searchTerms)
      Terms = strsplit(Terms," ")[[1]]
      
      Terms = gsub(x=Terms,pattern=paste(stopwords.vec,collapse = "|"),replacement="")
      Terms = Terms[Terms !=""]
      
      if (length(Terms)>=3) {
         Terms = Terms[(length(Terms)-2):length(Terms)]  # take the last 3 words
         Terms = paste0(as.character(Terms),"_",collapse="") # add the _ char as the delimiter and string them along
         Terms = substr(Terms,1,nchar(Terms)-1)  # remove the trailing the _ char
      } else {
         Terms=c("")
      }
   })
   
   KBO.df = reactive({
      
      discount=.75
      df= buildKBO(searchTerms(),nGram=trBV4,prior.nGram=trBV3, discount)
   
   })
   
   output$Top_words_text = renderUI({
      
      if (searchTerms()!=""){
         HTML(
            paste0("The following words are predicted following <b>",input$searchTerms,"</b>")
         )
      } else {  # if searchTerms become blank after stripping common words
         HTML(
            paste0("Unfortunately, I cannot predict any words following <b>",input$searchTerms,"</b>")
         )
      }
   }) # Top_words_text
   
   output$Top_words_table = renderTable({
      if (searchTerms()!="") {
         TopWords = KBO.df()
         if (nrow(TopWords)>0) {
            TopWords = head(TopWords[order(-TopWords$MLE),],input$topNum)
            predWords = as.character(lapply(strsplit(as.character(TopWords$term), split="_"),
                                          tail, n=1))
            df = as.data.frame(predWords)
            names(df) = c("Predicted Words")
            df
         } else {
            error_msg = c("Unfortunately, I cannot predict any words. Try a different phrase.")
            df = data.frame(error_msg)
            names(df) = c("Error Message")
            df
         } # if nrow(...)
         
      } # if searchTerms
   }) # output$TopWordsp
   
})
