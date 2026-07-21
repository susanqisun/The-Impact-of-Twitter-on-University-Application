
# The Relationship Between Twitter and University Undergraduate Application

The purpose of this project is to examine the relationship between Twitter and undergraduate application. 


## 1. Getting Started

The applicant data is saved at the data folder.

```
Introduction:

1. "workflow.png" is a brief introduction of how this works.

2. "end to end process.png" outlines the entire end to end process, including access info.

3. "development_process.png" is a detailed introduction on how this was developed and 
    shows which file in the folder of "02. Develop and Build" was used to create the process.

```

## 2. Development


All codes used for this project are saved at the "Develop and Build" folder.


### Test codes of development

```
Start: Run "Step01. Scrape_to_S3.py"

We can run this locally or set up a schedule to automatically run it.

The whole process will take 10 mins.

```

#### Prerequisites:
```

#Scrape Twitter data:

pip install GetOldTweets3

(documentation: https://pypi.org/project/GetOldTweets3/)


# Load library:

import pandas as pd
import GetOldTweets3 as got
import datetime
import boto3
from io import StringIO
import time

import nltk
nltk.download('vader_lexicon')
nltk.download('movie_reviews')
nltk.download('punkt')

import mysql.connector
from mysql.connector import errorcode

import sqlalchemy 
from sqlalchemy import create_engine

import email
import smtplib
from datetime import datetime

```

#### Results:
```

If there's no error while running Python script, I'll receive a email, which is the last step in Python script. 
Also,I'll receive one email about RDS connection and one email about Lambda status (Success/Failure).

The OLTP and OLAP database will be updated.

Open Tableau and enter the password (Susan830) to connect to the RDS MySQL database, 
update the database.

```

### Test OLAP database

```

Use "Test_OLAP_example queries.sql"

```

## 3. AWS Lambda  

```
* Configuring a Lambda function to access Amazon RDS:
Trusted entity – Lambda.
Permissions – AWSLambdaVPCAccessExecutionRole.
Role name – lambda-vpc-role.
ARN IAM ROLE: 
arn:aws:iam::303671420746:role/lambda-vpc-role

* ARN: lambda function:
arn:aws:lambda:us-east-1:303671420746:function:rds_final

```

### Create external library for AWS Lambda

```

"Step06c. Create_External_Lib.txt" is used on Mac to create library.

```

### Set up and Test AWS Lambda:

```
Upload "Step07. app_UploadToLambda.zip" to AWS Lambda

Runtime: Python 3.7
Handler: app.handler
Timeout: 15 min

```

## 4. Access:

```

* AWS S3 bucket (trigger AWS Lambda):

* AWS S3 (save raw twitter data):

* Tableau:
connect to AWS RDS MySQL 


* AWS RDS MySQL OLAP database:
Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
Port: 3306
username: admin
password: 
database: applicant_twitter


* AWS RDS MySQL OLTP database:
Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
Port: 3306
username: admin
password: 
database: rawdata02


```

<img width="1007" height="1822" alt="development_process" src="https://github.com/user-attachments/assets/4b0b7351-9fed-493d-8d91-31967c124c27" />

<img width="909" height="1191" alt="workflow" src="https://github.com/user-attachments/assets/e1ab20e3-2723-417c-8d2c-d1d500dbe54c" />

<img width="1231" height="1857" alt="end to end process" src="https://github.com/user-attachments/assets/34a92a2e-71f2-4127-ad96-755075acffec" />



