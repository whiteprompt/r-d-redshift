import boto3
import argparse
import awswrangler as wr
import pandas as pd
from distutils.util import strtobool
from datetime import datetime
from utils import Logger

log = Logger()

# Schema definitions
category_schema = {
    "catid": "int",
    "catgroup": "string",
    "catname": "string",
    "catdesc": "string"
}
date_schema = {
    "dateid": "int",
    "caldate": "string",
    "day": "string",
    "week": "int",
    "month": "string",
    "qtr": "int",
    "year": "int",
    "holiday": "boolean"
}
event_schema = {
    "eventid": "int",
    "venueid": "int",
    "catid": "int",
    "dateid": "int",
    "eventname": "string",
    "starttime": "datetime64"
}
listing_schema = {
    "listid": "int",
    "sellerid": "int",
    "eventid": "int",
    "dateid": "int",
    "numtickets": "int",
    "priceperticket": "float64",
    "totalprice": "float64",
    "listtime": "datetime64"
}
sales_schema = {
    "salesid": "int",
    "listid": "int",
    "sellerid": "int",
    "buyerid": "int",
    "eventid": "int",
    "dateid": "int",
    "qtysold": "int",
    "pricepaid": "int",
    "commission": "float64",
    "saletime": "datetime64"
}
user_schema = {
    "userid": "int",
    "username": "string",
    "firstname": "string",
    "lastname": "string",
    "city": "string",
    "state": "string",
    "email": "string",
    "phone": "string",
    "likesports": "boolean",
    "liketheatre": "boolean",
    "likeconcerts": "boolean",
    "likejazz": "boolean",
    "likeclassical": "boolean",
    "likeopera": "boolean",
    "likerock": "boolean",
    "likevegas": "boolean",
    "likebroadway": "boolean",
    "likemusicals": "boolean"
}
venue_schema = {
    "venueid": "int",
    "venuename": "string",
    "venuecity": "string",
    "venuestate": "string",
    "venueseats": "string"
}

table_conf = [
    {
        "name": "category",
        "sep": "|"
    },
    {
        "name": "date",
        "sep": "|"
    },
    {
        "name": "event",
        "sep": "|"
    },
    {
        "name": "listing",
        "sep": "|"
    },
    {
        "name": "sales",
        "sep": "\t"
    },
    {
        "name": "user",
        "sep": "|"
    },
    {
        "name": "venue",
        "sep": "|"
    }
]


def process_trusted_data(raw_path, trusted_path):
    try:
        for table in table_conf:
            df_table = wr.s3.read_csv(f"{raw_path}{table['name']}/", sep=f"{table['sep']}", dtype = exec(f"{table['name']}_schema"))
            log.info(f"Writing data to {trusted_path}{table['name']}/")
            wr.s3.to_parquet(
                df=df_table,
                path=f"{trusted_path}{table['name']}/",
                dataset=True,
                mode="append"
            )
    except Exception as e:
        log.error(f"Fail to process data from '{raw_path}' to '{trusted_path}': {str(e)}")

