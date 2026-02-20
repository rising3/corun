---
title: "Documentation Index"
spec_id: "DOCS-README"
version: "0.1.0"
status: "accepted"
summary: "リポジトリ内のドキュメント群の概要と運用ルール"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
tags: ["docs","index"]
schema_version: "1.0"
---

# ドキュメント インデックス

このディレクトリはプロジェクトのドキュメント群のインデックスです。
目的は設計者・実装者・運用担当が同じ情報にアクセスできることです。

## 構成概要

- `introduction/` : 導入、概要、クイックスタート
- `specs/` : 仕様ドキュメント（機能仕様は `specs/features/`）
- `architecture/` : アーキテクチャ設計、データフロー、運用方針
- `adr/` : Architectural Decision Records（設計判断の記録）

## 主要ドキュメント

- `introduction/README.md` — プロジェクトの導入と参照順
- `specs/README.md` — 仕様ドキュメントの目次と運用ルール
- `architecture/README.md` — アーキテクチャ文書の入口
- `adr/README.md` — ADR 一覧と追加手順

## 運用ルール（要点）

- すべての仕様ファイルは先頭に YAML frontmatter を置く（必須フィールド: `title`, `spec_id`, `version`, `status`, `summary`, `created`, `updated`, `authors`）。
- 仕様の追加は `specs/features/template.md` をコピーして新しい `FTR-xxxx-*.md` を作成する。
- ポリシーや重要な設計判断は ADR として `docs/adr/` に記録する（ADR が真実の源泉となる）。
- ドキュメント内のファイル参照は相対パスで行い、参照先を更新した場合はリンクを修正する。

### ADR を真実の源泉にする方針

- 重要な設計判断や運用ポリシーは `docs/adr/` に ADR として記録し、ADR の内容を他ドキュメントが参照する形を原則とします。
- ドキュメントを更新する際に設計方針やポリシーに変更が入る場合は、まず該当 ADR を更新または新規 ADR を作成してください。ADR と矛盾する変更は避けてください。

## 変更手順

1. ドキュメントを編集したら、プルリクエストで変更を提出してください。
2. 変更が仕様やポリシーに影響する場合は該当 ADR を更新または新規作成してください。

## 貢献と問い合わせ

- 不明点や提案は Issue を立ててください。
- ドキュメント改善のプルリクエストは歓迎します。

