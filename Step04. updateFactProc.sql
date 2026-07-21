#Author: Qi Sun#
-- AWS RDS MySQL OLAP database: applicant_twitter
-- Endpoint: database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com
-- Port: 3306
-- username: admin
-- password: Susan830


USE `applicant_twitter`;
DROP procedure IF EXISTS `updateFactProc`;

DELIMITER $$
USE `applicant_twitter`$$
CREATE PROCEDURE `updateFactProc`()
BEGIN
SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

#Update applicant fact table
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SET FOREIGN_KEY_CHECKS=0;
  
TRUNCATE TABLE  applicant_twitter.fact_applicant;
INSERT INTO applicant_twitter.fact_applicant(date_key, gender_key, college_key, state_key, nation_key, applicant_count)
SELECT 
date_key, gender_key, college_key, state_key, nation_key, applicant_count
FROM (SELECT rawdata02.applicant.appl_date, 
college, state, nation, gender,
COUNT(appl_date) as 'applicant_count'
FROM rawdata02.applicant
GROUP BY appl_date, gender, college, state, nation) as a
LEFT JOIN applicant_twitter.dim_college ON a.college = applicant_twitter.dim_college.college
LEFT JOIN applicant_twitter.dim_state ON a.state = applicant_twitter.dim_state.state 
LEFT JOIN applicant_twitter.dim_nation ON a.nation= applicant_twitter.dim_nation.nation
LEFT JOIN applicant_twitter.dim_gender ON a.gender= applicant_twitter.dim_gender.gender
LEFT JOIN applicant_twitter.dim_date ON a.appl_date = applicant_twitter.dim_date.date_string
GROUP BY date_key, gender_key, college_key, state_key, nation_key
ORDER BY date_key, gender_key, college_key, state_key, nation_key;

SET FOREIGN_KEY_CHECKS=1;

END$$

DELIMITER ;

CALL `applicant_twitter`.`updateFactProc`();

SELECT * FROM fact_applicant;
