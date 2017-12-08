## Helpful links

 * More on [Empath](https://hci.stanford.edu/publications/2016/ethan/empath-chi-2016.pdf)
 * More on [Moral foundations](http://moralfoundations.org/), from this page, see also The Righteous Mind [Chapter 7](http://righteousmind.com/wp-content/uploads/2013/08/ch07.RighteousMind.final_.pdf)
 * More on LIWC: [Overview](https://liwc.wpengine.com/interpreting-liwc-output/), [Language Manual](https://liwc.wpengine.com/wp-content/uploads/2015/11/LIWC2015_LanguageManual.pdf)
 * [State of the News Media](http://www.pewresearch.org/topics/state-of-the-news-media/)
  * [Media Cloud](https://mediacloud.org/tools) to find stories? 
 
 ## Where we are
  * Stories are posted (stories.csv), with character encoding corrected, and up/down votes added
  * stories_LIWC.csv and stories_empath.csv are returned results from running the articles through LIWC and Empath

## To do next
  * Read through/skim backgrounds on features extracted by LIWC, Empath, Moral Foundations to discuss shared understanding potentially relevant dimensions
  * Buy license to LIWC for lab (share documentation in Box)
  * Add script to run Empath on stories.csv to github
  * Update getPosts.py to add permanent url, post date and grab comments, comment author, comment score/up votes/down votes, comment date in separate file (matchable to posted stories by permanent url); share example for data structure with Gautam
  * Update getPosts.py to return "Not Scrapable" in text field if not scrapable (these records can be filtered out for analysis when appropriate)
  * Continue exploring stories.csv in various ways (moral foundations, sentiment, topics, entities, liwc features, empath features, other features?); potentially using multiple environments
  * Continue scanning through posted articles/titles to get a sense of types/purpose of posts (consider manual coding possibilities)
  * Consider inclusion of other cases: August rallies in Charlottesville

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
