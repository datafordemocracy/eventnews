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