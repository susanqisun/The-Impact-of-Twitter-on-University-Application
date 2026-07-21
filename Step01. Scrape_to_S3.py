#!/usr/bin/env python
# coding: utf-8

####################
# Author: Qi Sun
# purpose01: Scrape Twitter data
# purpose02: Load (overwrite) Twitter data and Applicant data in RDS MySQL OLTP database
# purpose03: Upload data to S3, which will trigger AWS Lambda to update RDS MySQL OLAP databse (dimentions and fact tableas)
# This process will take 10 mins

#####################


#pip install GetOldTweets3.
import pandas as pd
import GetOldTweets3 as got
import datetime
import boto3
from io import StringIO
import time

##########################
# Step 1: scrape tweets from Twitter
#documentation: https://pypi.org/project/GetOldTweets3/

##########################

# Creation of query object
tweetCriteria = got.manager.TweetCriteria().setQuerySearch('Yeshiva University').setSince("2018-01-01").setEmoji("unicode")
                                                                                      
# Creation of list that contains all tweets
tweets = got.manager.TweetManager.getTweets(tweetCriteria)
df = pd.DataFrame([tweet.__dict__ for tweet in tweets])

# create a new column Date'to keep year/month/day
df['Date'] = pd.to_datetime(df['date']).apply(lambda x: x.date())


##########################
# Step 2: Load raw twitter data to S3 bucket 'raw-data02' 
# purpose: keep historical data
# S3 bucket 'raw-data02' address: https://s3.console.aws.amazon.com/s3/buckets/raw-data02/?region=us-east-1

##########################

s3 = boto3.resource(
    's3',
    region_name='us-east-1',
    aws_access_key_id='AKIAUNNB2E5FCXFXXQ3P',
    aws_secret_access_key='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'
)

bucket = 'raw-data02' # already created on S3
filename = 'tweets'
datetime = time.strftime("%Y%m%d%H%M%S")
filenames2 = "%s%s.csv"%(filename,datetime) #name of the filepath and csv file

csv_buffer = StringIO()
df.to_csv(csv_buffer)
s3.Object(bucket, filenames2).put(Body=csv_buffer.getvalue())


##########################
# Step 3: Sentiment analysis on tweets using nltk library
# Clean data and keep the columns that will be used for this project
##########################

#load nltk library 
import nltk
nltk.download('vader_lexicon')
nltk.download('movie_reviews')
nltk.download('punkt')

#sentiment analysis with NLTK, we'll use VADER to determine sentiment
from nltk.sentiment.vader import SentimentIntensityAnalyzer as SIA
sia = SIA()

#choose column used for the purpose of this project
def get_scores(row):
    id = row['id']
    date = row['Date']
    text = row['text']
    retweets = row['retweets']
    favorites = row['favorites']
    replies = row['replies']
    hashtags = row['hashtags']
    sia_scores = sia.polarity_scores(text)
    
    return pd.Series({
        'tweet_id': id,
        'date': date,
        'content': text,
        'retweets': retweets,
        'favorites': favorites,
        'replies': replies,
        'hashtags': hashtags,
        'nltk': sia_scores['compound'],
    })

scores = df.apply(get_scores,axis=1)

def b(scores):
    if scores['nltk'] > 0:
        return 'positive'
    elif scores['nltk'] == 0:
        return 'neutral'
    else:
        return 'negative'

scores['sentiment_nltk'] = scores.apply(b, axis=1)


##########################
# Step 4: Connect to AWS RDS MySQL database -'rawdata02'
# purpose: Create staging tables in RDS MySQL OLTP database

##########################

import mysql.connector
from mysql.connector import errorcode

rds_host = "database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com"
name = "admin"
password = "Susan830"
db_name = "rawdata02"

conn = mysql.connector.connect(host=rds_host, user=name, passwd=password, port=3306, db=db_name, allow_local_infile = "True")
cur = conn.cursor()

# create table for applicant
createStgTable11 = "DROP TABLE IF EXISTS applicant;"

