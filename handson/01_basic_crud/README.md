# 01. 基本 CRUD

Iceberg テーブルを作り、INSERT / UPDATE / DELETE / MERGE を実行する。
普通の SQL と同じように書けることと、書き込みのたびにスナップショットが増えることを確認する。

## 準備

```sh
make up-all   # 基盤 + Spark + Trino を起動（片方だけなら make up-spark / make up-trino）
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/01_basic_crud/spark.ipynb` を開き、上から順に実行する
2. **Trino**: 次のコマンドで SQL ファイルを実行する

   ```sh
   make trino-sql FILE=handson/01_basic_crud/trino.sql
   ```

3. **RustFS**: コンソール（http://localhost:9001 、ログインは `.env` の `RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY`）で `warehouse/handson/` を開き、テーブルごとに `data/` と `metadata/` ができていることを見る

## 観察のポイント

- テーブルを作った直後は `metadata/` だけで、INSERT すると `data/` に Parquet ファイルができる
- UPDATE / DELETE でも既存のファイルは書き換えられず、新しいファイルが増えていく
  - Spark: 更新対象を含むファイルを丸ごと書き直す（copy-on-write）
  - Trino: 「どの行を消したか」を記録した削除ファイルを書き足す（merge-on-read）
- 書き込みのたびにスナップショットが1つ増える（最後のクエリで確認できる）

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.crud_spark` | spark.ipynb |
| `lakehouse.handson.crud_trino` | trino.sql |

どちらも実行のたびに作り直すので、何度でもやり直せる。
