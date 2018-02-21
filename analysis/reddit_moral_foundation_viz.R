###################################
# CVille-related News Stories 
# from Partisan Reddit Threads
# Viz of Moral Foundations
# Alicia Nobles
# February 20, 2018
###################################

setwd("/Users/anobles/Documents/Statlab/reddit/Code")
#load("reddit_moralfound_viz.RData")

library(ggplot2)
library(grid)
library(gridExtra)

# Subset only posts (original submissions)
posts <- subset(stories2, type == "submission")
posts$party = as.factor(posts$party)
posts$party = droplevels(posts$party)
table(posts$party)

# Join the total number of comments on "id"
posts_withtotcomments <- read.csv("/Users/anobles/Documents/Statlab/reddit/stories_latest_LIWC.csv")
posts_withtotcomments <- subset(posts_withtotcomments, type == "submission")
myvars <- c("id", "total.comments")
posts_withtotcomments <- posts_withtotcomments[myvars]
posts2 <- merge(posts, posts_withtotcomments, by="id")
# what happened in line above? we lost 6 stories

moral_found_vars <- c("HarmVirtue", "HarmVice", "FairnessVirtue", "FairnessVice", 
                      "IngroupVirtue", "IngroupVice", "AuthorityVirtue", "AuthorityVice", 
                      "PurityVirtue", "PurityVice", "MoralityGeneral")

# Scatter and boxplots of all LIWC vars
pdf("~/Documents/Statlab/reddit/Images/moralfound_scatterplots.pdf")
for(var in moral_found_vars){
  print(var)
  
  yname = var
  
  # total comments
  tot_comments <- ggplot(posts2, aes(y=posts2[[var]], x=total.comments, shape=party, color=party)) + 
    geom_point() +
    #geom_smooth(method=lm, se=FALSE, fullrange=TRUE) + 
    labs(x="Total Comments", y = yname) +
    theme(axis.text=element_text(size=8)) 
  
  # score
  score <- ggplot(posts2, aes(y=posts2[[var]], x=score, shape=party, color=party)) + 
    geom_point() +
    #geom_smooth(method=lm, se=FALSE, fullrange=TRUE) + 
    labs(x="Score", y = yname) +
    theme(axis.text=element_text(size=8)) 
  
  # upvotes
  upvotes <- ggplot(posts2, aes(y=posts2[[var]], x=upvotes, shape=party, color=party)) + 
    geom_point() +
    #geom_smooth(method=lm, se=FALSE, fullrange=TRUE) + 
    labs(x="Upvotes", y = yname) +
    theme(axis.text=element_text(size=8)) 
  
  # downvotes
  downvotes <- ggplot(posts2, aes(y=posts2[[var]], x=downvotes, shape=party, color=party)) + 
    geom_point() +
    #geom_smooth(method=lm, se=FALSE, fullrange=TRUE) + 
    labs(x="Downvotes", y = yname) +
    theme(axis.text=element_text(size=8)) 
  
  # arrange on grid
  grid.arrange(tot_comments, score, upvotes, downvotes, ncol = 2, nrow = 2)
}
dev.off()

# Boxplots of all LIWC vars
pdf("~/Documents/Statlab/reddit/Images/moralfound_boxplots.pdf")
for(var in moral_found_vars){
  print(var)
  
  yname = var
  
  # boxplots
  box <- ggplot(posts2, aes(x=posts2$party, y=posts2[[var]], color=party)) + 
    geom_boxplot() +
    labs(x="Party", y = yname) +
    theme(axis.text=element_text(size=8))
  # arrange on grid
  grid.arrange(box, ncol = 1, nrow = 1)
}
dev.off()

#save.image("reddit_moralfound_viz.RData")
