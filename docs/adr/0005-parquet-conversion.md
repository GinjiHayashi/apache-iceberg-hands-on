# 0005. Parquet から Iceberg への変換は CTAS と add_files で試す

- 日付: 2026-09-26
- 状態: 採用

## 背景

学習ゴール (f) で、既存の Parquet ファイルを Iceberg のテーブルに変換する。カタログが Polaris（REST カタログ）なので、使える方法が限られる。

## 検討した選択肢

- Spark の CTAS — Parquet を読み込んで Iceberg として書き直す。最も確実
- PyIceberg の `add_files` — 既存の Parquet をそのまま登録し、メタデータだけを作る。ファイルはカタログの `allowedLocations`（`s3://warehouse`）の下に置く必要がある
- Trino の `add_files` — Trino 461 以降で使える。Polaris と組み合わせたときの動作は未検証。v3 のテーブルには使えない
- Spark の `add_files` — S3 上のパスを読むには `hadoop-aws` などの追加の jar と設定が必要
- Spark の `migrate` / `snapshot` — 元のテーブルが Spark のセッションカタログにある必要があり、この構成では使えない

## 決定

- 必須: Spark の CTAS（書き直す方式）と PyIceberg の `add_files`（書き直さない方式）
- 追加目標（任意）: Trino の `add_files`（`iceberg.add-files-procedure.enabled=true`）。Polaris から払い出された認証情報のままで動くことを実装時に確認した

## 理由

- 確実に動く2つの方式で、「データを書き直す／書き直さない」の違いを比べられる
- 違いは RustFS のコンソールで、ファイルの増え方として目で見られる

## 影響

- `add_files` で登録したファイルは、スナップショットの失効などで削除されることがある。ハンズオンの中で注意として説明する
- `add_files` はスキーマを検証しないので、列の型が合っていることを事前に確認する
- 登録するファイルはテーブルの場所の下に置く必要がある（払い出される認証情報の範囲がテーブルの場所に限られるため）
- 実装時の確認では、Trino の `add_files` で登録したファイルは `DROP TABLE` しても残った。Trino は中身のある場所にテーブルを作れないので、やり直すときは手でフォルダを消す
