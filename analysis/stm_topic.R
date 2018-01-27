###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Topic Models: stm library
# Michele Claibourn
# January 23, 2018
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
threads <- read_csv("stories_latest.csv")
stories <- threads %>% filter(type=="submission")
summary(stories)

r_corpus <- corpus(stories$text)
summary(r_corpus)

docvars(r_corpus, "party") <- stories$party
docvars(r_corpus, "title") <- stories$title
docvars(r_corpus, "date") <- stories$`Time Posted`
eventdate <- as.Date("2017-08-10", format="%Y-%m-%d")
stories$days <- difftime(stories$`Time Posted`, eventdate ,units="days")
docvars(r_corpus, "days") <- stories$days

r_dfm <- dfm(r_corpus, remove = stopwords("english"), remove_punct = TRUE)
r_dfm
r_dfm_trim <- dfm_trim(r_dfm, min_count = 3, max_docfreq = 375, verbose = TRUE)
r_dfm_trim

# format for stm
r_dfm_stm <- convert(r_dfm_trim, to="stm")

# searchK estimates topic exclusivity, coherence; model likelihood, residuals for each k
t1 <- Sys.time()
eval_k <- searchK(r_dfm_stm$documents, r_dfm_stm$vocab, K = seq(5,40,5), 
                     prevalence = ~ as.factor(party) + s(days), 
                     data = r_dfm_stm$meta, init.type = "Spectral")
Sys.time() - t1 # ~ 13 mins
plot(eval_k) # ~ 15
# Plot exclusivity by coherence, ~ 10
plot(eval_k$results$exclus, eval_k$results$semcoh)
text(eval_k$results$exclus, eval_k$results$semcoh, labels = eval_k$results$K, pos=4)

## Estimate with k=10
r_fit <- stm(r_dfm_stm$documents, r_dfm_stm$vocab, K = 10,
                   prevalence = ~ as.factor(party) + s(days), 
                   max.em.its = 75,
                   data = r_dfm_stm$meta, init.type = "Spectral")

## Examine
# Topic quality
topicQuality(r_fit, r_dfm_stm$documents)
# Topic prevalence
plot(r_fit, type = "summary", labeltype="frex")
# Topic top words
labelTopics(r_fit)
# Topic prevalence by covariates
r_effect <- estimateEffect(1:10 ~ party, r_fit, meta = r_dfm_stm$meta)
plot(r_effect, covariate = "party", topics = 1)
# xlim=c(-0.2, 0.5), labeltype="custom", custom.labels=c("NYT", "WSJ", "WP"))


# Save
save.image("reddit_stm.RData")
# load("reddit_stm.RData")

