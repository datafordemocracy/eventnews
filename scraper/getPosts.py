import praw
reddit = praw.Reddit(client_id=None,
                     client_secret=None,
                     user_agent='Python automatic replybot v2.0 (by /u/damnbit)')


count = 0

'''
Code for all the posts in /r/AllTheLeft that has the name trump

total posts is 100

Reddit API limits results to 100
'''
count = 0 
for submission in reddit.subreddit('politics').search('trump',limit = 5000,syntax='cloudsearch',sort = 'top'):
    print "Score of the submission ",submission.score  # Output: the submission's score
    print "Title of the submission ",submission.title  # Output: the submission's title
    print "ID of the submission ",submission.id      # Output: the submission's ID
    print "URL of the submission ",submission.url
    print 50*'*'
    count = count+1

print count