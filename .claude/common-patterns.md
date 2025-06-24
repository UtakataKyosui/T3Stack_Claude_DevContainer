# HukuLog_T3Stack よく使用するパターン

## Claude Codeでの頻用コマンドパターン

### 新機能開発

#### コンポーネント生成
```bash
# 新しいRadix UIベースコンポーネントの作成
claude create component [ComponentName] with TypeScript, Radix UI and Tailwind styling

# 例：服装アイテムカード
claude create ItemCard component with image preview, category badge, and action buttons
```

#### tRPCルーター追加
```bash
# 新しいtRPCルーターの作成
claude create tRPC router for [entity] with CRUD operations and Zod validation

# 例：コーディネート管理
claude create tRPC outfit router with create, read, update, delete, and list operations
```

#### Drizzleスキーマ定義
```bash
# 新しいデータベーステーブル
claude create Drizzle schema for [table] with proper relations and indexes

# 例：タグ機能
claude create Drizzle schema for tags with many-to-many relation to items
```

### デバッグ・トラブルシューティング

#### エラー解析
```bash
# エラーログの分析と解決策提案
claude analyze this error and suggest fixes: [error-message]

# tRPCエラーの特定
claude debug tRPC connection issue: [specific-error]

# 認証問題の解決
claude troubleshoot Better Auth + Passkey authentication: [issue-description]
```

#### パフォーマンス最適化
```bash
# 遅いクエリの最適化
claude optimize this Drizzle query for better performance: [query]

# 画像読み込み最適化
claude improve image loading performance with Next.js Image optimization
```

### UI/UX改善

#### レスポンシブデザイン
```bash
# モバイル対応の改善
claude make this component mobile-friendly with proper touch targets

# アクセシビリティ向上
claude improve accessibility for [component] following WCAG 2.1 guidelines
```

## よく使用する実装テンプレート

### 1. tRPCプロシージャテンプレート

#### 基本的なCRUD操作
```typescript
// src/server/api/routers/[entity].ts
export const [entity]Router = createTRPCRouter({
  // 作成
  create: protectedProcedure
    .input([entity]CreateSchema)
    .mutation(async ({ ctx, input }) => {
      const [entity] = await ctx.db.insert([entities]).values({
        ...input,
        userId: ctx.session.user.id,
      }).returning();
      return [entity];
    }),

  // 取得（一覧）
  list: protectedProcedure
    .input(z.object({
      limit: z.number().min(1).max(100).default(20),
      offset: z.number().min(0).default(0),
    }))
    .query(async ({ ctx, input }) => {
      return await ctx.db.query.[entities].findMany({
        where: eq([entities].userId, ctx.session.user.id),
        limit: input.limit,
        offset: input.offset,
        orderBy: desc([entities].createdAt),
      });
    }),

  // 取得（単体）
  getById: protectedProcedure
    .input(z.string())
    .query(async ({ ctx, input }) => {
      const [entity] = await ctx.db.query.[entities].findFirst({
        where: and(
          eq([entities].id, input),
          eq([entities].userId, ctx.session.user.id)
        ),
      });
      if (![entity]) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: '[Entity]が見つかりません',
        });
      }
      return [entity];
    }),

  // 更新
  update: protectedProcedure
    .input([entity]UpdateSchema)
    .mutation(async ({ ctx, input }) => {
      const { id, ...data } = input;
      const [updated] = await ctx.db.update([entities])
        .set(data)
        .where(and(
          eq([entities].id, id),
          eq([entities].userId, ctx.session.user.id)
        ))
        .returning();
      
      if (!updated) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: '[Entity]が見つかりません',
        });
      }
      return updated;
    }),

  // 削除
  delete: protectedProcedure
    .input(z.string())
    .mutation(async ({ ctx, input }) => {
      await ctx.db.delete([entities])
        .where(and(
          eq([entities].id, input),
          eq([entities].userId, ctx.session.user.id)
        ));
      return { success: true };
    }),
});
```

### 2. Reactコンポーネントテンプレート

#### フォームコンポーネント
```typescript
'use client';

import { useState } from 'react';
import { api } from '@/trpc/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

interface [Entity]FormProps {
  initialData?: [Entity];
  onSuccess?: () => void;
}

export function [Entity]Form({ initialData, onSuccess }: [Entity]FormProps) {
  const [formData, setFormData] = useState({
    name: initialData?.name ?? '',
    // その他のフィールド
  });

  const utils = api.useUtils();
  const createMutation = api.[entities].create.useMutation({
    onSuccess: () => {
      toast.success('[Entity]を作成しました');
      utils.[entities].list.invalidate();
      onSuccess?.();
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });

  const updateMutation = api.[entities].update.useMutation({
    onSuccess: () => {
      toast.success('[Entity]を更新しました');
      utils.[entities].list.invalidate();
      onSuccess?.();
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (initialData) {
      updateMutation.mutate({ id: initialData.id, ...formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const isLoading = createMutation.isPending || updateMutation.isPending;

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="name">名前</Label>
        <Input
          id="name"
          value={formData.name}
          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
          disabled={isLoading}
          required
        />
      </div>
      
      <Button type="submit" disabled={isLoading}>
        {isLoading ? '保存中...' : (initialData ? '更新' : '作成')}
      </Button>
    </form>
  );
}
```

#### リストコンポーネント
```typescript
'use client';

import { api } from '@/trpc/react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Loader2, Plus } from 'lucide-react';

export function [Entity]List() {
  const { data: [entities], isLoading } = api.[entities].list.useQuery();
  
  if (isLoading) {
    return (
      <div className="flex justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">[Entity]一覧</h2>
        <Button>
          <Plus className="h-4 w-4 mr-2" />
          追加
        </Button>
      </div>
      
      {[entities]?.length === 0 ? (
        <Card>
          <CardContent className="text-center py-8">
            <p className="text-muted-foreground">[Entity]が見つかりません</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[entities]?.map(([entity]) => (
            <[Entity]Card key={[entity].id} [entity]={[entity]} />
          ))}
        </div>
      )}
    </div>
  );
}
```

