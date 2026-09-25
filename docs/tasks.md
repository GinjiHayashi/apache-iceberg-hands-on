# タスク一覧

状態: `todo` / `doing` / `done`。上から順に進める。設計は [design.md](design.md) を参照。

## 準備

| # | タスク | 完了条件 | 状態 |
| --- | --- | --- | --- |
| 1 | ドキュメント基盤と CLAUDE.md の作成 | CLAUDE.md・docs/ の骨組みがコミットされている | done |
| 2 | 要件の整理 | requirements.md の TODO がすべて埋まり、未決事項が空 | done |
| 3 | 技術選定と設計 | 技術スタックの各項目に ADR があり、design.md に構成図とディレクトリ構成がある | done |
| 4 | 実装タスクの分解 | design.md を実現するタスクが完了条件付きでこの表に並んでいる | done |

## 環境構築

| # | タスク | 完了条件 | 状態 |
| --- | --- | --- | --- |
| 5 | リポジトリの土台 | `.gitignore`（`.env`、`data/`）、`.env.example`、ホストの `pyproject.toml`（`nbstripout`）がある。nbstripout が git の filter に登録され、`make help` がコマンド一覧を表示する | done |
| 6 | 基盤サービス（RustFS、PostgreSQL、Polaris） | `make up` で全サービスが healthy または正常終了になる。Management API でカタログ `lakehouse` と名前空間 `handson` を確認でき、RustFS のコンソールで `warehouse` バケットが見える。`make down` → `make up` の後も状態が残り、`make reset` で消える | done |
| 7 | Trino | `make up-trino` で起動し、`make smoke` が成功する（テーブルを作り、INSERT と SELECT ができ、RustFS に data/metadata ファイルができる）。これで Polaris から払い出された認証情報による S3 アクセスも確認できる | done |
| 8 | Spark + JupyterLab | `make up-spark` で起動し、`localhost:8888` をブラウザと VS Code の両方から開ける。ノートブックから `lakehouse` にテーブルを作って読める。Spark で作ったテーブルを Trino から読める | doing（VS Code からの接続確認待ち） |
| 9 | PyIceberg | Jupyter コンテナ内のノートブックから `lakehouse` のテーブル一覧を取得し、pandas に読み込める | done |
| 10 | サンプルデータの取得 | `make data` で 2024-12 と 2025-01 の Parquet が `data/` に揃い、Jupyter コンテナから読める。再実行してもダウンロードし直さない | todo |

## ハンズオン教材

各回は `handson/NN_xxx/` に README.md、`spark.ipynb`、`trino.sql` を置く。完了条件は共通で、「`make reset` した直後の環境で、README の手順どおりに上から実行して最後まで動く」こと。

| # | タスク | 内容 | 状態 |
| --- | --- | --- | --- |
| 11 | 01_basic_crud | CREATE / INSERT / UPDATE / DELETE / MERGE | todo |
| 12 | 02_time_travel | スナップショット、過去時点のクエリ、ロールバック | todo |
| 13 | 03_schema_evolution | 列の追加・削除・名前変更。2025-01 の `cbd_congestion_fee` を題材にする | todo |
| 14 | 04_partition_evolution | 隠しパーティション、パーティション仕様の変更 | todo |
| 15 | 05_interoperability | Spark で書いて Trino で読む、およびその逆 | todo |
| 16 | 06_parquet_conversion | Spark の CTAS と PyIceberg の `add_files` を比べる。Trino の `add_files` は追加目標（任意） | todo |
| 17 | 07_maintenance | Compaction、スナップショットの失効、孤立ファイルの削除、マニフェストの統合を Spark と Trino の両方で行う | todo |
| 18 | 08_metadata_tables | `$snapshots`、`$files`、`$history` などの参照 | todo |
| 19 | 09_pyiceberg | テーブル一覧、pandas / DuckDB への読み込み、簡単な追記 | todo |
| 20 | 10_v3_upgrade（追加目標・任意） | v2 から v3 へのアップグレードと、各エンジンから読めるかの確認 | todo |

## 仕上げ

| # | タスク | 完了条件 | 状態 |
| --- | --- | --- | --- |
| 21 | README の整備 | 前提条件、起動手順、Make コマンドと実際に実行されるコマンド、ハンズオンの一覧が書かれている。README だけを読んで、まっさらな状態から `make smoke` まで到達できる | todo |
