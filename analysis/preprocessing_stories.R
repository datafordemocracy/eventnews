library(dplyr)
library(tidytext)
library(stringr)
library(ggplot2)
library(tidyr)
library(scales)
library(wordcloud)
library(reshape2)
library(tm)
library(qgraph)
library(plotly)
library(htmlwidgets)
library(Rgraphviz)

# Text Mining Example 1:

example.tm1 <- read.csv("/Users/gautam/Box Sync/newspaper/reddit_cville/stories_latest.csv", header = TRUE, stringsAsFactors = FALSE)
head(example.tm1)
str(example.tm1)

# Subset so only have type = submission
example.tm1 <- example.tm1[ which(example.tm1$type=='submission'), ]

# Creating a corpus object via the vector source function:
corpus <- Corpus(VectorSource(example.tm1[,13]))

# Applying transformations to the corpora:
corpus <- tm_map(corpus, tolower) # every character lower case
corpus <- tm_map(corpus, removePunctuation, ucp=TRUE) # remove punctuation; ucp = TRUE bc of how this is encoded
corpus <- tm_map(corpus, removeWords, stopwords("english")) # remove stopwords 
corpus <- tm_map(corpus, removeNumbers) # remove numbers
corpus <- tm_map(corpus, stripWhitespace)


#remove ������ what would be emojis
corpus<-tm_map(corpus, content_transformer(gsub), pattern="\\W",replace=" ")
# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeURL)
)

# Remove words with length less than or equal to 3
removeLetters <- function(x) gsub(" *\\b[[:alpha:]]{1,3}\\b *", " ", x)
corpus <-tm_map(corpus,content_transformer(removeLetters))

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))

# stemming ( Not required )
#corpus2 <- tm_map(corpus, stemDocument)


# Remove documents with less than 10 words
corpus2<-corpus[str_count(corpus$content,"\\S+")>10]

# Transforming the corpus object into a document term matrix:
dtm <- DocumentTermMatrix(corpus2)

# Reducing sparsity:
dtm <- removeSparseTerms(dtm, 0.85) # remove sparce term - we want a level of sparcity that is at most 85%
dtm

# Finding associations with the term "word"
#findAssocs(dtm, "word", 0.80)
#findAssocs(dtm, "word", 0.30)