### 3. Drizzleスキーマテンプレート

```typescript
// src/server/db/schema/[entities].ts
import { pgTable, text, timestamp, uuid, varchar, boolean } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';
import { users } from './users';

export const [entities] = pgTable('[entities]', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  description: text('description'),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const [entities]Relations = relations([entities], ({ one }) => ({
  owner: one(users, {
    fields: [[entities].userId],
    references: [users.id],
  }),
}));

// Zodスキーマ
export const [entity]CreateSchema = z.object({
  name: z.string().min(1, '名前は必須です'),
  description: z.string().optional(),
});

export const [entity]UpdateSchema = [entity]CreateSchema.extend({
  id: z.string(),
});

export type [Entity] = typeof [entities].$inferSelect;
export type [Entity]Create = z.infer<typeof [entity]CreateSchema>;
export type [Entity]Update = z.infer<typeof [entity]UpdateSchema>;
```

### 4. 認証ガードテンプレート

```typescript
// src/components/auth/auth-guard.tsx
'use client';

import { useSession } from '@/hooks/use-session';
import { Loader2 } from 'lucide-react';
import { redirect } from 'next/navigation';
import { useEffect } from 'react';

interface AuthGuardProps {
  children: React.ReactNode;
  requireAuth?: boolean;
}

export function AuthGuard({ children, requireAuth = true }: AuthGuardProps) {
  const { user, isLoading } = useSession();

  useEffect(() => {
    if (!isLoading && requireAuth && !user) {
      redirect('/auth/signin');
    }
  }, [user, isLoading, requireAuth]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  if (requireAuth && !user) {
    return null;
  }

  return <>{children}</>;
}
```

## 頻用するTailwindCSSクラス組み合わせ

### レイアウト
```css
/* カード型レイアウト */
.card-base {
  @apply bg-card text-card-foreground border rounded-lg shadow-sm;
}

/* フレックスレイアウト */
.flex-center {
  @apply flex items-center justify-center;
}

.flex-between {
  @apply flex items-center justify-between;
}

/* グリッドレイアウト */
.grid-responsive {
  @apply grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4;
}
```

### インタラクション
```css
/* ホバーエフェクト */
.hover-lift {
  @apply transition-transform duration-200 hover:scale-105;
}

/* ボタンスタイル */
.btn-primary {
  @apply bg-primary text-primary-foreground hover:bg-primary/90 px-4 py-2 rounded-md transition-colors;
}
```

## デバッグ時のよく使用するパターン

### ログ出力
```typescript
// 開発環境でのデバッグログ
if (process.env.NODE_ENV === 'development') {
  console.log('Debug:', { data, error, state });
}
```

### エラーハンドリング
```typescript
// tRPCエラーの適切な処理
try {
  const result = await api.[entity].create.mutate(data);
  return result;
} catch (error) {
  if (error instanceof TRPCError) {
    toast.error(error.message);
  } else {
    toast.error('予期しないエラーが発生しました');
    console.error('Unexpected error:', error);
  }
}
```

### 開発中のテンポラリ機能
```typescript
// TODO コメントと一緒に使用
// TODO: 本格実装時にPasskey認証に置き換え
const isDevMode = process.env.NODE_ENV === 'development';

if (isDevMode) {
  // 開発環境での簡易認証
  return mockAuthResponse;
}
```

## パフォーマンス最適化のパターン

### React最適化
```typescript
// メモ化
const MemoizedComponent = React.memo(Component);

// useMemoの適切な使用
const expensiveValue = useMemo(() => {
  return heavyCalculation(data);
}, [data]);

// useCallbackの適切な使用
const handleClick = useCallback((id: string) => {
  onItemClick(id);
}, [onItemClick]);
```

### 画像最適化
```typescript
// Next.js Imageコンポーネントの使用
<Image
  src={item.imageUrl}
  alt={item.name}
  width={300}
  height={200}
  className="object-cover"
  loading="lazy"
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
/>
```

## よく使用するZodバリデーションパターン

### ファイルアップロード
```typescript
const fileUploadSchema = z.object({
  file: z.instanceof(File)
    .refine((file) => file.size <= 10 * 1024 * 1024, {
      message: "ファイルサイズは10MB以下にしてください",
    })
    .refine((file) => ['image/jpeg', 'image/png', 'image/webp'].includes(file.type), {
      message: "JPG、PNG、WebP形式のファイルのみアップロード可能です",
    }),
});
```

### 日本語対応
```typescript
const itemSchema = z.object({
  name: z.string()
    .min(1, '名前は必須です')
    .max(100, '名前は100文字以下で入力してください'),
  category: z.enum(['tops', 'bottoms', 'shoes', 'accessories'], {
    errorMap: () => ({ message: '有効なカテゴリーを選択してください' }),
  }),
  tags: z.array(z.string()).max(10, 'タグは10個まで設定できます'),
});
```

## デプロイメント関連パターン

### 環境変数チェック
```typescript
// 必須環境変数の確認
const requiredEnvVars = [
  'DATABASE_URL',
  'BETTER_AUTH_SECRET',
  'BETTER_AUTH_URL',
] as const;

requiredEnvVars.forEach((envVar) => {
  if (!process.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
});
```

### ビルド時最適化
```typescript
// 条件付きコンパイル
if (process.env.NODE_ENV === 'production') {
  // 本番環境でのみ実行される処理
} else {
  // 開発環境での追加機能
}
```