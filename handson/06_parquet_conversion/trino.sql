-- 06. Parquet から Iceberg への変換（Trino）
-- spark.ipynb を実行した後に実行する:
--   make trino-sql FILE=handson/06_parquet_conversion/trino.sql
--
-- Trino は S3 上の素の Parquet ファイルを直接 SELECT できない（読むには Hive コネクタなどが必要）。
-- ここでは Spark の CTAS で作った taxi_ctas を元に、Trino の CTAS で形を変えたテーブルを作る。

-- 1. CTAS: 列を絞り、日単位のパーティションを付けて書き直す
DROP TABLE IF EXISTS taxi_ctas_trino;
CREATE TABLE taxi_ctas_trino
WITH (partitioning = ARRAY['day(pickup_at)'])
AS
SELECT
    vendorid              AS vendor_id,
    tpep_pickup_datetime  AS pickup_at,
    trip_distance,
    total_amount
FROM taxi_ctas
WHERE tpep_pickup_datetime >= TIMESTAMP '2024-12-01 00:00:00'
  AND tpep_pickup_datetime <  TIMESTAMP '2025-01-01 00:00:00';

-- 2. 書き直されたファイルを確認する（日ごとのパーティションに分かれている）
SELECT count(*) AS data_files, sum(record_count) AS rows FROM "taxi_ctas_trino$files";

SELECT partition, record_count, file_count
FROM "taxi_ctas_trino$partitions"
ORDER BY partition
LIMIT 5;
