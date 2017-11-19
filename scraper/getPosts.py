'''
Getting Started:

Run the following commands to install packages

pip install praw
pip install urlparse
pip install collections

'''

import praw
from urllib.parse import urlparse
from collections import Counter
from newspaper import Article

# Reddit Oauth 
reddit = praw.Reddit(client_id='',
                     client_secret='',
                     user_agent='Python code to scrape')

'''Having a count variable for counting number of articles being retrieved

nonScrapable keeps the sites that don't give enough information about topic or have been blocked from being scrapped
'''
leftScore=[]
rightScore=[]
nonScrapable = ['twitter.com','youtube.com','i.imgur.com','np.reddit.com','i.redd.it','youtu.be','redd.it','www.facebook.com','www.youtube.com','imgur.com']

'''
Code for all the posts in left subreddits that correspond to a search query

The search being executed is for the query 'charlottesville' 
'''
countLeft = 0 
for submission in reddit.subreddit('CornbreadLiberals+GreenParty+Liberal+SandersForPresident+SocialDemocracy+alltheleft+clinton+democrats+demsocialist+labor+leftcommunism+leninism+neoprogs+obama+progressive+socialism').search('Charlottesville',limit = 5000,syntax='cloudsearch',sort = 'top'):
    url = submission.url
    source = urlparse(url)
    if source.netloc not in nonScrapable:
        print("Score of the submission ",submission.score)  # Output: the submission's score
        print("Title of the submission ",submission.title)  # Output: the submission's title
        print("ID of the submission ",submission.id)      # Output: the submission's ID
        print("URL of the submission ",submission.url)    # Output: the submisson's url
        print("Domain", source.netloc)  #  Output: the submisson's Domain
        try:
            article = Article(url)
            article.download() # Download the article
            article.parse()
            print(article.text)
            leftScore.append(str(source.netloc))
            countLeft = countLeft+1
        except:
            print("not able to do so")
        print(50*'*')
'''
Code for all the posts in right subreddits that correspond to a search query

The search being executed is for the query 'charlottesville'
'''

countRight = 0 
for submission in reddit.subreddit('Conservative+NewRight+Objectivism+Republican+Romney+Trueobjectivism+conservatives+monarchism+paleoconservative+republicans').search('Charlottesville',limit = 5000,syntax='cloudsearch',sort = 'top'):
    url = submission.url
    source = urlparse(url)
    if source.netloc not in nonScrapable:
        print("Score of the submission ",submission.score)  # Output: the submission's score
        print("Title of the submission ",submission.title)  # Output: the submission's title
        print("ID of the submission ",submission.id)      # Output: the submission's ID
        print("URL of the submission ",submission.url)    # Output: the submisson's url
        print("Domain", source.netloc)  #  Output: the submisson's Domain
        try:
            article = Article(url)
            article.download() # Download the article
            article.parse()
            print(article.text)
            rightScore.append(str(source.netloc))
            countRight = countRight+1
        except:
            print("not able to do so")
        print(50*'*')

# Print the number of articles extracted from each collective subreddits
print()
print("Number of articles from left: ",countLeft)
print("Number of articles from right",countRight)
print()

# Calculate the number of times each source is referenced in their respective subreddits

left = Counter(leftScore)  # Frequency calculation
right = Counter(rightScore)

# Sort the list putting most referenced sources in the top

left = left.most_common()  # Most_common sorts the list based on how often they have occured
right = right.most_common()

# Print the values in console

print('{} {: >30s}'.format("Left","Right"))
for i,j in zip(left,right):   # Here I'm taking the top 10 articles
    print('{}: {} , {}: {}'.format(i[0],i[1],j[0],j[1]))