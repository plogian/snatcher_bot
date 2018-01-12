# snatcher_bot
Created twitter bot that tweets rhymed versions of classical novel titles.

This is deployed on Heroku. 

buildTweetDB.R creates a tweetCorpus. 
init.R is required to download packages on Heroku's R buildpack.
run.R is what runs every two hours to send out the tweets. 

Running live here: 
https://twitter.com/SnatcherInThePi
