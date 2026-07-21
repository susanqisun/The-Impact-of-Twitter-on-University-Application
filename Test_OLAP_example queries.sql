
-- example queries:

-- How many students on the list applied Yeshiva College?

USE applicant_twitter;

SELECT count(*) FROM fact_applicant
JOIN dim_college On fact_applicant.college_key = dim_college.college_key
WHERE dim_college.college_code = 'YC';



-- How many students applied YU undergraduate programs in 2018?
SELECT count(*) FROM fact_applicant
JOIN dim_date On fact_applicant.date_key = dim_date.date_key
WHERE dim_date.date_year = '2018';



-- How many positive comments about yeshiva university in 2019?
SELECT count(*) FROM fact_twitter
JOIN dim_date On fact_twitter.date_key = dim_date.date_key
JOIN dim_sentiment ON fact_twitter.sentiment_key = dim_sentiment.sentiment_key
WHERE dim_date.date_year = '2019' and sentiment = 'positive';




