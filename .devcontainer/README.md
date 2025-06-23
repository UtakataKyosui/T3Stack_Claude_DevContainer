# HukuLog T3 Stack Development Container

このディレクトリには、HukuLog_T3Stackプロジェクトの開発環境をDockerコンテナで構築するための設定ファイルが含まれています。

## 🚀 概要

モダンなDevContainer環境として以下の特徴を持ちます：

- **Microsoft公式TypeScript-Nodeイメージ**を使用
- **Biome**による高速なLint・Format
- **Drizzle Studio**によるデータベース管理
- **MinIO**でのS3互換オブジェクトストレージ
- **MailHog**による開発用メール環境

## 📦 構成サービス

### メインサービス
- **app**: 開発コンテナ (TypeScript-Node:22)
- **postgres**: PostgreSQL 16 (hukulogデータベース)
- **redis**: Redis 7 (セッション管理・キャッシュ)

### 開発支援サービス
- **drizzle-studio**: データベース管理 (Port: 4983)
- **adminer**: 軽量DB管理ツール (Port: 8080)
- **mailhog**: 開発用メールサーバー (Port: 8025)
- **minio**: S3互換ストレージ (Port: 9000/9001)

## 🎯 アクセス情報

| サービス | URL | 認証情報 |
|---------|-----|---------|
| Next.js App | http://localhost:3000 | - |
| Drizzle Studio | http://localhost:4983 | - |
| Adminer | http://localhost:8080 | postgres/password |
| MailHog Web UI | http://localhost:8025 | - |
| MinIO Console | http://localhost:9001 | minioadmin/minioadmin123 |
| MinIO API | http://localhost:9000 | minioadmin/minioadmin123 |

## 🛠️ VS Code拡張機能

自動インストールされる拡張機能：

### コア開発
- **Biome**: Lint・Format（Prettier/ESLintの代替）
- **TypeScript**: 最新TypeScript言語サポート
- **Tailwind CSS**: CSSクラス補完・プレビュー

### 開発効率化
- **Auto Rename Tag**: HTMLタグの自動リネーム
- **Path Intellisense**: ファイルパス補完
- **Error Lens**: インラインエラー表示
- **Pretty TypeScript Errors**: TypeScriptエラーの可読性向上

### Git・プロジェクト管理
- **GitLens**: Git履歴・責任範囲の可視化
- **GitHub Theme**: GitHubライクなテーマ
- **Material Icon Theme**: ファイルアイコン

### テスト・デバッグ
- **Playwright**: E2Eテスト
- **REST Client**: API テスト

## ⚙️ VS Code設定

### エディタ設定
- **デフォルトフォーマッター**: Biome
- **保存時フォーマット**: 有効
- **フォント**: Fira Code（リガチャ有効）
- **ルーラー**: 80, 120文字

### TypeScript設定
- **自動インポート**: type-only imports優先
- **ファイル移動時**: インポート自動更新
- **インレイヒント**: 有効

### TailwindCSS設定
- **クラス補完**: cva, cx, cn関数対応
- **CSS認識**: TypeScriptファイルでTailwind補完

## 🗃️ データベース設定

### PostgreSQL 16
```bash
Database: hukulog
User: postgres
Password: password
Port: 5432
```

### 有効化される拡張機能
- `uuid-ossp`: UUID生成
- `pgcrypto`: 暗号化機能
- `btree_gist`: 日時インデックス最適化

### Redis設定
- **メモリ制限**: 256MB（開発環境用）
- **永続化**: 軽量設定
- **セッション最適化**: hash設定調整済み

## 🚦 起動手順

1. **VS Code + Dev Containers拡張をインストール**
2. **プロジェクトを開く**
   ```bash
   code /path/to/HukuLog_T3Stack
   ```
3. **コマンドパレット** (`Ctrl+Shift+P`) → `Dev Containers: Reopen in Container`
4. **初期化完了を待つ** (初回は数分かかります)

## 🔧 カスタマイズ

### 環境変数の追加
`.devcontainer/.env.example`を参考に独自の環境変数を設定可能。

### ポート追加
`devcontainer.json`の`forwardPorts`で追加ポートを設定。

### VS Code設定変更
`devcontainer.json`の`customizations.vscode.settings`で設定をカスタマイズ。

## 🐍 Python/uv サポート

DevContainerには **uv** (高速Pythonパッケージマネージャー) が自動インストールされます：

### 使用方法
```bash
# Python パッケージのインストール
uv pip install package-name

# 仮想環境の作成
uv venv

# requirements.txtからインストール
uv pip install -r requirements.txt

# MCPサーバーの実行 (mcp.jsonで設定済み)
uvx mcp-server-fetch
```

### 特徴
- **高速**: pipより10-100倍高速
- **依存関係解決**: より正確な依存関係管理
- **Claude Code MCP**: fetch serverなどで利用

## 🛠️ トラブルシューティング

### 権限エラーが発生する場合
DevContainer起動時に自動的に権限修正が実行されますが、問題がある場合：

```bash
# 手動で権限修正スクリプトを実行
bash .devcontainer/fix-permissions.sh
```

### uvが見つからない場合
```bash
# PATHを再読み込み
source ~/.bashrc

# 手動でuvを再インストール
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Claude Codeが起動しない場合
```bash
# DevContainer内でClaude Codeの状態確認
which claude
claude --version

# npm経由での手動インストール
npm install -g @anthropic-ai/claude-code@latest

# PATHの確認と設定
echo $PATH
export PATH="$(npm config get prefix)/bin:$PATH"

# MCP設定の確認
cat /workspace/.mcp.json
```

### 権限エラーが発生する場合
```bash
# ホストマシンで（DevContainerの外で）
mkdir -p ~/.anthropic
chmod 755 ~/.anthropic

# DevContainer再構築
# VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

### 追加サービス
`docker-compose.yml`に新しいサービスを追加可能。

## 🔍 トラブルシューティング

### コンテナが起動しない
```bash
# コンテナとボリュームをクリーンアップ
docker-compose -f .devcontainer/docker-compose.yml down -v
docker system prune -f
```

### データベース接続エラー
```bash
# PostgreSQLヘルスチェック確認
docker-compose -f .devcontainer/docker-compose.yml logs postgres
```

### Node.js依存関係エラー
```bash
# node_modulesボリュームリセット
docker volume rm hukulog_t3stack_node_modules
```

## 📚 関連ドキュメント

- [Dev Containers公式ドキュメント](https://containers.dev/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Drizzle Studio](https://orm.drizzle.team/drizzle-studio/overview)
- [Biome](https://biomejs.dev/)

---

**最終更新**: 2025-06-21  
**改善履歴**: `.claude/project-improvements.md`を参照