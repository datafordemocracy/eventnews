###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Add features
# Michele Claibourn
# February 6, 2018
###################################

rm(list=ls())

# Loading libraries
library(tidyverse)
library(tm)
library(quanteda)
library(stm)

# Setting directories, reading in data
setwd("/Users/mpc8t/Box Sync/mpc/dataForDemocracy/newspaper/reddit_cville")
load("reddit_text.RData")

##############
## Complexity
##############
readability <- textstat_readability(qcorpus,
                                            measure = "Flesch.Kincaid")
stories2$readbility <- readability$Flesch.Kincaid


####################
# Sentiment/Polarity
####################
library(sentimentr)
# sentimentr operates on the sentence level
# sentiment_by returns average polarity/sentiment by speech
qc_sentence <- sentiment_by(stories2$text)
stories2[,ncol(stories2)+1:4] <- qc_sentence[,1:4]


###################
# Moral foundations
###################
# Read in & create dictionary
download.file("https://goo.gl/5gmwXq", tf <- tempfile()) # download dictionary
mfdict <- dictionary(file = tf, format = "LIWC") # create dictionary
mf_score <- dfm(qcorpus, dictionary = mfdict) # apply dictionary

# Turn into data frame and add to existing stories2
mf_score <- as.data.frame(mf_score)
stories2[,ncol(stories2)+1:11] <- mf_score[,1:11]

# Generate percents
stories2 <- stories2 %>% 
  mutate(HarmVirtue=(HarmVirtue/word_count)*100,
         HarmVice=(HarmVice/word_count)*100,
         FairnessVirtue=(FairnessVirtue/word_count)*100,
         FairnessVice=(FairnessVice/word_count)*100,
         IngroupVirtue=(IngroupVirtue/word_count)*100,
         IngroupVice=(IngroupVice/word_count)*100,
         AuthorityVirtue=(AuthorityVirtue/word_count)*100,
         AuthorityVice=(AuthorityVice/word_count)*100,
         PurityVirtue=(PurityVirtue/word_count)*100,
         PurityVice=(PurityVice/word_count)*100,
         MoralityGeneral=(MoralityGeneral/word_count)*100)


######
# liwc
######
# Read in & create dictionary
lcdict <- dictionary(file = "../../LIWC2015_English.dic", format = "LIWC") # create dictionary
lc_score <- dfm(qcorpus, dictionary = lcdict) # apply dictionary

# Turn into data frame and add to existing stories2
lc_score <- as.data.frame(lc_score)
# add affect, social, cogproc, drives, time, relativ
lc_restricted <- lc_score[,c(22:39, 49:61)]
names(lc_restricted) <- c("affect", "aff_pos", "aff_net", "neg_anx", 
                          "neg_anger", "neg_sad", "social", "soc_family", "soc_friends",
                          "soc_female", "soc_male", "cogproc", "cp_insight", "cp_cause", 
                          "cp_discrep", "cp_tentative", "cp_certain", "cp_differentiate", 
                          "drives", "dr_affil", "dr_achieve", "dr_power", 
                          "dr_reward", "dr_risk", "time_past", "time_present", 
                          "time_future", "relativity", "rel_motion", "rel_space", 
                          "rel_time")
stories2[,ncol(stories2)+1:31] <- lc_restricted[,1:31]

# Generate percents
stories2 <- stories2 %>% 
  mutate(affect=(affect/word_count)*100,
         aff_pos=(aff_pos/word_count)*100,
         aff_net=(aff_net/word_count)*100,
         neg_anx=(neg_anx/word_count)*100,
         neg_anger=(neg_anger/word_count)*100,
         neg_sad=(neg_sad/word_count)*100,
         social=(social/word_count)*100,
         soc_family=(soc_family/word_count)*100,
         soc_friends=(soc_friends/word_count)*100,
         soc_female=(soc_female/word_count)*100,
         soc_male=(soc_male/word_count)*100,
         cogproc=(cogproc/word_count)*100,
         cp_insight=(cp_insight/word_count)*100,
         cp_cause=(cp_cause/word_count)*100,
         cp_discrep=(cp_discrep/word_count)*100,
         cp_tentative=(cp_tentative/word_count)*100,
         cp_certain=(cp_certain/word_count)*100,
         cp_differentiate=(cp_differentiate/word_count)*100,
         drives=(drives/word_count)*100,
         dr_affil=(dr_affil/word_count)*100,
         dr_achieve=(dr_achieve/word_count)*100,
         dr_power=(dr_power/word_count)*100,
         dr_reward=(dr_reward/word_count)*100,
         dr_risk=(dr_risk/word_count)*100,
         time_past=(time_past/word_count)*100,
         time_present=(time_present/word_count)*100,
         time_future=(time_future/word_count)*100,
         relativity=(relativity/word_count)*100,
         rel_motion=(rel_motion/word_count)*100,
         rel_space=(rel_space/word_count)*100,
         rel_time=(rel_time/word_count)*100)