def load_redshift_spectrum():
    try:
        con = wr.redshift.connect(connection="wp-lakehouse-redshift")
        query_tickit_sales_by_category = f"""
        CREATE TABLE lakehouse_poc.tickit_sales_by_category AS (WITH cat AS (
        SELECT DISTINCT e.eventid,
            c.catgroup,
            c.catname
        FROM wp_trusted_redshift.event AS e
            LEFT JOIN wp_trusted_redshift.category AS c ON c.catid = e.catid
    )
    SELECT cast(d.caldate AS DATE) AS caldate,
        s.pricepaid,
        s.qtysold,
        round(cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold, 2) AS sale_amount,
        cast(s.commission AS DECIMAL(8,2)) AS commission,
        round((cast(s.commission AS DECIMAL(8,2)) / (cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold)) * 100, 2) AS commission_prcnt,
        e.eventname,
        concat(u1.firstname, ' ', u1.lastname) AS seller,
        concat(u2.firstname, ' ', u2.lastname) AS buyer,
        c.catname AS bucket_catname,
        c.catgroup,
        c.catname
    FROM wp_trusted_redshift.sales AS s
        LEFT JOIN wp_trusted_redshift.listing AS l ON l.listid = s.listid
        LEFT JOIN wp_trusted_redshift.user AS u1 ON u1.userid = s.sellerid
        LEFT JOIN wp_trusted_redshift.user AS u2 ON u2.userid = s.buyerid
        LEFT JOIN wp_trusted_redshift.event AS e ON e.eventid = s.eventid
        LEFT JOIN wp_trusted_redshift.date AS d ON d.dateid = s.dateid
        LEFT JOIN cat AS c ON c.eventid = s.eventid;)
        """

        query_tickit_sales_by_date = f"""
        CREATE TABLE lakehouse_poc.tickit_sales_by_date AS (WITH cat AS (
        SELECT DISTINCT e.eventid,
            c.catgroup,
            c.catname
        FROM wp_trusted_redshift.event AS e
            LEFT JOIN wp_trusted_redshift.category AS c ON c.catid = e.catid
    )
    SELECT cast(d.caldate AS DATE) AS caldate,
        s.pricepaid,
        s.qtysold,
        round(cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold, 2) AS sale_amount,
        cast(s.commission AS DECIMAL(8,2)) AS commission,
        round((cast(s.commission AS DECIMAL(8,2)) / (cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold)) * 100, 2) AS commission_prcnt,
        e.eventname,
        concat(u1.firstname, ' ', u1.lastname) AS seller,
        concat(u2.firstname, ' ', u2.lastname) AS buyer,
        c.catgroup,
        c.catname,
        d.month AS bucket_month,
        d.year,
        d.month
    FROM wp_trusted_redshift.sales AS s
        LEFT JOIN wp_trusted_redshift.listing AS l ON l.listid = s.listid
        LEFT JOIN wp_trusted_redshift.users AS u1 ON u1.userid = s.sellerid
        LEFT JOIN wp_trusted_redshift.users AS u2 ON u2.userid = s.buyerid
        LEFT JOIN wp_trusted_redshift.event AS e ON e.eventid = s.eventid
        LEFT JOIN wp_trusted_redshift.date AS d ON d.dateid = s.dateid
        LEFT JOIN cat AS c ON c.eventid = s.eventid;)
        """
        
        with con.cursor() as cursor:
            cursor.execute(query_tickit_sales_by_category)
            cursor.execute(query_tickit_sales_by_date)
        con.close()
    
    except Exception as e:
        log.error(f"Fail to load data into Redshift Spectrum': {str(e)}")


def main(raw_path, trusted_path, redshift_load):
    if redshift_load:
        log.info("Beginning data processing from raw to trusted.")
        process_trusted_data(raw_path, trusted_path)
        log.info("Loading Redshift Spectrum tables.")
        load_redshift_spectrum()
    else:
        process_trusted_data(raw_path, trusted_path)



if __name__ == '__main__':
    app_parser = argparse.ArgumentParser(allow_abbrev=False)
    app_parser.add_argument('-r', '--raw',
                            action='store',
                            type=str,
                            required=True,
                            dest='raw_opt',
                            help='Set the raw path to read from.')
    app_parser.add_argument('-t', '--trusted',
                            action='store',
                            type=str,
                            required=True,
                            dest='trusted_opt',
                            help='Set the trusted path to write to.')     
    app_parser.add_argument('-rs', '--redshift',
                            action='store',
                            type=strtobool,
                            default=True,
                            dest='redshift_opt',
                            help='(Optional) Configure Redshift Spectrum to query data from S3 (default: true).')                    

    args = app_parser.parse_args()
    log.info(f"Started processing of trusted data'.")
    main(args.raw_opt, args.trusted_opt, args.redshift_opt)