# BYS 2.16.18
# NLP_KBObi.R


corpus2DF = function(filename) {
   
   if (!file.exists(filename)) {
      stop(paste(filename,"file does not exist! \n\n"))
   }
   
   t1 = Sys.time()
   txt = readLines(filename, warn=FALSE)  # turn off the warn param to ignore missing EOL in the file
   df = as.data.frame(txt)
   print(difftime(Sys.time(), t1, units = 'sec'))
   
   names(df) = c("text")
   
   df
} # corpus2DF


createTrainSet = function(df,trainsize, df.type="train") {
   
   df$id = as.numeric(row.names(df))  # create a new column called id
   df    = df %>% select(id,everything())  # make the id column the first column.
   
   set.seed(1000)
   all_ids = df$id
   train_ids = sample(all_ids, trainsize) 
   test_ids = setdiff(all_ids, train_ids)
   
   train.df = df[train_ids,]
   test.df  = df[test_ids,]  
   
   if (df.type=="train") {
      df = train.df
   } else {
      df = test.df
   }
   
   df = df %>% mutate(text = as.character(text)) %>% # covert the text colume from factor to char
      mutate(text = iconv(text,"latin1","ASCII"," ")) %>% # remove foreign language chars
      mutate(gsub("@\\w+", " ", text)) %>% 
      mutate(gsub("http\\w+", "", text)) %>%    # remove URLs
      mutate(gsub("[ |\t]{2,}", " ", text)) %>% # remove extra tabs
      mutate(gsub("^ ", "", text)) %>%  # remove leading spaces at the beginning
      mutate(gsub(" $", "", text))      # remove trailing spaces
   
}

buildNGram = function(dfm) {
   
   BV = docfreq(dfm)
   BV = melt(BV)
   BV$term = as.character(row.names(BV))  # create a new column called id
   trBV    = BV %>% select(term,everything())  # make the id column the first column
   row.names(trBV) = seq_along(1:nrow(trBV))  # assign sequential numbers to row names 
   names(trBV) = c("term","count")
   trBV
}

MatchInNgram = function(firstTerms,nGramDF,discount) {
# This function returns the 4-word phrase that starts with TrigramPrefix (arg 1) and the highest MLE.
   
# Arguments:
#     FirstTerms: The first words in the phrase being searched
#     nGramDF: an n gram table with two columns (term & count)
#     discount: the discounting factor to be applied to term counts to create probability mass to be distributed to the
#               unobserved

library(dplyr)
   
pattern = paste0("^",firstTerms,"_")
n.df = nGramDF %>% filter(grepl(pattern,term))

n.df = n.df %>% mutate(tailTermCount = count - discount) 
n.df = n.df %>% mutate(MLE = tailTermCount/sum(count))

# if all n.df$MLE is 1, which one to pick?  Should we treat the case the same as the unobserved
      
} # MatchInNgram


buildKBO = function(firstTerms,nGram,prior.nGram,discount) {
   
   # if firstTerms consists of 2 words, nGram should be 3-gram, prior.nGram be 2-gram.
   
   nDF = MatchInNgram(firstTerms,nGram,discount)  # return all rows of nGram matching firstTerms
   ProbMass = 1-sum(nDF$MLE)
   nGramOrder = length(unlist(strsplit(firstTerms,"_")))+1
   
   if (nrow(nDF)>0) {
      
      termlist = strsplit(nDF$term,"_")
      
      lastTerm = unlist(lapply(termlist,"[",nGramOrder))
      
      prior.nPrefix = gsub("^.*?_","_",firstTerms) # remove the first word from firstTerms
      
      if (substr(prior.nPrefix,1,1)=="_") {
         prior.nPrefix = substr(prior.nPrefix,2,nchar(prior.nPrefix))  # remove the _ prefix
      }
      
      setA = paste(prior.nPrefix,lastTerm,sep="_") 
      
      nDF2 = MatchInNgram(prior.nPrefix,prior.nGram,discount)
      # remove firstTerms from prior.nDF
      prior.nDF2 = nDF2 %>% filter(!(term %in% setA))
      prior.nDF2 = prior.nDF2 %>% mutate(MLE = ProbMass*tailTermCount/sum(tailTermCount))
      
     # prior.nDF3 = prior.nDF2 %>% mutate(term= paste(prior.nPrefix,term,sep="_"))
      
      KBOTable = rbind(nDF,prior.nDF2)
      return(KBOTable)
      
   } else {
      
      firstTerms = gsub("^.*?_","_",firstTerms)
      firstTerms = substr(firstTerms,2,nchar(firstTerms))
      
      nGramOrder = nGramOrder-1
      nGram.name = paste0("trBV",as.character(nGramOrder))
      #nGram.name = paste0("trBV",as.character(nGramOrder),"()") # for shiny app?
      nGram = eval(as.name(nGram.name))
     
      
      prior.nGram.name = paste0("trBV",as.character(nGramOrder-1))
      #prior.nGram.name = paste0("trBV",as.character(nGramOrder-1),"()") # for shiny app?
      prior.nGram = eval(as.name(prior.nGram.name))
      
      KBOTable = buildKBO(firstTerms,nGram,prior.nGram,discount)
      
   } # else
   
   if ((nGramOrder-2)==0) {
      #KBOTable
      return(KBOTable)  # https://stackoverflow.com/questions/21698641/how-can-i-write-a-recursive-function-in-r
   }
   KBOTable
   
} # buildKBO