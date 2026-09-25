# 08. メタデータテーブル

Iceberg のテーブルを構成するメタデータの階層（メタデータファイル → マニフェストリスト → マニフェスト → データファイル）を、
メタデータテーブルを使って SQL で覗く。

## 準備

```sh
make up-all
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/08_metadata_tables/spark.ipynb` を上から実行する
2. **Trino**: Spark で作った `meta_spark` を Trino から覗く

   ```sh
   make trino-sql FILE=handson/08_metadata_tables/trino.sql
   ```

3. **ストレージ**: S3 ブラウザ（http://localhost:8081 ）で `warehouse/handson/meta_spark/metadata/` を開き、
   `*.metadata.json`（メタデータファイル）、`snap-*.avro`（マニフェストリスト）、`*-m0.avro`（マニフェスト）が並んでいることを見る

## 主なメタデータテーブル

| 名前 | 中身 | Spark | Trino |
| --- | --- | --- | --- |
| `snapshots` | スナップショットの一覧 | `t.snapshots` | `"t$snapshots"` |
| `history` | 現在の状態に至る履歴 | `t.history` | `"t$history"` |
| `metadata_log_entries` | メタデータファイルの履歴 | `t.metadata_log_entries` | `"t$metadata_log_entries"` |
| `manifests` | 現在のマニフェスト | `t.manifests` | `"t$manifests"` |
| `files` | 現在のデータファイルと削除ファイル | `t.files` | `"t$files"` |
| `partitions` | パーティションごとの集計 | `t.partitions` | `"t$partitions"` |
| `refs` | ブランチとタグ | `t.refs` | `"t$refs"` |
| `entries` | マニフェストの各行（追加・既存・削除） | `t.entries` | `"t$entries"` |
| `all_data_files` など | 残っているすべてのスナップショットの分 | `t.all_data_files` | `"t$all_entries"` など |
| `properties` | テーブルのプロパティ | `SHOW TBLPROPERTIES t` | `"t$properties"` |

Trino では、行ごとの隠し列 `"$path"`（その行が入っているファイル）なども使える。

## 観察のポイント

- テーブルを変更するたびにメタデータファイルが増え、カタログはその最新の1つを指している
- マニフェストにはパーティションの値の範囲が、ファイルごとには列の最小値・最大値が記録され、読み飛ばしに使われる
- merge-on-read の DELETE では、データファイルはそのままで、削除ファイル（`content = 1`）が増える
- `partitions` の数え方はエンジンで違う。Spark はデータファイルだけを数え、Trino は削除ファイルも含めて数える

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.meta_spark` | spark.ipynb（trino.sql はこれを読むだけ） |
