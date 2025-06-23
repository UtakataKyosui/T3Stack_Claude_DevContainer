# T3 Stack Claude DevContainer

Reusable DevContainer configuration for T3 Stack projects with Claude Code integration.

## 概要

このリポジトリは、T3 Stack（Next.js + TypeScript + tRPC + Drizzle ORM）プロジェクト用の包括的なDevContainer環境設定を提供します。Claude Code CLIとの統合により、効率的な開発環境を構築できます。

## 特徴

- **T3 Stack完全対応**: Next.js 15, React 19, TypeScript, tRPC, Drizzle ORM
- **Claude Code統合**: AI支援開発環境
- **包括的なツールセット**: tmux, fzf, ripgrep, batなどの開発ツール
- **データベース環境**: PostgreSQL + Redis
- **テスト環境**: Playwright E2Eテスト対応
- **開発効率化**: VS Code拡張機能とセットアップの自動化

## 使用方法

### サブモジュールとして追加

```bash
# .devcontainerディレクトリとしてサブモジュール追加
git submodule add https://github.com/UtakataKyosui/T3Stack_Claude_DevContainer.git .devcontainer
```

### 直接クローン

```bash
git clone https://github.com/UtakataKyosui/T3Stack_Claude_DevContainer.git .devcontainer
```

## ファイル構成

- `devcontainer.json`: メインのDevContainer設定
- `docker-compose.yml`: サービス定義（PostgreSQL, Redis, etc.）
- `setup-devtools.sh`: 開発ツール自動インストール
- `fix-permissions.sh`: 権限問題の自動修正
- `.env.example`: 環境変数のテンプレート
- `init-scripts/`: データベース初期化スクリプト
- `redis.conf`: Redis設定

## 含まれるサービス

### 開発環境
- **Node.js 22**: 最新のLTS版
- **Python 3.12**: Claude Code用
- **Docker in Docker**: コンテナ管理
- **Git & GitHub CLI**: バージョン管理

### データベース
- **PostgreSQL 16**: メインデータベース (Port: 5432)
- **Redis 7**: セッション管理・キャッシュ (Port: 6379)
- **Adminer**: データベース管理UI (Port: 8080)
- **MailHog**: 開発用メールサーバー (Port: 8025)

### 開発ツール
- **Claude Code**: AI支援開発CLI
- **tmux**: ターミナルマルチプレクサー
- **fzf**: ファジーファインダー
- **ripgrep**: 高速検索
- **bat**: 改良されたcat
- **exa**: 改良されたls
- **htop**: プロセスモニター

### VS Code拡張機能
- Biome (コード品質・フォーマット)
- TailwindCSS IntelliSense
- TypeScript支援
- Playwright テスト
- GitLens
- Error Lens
- Path Intellisense

## アクセス情報

| サービス | URL | 認証情報 |
|---------|-----|---------|
| Next.js App | http://localhost:3000 | - |
| Adminer | http://localhost:8080 | postgres/password |
| MailHog Web UI | http://localhost:8025 | - |
| PostgreSQL | localhost:5432 | postgres/password |
| Redis | localhost:6379 | - |

## 環境変数

`.env`ファイルで以下の環境変数を設定できます：

```bash
# Database
DATABASE_URL=postgresql://postgres:password@postgres:5432/hukulog
REDIS_URL=redis://redis:6379

# Authentication
BETTER_AUTH_SECRET=development-secret-key
BETTER_AUTH_URL=http://localhost:3000
```

## トラブルシューティング

### ポート競合
デフォルトポート（3000, 5432, 6379）が使用中の場合は、`docker-compose.yml`のポートマッピングを変更してください。

### 権限エラー
```bash
# 権限修正スクリプトを実行
bash fix-permissions.sh
```

### Claude Code関連
```bash
# Claude Codeの状態確認
which claude
claude --version

# 手動インストール
npm install -g @anthropic-ai/claude-code@latest
```

### 開発ツール
```bash
# 開発ツールの再インストール
bash setup-devtools.sh
```

## 必要要件

- Docker Desktop
- VS Code + Dev Containers拡張機能
- Git

## ライセンス

MIT License

## 貢献

プルリクエストやIssueを歓迎します。

---

Created for efficient T3 Stack development with Claude Code integration.