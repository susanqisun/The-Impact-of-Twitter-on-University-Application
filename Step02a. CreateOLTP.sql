#Author: Qi Sun#
-- AWS RDS MySQL OLTP database: rawdata
-- Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
-- Port: 3306
-- username: admin
-- password: Susan830


USE rawdata;


DROP TABLE IF EXISTS applicant;

CREATE TABLE `rawdata`.`applicant` (
  `ID` INT NOT NULL,
  `hs_gpa` VARCHAR(25) NULL,
  `appl_date` VARCHAR(25) NOT NULL,
  `coll_code_1` VARCHAR(5) NULL,
  `college` VARCHAR(25) NULL,
  `stat_code` VARCHAR(5) NULL,
  `natn_code` VARCHAR(5) NULL,
  `gender` VARCHAR(2) NULL,
  `state` VARCHAR(30) NULL,
  `scod_code_iso` VARCHAR(10) NULL,
  `nation` VARCHAR(45) NULL,
  `capital` VARCHAR(25) NULL,
  `area` VARCHAR(25) NULL,
  `population` VARCHAR(25) NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `idnew_table_UNIQUE` (`ID` ASC));
  
DROP TABLE IF EXISTS twitter;

CREATE TABLE `rawdata`.`twitter` (
  `tweet_id` VARCHAR(30) NOT NULL,
  `date` DATETIME NOT NULL,
  `content` VARCHAR(1000) NULL,
  `retweets` INT NULL,
  `favorites` INT NULL,
  `replies` INT NULL,
  `hashtags` VARCHAR(100) NULL,
  `nltk` DECIMAL(10,10) NULL,
  `sentiment_nltk` VARCHAR(10) NULL,
  PRIMARY KEY (`tweet_id`));
  




