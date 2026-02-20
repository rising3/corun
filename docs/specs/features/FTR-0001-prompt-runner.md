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

# リダイレクトでプロンプトを実行する(--promptと同じ結果になる)
corun run < リダイレクト
```

## フラグ

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--prompt | -p | string | - | プロンプト定義ファイル名を指定する
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

`--prompt`フラグで指定するファイルの内容。

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

1. フラグ/引数をパースする
    - `--prompt'フラグでファイルが指定されている場合は、プロンプト定義をパースする
    - 引数でプロンプトが指定されている場合は、プロンプト定義の形式に変換する
2. プロンプト定義で定義されているプロンプト順に繰り返し実行する
    - corunとcopilot cliのフラグのマッピングを行う
    - copilot cli: copilot 指定されたフラグ一式 -p prompt
      - 各プロンプト側に設定されているフラグが優先される 
3. 終了する

## エラーと終了コード

- 共通仕様に準拠する。

## テストケース

### 単体テスト

#### 引数・フラグのパース

| ID | テストケース | 入力 | 期待結果 |
| --- | --- | --- | --- |
| UT-01 | `--prompt` でファイルパスを指定できる | `run --prompt prompts.yml` | `CORUN_PROMPT_FILE=prompts.yml` がセットされる |
| UT-02 | `-p` 短縮形でファイルパスを指定できる | `run -p prompts.yml` | `CORUN_PROMPT_FILE=prompts.yml` がセットされる |
| UT-03 | `--model` でモデル名を指定できる | `run --model gpt-5-mini "hello"` | `CORUN_MODEL=gpt-5-mini` がセットされる |
| UT-04 | `--continue` が true にセットされる | `run --continue "hello"` | `CORUN_CONTINUE=true` がセットされる |
| UT-05 | `--no-ask-user` が true にセットされる | `run --no-ask-user "hello"` | `CORUN_NO_ASK_USER=true` がセットされる |
| UT-06 | `--log-dir` でディレクトリを指定できる | `run --log-dir ~/logs "hello"` | `CORUN_LOG_DIR=~/logs` がセットされる |
| UT-07 | `--log-level` でレベルを指定できる | `run --log-level debug "hello"` | `CORUN_LOG_LEVEL=debug` がセットされる |
| UT-08 | 引数なし・パイプなし・`--prompt`なし → 引数エラー | `run` (stdin は TTY) | 終了コード 3 (EXIT_USAGE)、エラーメッセージを stderr に出力 |
| UT-09 | 複数のプロンプト文字列を引数で受け取れる | `run "hello" "bye"` | `CORUN_ARGS=(hello bye)` がセットされる |

#### copilot CLI フラグマッピング

| ID | テストケース | corun フラグ | 生成される copilot CLI フラグ |
| --- | --- | --- | --- |
| UT-10 | `--model` をマッピングする | `--model gpt-5-mini` | `--model gpt-5-mini` が付与される |
| UT-11 | `--continue` をマッピングする | `--continue` | `--continue` が付与される |
| UT-12 | `--no-ask-user` をマッピングする | `--no-ask-user` | `--no-ask-user` が付与される |
| UT-13 | `--log-dir` をマッピングする | `--log-dir ~/logs` | `--log-dir ~/logs` が付与される |
| UT-14 | `--log-level` をマッピングする | `--log-level debug` | `--log-level debug` が付与される |
| UT-15 | `--model` 未指定時はデフォルト値 `gpt-5-mini` が使用される | (フラグなし) | `--model gpt-5-mini` が付与される |

#### プロンプト定義ファイルのパース

| ID | テストケース | 入力 | 期待結果 |
| --- | --- | --- | --- |
| UT-16 | 有効な YAML を正常にパースできる | `prompts.yml` (正常な YAML) | プロンプトリストが読み込まれる |
| UT-17 | 不正な YAML はエラーになる | `prompts.yml` (インデント不正) | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| UT-18 | `prompts` キーが空のとき警告してスキップする | `prompts: []` | 終了コード 0、「プロンプトが存在しない」を stderr に出力 |
| UT-19 | トップレベルの `continue` がグローバルデフォルトになる | `continue: true` | 各プロンプトで `--continue` が付与される |
| UT-20 | プロンプト個別の `continue` がグローバル設定を上書きする | グローバル `continue: false`、個別 `continue: true` | そのプロンプトのみ `--continue` が付与される |
| UT-21 | プロンプト個別の `no-ask-user` がグローバル設定を上書きする | グローバル `no-ask-user: false`、個別 `no-ask-user: true` | そのプロンプトのみ `--no-ask-user` が付与される |

---

### 結合テスト

#### 正常系

| ID | テストケース | コマンド | 期待結果 |
| --- | --- | --- | --- |
| IT-01 | 単一プロンプト文字列を実行できる | `corun run "hello"` | 終了コード 0、copilot CLI が `"hello"` で呼び出される |
| IT-02 | 複数プロンプトを順番に実行できる | `corun run "hello" "bye"` | 終了コード 0、`"hello"` → `"bye"` の順に copilot CLI が呼び出される |
| IT-03 | `--prompt` でファイルを読み込み実行できる | `corun run --prompt prompts.yml` | 終了コード 0、定義ファイルのプロンプトが順番に実行される |
| IT-04 | パイプ入力を受け取って実行できる | `echo "hello" \| corun run` | 終了コード 0、`"hello"` で copilot CLI が呼び出される |
| IT-05 | リダイレクト入力を受け取って実行できる | `corun run < prompts.txt` | 終了コード 0、入力内容で copilot CLI が呼び出される |
| IT-06 | `--continue` を付与して実行できる | `corun run --continue "hello" "bye"` | 終了コード 0、各呼び出しに `--continue` が付与される |
| IT-07 | `--model` を付与して実行できる | `corun run --model gpt-5-mini "hello"` | 終了コード 0、`--model gpt-5-mini` が付与される |
| IT-08 | stdout に正常な出力が出る | `corun run "hello"` | copilot CLI の出力が stdout に流れる |
| IT-09 | `--verbose` 付きで実行するとデバッグログが stderr に出る | `corun --verbose run "hello"` | stderr に `level=DEBUG` ログが出力される |

#### 異常系

| ID | テストケース | コマンド | 期待結果 |
| --- | --- | --- | --- |
| IT-10 | 引数・パイプ・`--prompt` がすべてない場合は使用方法エラー | `corun run` (stdin は TTY) | 終了コード 3 (EXIT_USAGE)、使用方法ヒントを stderr に出力 |
| IT-11 | 存在しない `--prompt` ファイルはエラーになる | `corun run --prompt not-exist.yml` | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| IT-12 | 不正な YAML ファイルはエラーになる | `corun run --prompt invalid.yml` | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| IT-13 | copilot CLI が失敗したとき `on_failure: abort` で中断する | プロンプト1失敗、`on_failure: abort` | 終了コード 1、プロンプト2以降は実行されない |
| IT-14 | retries 設定に従って再試行する | copilot CLI が1回失敗、`retries.count: 2` | `delay_seconds` 待機後に最大2回再試行する |
| IT-15 | SIGINT を送信すると終了コード 2 で終了する | `corun run "hello"` 実行中に Ctrl-C | 終了コード 2 (EXIT_CANCEL) |



## 参考情報

なし

## 更新履歴

- 2026-02-21: 作成
