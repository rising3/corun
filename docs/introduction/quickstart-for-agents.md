---
title: "Quickstart — Agents"
spec_id: "INTRO-QUICKSTART-AGENTS"
version: "0.1.0"
status: "accepted"
summary: "エージェント/開発者向けの最短導入手順と基本コマンド例"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
tags: ["quickstart","agents"]
schema_version: "1.0"
---

# Quickstart（AIコーディングエージェント向け）

このドキュメントはAIコーディングエージェントがプロジェクトに参加し、仕様理解から実装・テストまでを行うための導入手順です。

## 1. ワークスペース構造の把握

まず、プロジェクトの構造を理解してください：

- `docs/` — 全ドキュメント（仕様、ADR、アーキテクチャ）
- `bin/` — 実行可能スクリプト
- `src/` — ソースコード実装
- `tests/` — テストコード
- `Makefile` — ビルド・テスト・Lint タスク

## 2. ドキュメント参照の優先順位（必須）

実装や変更を行う前に、必ず以下の順で確認してください：

1. **`docs/adr/`** — 設計判断の真実の源泉。変更がポリシーに影響しないか確認
2. **`docs/specs/features/`** — 機能仕様。実装すべき内容とフォーマットを理解
3. **`docs/architecture/`** — システム構造と運用フロー
4. **関連する README** — 各ディレクトリの目次と運用ルール

### 参照手順の例

```bash
# 1. 関連する ADR を検索
grep -R "<対象機能キーワード>" docs/adr/ || true

# 2. 対応する仕様ファイルを確認
ls docs/specs/features/FTR-*.md

# 3. frontmatter の status と related を確認
yq e '.status, .related' docs/specs/features/FTR-0001-task-runner.md
```

## 3. 実装前の確認事項

- 該当する仕様ファイルの `status` (draft/accepted/deprecated 等) を確認
- `related` フィールドで関連 ADR を確認し、設計方針との整合性を確認
- テストケースの存在を確認（`tests/` 配下）
- frontmatter の必須フィールド（`title`, `spec_id`, `version`, `status`, `summary`, `created`, `updated`, `authors`）が揃っているか確認

## 4. 実装と検証のフロー

```bash
# 1. 既存テストを実行して現状を確認
make test

# 2. 静的解析で問題がないか確認
make lint

# 3. 実装後、再度テストを実行して影響範囲を確認
make test

# 4. ビルドを確認
make build

# 5. （任意）結合テストを実行
make integration_test
```

## 5. 仕様追加・変更時の必須作業

### A. 影響評価

- 変更がポリシーや運用に影響するか判定
- 影響がある場合は ADR の作成/更新を検討

### B. ADR 作成（必要な場合）

```bash
# ADR テンプレートをコピー
cp docs/adr/template.md docs/adr/ADR-00XX-<title>.md

# frontmatter を編集: status: draft, date, authors を設定
# 背景・決定・理由・代替案・影響を記載
```

### C. 仕様ファイルの更新

```bash
# 仕様テンプレートをコピー
cp docs/specs/features/template.md docs/specs/features/FTR-00XX-<feature>.md

# frontmatter を埋める（status: draft で開始）
# related に該当 ADR を追加
# 更新履歴をファイル末尾に追記
```

### D. ドキュメント目次の更新

- `docs/specs/README.md` や `docs/adr/README.md` のテーブルに新規ファイルを追加
- ステータス列を反映

### E. 変更の検証

- frontmatter の `updated` フィールドを現在日時に更新
- `make test` と `make lint` を実行
- 変更が期待通りか確認

## 6. トラブルシューティング

| 問題 | 確認事項 | 対処 |
|---|---|---|
| `make test` が失敗 | stderr を確認し、期待値と実際の挙動の差分を特定 | テストケースまたは実装を修正 |
| 仕様が不明確 | 該当 ADR または仕様ファイルの `summary` を確認 | 仕様作成者に Issue で問い合わせ |
| ドキュメントの矛盾 | ADR を優先し、他ドキュメントは ADR を参照する形に修正 | ADR に整合する形で他ドキュメントを更新 |
| frontmatter が不足 | `yq` で必須フィールドをチェック | テンプレートを参照して追加 |

## 7. 推奨運用ルール

- ADR を設計方針の単一の真実の源泉（source of truth）とする
- 仕様ファイルは必ず YAML frontmatter を持つ
- 変更は小さく、1 PR = 1 仕様変更（または 1 ADR）を原則とする
- テストを必ず追加し、`make test` が成功することを確認してから PR を作成する

## 8. 次のステップ

- 実装を行う場合は `docs/specs/features/` の該当仕様を精読してください
- 設計判断を行う場合は `docs/adr/template.md` を参照して ADR を作成してください
- アーキテクチャを理解したい場合は `docs/architecture/README.md` から開始してください
