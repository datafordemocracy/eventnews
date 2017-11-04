'''
Getting Started:

Run the following commands to install packages

pip install praw
pip install urlparse
pip install collections

'''

import praw
from urlparse import urlparse
from collections import Counter

# Reddit Oauth 
reddit = praw.Reddit(client_id='',
                     client_secret='',
                     user_agent='Python code to scrape')

# Having a count variable for counting number of articles being retrieved
left_score=[]
right_score=[]

'''
Code for all the posts in left subreddits that correspond to a search query

The search being executed is for the query 'charlottesville' 
'''
count_left = 0 
for submission in reddit.subreddit('CornbreadLiberals+GreenParty+Liberal+SandersForPresident+SocialDemocracy+alltheleft+clinton+democrats+demsocialist+labor+leftcommunism+leninism+neoprogs+obama+progressive+socialism').search('Charlottesville',limit = 5000,syntax='cloudsearch',sort = 'top'):
    url = submission.url
    source = urlparse(url)
    left_score.append(str(source.netloc))
    print "Score of the submission ",submission.score  # Output: the submission's score
    print "Title of the submission ",submission.title  # Output: the submission's title
    print "ID of the submission ",submission.id      # Output: the submission's ID
    print "URL of the submission ",submission.url    # Output: the submisson's url
    print "Domain", source.netloc  #  Output: the submisson's Domain
    print 50*'*'
    count_left = count_left+1

'''
Code for all the posts in right subreddits that correspond to a search query

The search being executed is for the query 'charlottesville' 
'''
count = 0 
for submission in reddit.subreddit('Conservative+NewRight+Objectivism+Republican+Romney+Trueobjectivism+conservatives+monarchism+paleoconservative+republicans').search('Charlottesville',limit = 5000,syntax='cloudsearch',sort = 'top'):
    url = submission.url
    source = urlparse(url)
    right_score.append(str(source.netloc))
    print "Score of the submission ",submission.score  # Output: the submission's score
    print "Title of the submission ",submission.title  # Output: the submission's title
    print "ID of the submission ",submission.id      # Output: the submission's ID
    print "URL of the submission ",submission.url   # Output: the submisson's url
    print "Domain", source.netloc  # Output: the submisson's domain
    print 50*'*'
    count = count+1

# Print the number of articles extracted from each collective subreddits
print
print "Number of articles from left: ",count_left
print "Number of articles from right",count
print

# Calculate the number of times each source is referenced in their respective subreddits

left = Counter(left_score)  # Frequency calculation
right = Counter(right_score)

# Sort the list putting most referenced sources in the top

left = left.most_common()  # Most_common sorts the list based on how often they have occured
right = right.most_common()

# Print the values in console

print '{} {: >30s}'.format("Left","Right")
for i,j in zip(left[0:10],right[0:10]):   # Here I'm taking the top 10 articles
    print '{}: {} , {}: {}'.format(i[0],i[1],j[0],j[1])