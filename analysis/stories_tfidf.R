# TF-IDF analysis of Reddit right/left posts regarding Charlottesville
# Peter Wu

library(dplyr)
library(tm)
library(statnet)

stories <- read.csv("C:/Users/Peter/Documents/GitHub/eventnews/scraper/stories.csv", encoding = "UTF-8")
stories[1,]

##### TF-IDF comparison of words #####

# for the purpose of this analysis, we only use the textual content
right.df <- as.data.frame(stories[which(stories$party == "right"),"text"], stringsAsFactors = FALSE)
left.df <- as.data.frame(stories[which(stories$party == "left"),"text"], stringsAsFactors = FALSE)
all.df <- as.data.frame(stories[,"text"], stringsAsFactors = FALSE)
  
# convert text data frame to a corpus object.
right.corp <- VCorpus(DataframeSource(right.df))
left.corp <- VCorpus(DataframeSource(left.df))
all.corp <- VCorpus(DataframeSource(all.df))

# inspection
right.corp[[1]]$content
left.corp[[1]]$meta

# reduce sparcity
preprocess <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(removeNumbers))
  corpus <- tm_map(corpus, content_transformer(removePunctuation))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, content_transformer(removeWords), stopwords("english"))
  corpus <- tm_map(corpus, stemDocument)
}

right.corp.clean <- preprocess(right.corp)
left.corp.clean <- preprocess(left.corp)
all.corp.clean <- preprocess(all.corp)
left.corp.clean[[1]]$content

# compute TF-IDF matrix 
right.tfidf <- DocumentTermMatrix(right.corp.clean, control = list(weighting = weightTfIdf)) # empty documents: 23, 75, 182
left.tfidf <- DocumentTermMatrix(left.corp.clean, control = list(weighting = weightTfIdf))
all.tfidf <- DocumentTermMatrix(all.corp.clean, control = list(weighting = weightTfIdf))

length(right.tfidf$dimnames$Terms) # 7994 words in right vocabulary 
length(left.tfidf$dimnames$Terms) # 8571 words in left vocabulary
shared.words <- intersect(right.tfidf$dimnames$Terms, left.tfidf$dimnames$Terms)
length(shared.words) # 4443 shared words

# compute average tfidf for shared words in the right documents
right.shared.word.index <- which(right.tfidf$dimnames$Terms %in% left.tfidf$dimnames$Terms)
right.shared.tfidf.index <- which(right.tfidf$j %in% which(right.tfidf$dimnames$Terms %in% left.tfidf$dimnames$Terms))
right.shared.tfidf.feature <- data.frame(i = right.tfidf$i[right.shared.tfidf.index], 
                                         j = right.tfidf$j[right.shared.tfidf.index], 
                                         tfidf = right.tfidf$v[right.shared.tfidf.index]) %>%
                              group_by(j) %>% 
                              summarize(avgTfidf = mean(tfidf)) %>%
                              mutate(word = right.tfidf$dimnames$Terms[j])
right.shared.tfidf.feature

# compute average tfidf for shared words in the left documents
left.shared.word.index <- which(left.tfidf$dimnames$Terms %in% right.tfidf$dimnames$Terms)
left.shared.tfidf.index <- which(left.tfidf$j %in% which(left.tfidf$dimnames$Terms %in% right.tfidf$dimnames$Terms))
left.shared.tfidf.feature <- data.frame(i = left.tfidf$i[left.shared.tfidf.index], 
                                         j = left.tfidf$j[left.shared.tfidf.index], 
                                         tfidf = left.tfidf$v[left.shared.tfidf.index]) %>%
                             group_by(j) %>% 
                             summarize(avgTfidf = mean(tfidf)) %>%
                             mutate(word = left.tfidf$dimnames$Terms[j])
left.shared.tfidf.feature

# compare average tfidf of shared words in right and left documents
tfidf.comparison <- full_join(x = right.shared.tfidf.feature[,c("avgTfidf","word")],
                              y = left.shared.tfidf.feature[,c("avgTfidf", "word")],
                              by = c("word" = "word")) %>%
                    select(avgTfidf.x, avgTfidf.y, word) %>%
                    mutate(rightLeftDiff = avgTfidf.x - avgTfidf.y)

# IMPORTANT: top signature words in right and left documents
tfidf.comparison %>% arrange(desc(rightLeftDiff)) %>% filter(rightLeftDiff > 0)
tfidf.comparison %>% arrange(rightLeftDiff) %>% filter(rightLeftDiff < 0)

# right and left only words
right.only.tfidf.feature <- data.frame(i = right.tfidf$i[-right.shared.tfidf.index], 
                                         j = right.tfidf$j[-right.shared.tfidf.index], 
                                         tfidf = right.tfidf$v[-right.shared.tfidf.index]) %>%
                            group_by(j) %>% 
                            summarize(avgTfidf = mean(tfidf)) %>%
                            mutate(word = right.tfidf$dimnames$Terms[j])
right.only.tfidf.feature

left.only.tfidf.feature <- data.frame(i = left.tfidf$i[-left.shared.tfidf.index], 
                                        j = left.tfidf$j[-left.shared.tfidf.index], 
                                        tfidf = left.tfidf$v[-left.shared.tfidf.index]) %>% 
                           group_by(j) %>% 
                           summarize(avgTfidf = mean(tfidf)) %>%
                           mutate(word = left.tfidf$dimnames$Terms[j])
left.only.tfidf.feature


##### TF-IDF based document similarity #####

# does it reflect the left-right divide?
all.shared.tfidf <- all.tfidf[, intersect(colnames(all.tfidf), shared.words)] # retain shared words as basis dimensions
all.shared.tfidf <- all.shared.tfidf[-which(apply(all.shared.tfidf,1, sum)==0),] # remove three articles that are empty
inspect(all.shared.tfidf)

adjacency <- matrix(rep(0, nrow(all.shared.tfidf)^2), nrow = nrow(all.shared.tfidf), ncol = nrow(all.shared.tfidf))
all.shared.tfidf.matrix <- as.matrix(all.shared.tfidf)
for (i in 1 : nrow(all.shared.tfidf)) {
  for (j in i : nrow(all.shared.tfidf)) {
    # cosine similarity between documents
    adjacency[i,j]  <- all.shared.tfidf.matrix[i, ] %*% all.shared.tfidf.matrix[j, ] / 
              (sqrt(sum(all.shared.tfidf.matrix[i, ]^2)) * sqrt(sum(all.shared.tfidf.matrix[j, ]^2)))
  }
}

# which document is most similar to document 1 (left)?
stories[rownames(all.shared.tfidf)[which.max(adjacency[1,-1])], "text"] # document 66 (also left)

# plot network graph of document similarity
# need major improvement: potentially graphicall lasso to force insignificant simialarity to zero; right now edge weights are too liberal
sample <- sample(1:nrow(all.shared.tfidf), 50)
adj_network <- network(adjacency[sample, sample], matrix.type="adjacency", directed=FALSE, ignore.eval=FALSE, names.eval="value") 
weights <- as.sociomatrix(adj_network, "value")
gplot(adj_network, gmode="graph", 
      edge.lwd=0.1*adj_network%e%'value', edge.col = "grey",
      jitter = F, 
      vertex.col = ifelse(stories[rownames(all.shared.tfidf)[sample], "party"] == "left", "red", "blue"),
      #vertex.cex = 0.01*as.numeric(apply(all.shared.tfidf.matrix,1,function(x) {length(which(x>0))}))[1:100],
      displayisolates = T)
