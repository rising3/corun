---
title: "ADR-0003: 仕様ファイルの frontmatter スキーマ"
date: "2026-02-20"
status: "accepted"
authors:
  - name: "maintainer"
    email: ""
tags: ["specs","metadata"]
---
## 概要

仕様ファイルに一貫したメタデータスキーマを定義し、ドキュメント生成や検索、CI チェックを容易にする。

## コンテキスト

仕様ファイルは機械および人間双方で参照され、メタデータの整合性が重要である。複数のフォーマットや場所に分散したメタ情報は運用コスト増を招く。

## 決定

すべての仕様ファイルは先頭に YAML frontmatter を配置し、少なくとも次のフィールドを含める:

- `title`, `spec_id`, `version`, `status`, `summary`, `created`, `updated`, `authors`。

追加で `tags`, `related`, `schema_version`, `command` 等を許容する。

### status

仕様ファイルが取りうる代表的な状態とその意味:

- `draft`: 作成中またはレビュー待ちの状態。未公開・未実装。
- `accepted`: レビューを通過し採用された状態。実装・公開を前提とする。
- `rejected`: 検討したが採用しないと決定した状態。
- `deprecated`: 以前は採用されていたが非推奨となった状態。代替仕様を `related` で参照すること。
- `removed`: ドキュメントや仕様から削除された状態。

運用上の推奨事項:

- `status` フィールドは必須とし、初期値は `draft` を用いる。
- `status` を変更する場合は変更履歴（`updated` フィールド）とコミット/ADR の参照を残すこと。
- CI の lint チェックでは `status` が許容値のいずれかであることを検証することを推奨する。

## 決定の理由（Rationale）

- Frontmatter を用いることで1ファイル完結のメタデータ表現が可能となり、静的解析や自動生成ツールで扱いやすくなる。

## 影響とフォローアップ

- 新規仕様は `template.md` をコピーして frontmatter を更新するワークフローを推奨。
- 将来的に frontmatter の lint ルール（例: 必須フィールドチェック）を CI に追加すること。

## 代替案

- メタデータを別ファイル（manifest）で管理する案があるが、運用と参照の煩雑さを避けるため採用しない。

## 関連資料 / 参照

- docs/specs/features/template.md

## ステータス履歴

- 2026-02-20: draft
- 2026-02-20: accepted
