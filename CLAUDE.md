# apache-iceberg-hands-on

個人の学習用ハンズオン。ローカル環境で Apache Iceberg のデータレイクハウスを構築し、Iceberg の機能を手を動かして理解する。

## 現在のフェーズ

**実装完了**（Step 5）。docs/tasks.md のタスクはすべて完了。以降の変更も、要件・設計・ADR・tasks.md を更新しながら進める。

フェーズの流れ: 要件定義 → 技術選定・設計 → タスク分解 → 実装。フェーズが進んだらこの節を更新する。

## docs/ — 仕様の単一の情報源

- [docs/requirements.md](docs/requirements.md) — 学習ゴール・要件・スコープ外。作業の前提を確認するときに読む。
- [docs/design.md](docs/design.md) — アーキテクチャと構成。実装・構成変更の前に読む。
- [docs/tasks.md](docs/tasks.md) — タスク一覧と状態。次に何をやるか判断するときに読む。
- [docs/adr/](docs/adr/) — 決定記録（ADR）。技術選定や方針を決めた・変えたときに、[テンプレート](docs/adr/0000-template.md)をコピーして連番で追加する。

## 作業ルール

- 要件・設計に書かれていない事項は、決めずにユーザーへ質問する。合意したら該当 docs と ADR に反映する。
- タスクに着手したら tasks.md の状態を `doing`、完了条件を満たしたら `done` に更新する。

## コマンド

操作は Makefile にまとめている（`make help` で一覧）。一覧と実際のコマンドは README.md を参照。

- 起動と停止: `make up-all` / `make down`。完全に初期化するときは `make reset`
- 動作確認: `make smoke`
- ノートブックをコマンドラインで検証するとき: `docker compose exec -T jupyter jupyter nbconvert --to notebook --execute <ipynb> --output /tmp/out.ipynb`（出力は /tmp に置き、リポジトリのノートブックに実行結果を残さない）
