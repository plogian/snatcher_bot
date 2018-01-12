setwd("/app")

library(twitteR)
snatcher_twitter_api_key <- "your twitter api key here"
snatcher_twitter_api_secret <- "your twitter api secret here"
snatcher_twitter_access_token <- "your twitter access token here"
snatcher_twitter_access_token_secret <- "your twitter access secret here"

start <- as.POSIXlt("2017-11-30 13:30:00 UTC")
now <- Sys.time()
difference <- as.numeric(difftime(now, start, units='mins'))
count <- floor(difference/10) + 4


tweetCorpus <- read.csv("tweetCorpus.csv", stringsAsFactors = F)
tweetContent <- tweetCorpus[count, 2]

snatcher_api_key             <- snatcher_twitter_api_key
snatcher_api_secret          <- snatcher_twitter_api_secret
snatcher_access_token        <- snatcher_twitter_access_token
snatcher_access_token_secret <- snatcher_twitter_access_token_secret
origop <- options("httr_oauth_cache")
options(httr_oauth_cache=F)
setup_twitter_oauth(snatcher_api_key, snatcher_api_secret, snatcher_access_token, snatcher_access_token_secret)
options(httr_oauth_cache=origop)

tweet(tweetContent)

q()