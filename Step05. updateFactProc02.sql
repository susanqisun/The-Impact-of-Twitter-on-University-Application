#Author: Qi Sun#
-- AWS RDS MySQL OLAP database: applicant_twitter
-- Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
-- Port: 3306
-- username: admin
-- password: Susan830


USE `applicant_twitter`;
DROP procedure IF EXISTS `updateFactProc02`;

DELIMITER $$
USE `applicant_twitter`$$
CREATE PROCEDURE `updateFactProc02`()
BEGIN
SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
#Update twitter fact table
ALTER TABLE applicant_twitter.dim_sentiment CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE applicant_twitter.dim_date CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;

SET FOREIGN_KEY_CHECKS=0;
  
TRUNCATE TABLE  applicant_twitter.fact_twitter;
INSERT INTO applicant_twitter.fact_twitter(date_key, sentiment_key, sentiment_count, 
retweets_count, favorites_count, replies_count)
SELECT 
date_key, sentiment_key, sentiment_count, 
retweets_count, favorites_count, replies_count
FROM (SELECT DATE_FORMAT(rawdata02.twitter.twitter_date, '%c/%e/%Y') as twitter_date,
sentiment_nltk,
COUNT(sentiment_nltk) as 'sentiment_count',
SUM(retweets) as 'retweets_count',
SUM(favorites) as 'favorites_count',
SUM(replies) as 'replies_count'
FROM rawdata02.twitter
GROUP BY twitter_date, sentiment_nltk) as a
LEFT JOIN applicant_twitter.dim_sentiment ON a.sentiment_nltk = applicant_twitter.dim_sentiment.sentiment
LEFT JOIN applicant_twitter.dim_date ON a.twitter_date = applicant_twitter.dim_date.date_string
WHERE date_key IS NOT NULL
GROUP BY date_key, sentiment_key
ORDER BY date_key, sentiment_key;

SET FOREIGN_KEY_CHECKS=1;

END$$

DELIMITER ;


CALL `applicant_twitter`.`updateFactProc02`();

SELECT * FROM applicant_twitter.fact_twitter;
