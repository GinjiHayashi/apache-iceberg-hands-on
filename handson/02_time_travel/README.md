# 02. スナップショットとタイムトラベル

Iceberg は書き込みのたびにスナップショット（その時点のテーブルの状態）を残す。
スナップショットを指定して過去の状態を読む（タイムトラベル）、名前を付ける（タグ）、過去の状態に戻す（ロールバック）を試す。

## 準備

```sh
make up-all
```

## 手順

### Spark

JupyterLab（http://localhost:8888 ）で `handson/02_time_travel/spark.ipynb` を上から実行する。
スナップショット ID を Python の変数で受け渡すので、ノートブックだけで最後まで進む。

### Trino

1. テーブルを作ってスナップショットを確認する

   ```sh
   make trino-sql FILE=handson/02_time_travel/trino.sql
   ```

   最後に表示される `snapshot_id` と `committed_at` のうち、**1回目の INSERT（2行目）** のものを控える。

2. Trino CLI を開き、控えた値でタイムトラベルとロールバックを試す（`<ID>` と `<時刻>` を置き換える）

   ```sh
   make trino-cli
   ```

   ```sql
   -- スナップショット ID を指定して読む
   SELECT * FROM tt_trino FOR VERSION AS OF <ID> ORDER BY trip_id;

   -- 時刻を指定して読む（例: TIMESTAMP '2026-09-25 16:54:37.770 UTC'）
   SELECT * FROM tt_trino FOR TIMESTAMP AS OF TIMESTAMP '<時刻>' ORDER BY trip_id;

   -- 現在の状態を過去のスナップショットに戻す
   ALTER TABLE tt_trino EXECUTE rollback_to_snapshot(<ID>);
   SELECT * FROM tt_trino ORDER BY trip_id;

   -- Spark のノートブックで付けたタグも Trino から読める
   SELECT * FROM tt_spark FOR VERSION AS OF 'before_delete' ORDER BY trip_id;
   ```

   `quit` で CLI を終了する。

## 観察のポイント

- 書き込みのたびにスナップショットが増え、`parent_id` で1本の履歴につながっている
- タイムトラベルは読むだけで、テーブルの現在の状態は変わらない
- ロールバックしても、戻す前のスナップショットは消えない（`history` の `is_current_ancestor` が false になる）
- タグは Spark で作れる。Trino 483 はタグの作成には対応していないが、タグを指定して読むことはできる

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.tt_spark` | spark.ipynb |
| `lakehouse.handson.tt_trino` | trino.sql |
