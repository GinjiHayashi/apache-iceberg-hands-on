-- 08. メタデータテーブル（Trino）
-- 実行: make trino-sql FILE=handson/08_metadata_tables/trino.sql
-- Trino では "テーブル名$メタデータテーブル名" と書く（ダブルクォートで囲む）。
-- spark.ipynb で作った meta_spark を、Trino から覗く。

-- 1. テーブルのプロパティ（Spark で指定した write.delete.mode も見える）
SELECT * FROM "meta_spark$properties";

-- 2. メタデータファイルの履歴
SELECT timestamp, file FROM "meta_spark$metadata_log_entries" ORDER BY timestamp;

-- 3. スナップショット
SELECT committed_at, snapshot_id, operation, manifest_list FROM "meta_spark$snapshots" ORDER BY committed_at;

-- 4. マニフェスト（content: 0 = データファイルの、1 = 削除ファイルのマニフェスト）
SELECT content, path, added_data_files_count, added_rows_count
FROM "meta_spark$manifests";

-- 5. データファイルと削除ファイル（content: 0 = データ、1 = 位置削除）
SELECT content, partition, record_count, file_size_in_bytes FROM "meta_spark$files" ORDER BY content;

-- 6. パーティションごとの集計
SELECT partition, record_count, file_count FROM "meta_spark$partitions";

-- 7. 参照（ブランチとタグ）
SELECT * FROM "meta_spark$refs";

-- 8. 隠し列: 各行がどのファイルに入っているか
SELECT trip_id, vendor, "$path", "$file_modified_time" FROM meta_spark ORDER BY trip_id;
