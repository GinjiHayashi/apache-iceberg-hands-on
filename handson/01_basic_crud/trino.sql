-- 01. 基本 CRUD（Trino）
-- 実行: make trino-sql FILE=handson/01_basic_crud/trino.sql
-- カタログ lakehouse、スキーマ handson で実行される（Makefile で指定）。

-- 1. テーブルを作る。何度でもやり直せるよう先に削除する
DROP TABLE IF EXISTS crud_trino;

CREATE TABLE crud_trino (
    trip_id    BIGINT,
    vendor     VARCHAR,
    fare       DECIMAL(10, 2),
    pickup_at  TIMESTAMP(6)
);

-- テーブルの定義と置き場所（location）を確認する
SHOW CREATE TABLE crud_trino;

-- 2. INSERT
INSERT INTO crud_trino VALUES
    (1, 'A', 12.5, TIMESTAMP '2025-01-01 08:00:00'),
    (2, 'B', 30.0, TIMESTAMP '2025-01-01 09:15:00'),
    (3, 'A',  8.0, TIMESTAMP '2025-01-02 18:30:00');

SELECT * FROM crud_trino ORDER BY trip_id;

-- 3. UPDATE（Trino は削除ファイルを書き足す merge-on-read で更新する）
UPDATE crud_trino SET fare = fare * 1.1 WHERE vendor = 'A';

SELECT * FROM crud_trino ORDER BY trip_id;

-- 4. DELETE
DELETE FROM crud_trino WHERE trip_id = 2;

SELECT * FROM crud_trino ORDER BY trip_id;

-- 5. MERGE（あれば更新、なければ追加）
MERGE INTO crud_trino AS t
USING (VALUES (1, 'A', 15.0), (4, 'C', 22.0)) AS u (trip_id, vendor, fare)
ON t.trip_id = u.trip_id
WHEN MATCHED THEN UPDATE SET fare = u.fare
WHEN NOT MATCHED THEN INSERT (trip_id, vendor, fare, pickup_at)
                      VALUES (u.trip_id, u.vendor, u.fare, localtimestamp);

SELECT * FROM crud_trino ORDER BY trip_id;

-- 6. スナップショットを覗いてみる（書き込みのたびに1つずつ増えている。
--    Trino では CREATE TABLE でも空のスナップショットが1つできる）
SELECT committed_at, snapshot_id, operation FROM "crud_trino$snapshots" ORDER BY committed_at;
