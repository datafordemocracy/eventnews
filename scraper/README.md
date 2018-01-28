# About getPosts

### Before running the program
The program is written in Python 3x. Install Python3x before running the code. Enter your client_id and client_secret in the `praw.ini` file without *quotes*.

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
* csv
* praw
* collections
* configparser
* string


## Running the Code
```
python3 getPosts.py --query [search term]
```
