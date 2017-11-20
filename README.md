# eventnews

### Before running the program
Enter your client_id and client_secret in the `praw.ini` file without *quotes*.

### Code Description
```
usage: getPosts.py [-h] --query QUERY

This program accepts a search query and searches political subreddits for urls
shared by users. Using this url, the program scrapes text data and stores it in a dataframe
for further processing

optional arguments:
  -h, --help     show this help message and exit
  --query QUERY  Input value of query term to be searched
```

### Required Packages
* argparse
* newspaper3k
* urllib
* pandas
* numpy
* praw
* collections
* configparser


## Running the Code
```
python getPosts.py --query [search term]
```
## About
Comparing media representations of politically-charged events

The project compares the nature of media representations of politically-charged events shared by liberal and conservative audiences on reddit.

Events include:
 * The unite the right rallies and counter-rallies in Charlottesville, VA on August 11-12, 2017
 * TBD
 
News stories shared on the the [Multi Reddit of all Left-Right partisan subreddits](https://www.reddit.com/r/politics/wiki/relatedsubs) are searched for submissions related to one of the selected events. The top XX threads are scraped and the thread id, article source, title, and link/url are captured. The returned articles will make up the corpora. 
  
In addition, news stories related to the same events will be acquired from establishment news sources (NYT, WSJ?) as a reference point.
 
