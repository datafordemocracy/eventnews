###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Exploration, descriptives
# Michele Claibourn
# February 2, 2018
###################################

#####################
# Loading libraries
# Setting directories
#####################
rm(list=ls())

library(tidyverse)
library(quanteda)
library(stm)
library(timevis)
library(ggplot2)
library(scales)
library(plyr)
setwd("/Users/mpc8t/Box Sync/mpc/dataForDemocracy/newspaper/reddit_cville")
load("reddit_features.RData")

# descriptives for on right, left
stories2 <-threads
table(stories2$party)

# no total comments available
options(tibble.width = Inf)
stories2 %>% group_by(party) %>% 
  summarize(n_auth = n_distinct(author),
            avg_upvotes = mean(upvotes), sd_upvotes = sd(upvotes),
            avg_downvotes = mean(downvotes), sd_downvotes = sd(downvotes),
            avg_score = mean(score), sd_score = sd(score), 
            n_domain = n_distinct(domain))

# what domains
party_domain <- stories2 %>% group_by(party, domain) %>% 
  summarize(freq = n()) %>% arrange(party, desc(freq))

ggplot(filter(party_domain, freq>1), aes(reorder(domain, freq), y = freq)) +
  geom_bar(stat = "identity") + coord_flip() +
  facet_wrap(~ party) 



##########################
## Time Stamp Analysis ###
##########################
# Read stories
mydata <- read_csv("stories_latest.csv")
# Subset only submission data
submission <- subset(mydata,type=='submission')
# Take only from months starting in August 2017
submission <- subset(submission, `Time Posted` >= as.POSIXct('2017-08-04'))
# Aggregate posts so anything less than one can be eliminated
new_submission<-count(submission, c('domain','party','`Time Posted`'))
new_submission<-subset(new_submission,freq>1)
#Subset new df for comments greater than 2
comments_graph<-subset(submission,`total comments`>2)

author_count<-count(submission, c('author','party','`Time Posted`'))
# Graph for author and time posted
ggplot(submission,aes(x=`Time Posted`, y=author,colour=party))+ geom_point()+ scale_color_manual(values=c("#4863A0", "#F8766D"))

# Graph of author and frequency of posting
author_consolidated<-subset(author_count,freq>=1)
ggplot(author_consolidated,aes(x=`Time.Posted`, y=author,colour=party))+ geom_point(aes(size=freq))+ scale_color_manual(values=c("#4863A0", "#F8766D"))

# Graph for domain and time posted where domain has more than 1 submission per day
ggplot(new_submission,aes(x=`Time.Posted`, y=domain,colour=party))+ geom_point(aes(size=freq))+ scale_color_manual(values=c("#4863A0", "#F8766D"))
# Graph for domain and time posted
ggplot(submission,aes(x=`Time Posted`, y=domain,colour=party))+ geom_point()+ scale_color_manual(values=c("#4863A0", "#F8766D"))

# Graph for total comments with time ( popularity of posts over time)

ggplot(comments_graph,aes(x=`Time Posted`, y=`total comments`,colour=party))+ geom_point()+ scale_color_manual(values=c("#4863A0", "#F8766D"))

# Graph for total score with time
ggplot(submission,aes(x=`Time Posted`,y=`score`,colour=party))+geom_point()+scale_color_manual(values=c("#4863A0", "#F8766D"))

# Graph for total downvotes with time
submission[, 7:8] <- sapply(submission[, 7:8], as.numeric)
plot1<-ggplot(submission,aes(x=`Time Posted`,y=`downvotes`,colour=party))+geom_point()+scale_color_manual(values=c("#4863A0", "#F8766D"))

#  Graph for total upvotes with time
plot2<-ggplot(submission,aes(x=`Time Posted`,y=`upvotes`,colour=party))+geom_point()+scale_color_manual(values=c("#4863A0", "#F8766D"))

require(gridExtra)
grid.arrange(plot1, plot2, ncol=2)
############################
# Analysing User comments ##
############################

user_comments <- subset(mydata,type=='comment',select=author)
freq_auth <- count(user_comments, "author")
authorComments<-head(freq_auth[order(-freq_auth$freq),],10)

## Split data by left and right
left_comments<-subset(mydata,type=='comment' & party=='left')
right_comments<-subset(mydata,type=='comment' & party=='right',select=author)
left_freq <- count(left_comments, "author")
right_freq <- count(right_comments, "author")
left_freq<-head(left_freq[order(-left_freq$freq),],10)
right_freq<-head(right_freq[order(-right_freq$freq),],10)

#########################
##  ##
#########################
