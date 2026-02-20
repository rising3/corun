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

## 仕様追加／変更フロー（簡易ガイド）

目的: 仕様の追加や変更でドキュメントの齟齬が起きないよう、参照順と実施事項を統一する。

1) まず確認すべき順序

- `docs/adr/` (ADR): ポリシーや設計方針に影響があるか確認する。ADR がある場合は優先して参照。
- `docs/specs/features/template.md`: 仕様の記載フォーマットを確認する。
- 該当する仕様ファイル (`docs/specs/features/*.md`): 現状と `status` を確認する。
- `docs/architecture/*`: 実装や運用フローに影響があるか確認する。
- `docs/* README`: 目次や引用の更新が必要か確認する。

2) 実施チェックリスト（順序）

- 影響評価: 変更がポリシー/運用に影響するかを判定し、影響がある場合は ADR を作成/更新する。
- ADR（必要時）: `docs/adr/template.md` をコピーし `status: draft` で作成→PRで議論→承認後 `accepted` に更新。
- 仕様更新: `specs` 側は `template.md` をコピーして `status: draft` で編集、`related` に該当 ADR を記載。
- アーキテクチャ更新: 実装/運用手順が変わる場合は `docs/architecture/*` に追記し、該当 ADR を参照。
- 目次/README 更新: `docs/specs/README.md` / `docs/adr/README.md` 等の一覧を更新。
- テスト/CI: 必要なテストを追加・実行し、frontmatter の必須フィールドを CI で検証する（推奨）。
- PR 作成: 変更点要約・関連 ADR へのリンク・テスト結果・影響範囲を明記してレビューを依頼。
- マージ後: 必要に応じて `status` を更新し、CHANGELOG/リリースノートを記載。

3) 推奨運用ルール

- ADR を設計方針の単一の真実の源泉（source of truth）とする。ドキュメントは ADR を参照する形にする。
- 仕様ファイルは必ず YAML frontmatter を持ち、`status` は `draft|accepted|rejected|deprecated|removed` のいずれかとする。
- 可能な限り 1 PR = 1 仕様変更（または 1 ADR）で小さく分ける。

4) 簡易チェックコマンド（ローカル）

```bash
# ADR を検索して影響範囲を確認
grep -R "<キーワード>" docs || true

# frontmatter の status を確認
yq e '.status' docs/specs/features/*.md

# README/参照の整合性を簡易検査
grep -R "features/" docs | sed -n '1,200p'
```

5) 自動化提案（任意）

- CI で frontmatter-lint（`yq`/`jq`）を実行して必須フィールドを検証する。
- `scripts/generate_adr_index.sh` を作成して `docs/adr/README.md` のテーブルを自動生成する。
- PR 作成時に関連 ADR が記載されているかをチェックする小スクリプトを導入する。

## 貢献と問い合わせ

- 不明点や提案は Issue を立ててください。
- ドキュメント改善のプルリクエストは歓迎します。

