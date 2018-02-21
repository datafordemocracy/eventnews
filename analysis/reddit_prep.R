###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Text processing and exploration
# Jessica or Gautam started this
# Updated: Michele Claibourn
# February 20, 2018
###################################

rm(list = ls())
library(tidyverse)
library(tm)
library(wordcloud)

# Set working directory
setwd("/Users/mpc8t/Box Sync/mpc/dataForDemocracy/eventnewsshared/reddit_cville/Data/")

# Read in stories (reading in with read_csv, it handles the dates better)
threads <- read_csv("stories_latest.csv")
head(threads)
str(threads)

# Subset so only have type = submission
stories <- threads %>% filter(type=="submission")


###########################
## Remove non-stories
###########################
# Remove rows with fewer than 6 words in the text field
# break up the strings in each row by " "
stories$temp <- strsplit(stories$text, split=" ")
stories$wordcount <- sapply(stories$temp, length)
summary(stories$wordcount)
ggplot(stories, aes(x=wordcount)) + geom_histogram()
stories2 <- stories %>% filter(wordcount>5) %>% select(-one_of("temp"))


######################
## Processing with TM
######################
# Creating a corpus object via the vector source function:
corpus <- Corpus(VectorSource(stories2$text))

# Assign metadata
meta(corpus, "party") <- stories2$party

# Applying transformations to the corpora:
corpus <- tm_map(corpus, tolower) # every character lower case
corpus <- tm_map(corpus, removePunctuation, ucp=TRUE) # remove punctuation; ucp = TRUE bc of how this is encoded
corpus <- tm_map(corpus, removeNumbers) # remove numbers
corpus <- tm_map(corpus, removeWords, stopwords("english")) # remove stopwords 

#remove ������ what would be emojis
corpus<-tm_map(corpus, content_transformer(gsub), pattern="\\W",replace=" ")
# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeURL))
# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))

# stemming
corpus2 <- tm_map(corpus, stemDocument)

# Transforming the corpus object into a document term matrix:
dtm <- DocumentTermMatrix(corpus2)
dtm


##############################
# Examining the TM corpus, dtm
##############################
findFreqTerms(dtm, lowfreq = 250) # words occuring at least 250 times
wordFreq <- colSums(as.matrix(dtm)) # sum across columns, turn into df
wordFreq <- as.data.frame(wordFreq)
wordFreq$word <- row.names(wordFreq) # make variable from rownames
wordFreq <- arrange(wordFreq, desc(wordFreq)) # order
wordFreq[1:25,]

p <- ggplot(wordFreq[1:50,], aes(x = reorder(word, wordFreq), y=wordFreq))
p + geom_bar(stat="identity") + coord_flip()


# By party: Create corpus filtering out just Republican, just Democratic addresses
left <- corpus2[meta(corpus2, "party")=="left"] 
right <- corpus2[meta(corpus2, "party")=="right"]

wordcloud(left, max.words=100, scale=c(3,.25), colors="blue3")
wordcloud(right, max.words=100, scale=c(3,.25), colors="orange3")

ldtm <- TermDocumentMatrix(left)
rdtm <- TermDocumentMatrix(right)
lFreq <- findFreqTerms(ldtm, lowfreq=200)
rFreq <- findFreqTerms(rdtm, lowfreq=200)
lFreq
lFreq

# Co-occurring words
findAssocs(ldtm, "polic", 0.5)
findAssocs(rdtm, "polic", 0.5)

# Word clouds, in contrast/in common
# turn these into single term vector for left, right
ldtm_sum <- rowSums(as.matrix(ldtm)) 
ldtm_sum <- as.data.frame(ldtm_sum)
ldtm_sum$word <- row.names(ldtm_sum)
rdtm_sum <- rowSums(as.matrix(rdtm)) 
rdtm_sum  <- as.data.frame(rdtm_sum)
rdtm_sum$word <- row.names(rdtm_sum)

dtm_sum <- full_join(ldtm_sum, rdtm_sum, by="word")
dtm_sum$ldtm_sum <- ifelse(is.na(dtm_sum$ldtm_sum), 0, dtm_sum$ldtm_sum)
dtm_sum$rdtm_sum <- ifelse(is.na(dtm_sum$rdtm_sum), 0, dtm_sum$rdtm_sum)
row.names(dtm_sum) <- dtm_sum$word
dtm_sum$word <- NULL

# comparison cloud
comparison.cloud(dtm_sum, max.words=100, 
                 scale=c(3,.3), random.order=FALSE, 
                 colors=c("blue3", "red3"), title.size=.75)

# commonality cloud
commonality.cloud(dtm_sum, max.words=100, scale=c(3,.3),
                  random.order=FALSE, colors="purple3")

# Discriminating words via tf.idf
# Put all words from left in one vector, all words from right in another
leftvec <- paste0(stories2$text[1:190], collapse = " ")
rightvec <- paste0(stories2$text[191:389], collapse = " ")
corpus_party <- Corpus(VectorSource(c(leftvec, rightvec)))

