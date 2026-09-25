# docker compose を呼ぶだけの薄いラッパー。各ターゲットの中身がそのまま実際のコマンド。
# `make help` で一覧を表示する。

COMPOSE := docker compose
FILE ?=

.DEFAULT_GOAL := help
.PHONY: help setup up up-spark up-trino up-all down reset ps logs trino-cli trino-sql smoke data

help: ## コマンドの一覧を表示する
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## 初回の準備（.env の作成、ホストの開発ツールと nbstripout の導入）
	@test -f .env || cp .env.example .env
	uv sync
	uv run nbstripout --install --attributes .gitattributes

up: ## 基盤（RustFS, PostgreSQL, Polaris）を起動する
	$(COMPOSE) up -d --wait

up-spark: ## 基盤 + Spark（JupyterLab）を起動する
	$(COMPOSE) --profile spark up -d --wait

up-trino: ## 基盤 + Trino を起動する
	$(COMPOSE) --profile trino up -d --wait

up-all: ## 基盤 + Spark + Trino を起動する
	$(COMPOSE) --profile spark --profile trino up -d --wait

down: ## 停止する（データは残る）
	$(COMPOSE) --profile spark --profile trino down

reset: ## 完全に初期化する（ボリュームごと削除）
	$(COMPOSE) --profile spark --profile trino down -v

ps: ## コンテナの状態を表示する
	$(COMPOSE) --profile spark --profile trino ps -a

logs: ## ログを表示する（例: make logs S=polaris）
	$(COMPOSE) --profile spark --profile trino logs -f $(S)

trino-cli: ## Trino CLI に接続する
	$(COMPOSE) exec trino trino --catalog lakehouse --schema handson

trino-sql: ## SQL ファイルを実行する（例: make trino-sql FILE=handson/01_basic_crud/trino.sql）
	@test -n "$(FILE)" || (echo "FILE を指定してください" && exit 1)
	$(COMPOSE) exec -T trino trino --catalog lakehouse --schema handson < $(FILE)

smoke: ## 動作確認（Trino でテーブルを作ってクエリを実行する）
	$(COMPOSE) exec -T trino trino --catalog lakehouse --schema handson < scripts/smoke.sql

data: ## サンプルデータ（NYC タクシー）を data/ に取得する
	./scripts/download_data.sh
