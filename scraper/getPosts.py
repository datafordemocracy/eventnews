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
# /usr/local/bin/python
import praw
import configparser
from urllib.parse import urlparse
from collections import Counter
from newspaper import Article
import argparse
import csv
import string
import datetime
import json
import pandas as pd
from textblob import TextBlob
from textblob.sentiments import NaiveBayesAnalyzer
import spacy
# Config Parser
config = configparser.ConfigParser()
config.read("praw.ini")
client_id = str(config['app']['client_id'])
client_secret = str(config['app']['client_secret'])
# Load parser
nlp = spacy.load('en')

# Reddit Oauth
reddit = praw.Reddit(client_id=client_id,
                     client_secret=client_secret,
                     user_agent='Python code to scrape')


# nonScrapable keeps the sites that don't give enough information about topic or have been blocked from being scrapped
nonScrapable = ['twitter.com','youtube.com','i.imgur.com','np.reddit.com','i.redd.it','youtu.be','redd.it','www.facebook.com','www.youtube.com','imgur.com']




def extract(query,subreddits,side):
    '''
    Code for all the posts in left subreddits that correspond to a search query

    The search being executed is for the query charlottesville
    '''
    score=[]
    count = 0
    data=[]
    narayanFake = extract_fakenews()
    for submission in reddit.subreddit(subreddits).search(query,limit = 5000,syntax='cloudsearch',sort = 'top'):
        named_entities = {}
        columns = ['PERSON','NORP','FACILITY','ORG','GPE','LOC','PRODUCT','EVENT','WORK_OF_ART','LAW','LANGUAGE','DATE','TIME','PERCENT','MONEY','QUANTITY','ORDINAL','CARDINAL']
        # Initialzize empty dictionary
        for i in columns:
            named_entities[i]=[]
        url = submission.url
        source = urlparse(url)
        if source.netloc not in nonScrapable:
            time = submission.created
            time = datetime.datetime.fromtimestamp(time).date()
            ratio = reddit.submission(submission).upvote_ratio
            reddit_post = "www.reddit.com/"+submission.permalink
            subreddit = submission.subreddit
            subredditName = subreddit.display_name
            subredditSubs = subreddit.subscribers
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
                total_comments = submission.comments.list()
                '''
                submission.num_comments gives you the total number of comments, but users remove their comments from posts which is not captured by num_comments. Its better to list all comments and take the length
                '''
                #test_comments = submission.num_comments
                num_comments = min(5,len(total_comments))
                domain = source.netloc
                if domain[:3] == 'www':
                    tempDomain = domain.split('.')[1:]
                    tempDomain = ".".join(tempDomain)
                    print (tempDomain)
                else:
                    tempDomain = domain
                    print (tempDomain)
                for  domain in narayanFake:
                    if tempDomain in domain:
                        isnarayanFake = True
                        break
                    else:
                        isnarayanFake = False
                sentiment = TextBlob(content)
                parsedText = nlp(content)
                for entities in parsedText.ents:
                    entity_name = str(entities).strip()
                    if(entity_name==''):
                        continue
                    named_entities[entities.label_].append(entity_name)
                polarity_pattern = sentiment.sentiment.polarity
                sentiment_pattern = 'Positive' if polarity_pattern >0 else 'Negative'
                sentiment_nltk = TextBlob(content,analyzer=NaiveBayesAnalyzer())
                polarity_nltk = sentiment_nltk.sentiment.p_pos
                sentiment_nltk = 'Positive' if polarity_nltk >0.5 else 'Negative'
                row =[submission.id,'submission',submission.id,submission.title,author,submission.score,ups,downs,num_comments,len(total_comments),subredditName,subredditSubs,reddit_post,source.netloc,isnarayanFake,url,time,content,named_entities['PERSON'],named_entities['NORP'],named_entities['FACILITY'],named_entities['ORG'],named_entities['GPE'],named_entities['LOC'],named_entities['PRODUCT'],named_entities['EVENT'],named_entities['WORK_OF_ART'],named_entities['LAW'],named_entities['LANGUAGE'],named_entities['DATE'],named_entities['TIME'],named_entities['PERCENT'],named_entities['MONEY'],named_entities['QUANTITY'],named_entities['ORDINAL'],named_entities['CARDINAL'],polarity_pattern,sentiment_pattern,polarity_nltk,sentiment_nltk,side]
                data.append(row)
                for i in total_comments[0:num_comments]:
                    comment_created = datetime.datetime.fromtimestamp(i.created).date()
                    sentiment = TextBlob(i.body)
                    polarity_pattern = sentiment.sentiment.polarity
                    sentiment_pattern = 'Positive' if polarity_pattern >0 else 'Negative'
                    sentiment_nltk = TextBlob(i.body,analyzer=NaiveBayesAnalyzer())
                    polarity_nltk = sentiment_nltk.sentiment.p_pos
                    sentiment_nltk = 'Positive' if polarity_nltk >0.5 else 'Negative'
                    row=[i.id,'comment',i.parent_id,'',i.author,i.score,"N/A","N/A","","","","","","","","",comment_created,i.body,"","","","","","","","","","","","","","","","","","",polarity_pattern,sentiment_pattern,polarity_nltk,sentiment_nltk,side]
                    data.append(row)
                score.append(str(source.netloc))
                count = count+1
            except:
                print("Article not found in webpage or non-downloadable: ",source.netloc)
    return count,score,data

def extract_fakenews():
    xl = pd.ExcelFile('fakenews.xlsx')
    df1 = xl.parse('Junk news sources')
    narayanFake = df1['base_url']
    return narayanFake
    
def write_csv(data):
    with open('stories.csv', 'w', encoding='utf-8') as outcsv:
        headers = ['id','type','parent_id','title','author', 'score','upvotes','downvotes','num_comments','total comments','subreddit name','subreddit subscribers', 'permalink', 'domain','Narayanan Fake News','url', 'Time Posted','text','PERSON','NORP','FACILITY','ORG','GPE','LOC','PRODUCT','EVENT','WORK_OF_ART','LAW','LANGUAGE','DATE','TIME','PERCENT','MONEY','QUANTITY','ORDINAL','CARDINAL','pattern analyser polarity','pattern analyser sentiment','naive bayes polarity','naive bayes sentiment','party']
        writer = csv.writer(outcsv,delimiter=',')
        writer.writerow(headers)
        for row in data:
            writer.writerow(row)

if __name__== "__main__":
#Print the number of articles extracted from each collective subreddits
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
    print('{} {: >30s}'.format("Left","Right"))
    for i,j in zip(left,right):
        print('{}: {} , {}: {}'.format(i[0],i[1],j[0],j[1]))
    print()
    print('*'*70)
    print ("Data stored in stories.csv ")
