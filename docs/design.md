# 設計

> 状態: 未着手（要件確定後、Step 3 で記述する）

## 技術スタック

| 役割 | 採用 | 決定記録 |
| --- | --- | --- |
| クエリエンジン | Spark (PySpark), Trino, PyIceberg | 要件で指定 |
| カタログ | Apache Polaris（PostgreSQL で永続化） | 要件で指定 |
| ストレージ | RustFS | [0001](adr/0001-object-storage-rustfs.md) |
| 実行基盤 | Docker Compose + uv | 要件で指定 |

## アーキテクチャ

TODO（mermaid で構成図を記述）

## ディレクトリ構成

TODO
