-- 06. 追加目標（任意）: Trino の add_files（2/2 ファイルを登録する）
-- S3 ブラウザ（s3manager）で warehouse/handson/taxi_trino_addfiles/import/ に
-- yellow_tripdata_2024-12.parquet をアップロードしてから実行する:
--   make trino-sql FILE=handson/06_parquet_conversion/trino_add_files_2_register.sql

-- 1. アップロードしたファイルを、書き直さずに登録する
ALTER TABLE taxi_trino_addfiles
EXECUTE add_files(location => 's3://warehouse/handson/taxi_trino_addfiles/import', format => 'PARQUET');

-- 2. 登録されたファイルは、アップロードした元のファイルそのもの
SELECT file_path, record_count, file_size_in_bytes FROM "taxi_trino_addfiles$files";
SELECT count(*) AS trips, round(avg(total_amount), 2) AS avg_total FROM taxi_trino_addfiles;
