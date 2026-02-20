---
title: "アーキテクチャ概要"
spec_id: "ARCH-README"
version: "0.1.0"
status: "accepted"
summary: "corun のアーキテクチャドキュメント群の入口。システム概要、データフロー、デプロイ、可観測性、セキュリティ等を含む。"
created: "2026-02-20"
updated: "2026-02-20"
authors:
	- name: "maintainer"
		email: ""
tags: ["architecture","design"]
schema_version: "1.0"
---

# アーキテクチャ

このディレクトリには `corun` の設計/運用に関するドキュメントをまとめています。各ファイルは次の観点を扱います。

- システム全体の概要: `system-overview.md`
- データの流れと依存関係: `data-flow.md`
- デプロイと運用手順: `deployment.md`
- 実行時の観測性とログ設計: `observability.md`
- 実行時ビュー（コンポーネントの振る舞い）: `runtime-view.md`
- セキュリティ方針: `security.md`

目的は設計者と運用担当が同じ理解を持ち、実装と運用が一貫することです。

## ADR と設計方針

- アーキテクチャ上の重要な決定（ログ形式、デプロイ方針、セキュリティ要件など）は ADR に記録し、`architecture` ドキュメントは該当する ADR を参照して実装や運用手順を記述してください。
- ADR がポリシーの真実の源泉 (source of truth) となるため、ドキュメント更新時は ADR と整合しているかを確認してください。
