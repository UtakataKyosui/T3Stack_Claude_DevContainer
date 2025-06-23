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
# サブモジュールとして追加
git submodule add https://github.com/UtakataKyosui/T3Stack_Claude_DevContainer.git .devcontainer-config

# DevContainerファイルをリンク
ln -s .devcontainer-config/.devcontainer .devcontainer
ln -s .devcontainer-config/.mcp.json .mcp.json
```

### 直接クローン

```bash
git clone https://github.com/UtakataKyosui/T3Stack_Claude_DevContainer.git
cd T3Stack_Claude_DevContainer
```

## 含まれる機能

### 開発環境
- **Node.js 22**: 最新のLTS版
- **Python 3.12**: Claude Code用
- **Docker in Docker**: コンテナ管理
- **Git & GitHub CLI**: バージョン管理

### データベース
- **PostgreSQL 16**: メインデータベース
- **Redis 7**: セッション管理・キャッシュ
- **Adminer**: データベース管理UI

### 開発ツール
- **Claude Code**: AI支援開発
- **tmux**: ターミナルマルチプレクサー
- **fzf**: ファジーファインダー
- **ripgrep**: 高速検索
- **bat**: 改良されたcat
- **exa**: 改良されたls
- **htop**: プロセスモニター

### VS Code拡張機能
- Biome (コード品質)
- TailwindCSS IntelliSense
- TypeScript支援
- Playwright テスト
- GitLens

## 設定ファイル

- `.devcontainer/devcontainer.json`: メインのDevContainer設定
- `.devcontainer/docker-compose.yml`: サービス定義
- `.devcontainer/setup-devtools.sh`: 開発ツール自動インストール
- `.mcp.json`: Claude Code MCP設定

## カスタマイズ

### 環境変数
`.devcontainer/.env`ファイルで環境設定をカスタマイズできます。

### 追加ツール
`setup-devtools.sh`を編集して、プロジェクト固有のツールを追加できます。

## トラブルシューティング

### ポート競合
デフォルトポート（3000, 5432, 6379）が使用中の場合は、`docker-compose.yml`のポートマッピングを変更してください。

### 権限エラー
`fix-permissions.sh`スクリプトが自動的に権限問題を解決します。

## ライセンス

MIT License

## 貢献

プルリクエストやIssueを歓迎します。

---

Created for efficient T3 Stack development with Claude Code integration.