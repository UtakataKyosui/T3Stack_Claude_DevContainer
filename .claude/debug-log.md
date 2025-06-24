# HukuLog_T3Stack デバッグ記録

## デバッグ情報管理ルール

### 永続化基準
以下の条件を満たす問題は、このファイルに記録する：
- **解決時間**: 30分以上要した問題
- **再発可能性**: 同様の問題が再発する可能性が高い
- **影響範囲**: チーム（将来的な協力者）に共有すべき知見
- **技術的価値**: T3 Stack特有の問題や解決法

### 記録フォーマット
```markdown
## [YYYY-MM-DD] 問題の概要

**症状**: エラーメッセージや異常動作の詳細
**環境**: OS, Node.js, ブラウザ, データベースバージョン
**再現手順**: 具体的な操作手順（1. 2. 3...）
**試行錯誤**: 試した方法とその結果（❌/✅で表示）
**最終解決方法**: 確実に動作する解決手順
**根本原因**: 問題の本質的な原因
**予防策**: 同じ問題を避けるための対策
**関連資料**: 参考にしたドキュメントやIssue
```

---

## [2025-06-21] 知見管理システムの初期構築

**症状**: Claude Codeでの開発効率化のための知見管理システムが未整備
**環境**: 
- Windows 11
- Node.js 18.17.0
- HukuLog_T3Stack repository

**実装内容**:
1. Zenn記事「Claude Codeで効率的に開発するための知見管理」を参考
2. HukuLog_T3Stack用にカスタマイズした知見管理システムを構築
3. 以下のファイルを新規作成：
   - `.claude/context.md`: プロジェクト背景・制約・技術選定理由
   - `.claude/project-knowledge.md`: T3 Stack実装パターンと設計知見
   - `.claude/project-improvements.md`: 改善履歴
   - `.claude/common-patterns.md`: 頻用コマンドとテンプレート
   - `.claude/debug-log.md`: 本ファイル

**期待効果**:
- Claude Codeでの開発時の文脈共有効率化
- 過去の設計決定や技術的知見の蓄積
- 新機能開発時の一貫性確保
- デバッグ時間の短縮

**今後の運用方針**:
- 重要な実装や決定時の知見ファイル更新を習慣化
- 月1回の定期的な情報整理とメンテナンス
- 新しい問題解決時の積極的な記録

---

## T3 Stack特有の問題と解決法

### tRPCクライアント初期化エラー

**症状**: `useQuery` フックでの型エラーや実行時エラー
**環境**: Next.js 15, tRPC v11
**再現手順**:
1. tRPCクライアントを新しいコンポーネントで使用
2. `api.items.list.useQuery()` を実行
3. TypeScriptエラーまたは実行時エラーが発生

**よくある原因と解決法**:

#### 1. Provider設定の不備
❌ **問題**: TRPCProviderがコンポーネントツリーで不適切に配置
```typescript
// 間違った例
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <TRPCReactProvider>{/* Providerの位置が間違い */}</TRPCReactProvider>
      </body>
    </html>
  );
}
```

✅ **解決法**: 適切なProvider配置
```typescript
// 正しい例
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <TRPCReactProvider>
          {children}
        </TRPCReactProvider>
      </body>
    </html>
  );
}
```

#### 2. Server Componentでのクライアントフック使用
❌ **問題**: Server ComponentでuseQueryを直接使用
```typescript
// app/page.tsx (Server Component)
export default function HomePage() {
  const { data } = api.items.list.useQuery(); // エラー！
  return <div>{/* ... */}</div>;
}
```

✅ **解決法**: Client Componentの作成またはサーバーサイド取得
```typescript
// components/ItemsList.tsx (Client Component)
'use client';

export function ItemsList() {
  const { data } = api.items.list.useQuery();
  return <div>{/* ... */}</div>;
}

// または Server Action使用
// app/page.tsx
import { api } from '@/trpc/server';

export default async function HomePage() {
  const items = await api.items.list();
  return <div>{/* ... */}</div>;
}
```

### Drizzle ORMでのリレーション取得問題

**症状**: リレーションデータが取得できない、またはN+1クエリが発生
**再現手順**:
1. リレーションを含むクエリを実行
2. 関連データが undefined または空
3. ログで大量のクエリ実行を確認

**解決パターン**:

#### 1. リレーション定義の確認
```typescript
// schema/items.ts
export const itemsRelations = relations(items, ({ one, many }) => ({
  owner: one(users, {
    fields: [items.userId],
    references: [users.id],
  }),
  categories: many(itemCategories), // 正しく定義されているか確認
}));
```

#### 2. クエリでの明示的なwith指定
```typescript
// ❌ リレーションが取得されない
const items = await db.query.items.findMany();

// ✅ withで明示的に指定
const items = await db.query.items.findMany({
  with: {
    owner: true,
    categories: true,
  },
});
```

### Better Authセットアップでのセッション問題

**症状**: ログイン後にセッション情報が取得できない
**環境**: Better Auth v1.2.x, Next.js 15

**チェックポイント**:
1. **環境変数の設定**
   ```env
   BETTER_AUTH_SECRET=your-32-character-secret-key
   BETTER_AUTH_URL=http://localhost:3000
   ```

2. **ミドルウェア設定**
   ```typescript
   // middleware.ts
   import { betterAuth } from "better-auth";
   
   export default betterAuth({
     secret: process.env.BETTER_AUTH_SECRET!,
     baseURL: process.env.BETTER_AUTH_URL!,
   }).middleware;
   ```

3. **Cookieの設定確認**
   - SameSite属性の適切な設定
   - HTTPSでのSecure属性
   - Domain設定の確認

### SimpleWebAuthn（Passkey）ブラウザ対応問題

