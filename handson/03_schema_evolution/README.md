# 03. スキーマ進化

列の追加・名前変更・型の拡張・削除を、データファイルを書き直さずに行う。
Iceberg が列を名前ではなく列 ID で管理していることを確かめる。

## 準備

```sh
make data     # NYC タクシーのデータ（2024-12, 2025-01）を取得する
make up-all
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/03_schema_evolution/spark.ipynb` を上から実行する（約 1 分）
   - 2024-12 のデータでテーブルを作り、2025-01 から追加された `cbd_congestion_fee` 列を後から取り込む
2. **Trino**: 小さな手作りのデータで同じ操作を試す

   ```sh
   make trino-sql FILE=handson/03_schema_evolution/trino.sql
   ```

## 観察のポイント

- どの変更の前後でも、データファイルの数（`files` / `$files`）が変わらない
- 列を追加すると、既存の行では NULL として読まれる
- 名前を変えても、古いファイルのデータがそのまま読める
- 型は INT → BIGINT のような「広げる」方向だけ変えられる
- 列を削除して同じ名前で追加し直しても、古い値は復活しない（新しい列 ID が振られるため）

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.taxi_schema_spark` | spark.ipynb（約 714 万行） |
| `lakehouse.handson.schema_trino` | trino.sql |
