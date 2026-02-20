---
title: "共通仕様"
spec_id: "SPEC-COMMON"
version: "0.2.0"
status: "accepted"
summary: "corun 全体で共有する基本仕様（終了コード、グローバルフラグ、入出力、コマンド階層など）"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["common", "cli", "corun"]
command_root: "corun"
related:
  - FTR-0001-task-runner.md
  - FTR-0002-task-gen.md
  - template.md
schema_version: "1.0"
---

# 共通仕様

開発するCLIの全コマンドに共通する仕様を定義する。

## 1.基本情報

- コマンド名: corun

## 2.終了コード

コード | 名称 | 説明
--- | --- | ---
0 | 正常終了 | コマンドが成功した
1 | 一般エラー | 処理中にエラーが発生した
2 | キャンセル | ユーザーが処理をキャンセルした
3 | 使用方法エラー | 引数・フラグの指定が不正

## 3.グローバルフラグ

全コマンドで使用可能なフラグ:

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--help | -h | bool | false | ヘルプを表示
--verbose | - | bool | false | 詳細なログ出力を有効化

ルートコマンドのみで使用可能なフラグ:

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--version | -v | bool | false | バージョンを表示

### フラグの優先順位

```md
1. コマンドライン引数(最優先)
2. 環境変数
3. デフォルト値 
```

> **Note**: 設定ファイルはサポートしないため優先順位チェーンに含まない（6. 設定ファイル 参照）。

### フラグの重複指定

同一フラグを複数回指定した場合、最後の指定を有効にする（last-wins）。

### --verbose ログ出力形式

`--verbose` を有効にした場合、以下の構造化形式で stderr に出力する:

```
timestamp=<ISO8601> level=DEBUG msg=<メッセージ>
```

例:

```
timestamp=2026-02-20T12:00:00Z level=DEBUG msg=loading task file
```

## 4.入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

### stdin の挙動

stdin がパイプでもなく TTY でもない（クローズ済み）場合、コマンドはハングせず正常終了（終了コード 0）する。stdin を使用しないコマンドは stdin の状態を無視して続行する。

### エラーメッセージ形式

#### ルートコマンドのエラー形式

```
Error: <エラーメッセージ>

Usage: <コマンド名> <command> [flags]

Run '<コマンド名> <command> --help' for more information.
```

#### ファイル操作系サブコマンドのエラー形式

ファイル操作を行うサブコマンドでは、GNU coreutils互換のエラー形式を使用:

```
<コマンド名>: <filename>: <error description> 
```

## 5. コマンド階層

```
<コマンド名>
├── run     # 実行: タスクを実行する
└── gen     # 生成: テンプレートを生成する
```

## 6. 設定ファイル

サポートしない。

## 7. シェル補完

サポートしない。

## 8. ヘルプ出力形式

```text
<コマンド名> - <短い説明>

DESCRIPTION:
  <詳細な説明>

USAGE:
  <コマンド名> <command> [flags] [arguments]

AVAILABLE COMMANDS:
  <サブコマンド一覧>

EXAMPLES:
  <使用例>

LEARN MORE:
  Use `<コマンド名> <command> --help` for more information about a command.
```

## 9. バージョン情報

### バージョン形式

Semantic Versioning に準拠:

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

### 出力形式

```
<コマンド名> version <バージョン番号>
```

## 10. 参考情報

- [Semantic Versioning](https://semver.org/)