createStgTable12 = "CREATE TABLE applicant(ID INT NOT NULL, hs_gpa VARCHAR(25) NULL,appl_date VARCHAR(25) NOT NULL, coll_code_1 VARCHAR(5) NULL, college VARCHAR(25) NULL, stat_code VARCHAR(5) NULL,natn_code VARCHAR(5) NULL, gender VARCHAR(2) NULL, state VARCHAR(30) NULL, scod_code_iso VARCHAR(10) NULL,nation VARCHAR(45) NULL, capital VARCHAR(25) NULL,area VARCHAR(25) NULL, population VARCHAR(25) NULL, PRIMARY KEY (ID),UNIQUE INDEX idnew_table_UNIQUE (ID ASC));"

# create table for twitter
createStgTable21 = "DROP TABLE IF EXISTS twitter;"

createStgTable22 = "CREATE TABLE twitter (  tweet_id VARCHAR(30) NOT NULL,  date DATETIME NOT NULL,  content VARCHAR(1000) NULL,  retweets INT NULL,  favorites INT NULL,  replies INT NULL,  hashtags VARCHAR(100) NULL,  nltk DECIMAL(10,10) NULL,  sentiment_nltk VARCHAR(10) NULL,  PRIMARY KEY (`tweet_id`));"


cur.execute(createStgTable11)
cur.execute(createStgTable12)
cur.execute(createStgTable21)
cur.execute(createStgTable22)
conn.commit()


##########################
# Step 5: Read applicant data from MY local directory
# Applicant data is a ready-to-use csv file, which is saved at a local directory

##########################

applicants = pd.read_csv('https://raw.githubusercontent.com/susanqisun/DAV6100/master/applicants.csv')


##########################
# Step 6: Load data to (overwrite) RDS MySQL OLTP database using 'sqlalchemy.create_engine'
##########################

import sqlalchemy 
from sqlalchemy import create_engine

database_connection = sqlalchemy.create_engine('mysql+mysqlconnector://admin:Susan830@database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com/rawdata02')

#overwrite/load twitter data
scores.to_sql('twitter', con=database_connection, if_exists='replace')

#overwrite/load applicant data
applicants.to_sql('applicant', con=database_connection, if_exists='replace')


##########################
# Step 7: Load data to another S3 bucket 'raw-data01'
# purpose: Put data to S3 to trigger Lambda for updating RDS OLAP databasae (dimentions and fact tables).
# S3 bucket: https://s3.console.aws.amazon.com/s3/buckets/raw-data01/?region=us-east-1
##########################

import boto3
import time

s3 = boto3.resource(
    's3',
    region_name='us-east-1',
    aws_access_key_id='AKIAUNNB2E5FCXFXXQ3P',
    aws_secret_access_key='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'
)

bucket = 'raw-data01' # already created on S3
datetime = time.strftime("%Y%m%d%H%M%S")
filename01 = 'tweets'
filenames02 = "%s%s.csv"%(filename01,datetime) #name of the filepath and csv file
filename03 = 'applicants'
filenames04 = "%s%s.csv"%(filename03,datetime) #name of the filepath and csv file


csv_buffer_applicant = StringIO()
applicants.to_csv(csv_buffer_applicant)

s3.Object(bucket, filenames02).put(Body=csv_buffer_applicant.getvalue())

csv_buffer_twitter = StringIO()
scores.to_csv(csv_buffer_twitter)

s3.Object(bucket, filenames04).put(Body=csv_buffer_twitter.getvalue())

conn.close()
#print success message
print("Successfull uploaded file to S3 bucket 'raw-data01'")   


##########################
# Step 8: Send notification to gmail about the status
# Reference: Brandon Chiazza's Lab 2-part 1-"example_email.py".
# Generate app password @google -https://myaccount.google.com/security

##########################


import email
import smtplib
from datetime import datetime

gmail_user = 'susan.qisun@gmail.com'
gmail_password = 'qweuneditdqtuzot'
now = datetime.now() # current date and time


sent_from = gmail_user
to = ['susan.qisun@gmail.com']
subject = 'Process Completed on: ' + now.strftime("%m/%d/%Y - %H:%M:%S")
body = 'Your Job Processed with 0 Errors'

email_text = """From: %s
    To: %s
    Subject: %s
    
    %s
    """ % (sent_from, to, subject, body)

try:
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls()
    server.login(gmail_user, gmail_password)
    server.sendmail(sent_from, to, email_text)
    server.close()
    print ('Email successfully sent')
except:
    print ('Error: your email did not send')





