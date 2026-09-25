# 05. エンジン間の相互運用

1つのテーブルを Spark と Trino で交互に読み書きする。
Iceberg がオープンな仕様で、同じカタログに接続していればエンジンを問わず同じテーブルを扱えることを確かめる。

## 準備

```sh
make up-all   # Spark と Trino の両方が必要
```

## 手順

1. **Spark（前半）**: JupyterLab（http://localhost:8888 ）で `handson/05_interoperability/spark.ipynb` を開き、「Trino の SQL を実行する」の手前まで実行する
2. **Trino**: Spark が書いたテーブルを読み、追記・更新・列の追加をする

   ```sh
   make trino-sql FILE=handson/05_interoperability/trino.sql
   ```

3. **Spark（後半）**: ノートブックの続きを実行する

## 観察のポイント

- Spark が書いたテーブルを、Trino は何の設定もなく読み書きできる（その逆も）
- Trino が追加した列も Spark から見える。スキーマもメタデータを通じて共有される
- Spark はテーブルのメタデータをキャッシュする（既定で 30 秒）。他のエンジンの変更を直後に見るには `REFRESH TABLE` を実行する
- スナップショットの `summary['engine-name']` に、どのエンジンが書いたかが記録される

## 作られるテーブル

| テーブル | 作成元 |
| --- | --- |
| `lakehouse.handson.interop` | spark.ipynb（前半）で作り、trino.sql と spark.ipynb（後半）で更新する |
