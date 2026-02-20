---
title: "機能仕様テンプレート"
spec_id: "SPEC-TEMPLATE"
version: "0.1.0"
status: "accepted"
summary: "新しい機能仕様作成のテンプレート"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["template","spec"]
schema_version: "1.0"
---

# 機能名

- 基本情報（コマンド名、親コマンドなど）

## 概要

- 短い説明

## コマンド

- `corun <command> [flags] [args]` の使用法と例

### 使用例

```
corun xxx yyy zzz
```

## フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--flag | -f | string | - | xxx

### フラグの競合

- なし

## 引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | 文字列(複数指定可能)



## 入出力

- stdin/stdout/stderr の仕様と例

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

## 動作フロー

- 実行ステップの箇条書きまたは図

## エラーと終了コード

- 想定されるエラーと対応する終了コード

## テストケース

- 主要な単体/結合テストの一覧と期待結果

## 更新履歴

- YYYY-MM-DD: 説明
