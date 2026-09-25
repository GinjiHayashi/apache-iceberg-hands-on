# 09. PyIceberg

JVM（Java）を使わない Python 製の Iceberg クライアント PyIceberg で、テーブルを作り、読み書きする。
pandas や DuckDB と組み合わせて、Python の中だけで分析できることを確かめる。

## 準備

```sh
make data
make up-all   # Trino で確認しないなら make up-spark だけでよい（PyIceberg は jupyter コンテナに入っている）
```

## 手順

1. **PyIceberg**: JupyterLab（http://localhost:8888 ）で `handson/09_pyiceberg/pyiceberg.ipynb` を上から実行する（Spark は使わない）
2. **Trino**: PyIceberg で作ったテーブルを Trino から読む

   ```sh
   make trino-sql FILE=handson/09_pyiceberg/trino.sql
   ```

## 観察のポイント

- 接続設定は環境変数（`compose.yaml` の `PYICEBERG_CATALOG__LAKEHOUSE__*`）で渡しているので、`load_catalog("lakehouse")` だけで Polaris に接続できる
- `scan(row_filter=..., selected_fields=...)` で、必要なファイルと列だけを読む
- `table.inspect` で、メタデータテーブル（08）と同じ情報を取り出せる
- PyIceberg で書いたテーブルも、Spark や Trino からそのまま読める

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.py_trips` | pyiceberg.ipynb（2025-01-01 と 01-02 の乗車、約 17 万行） |
