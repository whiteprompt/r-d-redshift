import boto3
import sys
import argparse
import utils
import pyspark.sql.functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, TimestampType, BooleanType
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from distutils.util import strtobool
import awswrangler as wr
from utils import Logger
from datetime import datetime

sc = SparkContext.getOrCreate()
spark = SparkSession.builder.master("yarn").getOrCreate()
log = Logger()
s3 = boto3.client('s3')
s3_resource = boto3.resource('s3')

# Schema definitions
category_schema = StructType([
    StructField("catid", IntegerType(), True),
    StructField("catgroup", StringType(), True),
    StructField("catname", StringType(), True),
    StructField("catdesc", StringType(), True)])

tbldate_schema = StructType([
    StructField("dateid", IntegerType(), True),
    StructField("caldate", StringType(), True),
    StructField("day", StringType(), True),
    StructField("week", IntegerType(), True),
    StructField("month", StringType(), True),
    StructField("qtr", IntegerType(), True),
    StructField("year", IntegerType(), True),
    StructField("holiday", BooleanType(), True)])

event_schema = StructType([
    StructField("eventid", IntegerType(), True),
    StructField("venueid", IntegerType(), True),
    StructField("catid", IntegerType(), True),
    StructField("dateid", IntegerType(), True),
    StructField("eventname", StringType(), True),
    StructField("starttime", TimestampType(), True)])

listing_schema = StructType([
    StructField("listid", IntegerType(), True),
    StructField("sellerid", IntegerType(), True),
    StructField("eventid", IntegerType(), True),
    StructField("dateid", IntegerType(), True),
    StructField("numtickets", IntegerType(), True),
    StructField("priceperticket", FloatType(), True),
    StructField("totalprice", FloatType(), True),
    StructField("listtime", TimestampType(), True)])

sales_schema = StructType([
    StructField("salesid", IntegerType(), True),
    StructField("listid", IntegerType(), True),
    StructField("sellerid", IntegerType(), True),
    StructField("buyerid", IntegerType(), True),
    StructField("eventid", IntegerType(), True),
    StructField("dateid", IntegerType(), True),
    StructField("qtysold", IntegerType(), True),
    StructField("pricepaid", FloatType(), True),
    StructField("commission", FloatType(), True),
    StructField("saletime", StringType(), True)])

user_schema = StructType([
    StructField("userid", IntegerType(), True),
    StructField("username", StringType(), True),
    StructField("firstname", StringType(), True),
    StructField("lastname", StringType(), True),
    StructField("city", StringType(), True),
    StructField("state", StringType(), True),
    StructField("email", StringType(), True),
    StructField("phone", StringType(), True),
    StructField("likesports", BooleanType(), True),
    StructField("liketheatre", BooleanType(), True),
    StructField("likeconcerts", BooleanType(), True),
    StructField("likejazz", BooleanType(), True),
    StructField("likeclassical", BooleanType(), True),
    StructField("likeopera", BooleanType(), True),
    StructField("likerock", BooleanType(), True),
    StructField("likevegas", BooleanType(), True),
    StructField("likebroadway", BooleanType(), True),
    StructField("likemusicals", BooleanType(), True)])

venue_schema = StructType([
    StructField("venueid", IntegerType(), True),
    StructField("venuename", StringType(), True),
    StructField("venuecity", StringType(), True),
    StructField("venuestate", StringType(), True),
    StructField("venueseats", IntegerType(), True)])

table_conf = [
    {
        "name": "category",
        "sep": "|",
        "schema": category_schema
    },
    {
        "name": "tbldate",
        "sep": "|",
        "schema": tbldate_schema
    },
    {
        "name": "event",
        "sep": "|",
        "schema": event_schema
    },
    {
        "name": "listing",
        "sep": "|",
        "schema": listing_schema
    },
    {
        "name": "sales",
        "sep": "\t",
        "schema": sales_schema
    },
    {
        "name": "user",
        "sep": "|",
        "schema": user_schema
    },
    {
        "name": "venue",
        "sep": "|",
        "schema": venue_schema
    }
]

def process_data(raw_path, trusted_path):
    try:
        for table in table_conf:
            df_table = spark.read.option("header", "true").option("delimiter", f"{table['sep']}").option("escapeQuotes", "true").schema(table['schema']).csv(f"{raw_path}{table['name']}/")
            log.info(f"Writing data to {trusted_path}{table['name']}/")
            df_table.coalesce(1).write.mode("append").option("compression", "snappy").parquet(f"{trusted_path}{table['name']}/")
    except Exception as e:
        log.error(f"Fail to process data from '{raw_path}' to '{trusted_path}': {str(e)}")


def load_redshift_spectrum():
    try:
        con = wr.redshift.connect(connection="wp-lakehouse-redshift")
        cmd_external_schema = """
        create external schema wp_spectrum
        from data catalog
        database 'wp_trusted_redshift'
        iam_role 'arn:aws:iam:::role/wp-lakehouse-spectrum-poc-redshift-role'
        """
        query_tickit_sales_by_category = f"""
        CREATE TABLE public.tickit_sales_by_category AS (WITH cat AS (
        SELECT DISTINCT e.eventid,
            c.catgroup,
            c.catname
        FROM wp_spectrum.event AS e
            LEFT JOIN wp_spectrum.category AS c ON c.catid = e.catid
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
        c.catname,
        c.catgroup,
        c.catname
    FROM wp_spectrum.sales AS s
        LEFT JOIN wp_spectrum.listing AS l ON l.listid = s.listid
        LEFT JOIN wp_spectrum.user AS u1 ON u1.userid = s.sellerid
        LEFT JOIN wp_spectrum.user AS u2 ON u2.userid = s.buyerid
        LEFT JOIN wp_spectrum.event AS e ON e.eventid = s.eventid
        LEFT JOIN wp_spectrum.tbldate AS d ON d.dateid = s.dateid
        LEFT JOIN cat AS c ON c.eventid = s.eventid)
        """

        query_tickit_sales_by_date = f"""
        CREATE TABLE public.tickit_sales_by_date AS (WITH cat AS (
        SELECT DISTINCT e.eventid,
            c.catgroup,
            c.catname
        FROM wp_spectrum.event AS e
            LEFT JOIN wp_spectrum.category AS c ON c.catid = e.catid
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
        d.month,
        d.year,
        d.month
    FROM wp_spectrum.sales AS s
        LEFT JOIN wp_spectrum.listing AS l ON l.listid = s.listid
        LEFT JOIN wp_spectrum.users AS u1 ON u1.userid = s.sellerid
        LEFT JOIN wp_spectrum.users AS u2 ON u2.userid = s.buyerid
        LEFT JOIN wp_spectrum.event AS e ON e.eventid = s.eventid
        LEFT JOIN wp_spectrum.tbldate AS d ON d.dateid = s.dateid
        LEFT JOIN cat AS c ON c.eventid = s.eventid;)
        """
        
        with con.cursor() as cursor:
            cursor.execute(cmd_external_schema)
            cursor.execute(query_tickit_sales_by_category)
            cursor.execute(query_tickit_sales_by_date)
        con.close()
    
    except Exception as e:
        log.error(f"Fail to load data into Redshift Spectrum': {str(e)}")


def main(raw_path, trusted_path, redshift_load):
    if redshift_load:
        log.info("Beginning data processing from raw to trusted.")
        process_data(raw_path, trusted_path)
        log.info("Loading Redshift Spectrum tables.")
        load_redshift_spectrum()
    else:
        process_data(raw_path, trusted_path)



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