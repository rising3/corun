---
title: "run サブコマンド仕様"
spec_id: "FTR-0001"
version: "0.1.0"
status: "accepted"
summary: "複数のプロンプトを実行するサブコマンドの仕様"
created: "2026-02-20"
updated: "2026-02-20"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["run","cli","prompt"]
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

複数のプロンプトを実行する。

## 3.構文

```
<コマンド名> run [flags] [string ...]
```

## 4.フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--prompt | -p | string | false | プロンプト定義ファイル名を指定する
--model | - | string | gpt-5-mini | モデル名を指定する
--continue | - | bool | true | 
--no-ask-user | - | bool | false | Disable the ask_user tool (agent works autonomously without asking questions)
--log-dir | - | string | copilot-cli準拠 | a Set log file directory (default: ~/.copilot/logs/ )
--log-level | - | string | copilot-cli準拠 | Set the log level (choices: "none", "error", "warning", "info", "debug", "all", "default")

### corunとcopilot cliのフラグのマッピング

以下のcorunのフラグが指定されている場合、copilot cliを実行する際のフラグを追加する。

corunフラグ | フラグの値 | copilot cliのフラグ
--- | --- | ---
-model | モデル\<model\>の指定がある場合 | --model \<model\>
--continue | trueの場合 | --continue
--no-ask-user | trueの場合 | --no-ask-user
--log-dir | ディレクトリ\<\dir>の指定がある場合 | --log-dir \<dir\>
--log-level | ログレベル\<\level>の指定がある場合 | --log-level \<level\>

### フラグの競合

- なし

## 5.引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | プロンプト文字列(複数指定可能)

引数が指定されていない場合、以下のいずれかの入力がなければ引数エラーとする
- パイプ入力がある
- `--prompt` フラグが指定されている

## 6.入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

## 7. 終了コード

共通仕様に準拠する。


## 10. 参考情報

なし




# run サブコマンド仕様

基本情報:
- コマンド名: run
- 親コマンド: <コマンド名>

## 概要

- 複数のプロンプトを実行する。

## コマンド

```
<コマンド名> run [flags] [string ...]
```
### 使用例

```bash

# プロンプト定義を読み込み実行する
corun run --prompt prompts.yml

# 同じセッションで複数のプロンプトを実行する
corun run --continue "hello" "How are you?" "Good bye"

# モデルを指定してプロンプトを実行する
corun run --model gpt-5-mini "hello"

# パイプでプロンプトを実行する
echo "hello" | corun run

# リダイレクトでプロンプトを実行する
corun run < リダイレクト
```

## フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--prompt | -p | string | false | プロンプト定義ファイル名を指定する
--model | - | string | gpt-5-mini | モデル名を指定する
--continue | - | bool | true | 
--no-ask-user | - | bool | false | Disable the ask_user tool (agent works autonomously without asking questions)
--log-dir | - | string | copilot-cli準拠 | a Set log file directory (default: ~/.copilot/logs/ )
--log-level | - | string | copilot-cli準拠 | Set the log level (choices: "none", "error", "warning", "info", "debug", "all", "default")

### corunとcopilot cliのフラグのマッピング

以下のcorunのフラグが指定されている場合、copilot cliを実行する際のフラグを追加する。

corunフラグ | フラグの値 | copilot cliのフラグ
--- | --- | ---
-model | モデル\<model\>の指定がある場合 | --model \<model\>
--continue | trueの場合 | --continue
--no-ask-user | trueの場合 | --no-ask-user
--log-dir | ディレクトリ\<\dir>の指定がある場合 | --log-dir \<dir\>
--log-level | ログレベル\<\level>の指定がある場合 | --log-level \<level\>

### フラグの競合

- なし

### プロンプト定義

```yaml
resume: session-id
log-dir: ~/test-log
log-level: debug
continue: true
no-ask-user: true
prompts:
	- id: hello
		title: "こんにちは"
		description: "挨拶する"
		prompt: |
			こんにちは
			暑いですね
		continue: true
		no-ask-user: true
		env:
			TZ: "Asia/Tokyo"
		timeout_seconds: 3600
		retries:
			count: 2
			delay_seconds: 60
			backoff: "linear"
		on_failure:
			action: "abort"
```

## 引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | プロンプト文字列(複数指定可能)

引数が指定されていない場合、以下のいずれかの入力がなければ引数エラーとする
- パイプ入力がある
- `--prompt` フラグが指定されている

## 入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力
stdout | 正常な出力結果
stderr | エラーメッセージ、ログ、進捗表示

## 動作フロー

- 実行ステップの箇条書きまたは図

## エラーと終了コード

- 共通仕様に準拠する。

## テストケース

- 主要な単体/結合テストの一覧と期待結果

## 参考情報

なし

## 更新履歴

- 2026-02-21: accepted
- 2026-02-21: draft
