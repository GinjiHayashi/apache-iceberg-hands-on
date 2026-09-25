#!/bin/sh
# NYC TLC Yellow Taxi のサンプルデータ（Parquet）を data/ に取得する。
# 既にあるファイルはダウンロードし直さない。
#   2024-12: 基本のデータ
#   2025-01: cbd_congestion_fee 列が追加された月（03_schema_evolution で使う）
set -eu

BASE_URL=https://d37ci6vzurychx.cloudfront.net/trip-data
MONTHS="2024-12 2025-01"
DATA_DIR=$(dirname "$0")/../data

mkdir -p "$DATA_DIR"
for month in $MONTHS; do
  file=yellow_tripdata_$month.parquet
  if [ -f "$DATA_DIR/$file" ]; then
    echo "⏭️  $file（既にあるのでスキップ）"
    continue
  fi
  echo "⬇️  $file をダウンロード中..."
  # 途中で失敗したときに壊れたファイルが残らないよう、一時ファイルに落としてから移動する
  curl -fL --progress-bar -o "$DATA_DIR/$file.part" "$BASE_URL/$file"
  mv "$DATA_DIR/$file.part" "$DATA_DIR/$file"
done
echo "✅ サンプルデータの準備ができました: $(cd "$DATA_DIR" && pwd)"
