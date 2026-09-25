-- 03. スキーマ進化（Trino）
-- 実行: make trino-sql FILE=handson/03_schema_evolution/trino.sql
-- どの変更もメタデータだけで終わり、データファイルは書き直されないことを確かめる。

DROP TABLE IF EXISTS schema_trino;
CREATE TABLE schema_trino (trip_id INTEGER, vendor VARCHAR, fare_amount DOUBLE, payment_type BIGINT);
INSERT INTO schema_trino VALUES (1, 'A', 12.5, 1), (2, 'B', 30.0, 2);

-- データファイルの数（この後いくらスキーマを変えても増えない）
SELECT count(*) AS data_files FROM "schema_trino$files";

-- 1. 列を追加する（既存の行では NULL になる）
ALTER TABLE schema_trino ADD COLUMN cbd_congestion_fee DOUBLE;
INSERT INTO schema_trino VALUES (3, 'A', 8.0, 1, 0.75);
SELECT * FROM schema_trino ORDER BY trip_id;

-- 2. 列の名前を変える（古いファイルも列 ID で対応が取れるので読める）
ALTER TABLE schema_trino RENAME COLUMN fare_amount TO fare;
SELECT trip_id, fare FROM schema_trino ORDER BY trip_id;

-- 3. 型を広げる（INTEGER → BIGINT のような安全な変更だけが許される）
ALTER TABLE schema_trino ALTER COLUMN trip_id SET DATA TYPE BIGINT;
DESCRIBE schema_trino;

-- 4. 列を削除して、同じ名前で追加し直す（新しい列 ID が振られるので古い値は復活しない）
ALTER TABLE schema_trino DROP COLUMN payment_type;
ALTER TABLE schema_trino ADD COLUMN payment_type BIGINT;
SELECT * FROM schema_trino ORDER BY trip_id;

-- 書き込んだのは INSERT の2回分だけなので、データファイルは2つのまま
SELECT count(*) AS data_files FROM "schema_trino$files";
