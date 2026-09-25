-- 04. パーティション進化（Trino）
-- 実行: make trino-sql FILE=handson/04_partition_evolution/trino.sql

-- 1. 月単位の隠しパーティションでテーブルを作る
--    Trino では partitioning プロパティに「変換(列)」を書く
DROP TABLE IF EXISTS part_trino;
CREATE TABLE part_trino (trip_id BIGINT, pickup_at TIMESTAMP(6), fare DOUBLE)
WITH (partitioning = ARRAY['month(pickup_at)']);

INSERT INTO part_trino VALUES
    (1, TIMESTAMP '2024-12-01 08:00:00', 12.5),
    (2, TIMESTAMP '2024-12-15 09:00:00', 30.0),
    (3, TIMESTAMP '2024-12-31 23:00:00', 8.0);

-- パーティションごとの行数とファイル数
SELECT partition, record_count, file_count FROM "part_trino$partitions";

-- 2. パーティションの切り方を変える（月 → 日）。既存のファイルは書き直されない
ALTER TABLE part_trino SET PROPERTIES partitioning = ARRAY['day(pickup_at)'];

INSERT INTO part_trino VALUES
    (4, TIMESTAMP '2025-01-01 10:00:00', 22.0),
    (5, TIMESTAMP '2025-01-02 11:00:00', 15.0);

-- 3. ファイルごとに、どの切り方（spec_id）で書かれたかを確認する
SELECT spec_id, partition, record_count FROM "part_trino$files" ORDER BY spec_id;

-- 4. 切り方が混在していても、クエリの書き方は変わらない
SELECT * FROM part_trino
WHERE pickup_at >= TIMESTAMP '2024-12-31 00:00:00' AND pickup_at < TIMESTAMP '2025-01-02 00:00:00'
ORDER BY pickup_at;
