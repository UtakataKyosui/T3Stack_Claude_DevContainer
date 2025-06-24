# HukuLog_T3Stack 技術知見集

## アーキテクチャ決定記録（ADR）

### 認証システム設計

#### Better Auth + SimpleWebAuthn構成
- **選択**: Better Auth をベースに SimpleWebAuthn でPasskey機能を追加
- **理由**: 
  - Better Auth: Next.js App Routerに最適化された現代的な認証ライブラリ
  - SimpleWebAuthn: WebAuthn実装の複雑さを抽象化
  - セッション管理とJWTの柔軟な使い分けが可能
- **学習**: 当初NextAuth.jsを検討したが、App Routerとの相性とPasskey対応でBetter Authを採用

#### セッション戦略
- **実装**: Cookie-based session + Redis cache
- **理由**: 
  - サーバーサイドでの確実なセッション管理
  - Passkeyとの相性（WebAuthnはステートフル）
  - スケーリング時のセッション共有が容易

### データベース設計パターン

#### Drizzle ORM最適化
- **スキーマ設計**: ファイル分割による管理性向上
  ```typescript
  // src/server/db/schema/
  ├── users.ts      // ユーザー関連
  ├── items.ts      // 服装アイテム
  ├── outfits.ts    // コーディネート
  └── index.ts      // エクスポート統合
  ```

- **リレーション定義**: 型安全な関連性管理
  ```typescript
  // 効果的なパターン
  export const itemsRelations = relations(items, ({ one, many }) => ({
    owner: one(users, {
      fields: [items.userId],
      references: [users.id],
    }),
    outfitItems: many(outfitItems),
  }));
  ```

#### クエリ最適化パターン
- **N+1問題の回避**: `with` によるeager loading
  ```typescript
  // 良い例
  const itemsWithUser = await db.query.items.findMany({
    with: {
      owner: true,
      outfitItems: {
        with: {
          outfit: true
        }
      }
    }
  });
  ```

- **パフォーマンス**: インデックス戦略
  - `userId` にインデックス（アイテム検索）
  - `createdAt` にインデックス（時系列ソート）
  - 複合インデックス `(userId, category)` で絞り込み高速化

### tRPC実装パターン

#### ルーター構成
```typescript
// src/server/api/root.ts
export const appRouter = createTRPCRouter({
  auth: authRouter,
  items: itemsRouter,
  outfits: outfitsRouter,
  upload: uploadRouter,
});
```

#### プロシージャパターン
- **認証付きプロシージャ**: `protectedProcedure` で統一
- **入力検証**: Zodスキーマの再利用
- **エラーハンドリング**: `TRPCError` での一貫したエラー応答

```typescript
// 効果的なパターン
export const itemsRouter = createTRPCRouter({
  create: protectedProcedure
    .input(createItemSchema)
    .mutation(async ({ ctx, input }) => {
      try {
        const item = await ctx.db.insert(items).values({
          ...input,
          userId: ctx.session.user.id,
        }).returning();
        return item[0];
      } catch (error) {
        throw new TRPCError({
          code: 'INTERNAL_SERVER_ERROR',
          message: 'アイテムの作成に失敗しました',
        });
      }
    }),
});
```

### フロントエンド設計パターン

#### Radix UI + TailwindCSS統合
- **コンポーネント設計**: 合成パターンの活用
  ```typescript
  // src/components/ui/button.tsx
  const Button = React.forwardRef<
    React.ElementRef<typeof Primitive.button>,
    React.ComponentPropsWithoutRef<typeof Primitive.button> & VariantProps<typeof buttonVariants>
  >(({ className, variant, size, ...props }, ref) => (
    <Primitive.button
      className={cn(buttonVariants({ variant, size, className }))}
      ref={ref}
      {...props}
    />
  ));
  ```

####状態管理戦略
- **サーバー状態**: tRPC + TanStack Query
- **クライアント状態**: React state（useState, useReducer）
- **グローバル状態**: Zustand（必要に応じて）

### 画像処理・アップロード

#### ファイルアップロード戦略
- **フロントエンド**: `input type="file"` + プレビュー機能
- **バリデーション**: クライアント＋サーバー両方で実装
- **最適化**: WebP変換、圧縮処理

```typescript
// 画像最適化パターン
const optimizeImage = async (file: File): Promise<File> => {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  // 圧縮・リサイズ処理
  return new File([blob], 'optimized.webp', { type: 'image/webp' });
};
```

## 実装ベストプラクティス

### TypeScript活用
- **型定義**: Zodスキーマからの型推論を活用
  ```typescript
  // schema.ts
  export const itemSchema = z.object({
    name: z.string().min(1),
    category: z.enum(['tops', 'bottoms', 'shoes', 'accessories']),
  });
  
  export type Item = z.infer<typeof itemSchema>;
  ```

### エラーハンドリング
- **統一的なエラー処理**: ErrorBoundaryとtoast通知
- **ユーザーフレンドリーなメッセージ**: 技術的エラーの翻訳
- **ログ収集**: 本番環境でのエラー追跡

### パフォーマンス最適化
- **画像遅延読み込み**: Next.js `Image` コンポーネント活用
- **コード分割**: 動的インポートによるバンドルサイズ削減
- **キャッシュ戦略**: SWRパターンでのデータキャッシュ

## 避けるべきパターン（アンチパターン）

### データベース
- ❌ **N+1クエリ**: リレーションの個別取得
- ❌ **大きなペイロード**: 不要なフィールドの取得
- ❌ **インデックス不足**: WHERE句で使用するカラムのインデックス漏れ

### React/Next.js
- ❌ **useEffect乱用**: 不必要な副作用処理
- ❌ **状態の過度な分割**: 関連する状態の分散管理
- ❌ **Client Componentの過用**: Server Componentで十分な箇所での無駄な使用

### tRPC
- ❌ **巨大なペイロード**: 大量データの一括取得
- ❌ **認証チェック漏れ**: protectedProcedureの使い忘れ
- ❌ **エラー情報の漏洩**: 本番環境での詳細エラーメッセージ

## ライブラリ選定基準

### 採用基準
- ✅ **TypeScript対応**: First-class TypeScript support
- ✅ **メンテナンス状況**: 活発な開発とコミュニティ
- ✅ **バンドルサイズ**: アプリケーション全体への影響
- ✅ **学習コスト**: チーム（個人）での習得容易性

### 現在の主要ライブラリ評価
- **状態管理**: Zustand > Redux Toolkit（軽量性重視）
- **テスト**: Playwright > Cypress（速度と安定性）
- **フォーム**: React Hook Form（パフォーマンス重視）
- **日付処理**: date-fns > moment.js（バンドルサイズ）

## セキュリティ考慮事項

### 認証・認可
- **Passkey実装**: ブラウザ対応状況の継続監視
- **セッション管理**: 適切な有効期限とローテーション
- **CSRF対策**: SameSite Cookieの活用

### データ保護
- **画像データ**: 個人特定可能情報の取り扱い注意
- **暗号化**: 保存時・転送時の暗号化
- **アクセス制御**: ユーザー間のデータ分離

### フロントエンド
- **XSS対策**: ユーザー入力のサニタイゼーション
- **CSP**: Content Security Policyの適切な設定
- **HTTPS**: 全通信の暗号化