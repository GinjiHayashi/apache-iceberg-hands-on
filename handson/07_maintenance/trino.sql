-- 07. メンテナンス（Trino）
-- 実行: make trino-sql FILE=handson/07_maintenance/trino.sql
-- Spark のプロシージャに対応する操作を、Trino では ALTER TABLE ... EXECUTE で行う。

-- 1. 小さな書き込みを 10 回繰り返す
DROP TABLE IF EXISTS maint_trino;
CREATE TABLE maint_trino (trip_id BIGINT, vendor VARCHAR, fare DECIMAL(10, 2));
INSERT INTO maint_trino VALUES (1, 'V1', 1.50);
INSERT INTO maint_trino VALUES (2, 'V2', 3.00);
INSERT INTO maint_trino VALUES (3, 'V0', 4.50);
INSERT INTO maint_trino VALUES (4, 'V1', 6.00);
INSERT INTO maint_trino VALUES (5, 'V2', 7.50);
INSERT INTO maint_trino VALUES (6, 'V0', 9.00);
INSERT INTO maint_trino VALUES (7, 'V1', 10.50);
INSERT INTO maint_trino VALUES (8, 'V2', 12.00);
INSERT INTO maint_trino VALUES (9, 'V0', 13.50);
INSERT INTO maint_trino VALUES (10, 'V1', 15.00);

-- 状態: 現在のデータファイル数 / マニフェスト数 / スナップショット数
SELECT
  (SELECT count(*) FROM "maint_trino$files")     AS current_data_files,
  (SELECT count(*) FROM "maint_trino$manifests") AS current_manifests,
  (SELECT count(*) FROM "maint_trino$snapshots") AS snapshots;

-- 2. Compaction（Spark の rewrite_data_files に相当）
ALTER TABLE maint_trino EXECUTE optimize;

-- 3. マニフェストの統合（Spark の rewrite_manifests に相当）
ALTER TABLE maint_trino EXECUTE optimize_manifests;

SELECT
  (SELECT count(*) FROM "maint_trino$files")     AS current_data_files,
  (SELECT count(*) FROM "maint_trino$manifests") AS current_manifests,
  (SELECT count(*) FROM "maint_trino$snapshots") AS snapshots;

-- 4. スナップショットの失効（retention_threshold より古いものを消す。最新の 1 つは必ず残る）
ALTER TABLE maint_trino EXECUTE expire_snapshots(retention_threshold => '0s');

SELECT
  (SELECT count(*) FROM "maint_trino$files")     AS current_data_files,
  (SELECT count(*) FROM "maint_trino$manifests") AS current_manifests,
  (SELECT count(*) FROM "maint_trino$snapshots") AS snapshots;

-- 5. 孤立ファイルの削除（この時点では孤立ファイルはないので、何も消えない）
--    試すには README の手順で孤立ファイルを置いてから、このクエリだけを Trino CLI で実行する
ALTER TABLE maint_trino EXECUTE remove_orphan_files(retention_threshold => '0s');
