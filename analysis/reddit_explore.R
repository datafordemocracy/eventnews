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

setwd("/Users/mpc8t/Box Sync/mpc/dataForDemocracy/newspaper/reddit_cville")
load("reddit_features.RData")

# descriptives for on right, left
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
