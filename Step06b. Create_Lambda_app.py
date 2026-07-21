#!/usr/bin/env python
# coding: utf-8

##########################
#Purpose: use AWS Lambda to update OLAP database - dimensions and fact tables.
#Reference: https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html
#Reference: Brandon Chiazza's app.py in class of 4/22/2020
##########################

import sys
import logging
import rds_config
import pymysql
#rds settings
rds_host  = "database-1.cqlyumyrdhnx.us-east-1.rds.amazonaws.com"
name = rds_config.db_username
password = rds_config.db_password
db_name = rds_config.db_name

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)
except pymysql.MySQLError as e:
    logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
    logger.error(e)
    sys.exit()

logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")
def handler(event, context):
    """
    This function fetches content from MySQL RDS instance
    """

    item_count = 0

    with conn.cursor() as cur:
        cur.execute("CALL `applicant_twitter`.`updateDimensionProc`();")
        cur.execute("CALL `applicant_twitter`.`updateFactProc`();")
        cur.execute("CALL `applicant_twitter`.`updateFactProc02`();")
        conn.commit()
        cur.execute("SELECT * from fact_applicant")
        for row in cur:
            item_count += 1
            logger.info(row)
            #print(row)
    conn.commit()

    return "Added %d items from RDS MySQL table" %(item_count)

