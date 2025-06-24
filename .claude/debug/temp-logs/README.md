# 一時ログディレクトリ

作業中の一時的なファイルやメモを保存するディレクトリです。

## 使用目的

- 作業中の思考メモ
- 試行錯誤の記録
- コードスニペットの一時保存
- エラーメッセージのコピー
- 参考URLやリソースのメモ

## ファイル例

```
work_YYYYMMDD_[description].md
temp_[feature-name]_notes.md
error_logs_YYYYMMDD.txt
code_snippets_[purpose].md
```

## 管理ポリシー

- **自動削除**: 作業完了後は不要ファイルを削除
- **重要な内容の移行**: 有用な情報は適切なファイルに移行
  - 解決策 → `debug-log.md`
  - パターン → `common-patterns.md`
  - 知見 → `project-knowledge.md`
- **クリーンアップ**: 週1回程度の整理を推奨

## .gitignore 対象

このディレクトリの内容は基本的に個人的なメモのため、必要に応じて `.gitignore` に追加を検討してください。