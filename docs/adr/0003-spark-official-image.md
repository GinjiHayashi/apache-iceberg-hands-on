# 0003. Spark のイメージは公式イメージに JupyterLab を追加して作る

- 日付: 2026-09-26
- 状態: 採用

## 背景

PySpark を JupyterLab で動かすコンテナが必要。要件では、バージョンを固定することと、Python の依存関係を uv で管理することを求めている。

## 検討した選択肢

- `quay.io/jupyter/pyspark-notebook` — 最新版は Spark 4.2 で、Iceberg 1.11 が対応していない。Spark 4.1.3 のタグもない。パッケージ管理が conda 方式で、uv の方針に合わない
- `apache/spark:4.1.3-scala2.13-java17-python3-ubuntu` に JupyterLab を追加する — Spark の公式配布物をそのまま使える。Python は Ubuntu 22.04 のシステム Python 3.10
- `eclipse-temurin:17-jre` をベースに自前でビルドする — uv で Python 3.12 と `pyspark` を管理できるが、Dockerfile が長くなる

## 決定

`apache/spark:4.1.3-scala2.13-java17-python3-ubuntu` をベースにし、JupyterLab と PyIceberg などの追加パッケージを uv で管理する。PySpark はイメージに含まれるものを使う。Iceberg の jar はビルド時に取得してイメージに含める。

## 理由

- 目的は「Jupyter で PySpark を実行できること」で、それには公式イメージに追加するのが最もシンプル
- Spark のバージョンはイメージのタグで固定される

## 影響

- Python 3.10 は 2026-10 にサポートが終了する。ローカルの学習用途なので許容する。Python を新しくしたくなったら、自前でビルドする方式に切り替える
- 追加パッケージは Python 3.10 で動くバージョンを選ぶ
