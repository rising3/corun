---
title: "可観測性"
spec_id: "ARCH-OBSERVABILITY"
version: "0.1.0"
status: "accepted"
summary: "ログ、メトリクス、トレースの方針と実装ガイドライン"
created: "2026-02-20"
updated: "2026-02-20"
authors:
	- name: "maintainer"
		email: ""
tags: ["architecture","observability"]
schema_version: "1.0"
---

# 可観測性

ログ設計:

- 標準出力（stdout）は主要な結果を出力し、機械で解析しやすい形式（JSON など）を推奨する。
- 標準エラー（stderr）はエラーと診断情報を含める。
- 実行ログには `timestamp`, `spec_id`, `version`, `command`, `exit_code` を含める。

メトリクス:

- 実行回数、成功率、平均実行時間、失敗原因の分類を収集する。
- CI 実行における失敗率を監視し、基準値を超えたらアラートを発報する。

トレース:

- 必要に応じて分散トレーシングを導入する（外部サービス呼び出しが増えた場合）。

ログ保存と検索:

- ログはローカルに保存するとともに、CI/運用環境では中央ログストレージへ集約することを推奨する。
