# 0001. オブジェクトストレージに RustFS を採用する

- 日付: 2026-09-26
- 状態: 採用

## 背景

Iceberg のデータとメタデータを置く S3 互換ストレージが必要。要件は次のとおり。

- 無料で、アカウント登録なしで手軽に使える
- S3 相当のオブジェクトストレージで、Web UI から中身を確認できると良い
- 再起動してもデータが残る（Polaris のメタデータを永続化するため、ストレージ側も揃える）
- WSL2 のメモリ 7.5GiB に収まる

当初は LocalStack を第一候補としていた。

## 検討した選択肢

いずれも 2026-09 時点の調査。メモリは起動直後にこのマシンで実測した値。

- LocalStack（Hobby プラン） — Community 版は 2026-03 に終了した。無料で使うにはアカウント登録とトークンが必要で、非商用に限られ、データを永続化できない
- **RustFS** — 1 コンテナで、アカウントは不要。Web コンソールがあり、STS AssumeRole は動作を確認した。永続化できる。約 100MiB。Apache-2.0。Polaris 公式の Quickstart と Trino ガイドで使われている。1.0.0 GA（2026-09）が出たばかり
- SeaweedFS — 1 コンテナで、ファイルブラウザ付きの管理 UI がある。約 77MiB。STS は初期設定のままでは使えず、ロールの設定が必要
- versitygw / Garage — 非常に軽いが、STS がない。Garage には Web UI もない
- MinIO — 本家は開発を終了した。フォーク版（pgsty/minio）は個人による保守で、AGPL
- Apache Ozone / Ceph — 複数コンテナの重い構成で、メモリの制約に合わない

## 決定

RustFS を採用する。イメージのバージョンは固定し、データはボリュームで永続化する。

## 理由

- 手軽さ・Web UI・永続化・軽さの要件をすべて満たす
- Polaris 公式の構成（`endpoint` / `endpointInternal` / `pathStyleAccess`）をほぼそのまま参考にできる
- STS が動くので、Polaris による認証情報の払い出し（vended credentials）も学習対象にできる

## 影響

- GA が出たばかりなので、細かい不具合に当たる可能性がある。問題が起きたら SeaweedFS に切り替える（Polaris 側は `stsUnavailable: true` で STS を無効にして動かす）
- コンテナは UID 10001 で動く。bind mount を使う場合は所有者を合わせる
- 実装後、付属のコンソールはログイン後に「セッションが切れた」となる不具合があるとわかった。閲覧には別の S3 ブラウザを使う（[ADR 0006](0006-storage-browser-s3manager.md)）
