---
title: "run サブコマンド仕様"
spec_id: "FTR-0001"
version: "0.1.0"
status: "accepted"
summary: "タスクを実行するサブコマンドの仕様"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
	email: ""
reviewers: []
tags: ["run","cli","task"]
command: "corun run"
related:
	- common.md
schema_version: "1.0"
---

# run サブコマンド仕様

## 1.基本情報

- コマンド名: run
- 親コマンド: <コマンド名>

## 2.概要

タスクを実行する。

## 3.構文

```
<コマンド名> run [flags] [string ...]
```

## 4.フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--task | -t | string | false | タスク定義ファイル名を指定する
--continue | - | bool | true | 
--model | - | string | なし | モデル名を指定する
--no-ask-user | - | bool | false | Disable the ask_user tool (agent works autonomously without asking questions)
--log-dir | - | string | あり | a Set log file directory (default: ~/.copilot/logs/ )
--log-level | - | string | あり | Set the log level (choices: "none", "error", "warning", "info", "debug", "all", "default")

### フラグの競合

- なし

## 5.引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | プロンプト文字列(複数指定可能)

引数が指定されていない場合、以下のいずれかの入力がなければ引数エラーとする
- パイプ入力がある
- `--task` フラグが指定されている

## 6.入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

## 7. 終了コード

## 8. 使用例

## 9. タスク定義

## 10. 参考情報

- [Semantic Versioning](https://semver.org/)
# run サブコマンド仕様

## 1.基本情報

- コマンド名: run
- 親コマンド: <コマンド名>

## 2.概要

タスクを実行する。

## 3.構文

```
<コマンド名> run [flags] [string ...]
```

## 4.フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--task | -t | string | false | タスク定義ファイル名を指定する
--continue | - | bool | true | 
--model | - | string | なし | モデル名を指定する
--no-ask-user | - | bool | false | Disable the ask_user tool (agent works autonomously without asking questions)
--log-dir | - | string | あり | a Set log file directory (default: ~/.copilot/logs/ )
--log-level | - | string | あり | Set the log level (choices: "none", "error", "warning", "info", "debug", "all", "default")

### フラグの競合

- なし

## 5.引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | プロンプト文字列(複数指定可能)

## 6.入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

## 7. 終了コード

## 8. 使用例


## 9. タスク定義


## 10. 参考情報

- [Semantic Versioning](https://semver.org/)