**症状**: 特定のブラウザでPasskey認証が動作しない
**対応ブラウザ確認リスト**:
- ✅ Chrome 108+
- ✅ Firefox 113+
- ✅ Safari 16+
- ✅ Edge 108+
- ❌ iOS Safari 15以下
- ❌ Android Chrome 107以下

**フォールバック実装**:
```typescript
// WebAuthn対応確認
const isWebAuthnSupported = () => {
  return typeof window !== 'undefined' && 
         'navigator' in window && 
         'credentials' in navigator;
};

// フォールバック認証の提供
if (!isWebAuthnSupported()) {
  // メール＋パスワード認証にフォールバック
  return <EmailPasswordAuth />;
}
```

## パフォーマンス関連の問題

### 画像アップロード時のメモリ使用量急増

**症状**: 大きな画像ファイルのアップロード時にブラウザがフリーズ
**原因**: フロントエンドでの画像処理時のメモリリーク

**解決法**:
```typescript
// メモリ効率的な画像リサイズ
const resizeImage = async (file: File, maxWidth: number): Promise<File> => {
  return new Promise((resolve) => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d')!;
    const img = new Image();
    
    img.onload = () => {
      // リサイズ処理
      const { width, height } = calculateDimensions(img.width, img.height, maxWidth);
      canvas.width = width;
      canvas.height = height;
      
      ctx.drawImage(img, 0, 0, width, height);
      
      canvas.toBlob((blob) => {
        if (blob) {
          resolve(new File([blob], file.name, { type: 'image/webp' }));
        }
      }, 'image/webp', 0.8);
      
      // メモリクリーンアップ
      canvas.width = 0;
      canvas.height = 0;
    };
    
    img.src = URL.createObjectURL(file);
  });
};
```

### PostgreSQL接続数上限エラー

**症状**: `sorry, too many clients already` エラー
**原因**: Drizzle接続プールの設定不備

**解決法**:
```typescript
// drizzle.config.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

const client = postgres(process.env.DATABASE_URL!, {
  max: 10, // 接続プールサイズ制限
  idle_timeout: 20,
  connect_timeout: 10,
});

export const db = drizzle(client);
```

## 開発環境セットアップの落とし穴

### Docker Composeでのデータベース接続問題

**症状**: アプリケーションからPostgreSQLに接続できない
**チェックリスト**:
1. ポート番号の重複確認
2. ネットワーク設定の確認
3. 環境変数のホスト名設定

**解決例**:
```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: hukulog
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    networks:
      - hukulog_network

  app:
    build: .
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/hukulog
    depends_on:
      - postgres
    networks:
      - hukulog_network

networks:
  hukulog_network:
```

### TailwindCSS設定でのスタイル適用問題

**症状**: Radix UIコンポーネントのスタイルが反映されない
**原因**: TailwindCSSの設定でRadix UIクラスが含まれていない

**解決法**:
```javascript
// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
    './node_modules/@radix-ui/**/*.{js,ts,jsx,tsx}', // 追加
  ],
  // ...
};
```

---

## 予防的メンテナンス

### 定期チェック項目（月1回）

1. **依存関係の更新確認**
   ```bash
   npm audit
   npm outdated
   ```

2. **データベースパフォーマンス確認**
   ```sql
   -- 遅いクエリの確認
   SELECT query, mean_exec_time, calls 
   FROM pg_stat_statements 
   ORDER BY mean_exec_time DESC 
   LIMIT 10;
   ```

3. **ログファイルの確認**
   - アプリケーションログのエラー確認
   - データベースログの警告確認
   - Vercelデプロイメントログの確認

### パフォーマンス監視

1. **Core Web Vitals**
   - LCP (Largest Contentful Paint) < 2.5s
   - FID (First Input Delay) < 100ms
   - CLS (Cumulative Layout Shift) < 0.1

2. **データベース監視**
   - クエリ実行時間の追跡
   - 接続数の監視
   - インデックス使用率の確認

3. **画像最適化**
   - WebP変換率の確認
   - 画像サイズの平均値監視
   - CDN キャッシュヒット率

---

## 緊急時対応手順

### サービス停止時の対応

1. **即座の確認事項**
   - Vercelデプロイメント状況
   - データベース接続状況
   - 外部API（認証サービス等）の状況

2. **ロールバック手順**
   ```bash
   # Vercelでの前回デプロイに戻す
   vercel --prod --force
   
   # データベースマイグレーションの確認
   npm run db:studio
   ```

3. **ユーザー通知**
   - 状況の透明な報告
   - 復旧予定時刻の共有
   - 代替手段の提案（可能な場合）

### セキュリティインシデント対応

1. **即座の対応**
   - 該当サービスの一時停止
   - ログの保全
   - 影響範囲の特定

2. **調査と対応**
   - セキュリティパッチの適用
   - パスワード/APIキーの変更
   - ユーザーへの通知

3. **再発防止**
   - セキュリティ監査の実施
   - 脆弱性スキャンの定期化
   - アクセス制御の見直し

---

## 外部連携時の注意点

### Vercelデプロイメント

**よくある問題**:
- 環境変数の設定漏れ
- ビルドエラーでのデプロイ失敗
- 静的ファイルの最適化問題

**チェックリスト**:
```bash
# ローカルでのビルド確認
npm run build
npm run start

# 環境変数の確認
vercel env ls

# ログの確認
vercel logs [deployment-url]
```

### Supabase/Railwayデータベース

**接続問題の対処**:
1. 接続文字列の確認
2. IP許可リストの設定
3. SSL証明書の検証

**バックアップ戦略**:
```bash
# 定期バックアップ
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# 復元手順
psql $DATABASE_URL < backup_20250621.sql
```

---

**最終更新**: 2025-06-21  
**次回レビュー予定**: 2025-07-21  
**メンテナンス担当**: 開発者