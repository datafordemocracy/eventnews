###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Add features
# Michele Claibourn
# February 20, 2018
###################################

rm(list=ls())

# Loading libraries
library(tidyverse)
library(tm)
library(quanteda)
library(stm)

# Setting directories, reading in data
setwd("/Users/mpc8t/Box Sync/mpc/dataForDemocracy/eventnewsshared/reddit_cville/Data/")
load("reddit_text.RData")

##############
## Complexity
##############
# Call on untransformed corpus
readability <- textstat_readability(qcorpus,
                                            measure = "Flesch.Kincaid")
stories2$readbility <- readability$Flesch.Kincaid


####################
# Sentiment/Polarity
####################
# Call on untransformed corpus
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
# Apply to untransformed corpus
mf_score <- dfm(qcorpus, dictionary = mfdict) 

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


#####################
# Left/Right keywords
#####################
# Create dictionary
keydict <- dictionary(list(l_dsa="dsa*", l_fogel="fogel*", l_comrad="comrad*",
                           l_fund="fund*", l_committee="committee*", l_worker="worker*",
                           l_ncf="ncf*", l_torch="torch*", l_blackmon="blackmon*", 
                           l_npc="npc*",
                           r_media="media*", r_violenc="violenc*", r_stolberg="stolberg*",
                           r_trump="trump*", r_left="left*", r_presid="presid*",
                           r_mcauliff="mcauliff*", r_sheryl="sheryl*", r_barcelona="barcelona*",
                           r_cohn="cohn*"))
# Apply to untransformed corpus
key_score <- dfm(qcorpus, dictionary = keydict, valuetype = "glob") 

# Turn into data frame and add to existing stories2
kw_score <- as.data.frame(key_score)
stories2[,ncol(stories2)+1:20] <- kw_score[,1:20]

# Generate percents
stories2 <- stories2 %>% 
  mutate(l_dsa=(l_dsa/word_count)*100,
         l_fogel=(l_fogel/word_count)*100,
         l_comrad=(l_comrad/word_count)*100,
         l_fund=(l_fund/word_count)*100,
         l_committee=(l_committee/word_count)*100,
         l_worker=(l_worker/word_count)*100,
         l_ncf=(l_ncf/word_count)*100,
         l_torch=(l_torch/word_count)*100,
         l_blackmon=(l_blackmon/word_count)*100,
         l_npc=(l_npc/word_count)*100,
         r_media=(r_media/word_count)*100,
         r_violenc=(r_violenc/word_count)*100,
         r_stolberg=(r_stolberg/word_count)*100,
         r_trump=(r_trump/word_count)*100,
         r_left=(r_left/word_count)*100,
         r_presid=(r_presid/word_count)*100,
         r_mcauliff=(r_mcauliff/word_count)*100,
         r_sheryl=(r_sheryl/word_count)*100,
         r_barcelona=(r_barcelona/word_count)*100,
         r_cohn=(r_cohn/word_count)*100)


######
# liwc
######
# Read in & create dictionary
lcdict <- dictionary(file = "../../../LIWC2015_English.dic", format = "LIWC") # create dictionary
# Call on untransformed corpus
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
# Topics
########
qdfm_trim <- dfm_trim(qdfm, min_count = 2, max_docfreq = 370, verbose = TRUE)
qdfm_trim # 372 docs, 4,991 features, 95.2% sparse

# format for stm
qdfm_stm <- convert(qdfm_trim, to="stm")

# Previous exploration suggested between 10 and 15 topics
## Estimate with k=15
qfit <- stm(qdfm_stm$documents, qdfm_stm$vocab, K = 15,
             prevalence = ~ as.factor(party) + s(days), 
             max.em.its = 200,
             data = qdfm_stm$meta, init.type = "Spectral")

# Examine: 
# Topic quality
topicQuality(qfit, qdfm_stm$documents) # 3,5 not as exclusive; 1,8,12 not as coherent
# Topic prevalence
plot(qfit, type = "summary", labeltype="prob")
plot(qfit, type = "summary", labeltype="frex")
# Topic top words
labelTopics(qfit)
# Topic prevalence by covariates 
q_effect <- estimateEffect(1:15 ~ party, qfit, meta = qdfm_stm$meta)
# (in order of prevalence)
plot(q_effect, covariate = "party", topics = 14) 
# no diff to more right; trump, presid, white, said, violenc, side, charlotessvill
# join, presid, denounc, remark, blame, bigotri, trump
plot(q_effect, covariate = "party", topics = 13) 
# no diff to more left: white, charlottesvill, protest, ralli, said, right, statu
plot(q_effect, covariate = "party", topics = 15) 
# no diff: peopl, white, group, nazi, one, like, trump
plot(q_effect, covariate = "party", topics = 10) 
# more right: right, white, alt, trump, violenc, antifa, left
plot(q_effect, covariate = "party", topics = 8) 
# no diff: dsa, said, charlottesvill, fund, field, polic, heyer
plot(q_effect, covariate = "party", topics = 6) 
# more right: charlottesvill, polic, news, attack, white, august, state 
plot(q_effect, covariate = "party", topics = 11) 
# no diff: white, charlottesvill, join, supremacist, protest, polic, black 
plot(q_effect, covariate = "party", topics = 2) 
# more left: right, alt, kessler, ralli, white, charlottesvill, unit 
plot(q_effect, covariate = "party", topics = 9) 
# no diff: said, polic, citi, offic, mr, man, second
plot(q_effect, covariate = "party", topics = 3) 
# no diff to more right: right, violenc, speech, one, white, said, protest
plot(q_effect, covariate = "party", topics = 4) 
# more left: us, white, peopl, fascist, charlottesvill, right, black
plot(q_effect, covariate = "party", topics = 7) 
# more left: voter, american, state, nation, action, america, peopl
plot(q_effect, covariate = "party", topics = 12) 
# no diff: charlottesvill, organ, abl, fogel, polic, right, group
plot(q_effect, covariate = "party", topics = 5) 
# more right: peopl, american, polit, violenc, speech, one, like
plot(q_effect, covariate = "party", topics = 1) 
# no diff: call, program, c, year, black, live, can 

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

#######################
# named entities?
# ideological scaling?
#######################
