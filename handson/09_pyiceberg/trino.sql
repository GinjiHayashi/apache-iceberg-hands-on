-- 09. PyIceberg で作ったテーブルを Trino から読む
-- pyiceberg.ipynb を実行した後に実行する:
--   make trino-sql FILE=handson/09_pyiceberg/trino.sql

-- PyIceberg が書いたスナップショット（engine-name は記録されない）
SELECT committed_at, operation, summary['added-records'] AS added_records
FROM "py_trips$snapshots"
ORDER BY committed_at;

-- 日ごとの集計
SELECT CAST(tpep_pickup_datetime AS DATE) AS day,
       count(*) AS trips,
       round(avg(total_amount), 2) AS avg_total
FROM py_trips
GROUP BY 1
ORDER BY 1;
