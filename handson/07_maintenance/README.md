# 07. メンテナンス

書き込みを繰り返すと溜まっていく小さなファイル、マニフェスト、古いスナップショット、孤立ファイルを整理する。
タイムトラベルできる期間とストレージの量がトレードオフであることを確かめる。

## 準備

```sh
make up-all
```

## 手順

1. **Spark**: JupyterLab（http://localhost:8888 ）で `handson/07_maintenance/spark.ipynb` を上から実行する
2. **Trino**: 同じ流れを Trino で行う

   ```sh
   make trino-sql FILE=handson/07_maintenance/trino.sql
   ```

3. **（任意）Trino で孤立ファイルを消す**: RustFS のコンソール（http://localhost:9001 ）で `warehouse/handson/maint_trino-<ランダムな文字列>/data/` に適当なファイルをアップロードしてから、`make trino-cli` で次を実行する。`deleted_files_count` が 1 になる

   ```sql
   ALTER TABLE maint_trino EXECUTE remove_orphan_files(retention_threshold => '0s');
   ```

## Spark と Trino の対応

| 処理 | Spark | Trino |
| --- | --- | --- |
| Compaction | `CALL lakehouse.system.rewrite_data_files(...)` | `ALTER TABLE ... EXECUTE optimize` |
| マニフェストの統合 | `CALL lakehouse.system.rewrite_manifests(...)` | `ALTER TABLE ... EXECUTE optimize_manifests` |
| スナップショットの失効 | `CALL lakehouse.system.expire_snapshots(...)` | `ALTER TABLE ... EXECUTE expire_snapshots(retention_threshold => ...)` |
| 孤立ファイルの削除 | `CALL lakehouse.system.remove_orphan_files(...)` | `ALTER TABLE ... EXECUTE remove_orphan_files(retention_threshold => ...)` |

## 観察のポイント

- Compaction の直後は、古いファイルも過去のスナップショットのために残る（ストレージはむしろ増える）
- スナップショットを失効させると、はじめて古いファイルがストレージから消え、そのスナップショットにはタイムトラベルできなくなる
- 並行する書き込みを壊さないよう、失効と孤立ファイル削除には「どれだけ新しいものまで対象にするか」の下限がある

## この環境での設定と注意

- **Trino**: 下限（既定 7 日）を `docker/trino/catalog/lakehouse.properties` で 0 秒にしている（ハンズオン用）
- **Spark**: `remove_orphan_files` プロシージャは 24 時間より短い期間を受け付けない。ノートブックでは Java の Action API を PySpark から呼んで期間の制限なしで実行している
- **Spark**: ファイルの一覧に Iceberg の FileIO を使うため、`prefix_listing => true`（Action API では `usePrefixListing(True)`）を指定している
- 本番では、下限を短くせずに定期実行する

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.maint_spark` | spark.ipynb |
| `lakehouse.handson.maint_trino` | trino.sql |
