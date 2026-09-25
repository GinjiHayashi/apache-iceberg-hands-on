-- 10. v3 のテーブルを Trino から読み書きする（追加目標）
-- spark.ipynb を実行した後に実行する:
--   make trino-sql FILE=handson/10_v3_upgrade/trino.sql
-- Trino 483 の v3 対応は実験的。INSERT / DELETE / UPDATE は削除ベクトルを使って動く。

-- 1. テーブルのフォーマットのバージョン
SELECT value AS format_version FROM "v3_spark$properties" WHERE key = 'format-version';

-- 2. Spark が v3 で書いたテーブルを読む
SELECT * FROM v3_spark ORDER BY trip_id;

-- 3. Trino から書き込む
INSERT INTO v3_spark VALUES (5, 'D', 5.00);
DELETE FROM v3_spark WHERE trip_id = 4;

SELECT * FROM v3_spark ORDER BY trip_id;

-- 4. Trino の DELETE も削除ベクトル（PUFFIN）として記録される
SELECT content, file_format, record_count FROM "v3_spark$files" ORDER BY content;

-- 5. Trino から v2 のテーブルを v3 にアップグレードすることもできる
DROP TABLE IF EXISTS v3_trino;
CREATE TABLE v3_trino (trip_id BIGINT, fare DOUBLE);
INSERT INTO v3_trino VALUES (1, 10.0), (2, 20.0);
ALTER TABLE v3_trino SET PROPERTIES format_version = 3;
SELECT value AS format_version FROM "v3_trino$properties" WHERE key = 'format-version';
