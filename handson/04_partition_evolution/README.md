# 04. パーティション進化

列の値を変換した結果（月、日など）でパーティションを切る「隠しパーティション」と、
既存のデータを書き直さずにパーティションの切り方を変える「パーティション進化」を試す。

## 準備

```sh
make data
make up-all
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/04_partition_evolution/spark.ipynb` を上から実行する（約 1 分）
   - 2024-12 を月単位で入れ、切り方を日単位に変えてから 2025-01 を入れる
2. **Trino**: 小さな手作りのデータで同じ操作を試す

   ```sh
   make trino-sql FILE=handson/04_partition_evolution/trino.sql
   ```

3. **ストレージ**: S3 ブラウザ（http://localhost:8081 ）で各テーブルの `data/` を開き、`pickup_at_month=...` と `pickup_at_day=...` のディレクトリが並んでいることを見る

## 観察のポイント

- パーティション用の列を持たなくても、`WHERE pickup_at >= ...` と書くだけでパーティションが効く
- 切り方を変えても既存のファイルはそのまま。新しく書いたファイルだけが新しい切り方になる
- ファイルごとに `spec_id`（どの切り方で書かれたか）が記録され、混在していてもクエリの書き方は変わらない

## 書き方の違い

| | Spark | Trino |
| --- | --- | --- |
| 作成時 | `PARTITIONED BY (months(pickup_at))` | `WITH (partitioning = ARRAY['month(pickup_at)'])` |
| 変更 | `ALTER TABLE ... REPLACE PARTITION FIELD pickup_at_month WITH days(pickup_at)` | `ALTER TABLE ... SET PROPERTIES partitioning = ARRAY['day(pickup_at)']` |

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.taxi_part_spark` | spark.ipynb（約 714 万行） |
| `lakehouse.handson.part_trino` | trino.sql |
