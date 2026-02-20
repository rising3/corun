---
title: "ADR-0002: バージョニング方式 (SemVer)"
date: "2026-02-20"
status: "accepted"
authors:
  - name: "maintainer"
    email: ""
tags: ["versioning"]
---
## 概要

公開 API とパッケージリリースの互換性を明確にするため、標準化されたバージョニングルールを採用する。

## コンテキスト

リリースの整合性、依存関係管理、互換性の判断基準をチームで統一する必要がある。

## 決定

Semantic Versioning (SemVer) を採用する（MAJOR.MINOR.PATCH）。

## 決定の理由（Rationale）

- SemVer は広く採用されており、互換性に関する期待値を明確に伝えられる。
- 自動リリースやパッケージ管理ツールと相性が良い。

## 影響とフォローアップ

- リリース手順と `CHANGELOG.md` の整備が必要。
- リリース担当は適切にタグを付与し、ドキュメントを更新すること。

## 代替案

- CalVer（年月ベース）を採る案があるが、API 互換性の明確化という要件に対して SemVer の方が適している。

## 関連資料 / 参照

- https://semver.org/

## ステータス履歴

- 2026-02-20: accepted
- 2026-02-20: draft