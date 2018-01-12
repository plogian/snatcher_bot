library("NLP")
library("openNLP")
library("openNLPmodels.en")
library(httr)

sent_token_annotator <- Maxent_Sent_Token_Annotator()
word_token_annotator <- Maxent_Word_Token_Annotator()
pos_tag_annotator <- Maxent_POS_Tag_Annotator()

wordsApiKey <- "Your words API key here"

#list of 100 classic books by Penguin
books <- read.csv("books.csv", stringsAsFactors = F, header=F, col.names = c("Title", "Author"), sep=";")

findRhymes <- function(word) {
  url <- paste0("https://wordsapiv1.p.mashape.com/words/", word, "/rhymes")
  resp <- GET(url, add_headers("X-Mashape-Key" = wordsApiKey ,"Accept" = "application/json"))
  rhymeList <- unlist(content(resp)$rhymes$all)
  if(length(rhymeList)==0) {
    return(word)
  }
  removeRhymes <- c()
  for(i in 1:length(rhymeList)) {
    if(nchar(rhymeList[i])==1 | grepl(" |-", rhymeList[i], ignore.case=TRUE) | grepl(as.character(word), rhymeList[i], ignore.case=TRUE)){
      removeRhymes <- c(removeRhymes, i)
    } 
  }
  rhymeListCleaned <- rhymeList[-removeRhymes]
  return(rhymeListCleaned)
}
matchRhymePOS <- function(word) {
  rhymeList <- findRhymes(word)
  if(length(rhymeList)==0){
    return(word)
  }
  else {
    rhymeList <- as.String(rhymeList)
    rhymes <- annotate(rhymeList, list(sent_token_annotator, 
                                       word_token_annotator,
                                       pos_tag_annotator))
    rhymesw <- rhymes[rhymes$type == "word"]
    rhymesPOS <- unlist(lapply(rhymesw$features, `[[`, "POS"))
    removeNonNouns <- c()
    for(i in 1:length(rhymeList[rhymesw])) {
      if(!rhymesPOS[i] %in% c("NN", "NNS", "NNP", "NNPS")){
        removeNonNouns <- c(removeNonNouns, i)
      }
    }
    nounRhymes <- rhymeList[rhymesw]
    if(length(removeNonNouns>0)) {
      nounRhymes <- rhymeList[rhymesw][-removeNonNouns]
    }
    if(length(nounRhymes)==0) {
      return(word)
    }
    return(nounRhymes)
  }
}
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}
randomRhyme <- function(word) {
  nounRhymes <- matchRhymePOS(word)
  index <- sample(c(1:length(nounRhymes)), 1)
  finalRhyme <- simpleCap(nounRhymes[index])
  return(finalRhyme)
}

replaceTitleNouns <- function(title) {
  title <-as.String(title)
  a3 <- annotate(title, list(sent_token_annotator, 
                             word_token_annotator,
                             pos_tag_annotator))
  a3w <- a3[a3$type == "word"]
  POStags <- unlist(lapply(a3w$features, `[[`, "POS"))
  new <- title
  for(i in 1:length(title[a3w])) {
    if(POStags[i] %in% c("NN", "NNS", "NNP", "NNPS")){
      rhyme <- tryCatch({randomRhyme(title[a3w][i])}, error = function(e) {title[a3w][i]})
      new <- gsub(title[a3w][i], rhyme, new)
    }
  }
  return(new)
}

tweetText <- function() {
  randomNumber <- ceiling(runif(1, 0, nrow(books)))
  newTitle <- replaceTitleNouns(books[randomNumber,1])
  tweet <- paste0(newTitle, " by ", books[randomNumber, 2])
  return(tweet)
}

tweetCorpus <- replicate(144000, tweetText())
write.csv(tweetCorpus, "tweetCorpus.csv")