# Process this corpus
corpus_party <- tm_map(corpus_party, tolower) # every character lower case
corpus_party <- tm_map(corpus_party, removePunctuation, ucp=TRUE) # remove punctuation; ucp = TRUE bc of how this is encoded
corpus_party <- tm_map(corpus_party, removeNumbers) # remove numbers
corpus_party <- tm_map(corpus_party, removeWords, stopwords("english")) # remove stopwords 
corpus_party<-tm_map(corpus_party, content_transformer(gsub), pattern="\\W",replace=" ")
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
corpus_party <- tm_map(corpus_party, content_transformer(removeURL))
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus_party <- tm_map(corpus_party, content_transformer(removeNumPunct))
corpus_party2 <- tm_map(corpus_party, stemDocument)

dtm_party <- TermDocumentMatrix(corpus_party, control = list(weighting = weightTfIdf))
dtm_party_df <- as.data.frame(as.matrix(dtm_party))
names(dtm_party_df) <- c("left", "right")
summary(dtm_party_df)

subset(dtm_party_df, left>.0002)
subset(dtm_party_df, right>.0002)

dtm_party_df$word <- row.names(dtm_party_df)
p <- ggplot(dtm_party_df, aes(x=left, y=right)) 
p + geom_point() + geom_text(aes(label=word), hjust=0, vjust=0)

# Reducing sparsity
# dtm <- removeSparseTerms(dtm, 0.85) # remove sparce term - we want a level of sparcity that is at most 85%

# save work to date
save.image("reddit_text.RData")
# load("reddit_text.RData")


###########################
## Processing with Quanteda
###########################
library(quanteda)

# Make a corpus
qcorpus <- corpus(stories2$text)
summary(qcorpus)

# Add document metadata
docvars(qcorpus, "party") <- stories2$party
docvars(qcorpus, "title") <- stories2$title
docvars(qcorpus, "date") <- stories2$`Time Posted`
eventdate <- as.Date("2017-08-10", format="%Y-%m-%d")
stories2$days <- difftime(stories2$`Time Posted`, eventdate, units="days")
docvars(qcorpus, "days") <- stories2$days

# Extract the text
texts(qcorpus)[1]

# Make a document-feature matrix
qdfm<- dfm(qcorpus,  tolower = TRUE,
                 remove = stopwords("english"), remove_punct = TRUE,
                 remove_numbers = TRUE, remove_symbols = TRUE,
                 remove_url = TRUE, remove_hyphens = TRUE,
                 stem = TRUE, verbose = TRUE)
qdfm # 372 dos, 9,424 features, 97.3% sparse


######################################
## Examining the Quanteda corpus, dfm
######################################
# Frequent words
topfeatures(qdfm, 20)

qdfm %>% 
  textstat_frequency(n = 50) %>% 
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Term Frequency") +
  theme_minimal()

# Frequent words by party
freq_party <- textstat_frequency(qdfm, n = 50, groups = docvars(qdfm, 'party'))
freq_party

freq_party %>% ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() + facet_wrap(~group) +
  coord_flip() + 
  labs(x = NULL, y = "Term Frequency") + 
  theme_minimal()

# Keyness: compare words between target (left) and reference (right) documents
key <- textstat_keyness(qdfm, docvars(qdfm, 'party') == "left", measure = "lr")
head(key, 20)

textplot_keyness(key) + 
  scale_fill_manual(labels = c("right", "left"), values = c("#CC3333", "#003366"))

# save left/right key words to vectors
rightkey <- key %>% 
  arrange(G2) %>% 
  select(feature, G2) %>% 
  slice(1:10)

leftkey <- key %>% 
  arrange(desc(G2)) %>% 
  select(feature, G2) %>% 
  slice(1:10)

# tf-idf weights
qdfm_tfidf <- dfm_tfidf(qdfm, scheme_tf = "prop", scheme_df = "inverse")
textplot_wordcloud(qdfm_tfidf, max.words = 100, scale = c(3,.3))

# by party
qdfm_party <- dfm_group(qdfm, groups = "party")
textplot_wordcloud(dfm_tfidf(qdfm_party), comparison = TRUE, 
                   max.words = 100, scale = c(3, .3))

# collocations: can call on corpus directly
coll <- textstat_collocations(qcorpus, size = 3, min_count = 50)
head(coll, 20)

# wordfish: ideological scaling (didn't work here)
wf <- textmodel_wordfish(qdfm, dir = c(3,193))
summary(wf)
textplot_scale1d(wf, margin = "features", 
                 highlighted = c("supremacist", "nazi", "heil"))

# sparsity
# qdfm_trim <- dfm_trim(qdfm, min_count = 3, max_docfreq = 370, verbose = TRUE)
# qdfm_trim

rm(wf, coll, p, eventdate, leftvec, rightvec, lFreq, rFreq, removeURL, removeNumPunct,
   right, rdtm, rdtm_sum, left, ldtm, ldtm_sum, dtm_party, dtm_party_df, dtm_sum)
save.image("reddit_text.RData")
# load("reddit_text.RData")
