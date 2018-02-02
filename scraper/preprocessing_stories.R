library(dplyr)
library(tidytext)
library(janeaustenr)
library(stringr)
library(ggplot2)
library(gutenbergr) # provides access to the public domain works from the Project Gutenberg collection. The package includes tools both for downloading books (stripping out the unhelpful header/footer information), and a complete dataset of Project Gutenberg metadata that can be used to find works of interest
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

example.tm1 <- read.csv("/Users/jessicamazen/Box Sync/newspaper/reddit_cville/stories_latest.csv", header = TRUE, stringsAsFactors = FALSE)
head(example.tm1)
str(example.tm1)

# Subset so only have type = submission
example.tm1 <- example.tm1[ which(example.tm1$type=='submission'), ]

# Creating a corpus object via the vector source function:
corpus <- Corpus(VectorSource(example.tm1[,13]))

# Applying transformations to the corpora:
corpus <- tm_map(corpus, tolower) # every character lower case
corpus <- tm_map(corpus, removePunctuation, ucp=TRUE) # remove punctuation; ucp = TRUE bc of how this is encoded
corpus <- tm_map(corpus, removeNumbers) # remove numbers
corpus <- tm_map(corpus, removeWords, stopwords("english")) # remove stopwords 

#remove ������ what would be emojis
corpus<-tm_map(corpus, content_transformer(gsub), pattern="\\W",replace=" ")
# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeURL)
)
# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))

# stemming
corpus2 <- tm_map(corpus, stemDocument)

# Transforming the corpus object into a document term matrix:
dtm <- DocumentTermMatrix(corpus2)
dtm

# Reducing sparsity:
dtm <- removeSparseTerms(dtm, 0.85) # remove sparce term - we want a level of sparcity that is at most 85%
dtm

# Finding associations with the term "word"
#findAssocs(dtm, "word", 0.80)
#findAssocs(dtm, "word", 0.30)

# Transforming the document term matrix into a dataframe:
dtm.data <- as.data.frame(as.matrix(dtm))
head(dtm.data)

# Plot of word frequencies:
freq.dtm <- sort(colSums(dtm.data),decreasing=TRUE)
freq.data <- data.frame(word = names(freq.dtm),freq=freq.dtm)

# Easy way:

ggplot(freq.data, aes(reorder(word, freq), freq))+
  geom_col()+
  xlab(NULL)+
  coord_flip()+
  ylab("Frequency")+
  theme(text = element_text(size = 15))



#Word cloud

set.seed(1234)
wordcloud(words = freq.data$word, freq = freq.data$freq, min.freq = 1, 
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

# Dynamical Heatmap of the Correlations between tokens (terms):
cor.terms <- cor_auto(dtm.data)
a <- list(showticklabels = TRUE, tickangle = -45)
plot.cor <- plot_ly(x = colnames(cor.terms), y = colnames(cor.terms),
                    z = cor.terms, type = "heatmap") %>%
  layout(xaxis = a,  showlegend = FALSE, margin = list(l=100,b=100,r=100,u=100))

htmlwidgets::saveWidget(as_widget(plot.cor), file = "demo.html")


# Plotting correlations using the tm package:
plot(dtm, corThreshold = 0.2, weighting = TRUE, terms = Terms(dtm))


# Need complete words for sentiment analysis
complete.terms <- stemCompletion()
