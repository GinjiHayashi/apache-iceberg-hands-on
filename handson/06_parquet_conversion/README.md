# 06. Parquet から Iceberg への変換

既存の Parquet ファイルを Iceberg テーブルにする。
データを書き直す方式（CTAS）と、書き直さずに登録する方式（add_files）を比べる。

## 準備

```sh
make data
make up-all
```

## 手順

1. **Spark / PyIceberg**: JupyterLab（http://localhost:8888 ）で `handson/06_parquet_conversion/spark.ipynb` を上から実行する（約 1 分）
   - Spark の CTAS で 2024-12 を、PyIceberg の `add_files` で 2025-01 をテーブルにする
2. **Trino**: Spark が作った `taxi_ctas` を元に、Trino の CTAS で列を絞り、日単位のパーティションを付けたテーブルを作る

   ```sh
   make trino-sql FILE=handson/06_parquet_conversion/trino.sql
   ```

## 追加目標（任意）: Trino の add_files

1. テーブルを作る

   ```sh
   make trino-sql FILE=handson/06_parquet_conversion/trino_add_files_1_create.sql
   ```

2. アップロードするフォルダを用意し、S3 ブラウザ（http://localhost:8081 ）でフォルダごとアップロードする

   ```sh
   mkdir -p data/import && cp data/yellow_tripdata_2024-12.parquet data/import/
   ```

   S3 ブラウザで `warehouse` → `handson` → `taxi_trino_addfiles` を開き、フォルダのアップロードで `data/import` フォルダを選ぶ。
   `taxi_trino_addfiles/import/yellow_tripdata_2024-12.parquet` ができれば OK
   （Windows のブラウザからは、エクスプローラーのアドレス欄に `\\wsl.localhost\Ubuntu\home\<ユーザー名>\...\data` と入れると WSL のフォルダを開ける）
3. アップロードしたファイルを登録する

   ```sh
   make trino-sql FILE=handson/06_parquet_conversion/trino_add_files_2_register.sql
   ```

**やり直すとき**: この環境では、`add_files` で登録したファイルは `DROP TABLE` しても削除されずに残る。Trino は中身のある場所にテーブルを作れないので、次の手順で片付けてから 1. に戻る。

1. `make trino-cli` で `DROP TABLE taxi_trino_addfiles;` を実行する
2. S3 ブラウザで `handson/taxi_trino_addfiles/` フォルダを削除する

## 観察のポイント

- CTAS はデータを書き直すので、Iceberg が付けた名前の新しいファイルができる（元のファイルとは別にストレージを使う）
- add_files は元のファイルをそのまま登録する。`files` のパスとサイズが元のファイルと一致する
- add_files はスキーマを検証しない。テーブルの列と型を Parquet に合わせるのは登録する側の責任
- Trino は S3 上の素の Parquet を直接 SELECT できないので、Trino だけで変換するときは add_files を使うか、Hive コネクタなどで読む

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.taxi_ctas` | spark.ipynb（Spark の CTAS、2024-12） |
| `lakehouse.handson.taxi_addfiles` | spark.ipynb（PyIceberg の add_files、2025-01） |
| `lakehouse.handson.taxi_ctas_trino` | trino.sql（Trino の CTAS） |
| `lakehouse.handson.taxi_trino_addfiles` | 追加目標（Trino の add_files） |
