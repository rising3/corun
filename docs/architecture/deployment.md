---
title: "デプロイと運用"
spec_id: "ARCH-DEPLOYMENT"
version: "0.1.0"
status: "accepted"
summary: "ローカル開発および CI/本番へのデプロイ方針と手順の概要"
created: "2026-02-20"
updated: "2026-02-20"
authors:
	- name: "maintainer"
		email: ""
tags: ["architecture","deployment"]
schema_version: "1.0"
---

# デプロイと運用

対象:

- ローカル開発環境での検証
- CI（GitHub Actions）上でのテスト・パッケージング
- 必要に応じたアーティファクトの配布

ローカル手順（開発者向け）:

```bash
make lint
make test
make build
```

CI パイプライン（推奨フロー）:

1. `actions/checkout@v3`
2. 依存ツールのインストール（shellcheck, bats, shfmt 等）
3. `make lint` → `make test` → `make build`
4. アーティファクトのアップロード／リリース作業

バージョニングとリリース:

- SemVer を採用する。リリースはタグ付けと CHANGELOG を伴う。

ロールバック:

- 本質的に CLI 実行環境ではロールバックはバージョン切替で対応。
