-- 02. スナップショットとタイムトラベル（Trino）
-- 実行: make trino-sql FILE=handson/02_time_travel/trino.sql
-- SQL ファイルでは変数が使えないので、このファイルは「スナップショットを作って一覧を見る」まで。
-- タイムトラベルとロールバックは README の手順で、Trino CLI から対話的に試す。

-- 1. 3回に分けて書き込む（書き込みごとにスナップショットが1つできる）
DROP TABLE IF EXISTS tt_trino;
CREATE TABLE tt_trino (trip_id BIGINT, vendor VARCHAR, fare DECIMAL(10, 2));

INSERT INTO tt_trino VALUES (1, 'A', 12.50), (2, 'B', 30.00);   -- 1回目
INSERT INTO tt_trino VALUES (3, 'A', 8.00), (4, 'C', 22.00);    -- 2回目
DELETE FROM tt_trino WHERE vendor = 'A';                        -- 3回目

SELECT * FROM tt_trino ORDER BY trip_id;

-- 2. スナップショットの一覧（Trino では CREATE TABLE でも空のスナップショットが1つできる）
SELECT committed_at, snapshot_id, parent_id, operation
FROM "tt_trino$snapshots"
ORDER BY committed_at;

-- 3. ここから先（タイムトラベルとロールバック）は README の手順で、Trino CLI から試す。
