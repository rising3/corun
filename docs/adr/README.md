---
title: "ADR (Architecture Decision Records) 目次"
spec_id: "ADR-INDEX"
version: "0.1.0"
status: "accepted"
summary: "このプロジェクトで記録された主要な設計判断の一覧"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
tags: ["adr","decisions"]
schema_version: "1.0"
---

# ADR

このディレクトリは設計判断（ADR）を記録します。各 ADR は決定の背景、選択肢、採択理由、影響を簡潔に記載します。

# ADR一覧

| ADR ファイル | タイトル | 説明 | ステータス |
|---|---|---|---:|
| `ADR-0001-ci.md` | CI 実行フローとツール選定 | GitHub Actions と `make` を用いた CI ワークフロー | accepted |
| `ADR-0002-versioning.md` | バージョニング方式 (SemVer) | Semantic Versioning を採用 | accepted |
| `ADR-0003-spec-frontmatter.md` | 仕様ファイルの frontmatter スキーマ | 仕様ファイルに必要な YAML frontmatter スキーマを定義 | accepted |
| `ADR-0004-logging.md` | ログ形式と必須フィールド | 構造化 JSON ログと必須フィールドの定義 | accepted |
| `ADR-0005-security.md` | 秘密情報の取り扱いと権限方針 | シークレット管理と最小権限の原則 | accepted |

新しい ADR を追加する場合は `template.md` をコピーし、番号をインクリメントしてください。

## ADR の運用方針（要点）

- ADR は重要な設計判断とポリシーの「真実の源泉 (source of truth)」です。他ドキュメント（仕様、アーキテクチャ文書、README 等）は該当 ADR を参照してください。
- ドキュメントの更新が設計や運用ポリシーに影響する場合、関連 ADR を更新または新規作成して整合性を保ってください。
