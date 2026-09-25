#!/bin/sh
# 基盤の初期設定スクリプト（polaris-setup コンテナで実行される）
#
# やること:
#   1. RustFS に warehouse バケットを作る
#   2. Polaris にカタログ・プリンシパル・ロール・権限を作る
#   3. ハンズオン用の名前空間を作る
#
# 起動のたびに実行されるので、既に存在するもの（HTTP 409）はスキップする。
set -eu

POLARIS=http://polaris:8181
REALM=POLARIS
CATALOG=lakehouse
NAMESPACE=handson
PRINCIPAL=handson_user
PRINCIPAL_ROLE=handson_user_role
CATALOG_ROLE=handson_catalog_role

apk add --no-cache jq >/dev/null

# curl を呼び、HTTP ステータスが 2xx なら成功、409（既に存在）ならスキップとして扱う。
# 使い方: call <説明> <curl の引数...>
call() {
  desc=$1; shift
  status=$(curl -s -o /tmp/resp.json -w '%{http_code}' "$@")
  case $status in
    2??) echo "✅ $desc" ;;
    409) echo "⏭️  $desc（既に存在するのでスキップ）" ;;
    *)   echo "❌ $desc（HTTP $status）"; cat /tmp/resp.json; echo; exit 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# 1. バケットの作成
# S3 API は AWS 署名（SigV4）が必要。curl の --aws-sigv4 で署名して PUT する。
# ---------------------------------------------------------------------------
call "バケット warehouse を作成" -X PUT http://rustfs:9000/warehouse \
  --aws-sigv4 "aws:amz:us-east-1:s3" --user "$RUSTFS_ACCESS_KEY:$RUSTFS_SECRET_KEY"

# ---------------------------------------------------------------------------
# 2. root のアクセストークンを取得
# Polaris は OAuth2 の client credentials フローで認証する。
# root は起動時の bootstrap で作られた管理者プリンシパル。
# ---------------------------------------------------------------------------
TOKEN=$(curl -sf -X POST $POLARIS/api/catalog/v1/oauth/tokens \
  -d grant_type=client_credentials \
  -d client_id="$POLARIS_ROOT_CLIENT_ID" \
  -d client_secret="$POLARIS_ROOT_CLIENT_SECRET" \
  -d scope=PRINCIPAL_ROLE:ALL | jq -r .access_token)
echo "✅ root のトークンを取得"

# 以降の Management API 呼び出しで共通のヘッダー
set -- -H "Authorization: Bearer $TOKEN" -H "Polaris-Realm: $REALM" -H "Content-Type: application/json"
MGMT=$POLARIS/api/management/v1

# ---------------------------------------------------------------------------
# 3. カタログの作成
# カタログ = テーブルの置き場所（S3 のどこか）と、ストレージへの接続方法の定義。
#   endpoint         : クライアント（Spark, Trino, PyIceberg）に伝える S3 のアドレス
#   endpointInternal : Polaris 自身が S3 / STS にアクセスするときのアドレス
#   どちらもコンテナ内から届く rustfs:9000 にする（docs/adr/0004 を参照）。
# Polaris は STS AssumeRole で一時的な認証情報を発行し、クライアントに払い出す。
# ---------------------------------------------------------------------------
call "カタログ $CATALOG を作成" -X POST $MGMT/catalogs "$@" -d '{
  "catalog": {
    "name": "'$CATALOG'",
    "type": "INTERNAL",
    "properties": { "default-base-location": "s3://warehouse" },
    "storageConfigInfo": {
      "storageType": "S3",
      "allowedLocations": ["s3://warehouse"],
      "endpoint": "http://rustfs:9000",
      "endpointInternal": "http://rustfs:9000",
      "pathStyleAccess": true,
      "region": "us-east-1"
    }
  }
}'

# ---------------------------------------------------------------------------
# 4. プリンシパルの作成
# プリンシパル = Polaris に接続する利用者（ここでは Spark / Trino / PyIceberg が共用する）。
# 作成時にランダムな認証情報が発行されるので、直後にリセット API で .env の固定値に置き換える。
# ---------------------------------------------------------------------------
status=$(curl -s -o /tmp/resp.json -w '%{http_code}' -X POST $MGMT/principals "$@" \
  -d '{"principal": {"name": "'$PRINCIPAL'"}}')
case $status in
  2??)
    echo "✅ プリンシパル $PRINCIPAL を作成"
    call "プリンシパルの認証情報を .env の値に設定" -X POST $MGMT/principals/$PRINCIPAL/reset "$@" \
      -d '{"clientId": "'"$POLARIS_CLIENT_ID"'", "clientSecret": "'"$POLARIS_CLIENT_SECRET"'"}'
    ;;
  409) echo "⏭️  プリンシパル $PRINCIPAL を作成（既に存在するのでスキップ）" ;;
  *)   echo "❌ プリンシパルの作成（HTTP $status）"; cat /tmp/resp.json; exit 1 ;;
esac

# ---------------------------------------------------------------------------
# 5. ロールと権限
# Polaris の権限モデルは2段階:
#   プリンシパル ──(付与)── プリンシパルロール ──(付与)── カタログロール ──(権限)── カタログ
# プリンシパルロールは「誰か」、カタログロールは「このカタログで何ができるか」を表す。
# ---------------------------------------------------------------------------
call "プリンシパルロール $PRINCIPAL_ROLE を作成" -X POST $MGMT/principal-roles "$@" \
  -d '{"principalRole": {"name": "'$PRINCIPAL_ROLE'"}}'

call "カタログロール $CATALOG_ROLE を作成" -X POST $MGMT/catalogs/$CATALOG/catalog-roles "$@" \
  -d '{"catalogRole": {"name": "'$CATALOG_ROLE'"}}'

call "プリンシパルにプリンシパルロールを付与" -X PUT $MGMT/principals/$PRINCIPAL/principal-roles "$@" \
  -d '{"principalRole": {"name": "'$PRINCIPAL_ROLE'"}}'

call "プリンシパルロールにカタログロールを付与" -X PUT $MGMT/principal-roles/$PRINCIPAL_ROLE/catalog-roles/$CATALOG "$@" \
  -d '{"catalogRole": {"name": "'$CATALOG_ROLE'"}}'

# CATALOG_MANAGE_CONTENT = 名前空間・テーブルの作成、読み書き、削除などカタログの中身の操作全般
call "カタログロールに CATALOG_MANAGE_CONTENT を付与" -X PUT $MGMT/catalogs/$CATALOG/catalog-roles/$CATALOG_ROLE/grants "$@" \
  -d '{"type": "catalog", "privilege": "CATALOG_MANAGE_CONTENT"}'

# ---------------------------------------------------------------------------
# 6. 名前空間の作成
# ここからは Iceberg REST カタログ API。ハンズオン用のプリンシパルで実行し、権限設定が効いていることも確かめる。
# ---------------------------------------------------------------------------
USER_TOKEN=$(curl -sf -X POST $POLARIS/api/catalog/v1/oauth/tokens \
  -d grant_type=client_credentials \
  -d client_id="$POLARIS_CLIENT_ID" \
  -d client_secret="$POLARIS_CLIENT_SECRET" \
  -d scope=PRINCIPAL_ROLE:ALL | jq -r .access_token)
echo "✅ $PRINCIPAL のトークンを取得"

call "名前空間 $NAMESPACE を作成" -X POST $POLARIS/api/catalog/v1/$CATALOG/namespaces \
  -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json" \
  -d '{"namespace": ["'$NAMESPACE'"]}'

echo "🎉 初期設定が完了しました"
