#!/bin/sh
# Spark の設定ファイルを作ってから JupyterLab を起動する
set -eu

# compose の user で指定した UID がコンテナ内に登録されていなければ登録する
if ! getent passwd "$(id -u)" >/dev/null; then
  echo "handson:x:$(id -u):$(id -g):handson:$HOME:/bin/bash" >> /etc/passwd
fi

mkdir -p "$SPARK_CONF_DIR"
sed -e "s|\${POLARIS_CLIENT_ID}|$POLARIS_CLIENT_ID|" \
    -e "s|\${POLARIS_CLIENT_SECRET}|$POLARIS_CLIENT_SECRET|" \
    /opt/jupyter/spark-defaults.conf.template > "$SPARK_CONF_DIR/spark-defaults.conf"

# ローカル専用なので認証なし（ポートは compose で 127.0.0.1 に限定している）
exec jupyter lab \
  --ip=0.0.0.0 --port=8888 --no-browser \
  --IdentityProvider.token='' --ServerApp.password='' \
  --ServerApp.root_dir=/workspace
