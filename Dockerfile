FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYSPARK_PYTHON=/usr/local/bin/python
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/python
ENV SPARK_EXTRA_JARS_DIR=/opt/spark/jars/
ENV SPARK_EXTRA_CLASSPATH='/opt/spark/jars/*'
ENV PYTHONPATH=/opt/python/packages

RUN apt-get update && apt-get install -y wget procps tini --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "${SPARK_EXTRA_JARS_DIR}" \
    && mkdir -p "${PYTHONPATH}" \
    && pip install --no-cache-dir \
        google-cloud-storage \
        google-cloud-bigquery \
        google-cloud-bigquery-storage \
        pyarrow \
        pandas \
        numpy \
        rtree

RUN groupadd -g 1099 yarn_docker_user \
    && useradd -u 1099 -g 1099 -d /home/yarn_docker_user -m yarn_docker_user
USER yarn_docker_user
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python3"]
