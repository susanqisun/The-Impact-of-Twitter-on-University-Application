#Author: Qi Sun#
-- AWS RDS MySQL OLAP database: applicant_twitter
-- Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
-- Port: 3306
-- username: admin
-- password: Susan830

DROP DATABASE IF EXISTS applicant_twitter;

CREATE SCHEMA `applicant_twitter` ;

USE applicant_twitter;

DROP TABLE IF EXISTS dim_college;
CREATE TABLE `applicant_twitter`.`dim_college` (
  `college_key` INT NOT NULL AUTO_INCREMENT,
  `college_code` VARCHAR(5) NOT NULL,
  `college` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`college_key`));
  
  
DROP TABLE IF EXISTS dim_state;
CREATE TABLE `applicant_twitter`.`dim_state` (
  `state_key` INT NOT NULL AUTO_INCREMENT,
  `state_code` VARCHAR(5) NOT NULL,
  `state` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`state_key`));

  
DROP TABLE IF EXISTS dim_nation;
CREATE TABLE `applicant_twitter`.`dim_nation` (
  `nation_key` INT NOT NULL AUTO_INCREMENT,
  `nation_code` VARCHAR(5) NOT NULL,
  `nation` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`nation_key`));
  
  
DROP TABLE IF EXISTS dim_gender;
CREATE TABLE `applicant_twitter`.`dim_gender` (
  `gender_key` INT NOT NULL AUTO_INCREMENT,
  `gender` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`gender_key`));
  
DROP TABLE IF EXISTS `dim_date`;
CREATE TABLE `dim_date` (
  `date_key` int not null auto_increment primary key,
  `date_string` varchar(100),
  `date_year` int,
  `date_month` int,
  `date_day` int,
  `date_quarter` int,
  `date_weekday` int,
  `date_week` int
  );

DROP TABLE IF EXISTS `dim_sentiment`;
CREATE TABLE `applicant_twitter`.`dim_sentiment` (
  `sentiment_key` INT NOT NULL AUTO_INCREMENT,
  `sentiment` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`sentiment_key`));


DROP TABLE IF EXISTS `fact_applicant`;
CREATE TABLE `applicant_twitter`.`fact_applicant` (
  `date_key` INT NOT NULL,
  `gender_key` INT NOT NULL,
  `college_key` INT NOT NULL,
  `state_key` INT,
  `nation_key` INT,
  `applicant_count` INT NULL,
    FOREIGN KEY (`date_key`) REFERENCES `applicant_twitter`.`dim_date` (`date_key`),
    FOREIGN KEY (`gender_key`)
    REFERENCES `applicant_twitter`.`dim_gender` (`gender_key`),
    FOREIGN KEY (`college_key`)
    REFERENCES `applicant_twitter`.`dim_college` (`college_key`),
    FOREIGN KEY (`state_key`)
    REFERENCES `applicant_twitter`.`dim_state` (`state_key`),
    FOREIGN KEY (`nation_key`)
    REFERENCES `applicant_twitter`.`dim_nation` (`nation_key`)
);

DROP TABLE IF EXISTS `fact_twitter`;
CREATE TABLE `applicant_twitter`.`fact_twitter` (
  `date_key` INT NOT NULL,
  `sentiment_key` INT NOT NULL,
  `sentiment_count` INT NULL,
  `retweets_count` INT NULL,  
  `favorites_count` INT NULL,
  `replies_count` INT NULL,    
    FOREIGN KEY (`date_key`)
    REFERENCES `applicant_twitter`.`dim_date` (`date_key`),
    FOREIGN KEY (`sentiment_key`)
    REFERENCES `applicant_twitter`.`dim_sentiment` (`sentiment_key`)
);

select * from fact_twitter;

select * from fact_applicant;
