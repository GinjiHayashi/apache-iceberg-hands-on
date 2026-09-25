-- 05. エンジン間の相互運用（Trino 側）
-- spark.ipynb の前半を実行した後に実行する:
--   make trino-sql FILE=handson/05_interoperability/trino.sql

-- 1. Spark が書いたテーブルを読む
SELECT * FROM interop ORDER BY trip_id;

-- 2. Trino から追記・更新する
INSERT INTO interop VALUES (4, 'C', 22.00);
UPDATE interop SET fare = fare + 1 WHERE vendor = 'A';

-- 3. Trino から列を追加する（Spark からも見える）
ALTER TABLE interop ADD COLUMN note VARCHAR;
UPDATE interop SET note = 'written by trino' WHERE trip_id = 4;

SELECT * FROM interop ORDER BY trip_id;

-- 4. スナップショットごとに、書き込んだエンジンを確認する
SELECT committed_at, operation,
       summary['engine-name'] AS engine,
       summary['engine-version'] AS version
FROM "interop$snapshots"
ORDER BY committed_at;
