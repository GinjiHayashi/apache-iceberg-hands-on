# 10. テーブルフォーマット v3 へのアップグレード（追加目標）

v2 のテーブルを v3 にアップグレードし、v3 で加わった削除ベクトルと行の履歴（row lineage）を確かめる。
アップグレードは一方通行で、v2 には戻せない。

## 準備

```sh
make up-all
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/10_v3_upgrade/spark.ipynb` を上から実行する
2. **Trino**: v3 のテーブルを Trino から読み書きし、Trino でもアップグレードしてみる

   ```sh
   make trino-sql FILE=handson/10_v3_upgrade/trino.sql
   ```

   trino.sql は spark.ipynb の直後の状態を前提にしている。やり直すときは spark.ipynb から実行する。

## 観察のポイント

- アップグレードは `format-version` を 3 にするだけで、データファイルは書き直されない
- 同じ DELETE でも、v2 では位置削除ファイル（Parquet）、v3 では削除ベクトル（Puffin）が書かれる
- v3 では、1 つのデータファイルに対する削除が 1 つの削除ベクトルにまとめられる（v2 の削除ファイルも取り込まれる）
- UPDATE しても `_row_id` は変わらず、`_last_updated_sequence_number` だけが新しくなる

## エンジンごとの対応（このハンズオンのバージョン）

| エンジン | v3 の読み書き | v2 → v3 のアップグレード |
| --- | --- | --- |
| Spark 4.1 + Iceberg 1.11 | できる | `ALTER TABLE ... SET TBLPROPERTIES ('format-version' = '3')` |
| Trino 483 | できる（実験的な対応） | `ALTER TABLE ... SET PROPERTIES format_version = 3` |
| PyIceberg 0.12 | できる | できない |

variant 型やナノ秒のタイムスタンプなど、v3 の新しい型はエンジンによって対応が違うので、このハンズオンでは使わない。

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.v3_spark` | spark.ipynb（trino.sql で追記・削除する） |
| `lakehouse.handson.v3_trino` | trino.sql |
