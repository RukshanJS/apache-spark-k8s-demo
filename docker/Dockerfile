# Spark COVID-19 Analysis - Docker Image
# Base image: Apache Spark with Python support (ARM64 compatible)
FROM apache/spark:3.5.3-python3

# Metadata
LABEL maintainer="University of Moratuwa - Big Data Analytics Course"
LABEL description="Apache Spark application for COVID-19 data analysis"
LABEL version="1.0"

# Switch to root to set permissions
USER root

# Install pandas for data loading
RUN pip install --no-cache-dir pandas

# Create work directory
RUN mkdir -p /opt/spark/work-dir && \
    chown -R spark:spark /opt/spark/work-dir

# Copy application code
COPY src/covid_analysis.py /opt/spark/work-dir/covid_analysis.py

# Ensure script is executable
RUN chmod +x /opt/spark/work-dir/covid_analysis.py

# Switch back to spark user (UID 185)
USER spark

# Set working directory
WORKDIR /opt/spark/work-dir

# Default command (will be overridden by SparkApplication)
CMD ["/opt/spark/bin/spark-submit", "covid_analysis.py"]
