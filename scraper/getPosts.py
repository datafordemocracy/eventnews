'''
Getting Started:

Run the following commands to install packages

pip3 install praw
pip3 install urlparse
pip3 install collections
pip3 install newspaper3k
pip3 install argparse
pip3 install ConfigParser
'''

import praw
import configparser
from urllib.parse import urlparse
from collections import Counter
from newspaper import Article
import argparse
import csv
import string
import datetime
#Config Parser
config = configparser.ConfigParser()
config.read("praw.ini")
client_id = str(config['app']['client_id'])
client_secret = str(config['app']['client_secret'])

# Reddit Oauth
reddit = praw.Reddit(client_id=client_id,
                     client_secret=client_secret,
                     user_agent='Python code to scrape')


# nonScrapable keeps the sites that don't give enough information about topic or have been blocked from being scrapped
nonScrapable = ['twitter.com','youtube.com','i.imgur.com','np.reddit.com','i.redd.it','youtu.be','redd.it','www.facebook.com','www.youtube.com','imgur.com']




def extract(query,subreddits,side):
    '''
    Code for all the posts in left subreddits that correspond to a search query

    The search being executed is for the query 'charlottesville' 
    '''
    leftScore=[]
    countLeft = 0
    left_data=[]
    for submission in reddit.subreddit(subreddits).search(query,limit = 5000,syntax='cloudsearch',sort = 'top'):
        url = submission.url
        source = urlparse(url)
        if source.netloc not in nonScrapable:
            time = submission.created
            time = datetime.datetime.fromtimestamp(time).date()
            ratio = reddit.submission(submission).upvote_ratio
            reddit_post = "www.reddit.com/"+submission.id
            ups = round((ratio*submission.score)/(2*ratio - 1)) if ratio != 0.5 else round(submission.score/2)
            downs = ups - submission.score
            try:
                author = submission.author
            except:
                author = "unknown"
            try:
                article = Article(url)
                article.download() # Download the article
                article.parse()
                content=article.text
                content = content.replace(',', ' ')
                submission.comment_sort = 'top'
                comments = submission.comments.list()
                num_comments = min(5,len(comments))
                row =[submission.id,'submission',submission.id,submission.title,author,submission.score,ups,downs,num_comments,reddit_post,source.netloc,time,content,side]
                left_data.append(row)
                for i in comments[0:num_comments]:
                    comment_created = datetime.datetime.fromtimestamp(i.created).date()
                    row =[i.id,'comment',i.parent_id,'',i.author,i.score,i.ups,i.downs,"","","",comment_created,i.body,""]
                    left_data.append(row)
                leftScore.append(str(source.netloc))
                countLeft = countLeft+1
            except:
                print("Article not found in webpage or non-downloadable: ",source.netloc)
    return countLeft,leftScore,left_data


def write_csv(data):
    with open('stories.csv', 'w', encoding='utf-8') as outcsv:
        headers = ['id','type','parent_id','title','author', 'score','upvotes','downvotes','num_comments', 'permalink', 'domain', 'Time Posted','text','party']
        writer = csv.writer(outcsv,delimiter=',')
        writer.writerow(headers)
        for row in data:
            writer.writerow(row)

if __name__== "__main__":
# Print the number of articles extracted from each collective subreddits
    parser = argparse.ArgumentParser(description="This program accepts a search query and searches political subreddits for urls shared by users.")
    parser.add_argument('--query', help='Input value of query term to be searched',
                        required=True)
    args = parser.parse_args()
    query = args.query
    leftParties = 'CornbreadLiberals+GreenParty+Liberal+SandersForPresident+SocialDemocracy+alltheleft+clinton+democrats+demsocialist+labor+leftcommunism+leninism+neoprogs+obama+progressive+socialism'
    rightParties = 'Conservative+NewRight+Objectivism+Republican+Romney+Trueobjectivism+conservatives+monarchism+paleoconservative+republicans'
    countLeft,leftScore,leftdata = extract(query,leftParties,'left')
    countRight,rightScore,rightdata = extract(query,rightParties,'right')
    print('*'*70)
    data = leftdata+rightdata
    print("Writing data into CSV file")
    write_csv(data)
    print("Number of articles from left: ",countLeft)
    print("Number of articles from right",countRight)
    print()
    print('*'*70)
# Calculate the number of times each source is referenced in their respective subreddits

    left = Counter(leftScore)  # Frequency calculation
    right = Counter(rightScore)

    # Sort the list putting most referenced sources in the top

    left = left.most_common()  # Most_common sorts the list based on how often they have occured
    right = right.most_common()

    # Print the values in console

    print('{} {: >30s}'.format("Left","Right"))
    for i,j in zip(left,right):
        print('{}: {} , {}: {}'.format(i[0],i[1],j[0],j[1]))
    print()
    print('*'*70)
    print ("Data stored in stories.csv ")
