#!/usr/bin/env python3
"""
COVID-19 Data Analysis using Apache Spark
==========================================

This PySpark application demonstrates distributed data processing by analyzing
COVID-19 global statistics from a public GitHub dataset.

Analysis Tasks:
1. Top 10 countries by total confirmed cases
2. Top 10 countries by total deaths
3. Global statistics (total cases, deaths, recovered)
4. Dataset summary (country count, record count)

Data Source: https://github.com/datasets/covid-19
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import max as _max, sum as _sum, desc
import sys
import pandas as pd


def create_spark_session():
    return SparkSession.builder \
        .appName("COVID-19 Analysis") \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .getOrCreate()


def load_data(spark, data_url):
    print(f"\n{'='*60}")
    print("Loading COVID-19 Dataset")
    print(f"{'='*60}")
    print(f"Source: {data_url}\n")

    # Load via pandas on driver (supports HTTPS), then distribute
    pandas_df = pd.read_csv(data_url)
    print(f"✓ Downloaded {len(pandas_df):,} records")

    df = spark.createDataFrame(pandas_df)
    print(f"✓ Distributed as Spark DataFrame\n")
    return df


def analyze_top_countries_by_cases(df):
    print(f"\n{'='*60}")
    print("Analysis 1: Top 10 Countries by Confirmed Cases")
    print(f"{'='*60}\n")

    top_cases = df.groupBy("Country") \
        .agg(_max("Confirmed").alias("Total_Confirmed")) \
        .orderBy(desc("Total_Confirmed")) \
        .limit(10)

    top_cases.show(truncate=False)
    return top_cases


def analyze_top_countries_by_deaths(df):
    print(f"\n{'='*60}")
    print("Analysis 2: Top 10 Countries by Deaths")
    print(f"{'='*60}\n")

    top_deaths = df.groupBy("Country") \
        .agg(_max("Deaths").alias("Total_Deaths")) \
        .orderBy(desc("Total_Deaths")) \
        .limit(10)

    top_deaths.show(truncate=False)
    return top_deaths


def analyze_global_statistics(df):
    print(f"\n{'='*60}")
    print("Analysis 3: Global Statistics")
    print(f"{'='*60}\n")

    # Each country's peak cumulative value, then summed across all countries
    country_peaks = df.groupBy("Country").agg(
        _max("Confirmed").alias("Confirmed"),
        _max("Deaths").alias("Deaths"),
        _max("Recovered").alias("Recovered"),
    )
    global_stats = country_peaks.agg(
        _sum("Confirmed").alias("Global_Confirmed"),
        _sum("Deaths").alias("Global_Deaths"),
        _sum("Recovered").alias("Global_Recovered"),
    )

    global_stats.show(truncate=False)
    return global_stats


def analyze_dataset_summary(df):
    print(f"\n{'='*60}")
    print("Analysis 4: Dataset Summary")
    print(f"{'='*60}\n")

    country_count = df.select("Country").distinct().count()
    total_records = df.count()

    print(f"Total Countries : {country_count}")
    print(f"Total Records   : {total_records:,}\n")

    return country_count, total_records


def main():
    print(f"\n{'#'*60}")
    print("#" + " COVID-19 Analysis with Apache Spark".center(58) + "#")
    print(f"{'#'*60}\n")

    data_url = "https://raw.githubusercontent.com/datasets/covid-19/main/data/countries-aggregated.csv"

    spark = create_spark_session()
    spark.sparkContext.setLogLevel("ERROR")

    try:
        df = load_data(spark, data_url)
        df.printSchema()

        analyze_top_countries_by_cases(df)
        analyze_top_countries_by_deaths(df)
        analyze_global_statistics(df)
        analyze_dataset_summary(df)

        print(f"\n{'='*60}")
        print("Analysis Complete!")
        print("• Data distributed across executor pods")
        print("• Aggregations optimized by Catalyst query engine")
        print(f"{'='*60}\n")

    except Exception as e:
        print(f"\n✗ Error: {str(e)}", file=sys.stderr)
        sys.exit(1)
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
