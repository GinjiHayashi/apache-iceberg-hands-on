# Spark 公式イメージに JupyterLab と PyIceberg を追加する（docs/adr/0003 を参照）
FROM apache/spark:4.1.3-scala2.13-java17-python3-ubuntu

ARG ICEBERG_VERSION=1.11.0
USER root

# Iceberg の jar（Spark ランタイムと AWS 連携）をビルド時に取得して Spark に同梱する
RUN cd /opt/spark/jars \
 && curl -fsSLO https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.1_2.13/${ICEBERG_VERSION}/iceberg-spark-runtime-4.1_2.13-${ICEBERG_VERSION}.jar \
 && curl -fsSLO https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/${ICEBERG_VERSION}/iceberg-aws-bundle-${ICEBERG_VERSION}.jar

# 追加パッケージは uv で管理する。仮想環境はシステムの Python 3.10 で作る
COPY --from=ghcr.io/astral-sh/uv:0.12.19 /uv /usr/local/bin/uv
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON=/usr/bin/python3 \
    UV_PYTHON_DOWNLOADS=never
WORKDIR /opt/jupyter
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-cache \
 # イメージ同梱の PySpark を仮想環境から import できるようにする
 && SITE=$(/opt/venv/bin/python -c 'import site; print(site.getsitepackages()[0])') \
 && { echo /opt/spark/python; ls /opt/spark/python/lib/py4j-*-src.zip; } > $SITE/pyspark.pth

COPY spark-defaults.conf.template entrypoint.sh /opt/jupyter/
RUN chmod +x /opt/jupyter/entrypoint.sh \
 # ホストのユーザー（compose の user で指定）でも書き込めるホームディレクトリ
 && mkdir -p /home/handson && chmod 777 /home/handson \
 # 起動時に entrypoint.sh が実行ユーザーを登録できるようにする（Hadoop のログインにユーザー名が必要）
 && chmod 666 /etc/passwd

ENV PATH=/opt/venv/bin:$PATH \
    HOME=/home/handson \
    SPARK_CONF_DIR=/home/handson/spark-conf
WORKDIR /workspace
ENTRYPOINT ["/opt/jupyter/entrypoint.sh"]
