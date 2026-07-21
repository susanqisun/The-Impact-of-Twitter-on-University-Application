#Author: Qi Sun#
-- AWS RDS MySQL OLAP database: applicant_twitter
-- Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
-- Port: 3306
-- username: admin
-- password: Susan830


USE `applicant_twitter`;
DROP procedure IF EXISTS `updateDimensionProc`;

DELIMITER $$
USE `applicant_twitter`$$
CREATE PROCEDURE `updateDimensionProc`()
BEGIN
SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

SET FOREIGN_KEY_CHECKS=0;
#Update Date Dimension
TRUNCATE TABLE  applicant_twitter.dim_date;
INSERT INTO applicant_twitter.dim_date(date_string, date_year,date_month, date_day, date_quarter, date_weekday, date_week) 
SELECT distinct appl_date as 'Date String',
YEAR(str_to_date(appl_date,'%m/%d/%Y')) as Year,
MONTH(str_to_date(appl_date,'%m/%d/%Y')) as Month,
Day(str_to_date(appl_date,'%m/%d/%Y')) as Day,
Quarter(str_to_date(appl_date,'%m/%d/%Y')) as Quarter,
WeekDay(str_to_date(appl_date,'%m/%d/%Y')) as WeekDay,
Week(str_to_date(appl_date,'%m/%d/%Y')) as Week
FROM rawdata02.applicant
WHERE appl_date <> ' '
ORDER BY YEAR,MONTH, DAY;

#Update College Dimension
TRUNCATE TABLE  applicant_twitter.dim_college;
INSERT INTO applicant_twitter.dim_college(college_code, college) 
SELECT DISTINCT coll_code_1 AS 'college_code',
college as 'college'
FROM rawdata02.applicant
ORDER BY coll_code_1;

#Update State Dimension
TRUNCATE TABLE  applicant_twitter.dim_state;
INSERT INTO applicant_twitter.dim_state(state_code, state) 
SELECT DISTINCT stat_code AS 'state_code',
state as 'state'
FROM rawdata02.applicant
WHERE state <> ' '
ORDER BY state_code;

#Update Nation Dimension
TRUNCATE TABLE  applicant_twitter.dim_nation;
INSERT INTO applicant_twitter.dim_nation(nation_code, nation) 
SELECT DISTINCT natn_code AS 'nation_code',
nation as 'nation'
FROM rawdata02.applicant
WHERE nation <> ' '
ORDER BY nation_code;

#Update Gender Dimension
TRUNCATE TABLE  applicant_twitter.dim_gender;
INSERT INTO applicant_twitter.dim_gender(gender) 
SELECT DISTINCT gender AS 'gender'
FROM rawdata02.applicant
ORDER BY gender;

#Update Sentiment Dimension
TRUNCATE TABLE  applicant_twitter.dim_sentiment;
INSERT INTO applicant_twitter.dim_sentiment(sentiment) 
SELECT DISTINCT sentiment_nltk AS 'sentiment'
FROM rawdata02.twitter
ORDER BY sentiment;

SET FOREIGN_KEY_CHECKS=1;
END$$

DELIMITER ;

CALL `applicant_twitter`.`updateDimensionProc`();

