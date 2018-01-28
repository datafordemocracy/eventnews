## Where we are
  * Stories are posted (stories_latest.csv) in newspapers/reddit_cville folder, with character encoding corrected, up/down votes, top comments, total comments added
  * Some initial exploration: tf-idf (storie_tfidi.R), topics (stm_topic.R), LIWC (stories_latest_LIWC.csv and boxplots)

### Research Questions
1. What is the distribution of domains from which stories are pulled on the left and right?
2. On what features do stories posted by right and by left differ, on what features are they similar?
3. What features of stories promote audience engagement (e.g., more comments)?
4. What features of stories promote audience perception of quality (e.g., upvotes)?
5. Are the features that promtoe engagement or assessment of quality the same for stories promoted by the right and the left?
6. Are the features from 3,4 (5) those that distinguish stories posted by the left and right or those they have in common (2)?
7. What else?

## To do next
  * Take a stab at cleaning news stories, comments -- need to agree on some pre-processing for all subsequent analysis
  * Start exploring story sources, times, authors (e.g., range), scores/votes, comments -- 
  * More on possible publishing outlets
  * Can we get total number of comments?
  * Additional features:
    * Moral foundations: Jessica
    * Named entities? We didn't talk about this one, but I'll throw it out there (is someone interested?)
      
## Resources
 * More on [Empath](https://hci.stanford.edu/publications/2016/ethan/empath-chi-2016.pdf)
 * More on [Moral foundations](http://moralfoundations.org/), from this page, see also The Righteous Mind [Chapter 7](http://righteousmind.com/wp-content/uploads/2013/08/ch07.RighteousMind.final_.pdf)
 * More on LIWC: [Overview](https://liwc.wpengine.com/interpreting-liwc-output/), [Language Manual](https://liwc.wpengine.com/wp-content/uploads/2015/11/LIWC2015_LanguageManual.pdf)
 * R/Qaunteda [LIWCalike](https://github.com/kbenoit/LIWCalike)
 * [State of the News Media](http://www.pewresearch.org/topics/state-of-the-news-media/)
 * [Media Cloud](https://mediacloud.org/tools) to find stories? 
 
## Dimensions of Cases to Compare
Vary one dimension, and try to hold others approximately constant

* Policy dimension raised (e.g., immigration, civil rights, health, women's rights, terrorism, shooting/safety?)
* Pre-post Trump era
* Nature of event as collective action/protest vs. individual action/stimulus
* Ideological orientation of originating action/stimulus 

E.g., collective action events by Trump era; policy dimensions within Trump era.

### Potential cases

* Cville events
* Mass shootings: Texas (11/17), Las Vegas (10/17), Orlanda (6/16), San Bernandino (12/15) [(more here)](http://www.gannett-cdn.com/GDContent/mass-killings/index.html#frequency)
* Episodes of foreign travel by Trump
