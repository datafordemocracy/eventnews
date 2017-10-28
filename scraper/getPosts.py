import praw
reddit = praw.Reddit(client_id=insert_id,
                     client_secret=insert_secret,
                     user_agent='Python automatic replybot v2.0 (by /u/damnbut)')

subreddit = reddit.subreddit('pics')
count = 0

''' Code for top 1000 posts and taking only the posts that has the word trump in it
Reddit posts limit posts to 1000 and hard-coded search parameters in code and got the following
Total posts is 149
'''
keyword = 'Trump'
for submission in reddit.subreddit('AllTheLeft').hot(limit=1000):
    title = submission.title
    if keyword in title:
        count = count+1
        print "Score of the submission ",submission.score  # Output: the submission's score
        print "Title of the submission ",submission.title  # Output: the submission's title
        print "ID of the submission ",submission.id      # Output: the submission's ID
        print "URL of the submission ",submission.url
        print 50*'*'
print count

'''
Code for all the posts in /r/AllTheLeft that has the name trump

total posts is 100

Reddit API limits results to 100
'''
count = 0 
for submission in reddit.subreddit('AllTheLeft').search('Trump'):
    print "Score of the submission ",submission.score  # Output: the submission's score
    print "Title of the submission ",submission.title  # Output: the submission's title
    print "ID of the submission ",submission.id      # Output: the submission's ID
    print "URL of the submission ",submission.url
    print 50*'*'
    count = count+1

print count