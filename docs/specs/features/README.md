---
title: "機能仕様 (Features) Index"
spec_id: "SPEC-FEATURES-INDEX"
version: "0.1.0"
status: "accepted"
summary: "機能仕様群の入口と方針"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["features","specs"]
schema_version: "1.0"
---

# 機能仕様 (Features)

このディレクトリは `corun` の個別機能ごとの仕様をまとめた場所です。
設計者・実装者・テスト担当が共通理解を持てるよう、各機能ごとに以下の情報を記載してください。

主なファイル:

| ファイル | 説明 |
|---|---|
| `common.md` | 全体の共通仕様（終了コード、グローバルフラグ、入出力、コマンド階層など） |
| `FTR-0001-prompt-runner.md` | プロンプト実行（`run`）機能の仕様 |
| `FTR-0002-prompt-definition-gen.md` | プロンプト定義生成（`gen`）機能の仕様 |
| `template.md` | 新しい機能仕様作成のテンプレート |

ドキュメントの方針:

- 日本語で記載する。
- コマンドの使い方、入力／出力例、エラーケース、想定される終了コードを明確に示す。
- 変更があった場合はファイル末尾に「更新履歴」を追記する。

新しい機能仕様の追加手順:

1. `template.md` をコピーして新しいファイル名（例: `FTR-0003-xxx.md`）で保存する。
2. 機能の概要、コマンド、フラグ、入出力、動作フロー、テストケースを記入する。
3. ドキュメントをレビューして問題がなければプルリクエストを作成する。

テンプレート参照: `template.md`

例: `FTR-0001-prompt-runner.md` を参照して `run` コマンドの期待動作やテストケースを確認してください。

---

この README は機能仕様群の入口です。個別の詳細は各ファイルを開いて参照してください。

