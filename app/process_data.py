import argparse
import pyspark.sql.functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, BooleanType
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
import awswrangler as wr
from utils import Logger
from datetime import datetime

sc = SparkContext.getOrCreate()
spark = SparkSession.builder.master("yarn").getOrCreate()
log = Logger()

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
    StructField("starttime", StringType(), True)])

listing_schema = StructType([
    StructField("listid", IntegerType(), True),
    StructField("sellerid", IntegerType(), True),
    StructField("eventid", IntegerType(), True),
    StructField("dateid", IntegerType(), True),
    StructField("numtickets", IntegerType(), True),
    StructField("priceperticket", FloatType(), True),
    StructField("totalprice", FloatType(), True),
    StructField("listtime", StringType(), True)])

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
                 
    args = app_parser.parse_args()
    log.info(f"Started processing of trusted data'.")
    process_data(args.raw_opt, args.trusted_opt)