########
# topics
########
qdfm_trim <- dfm_trim(qdfm, min_count = 3, max_docfreq = 370, verbose = TRUE)
qdfm_trim

# format for stm
qdfm_stm <- convert(qdfm_trim, to="stm")

# Previous exploration suggested between 10 and 15 topics
## Estimate with k=15
qfit <- stm(qdfm_stm$documents, qdfm_stm$vocab, K = 15,
             prevalence = ~ as.factor(party) + s(days), 
             max.em.its = 150,
             data = qdfm_stm$meta, init.type = "Spectral")

# Examine: 
# Topic quality
topicQuality(qfit, qdfm_stm$documents)
# Topic prevalence
plot(qfit, type = "summary", labeltype="frex")
# Topic top words
labelTopics(qfit)
# Topic prevalence by covariates 
q_effect <- estimateEffect(1:15 ~ party, qfit, meta = qdfm_stm$meta)
# (in order of prevalence)
plot(q_effect, covariate = "party", topics = 8) 
# more right; trump, presid, said, white, violenc, charlotessvill, supremacist
# join, presid, denounc, remark, blame, bigotri, trump
plot(q_effect, covariate = "party", topics = 15) 
# more left: white, charlottesvill, said, protest, ralli, right, statu
# lee, remov, e, satu, imag, klan, spencer
plot(q_effect, covariate = "party", topics = 1) 
# more right: peopl, white, nazi, say, want, know, media
# want, obama, care, blm, hat, tell, barack
plot(q_effect, covariate = "party", topics = 6) 
# more left: dsa, fund, field, charlottesvill, polic, said, nation
# ncf, dsa, npc, richmond, fund, field, chapter
plot(q_effect, covariate = "party", topics = 10) 
# no diff: right, protest, violenc, charlottesvill, speech, free, sign
# sign, aclu, boston, free, court, gun, liberti
plot(q_effect, covariate = "party", topics = 9) 
# little more right: right, alt, white, trump , charlottesvill, violenc, antifa
# stolberg, alt, mcinn, sheryl, @sherylnyt, ugli, ciambotti
plot(q_effect, covariate = "party", topics = 4) 
# more right: charlottesvill, polic, news, white, attack, ralli, august
# barcelona, gosar, abc, mcauliff, heimbach, news, dhs
plot(q_effect, covariate = "party", topics = 7) 
# no diff: polic, said, citi, offi, man, mr, ralli
# second, mr, newslett, harri, cohn, amo, heaphi
plot(q_effect, covariate = "party", topics = 14) 
# no diff: white, charlottesvill, america, trump, suprmeacist, nazi, amerian
# penc, kratuamm, homeland, russion, pathet, popul, love
plot(q_effect, covariate = "party", topics = 12) 
# more left: right, white, black, us, peopl, one, action
# satan, chat, antifasciest, en, rock, class, aktion
plot(q_effect, covariate = "party", topics = 11) 
# no diff: trump, antifa, nazi, republican, new, call, time
# journal, editori, span, frazier, caller, voter, merck
plot(q_effect, covariate = "party", topics = 5) 
# more left: american, fogel, peopl, charlottesvill, nation, vote, trump
# fogel, northam, biden, texa, rape, vote, progress
plot(q_effect, covariate = "party", topics = 2) 
# more left: us, fascist, peopl, go, charlottesill, nazi, happen
# blackmon, traci, ami, reid, conrel, west, discord
plot(q_effect, covariate = "party", topics = 3) 
# more right: left, right, violenc, organ, american, charlottesvill, said
# q1, q2, rizzo, alinksi, milo, shut, alabama
plot(q_effect, covariate = "party", topics = 13) 
# more right: peopl, media, group, like, polit, white, get
# languag, manipul, resent, percept, cultiv, smith, element

# Examples
thoughts8 <- findThoughts(qfit, texts = qcorpus$documents$texts, n = 3, topics = 8)
thoughts8$docs[1]
thoughts15 <- findThoughts(qfit, texts = qcorpus$documents$texts, n = 3, topics = 15)
thoughts15$docs[1]
thoughts1 <- findThoughts(qfit, texts = qcorpus$documents$texts, n = 3, topics = 1)
thoughts1$docs[1]

# Add topics as features to stories2
story_topics <- as.data.frame(qfit$theta)
# name these....for the moment, three highest probl words
topicword <- labelTopics(qfit, n=3)[1]
topicnames <- map(1:15, function(x)paste0(topicword$prob[x,1:3], collapse = "-"))
names(story_topics) <- topicnames

stories2[,ncol(stories2)+1:15] <- story_topics[,1:15]

# clean up
rm(lc_restricted, lc_score, lcdict, mf_score, mfdict, qc_sentence, 
   readability, story_topics, temp, topicword, tf, topicnames)
# rm(corpus, corpus_party, corpus_party2, corpus2, dtm)

# Save
save.image("reddit_features.RData")
# load("reddit_features.RData")

#################
# named entities?
#################

######################
# ideological scaling?
# probably not
######################

# keyness, tf-idf largely descriptive; not features of documents