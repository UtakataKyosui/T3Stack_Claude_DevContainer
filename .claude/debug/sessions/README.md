# セッション別ログディレクトリ

このディレクトリには、Claude Codeでの開発セッション中に発生した一時的なデバッグ情報を保存します。

## ファイル命名規則

```
session_YYYYMMDD_HHMM_[issue-description].md
```

例：
- `session_20250621_1430_tRPC-connection-error.md`
- `session_20250621_1500_passkey-authentication-debug.md`

## 内容

- セッション中に発生した問題
- 試行した解決方法
- 一時的な回避策
- 参考にしたリソース

## 管理

- セッション終了時に重要な問題は `debug-log.md` に移行
- 解決済みの問題は `archive/` ディレクトリに移動
- 一時的な問題は定期的に削除