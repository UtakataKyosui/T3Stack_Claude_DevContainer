#!/bin/bash
set -e

# HukuLog開発データベースの初期化スクリプト
echo "Initializing HukuLog development database..."

# 追加のデータベースユーザー作成（必要に応じて）
# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#     CREATE USER hukulog_dev WITH ENCRYPTED PASSWORD 'dev_password';
#     GRANT ALL PRIVILEGES ON DATABASE hukulog TO hukulog_dev;
# EOSQL

# 開発用の拡張機能を有効化
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- UUID拡張を有効化
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    
    -- crypto拡張を有効化（パスワードハッシュ等で使用）
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    
    -- 日時関連の拡張
    CREATE EXTENSION IF NOT EXISTS "btree_gist";
EOSQL

echo "Database initialization completed!"