---
title: "仕様ドキュメントインデックス"
spec_id: "SPEC-INDEX"
version: "0.1.0"
status: "accepted"
summary: "プロジェクト全体の仕様ドキュメント群の目次。現状は `features` を含む。将来的に `db` や `api` などのカテゴリを追加可能。"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["specs","index"]
schema_version: "1.0"
---

# 仕様ドキュメント

このディレクトリは `corun` の仕様ドキュメントのトップレベルインデックスです。
各サブディレクトリはカテゴリ（例: `features`、`db`、`api`）ごとに分かれており、個別の仕様ファイルを格納します。

## カテゴリ

| カテゴリ | パス | 説明 |
|---|---:|---|
| 機能仕様 | `features/` | CLI 機能ごとの仕様（コマンド、フラグ、入出力、テストケース等） |

### 将来的に追加される可能性のあるカテゴリ例

- `ui/` — 画面仕様（画面構成／ワイヤーフレーム／操作フロー）
- `db/` — データベース設計・マイグレーション仕様
- `api/` — HTTP/API 仕様（エンドポイント、リクエスト／レスポンススキーマ、認証）

## 運用ルール（要点）

- 各カテゴリ配下の README（例: `features/README.md`）をそのカテゴリの目次／方針とする。
- 各仕様ファイルは先頭に YAML frontmatter を置き、少なくとも `title/spec_id/version/status/summary/created/updated/authors` を含めること。
- 新しい仕様は `template.md` をコピーして `FTR-xxxx-xxx.md` のような識別可能なファイル名を付ける。
- 仕様変更はファイル末尾に `更新履歴` を追記して履歴を残す。

## 参照

- 機能仕様入口: `features/README.md`
- 共通仕様: `features/common.md`
