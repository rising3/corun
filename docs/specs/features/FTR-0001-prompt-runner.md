---
title: "run サブコマンド仕様"
spec_id: "FTR-0001"
version: "0.1.0"
status: "accepted"
summary: "複数のプロンプトを実行するサブコマンドの仕様"
created: "2026-02-20"
updated: "2026-02-21"
authors:
  - name: "maintainer"
    email: ""
reviewers: []
tags: ["run","cli","prompt"]
command: "corun run"
related:
  - common.md
  - copilot-cli-help.txt
schema_version: "1.0"
---

# run サブコマンド仕様

基本情報:
- コマンド名: run
- 親コマンド: corun

## 概要

- 複数のプロンプトを実行する。

## コマンド

```
corun run [flags] [string ...]
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

グローバルフラグ (`--help/-h`, `--verbose`) は全コマンド共通（共通仕様参照）。以下は `run` サブコマンド固有のフラグ。

フラグ | 短縮形 | 型 | デフォルト | 説明
--- | --- | --- | --- | ---
--prompt | -p | string | - | プロンプト定義ファイルのパスを指定する
--model | - | string | copilot-cli 準拠 | 使用するモデル名を指定する（省略時は copilot-cli のデフォルトモデルに委ねる）
--continue | - | bool | false | 前回のセッションを継続する
--no-ask-user | - | bool | false | ユーザーへの問い合わせを無効化し、エージェントが自律的に動作する
--log-dir | - | string | copilot-cli 準拠 | ログファイルの出力先ディレクトリを指定する (デフォルト: `~/.copilot/logs/`)
--log-level | - | string | copilot-cli 準拠 | ログレベルを指定する。値の検証は行わず copilot-cli に透過的に渡す（エラー処理は copilot-cli に委ねる）

### フラグの優先順位

共通仕様に準拠する（コマンドライン引数 > 環境変数 > デフォルト値）。

### フラグの重複指定

共通仕様に準拠する（last-wins：同一フラグを複数回指定した場合、最後の指定が有効になる）。

### corunとcopilot cliのフラグのマッピング

以下のcorunのフラグが指定されている場合、copilot cliを実行する際のフラグを追加する。

corunフラグ | フラグの値 | copilot cliのフラグ
--- | --- | ---
--model | モデル `<model>` の指定がある場合 | --model `<model>`
--continue | `true` の場合 | --continue（1番目のプロンプト呼び出しを含む全プロンプトに付与する。ただし `resume` と同時指定時は1回目のプロンプト実行では `--continue` を渡さない）
--no-ask-user | `true` の場合 | --no-ask-user
--log-dir | ディレクトリ `<dir>` の指定がある場合 | --log-dir `<dir>`
--log-level | ログレベル `<level>` の指定がある場合 | --log-level `<level>`

### プロンプト定義ファイルのフィールドマッピング

プロンプト定義 YAML のトップレベルフィールドと copilot CLI フラグの対応：

YAML フィールド | copilot cli フラグ | 備考
--- | --- | ---
`text` | `-p <text>` | プロンプト本文。省略不可
`resume` | --resume `<session-id>` | 省略時は渡さない
`log-dir` | --log-dir `<dir>` | 省略時は copilot-cli デフォルト
`log-level` | --log-level `<level>` | 省略時は copilot-cli デフォルト
`continue` | --continue | `true` の場合のみ付与
`no-ask-user` | --no-ask-user | `true` の場合のみ付与

### フラグの競合

- `resume`（YAML フィールド）と `--continue` フラグを同時に指定した場合:
  - **1回目のプロンプト実行**: `--resume <session-id>` のみを付与し、`--continue` は渡さない（`resume` 優先）
  - **2回目以降のプロンプト実行**: `--resume` は渡さない。`--continue` が有効な場合のみ `--continue` を付与する

### プロンプト定義

`--prompt`フラグで指定するファイルの内容。

```yaml
resume: session-id       # 再開するセッションID (省略可。指定時は copilot CLI の --resume フラグとして渡す)
log-dir: ~/test-log      # ログ出力先 (省略可。省略時は copilot-cli のデフォルト)
log-level: debug         # ログレベル (省略可)
continue: true           # グローバルデフォルト: セッション継続
no-ask-user: true        # グローバルデフォルト: ユーザー問い合わせ無効
prompts:
  - id: hello
    title: "こんにちは"
    description: "挨拶する"
    text: |
      こんにちは
      暑いですね
    continue: true         # このプロンプトのみ有効 (グローバルより優先)
    no-ask-user: true      # このプロンプトのみ有効 (グローバルより優先)
    env:
      TZ: "Asia/Tokyo"     # このプロンプト実行時のみ適用される環境変数（サニタイズなしで copilot CLI の実行環境に透過的に渡す）
    timeout_seconds: 3600  # タイムアウト秒数 (省略可)
    retries:
      count: 2             # 最大再試行回数
      delay_seconds: 60    # 再試行前の待機秒数
      backoff: "linear"    # 待機時間の増加方式。linear: delay_seconds × n (n=1,2,3…)
    on_failure:
      action: "abort"      # 失敗時の動作 (abort: 以降をスキップ / 未指定: 継続)
```

- `prompts[]` の各プロンプトに `continue` / `no-ask-user` が設定されている場合は、そのプロンプトの実行時のみグローバルフラグ (`--continue` / `--no-ask-user`) の値より優先して使用する（グローバルフラグの値自体は変更しない）
- `text` フィールドが空文字または未設定のエントリは実行をスキップし、警告メッセージを stderr に出力して後続プロンプトの実行を継続する
- `retries.backoff` に `"linear"` 以外の値が指定された場合は終了コード 1 (EXIT_ERROR) で即時終了し、未サポートの値である旨を stderr に出力する
- `retries.count` に `0` が指定された場合は再試行なしとして扱い、`retries` 未設定と同等の動作をする
- `env` フィールドに設定された環境変数は corun によるサニタイズを一切行わず copilot CLI の実行環境にそのまま渡す。API キー・パスワード等の機密情報を `env` に設定しないことはユーザーの責任とする

## 引数

引数 | 必須 | 説明
--- |  --- | ---
string | いいえ | プロンプト文字列(複数指定可能)

入力ソースの優先順位: `--prompt` > 引数 > stdin（上位が存在すれば下位は無視する）。
上位と下位が同時に指定された場合は、上位を適用したうえで「下位の入力ソースを無視した」旨の警告メッセージを stderr に出力する。
引数が指定されていない場合、以下のいずれかの条件を満たさなければ終了コード 3 (EXIT_USAGE) とする。
- `--prompt` フラグが指定されている
- パイプ/リダイレクト入力がある

1回の実行で指定できるプロンプト数に実装上の上限は設けない（OS または AI 実行エンジンのリソース限界まで実行を継続する）。

## 入出力

ストリーム | 用途
--- | ---
stdin | データ入力、パイプ入力（複数行のテキストも改行を含め全体を1プロンプトとして copilot CLI に渡す）
stdout | 正常な出力結果（copilot CLI の出力をそのまま流す。複数プロンプトを連続実行する場合も区切り文字列は挿入しない）
stderr | エラーメッセージ、ログ、進捗表示。`--verbose` 指定時のみ以下の3イベントを構造化ログ形式（`timestamp=<ISO8601 UTC秒精度 例: 2026-02-21T12:00:00Z> level=DEBUG msg=<メッセージ>`）で出力する: 実行開始 `msg=running prompt id=<id>`・実行完了 `msg=prompt completed id=<id>`・実行失敗 `msg=prompt failed id=<id> exit_code=<N>`。`<id>` はプロンプトエントリの `id` フィールドを使用する。`id` が未設定の場合（コマンドライン引数・stdin 入力・YAML の `id` フィールド省略時）は実行順の連番インデックス（`1`, `2`, `3` ...）をフォールバック ID として使用する。`text` 未設定によるスキップは構造化ログイベントを出力せず、通常の警告メッセージ（非構造化テキスト）のみ stderr に出力する。

### stdin の挙動

共通仕様に準拠する。stdin がパイプでもなく TTY でもない（クローズ済み）場合はハングせず、引数なし・`--prompt`なしと同様に終了コード 3 (EXIT_USAGE) で終了する。

## 動作フロー

1. **前提条件を検証する**
   - copilot CLI (`copilot`) が PATH 上に存在するか確認する
   - 見つからない場合は即時に終了コード 1 (EXIT_ERROR) で終了し、エラーメッセージを stderr に出力する

2. **フラグ・引数をパースする**
   - グローバルフラグ (`--model`, `--continue`, `--no-ask-user`, `--log-dir`, `--log-level`) を解釈する
   - 不明なフラグがある場合は終了コード 3 (EXIT_USAGE) で終了し、使用方法ヒントを stderr に出力する

2. **フラグ・引数をパースする**
   - グローバルフラグ (`--model`, `--continue`, `--no-ask-user`, `--log-dir`, `--log-level`) を解釈する
   - 不明なフラグがある場合は終了コード 3 (EXIT_USAGE) で終了し、使用方法ヒントを stderr に出力する

3. **入力ソースを確定する** (優先順位: `--prompt` > 引数 > stdin。上位が存在すれば下位は無視する)
   - `--prompt <file>` が指定されている場合 → ファイルをプロンプト定義として読み込む（引数・stdin は無視）
   - `--prompt` なしで引数 (`string ...`) が指定されている場合 → 各引数を1プロンプトとしてプロンプト定義の形式に変換する（stdin は無視）
   - `--prompt`・引数いずれもなく stdin がパイプ/リダイレクトの場合 → stdin 全体を1プロンプトとして扱う
   - いずれも該当しない場合 (stdin が TTY またはクローズ済み) → ハングせず終了コード 3 (EXIT_USAGE) で終了する

4. **プロンプト定義をパースする**
   - YAML のパースに失敗した場合は終了コード 1 (EXIT_ERROR) で終了し、エラーメッセージを stderr に出力する
   - `prompts` リストが空の場合は警告を stderr に出力して終了コード 0 で終了する
   - `retries.backoff` に `"linear"` 以外の値が設定されているエントリが存在する場合は終了コード 1 (EXIT_ERROR) で即時終了し、未サポートの値である旨を stderr に出力する
   - 各 `prompts[]` エントリの `text` フィールドが空文字または未設定の場合は当該エントリをスキップし警告を stderr に出力して後続を継続する
   - `retries.count` が `0` のエントリは再試行なし（`retries` 未設定）と同等に扱う

5. **プロンプトを順番に実行する** (`prompts[]` の定義順)
   1. **copilot CLI フラグを組み立てる**
      - プロンプト定義ファイルの `resume` フィールドがある場合は、**1回目のプロンプト実行時のみ** `--resume <session-id>` を付与する
      - `resume` と `--continue` が両方指定されている場合: 1回目は `--resume` のみ（`--continue` は渡さない）、2回目以降は `--continue` が有効な場合のみ `--continue` を付与する
      - グローバルフラグをベースに copilot CLI フラグへマッピングする
      - プロンプト個別の `continue` / `no-ask-user` が設定されている場合はそちらを優先する (グローバル値を上書きするのではなく、そのプロンプト呼び出し時のみ有効)
      - プロンプト個別の `env` が設定されている場合は、環境変数として copilot CLI に渡す
   2. **copilot CLI を実行する**
      - `copilot <フラグ一式> -p <prompt文字列>` を実行する
      - `timeout_seconds` が設定されている場合は、タイムアウト経過で強制終了し copilot CLI の非ゼロ終了と同等の「失敗」として扱う（次の「失敗時の処理」ステップへ進む）
      - `timeout_seconds` が未設定の場合は corun 側でタイムアウトを設定せず、copilot CLI が終了するまで無制限に待つ
   3. **失敗時の処理** (判定基準: copilot CLI の終了コードが 0 以外)
      - レートリミット（クォータ超過）エラーを含む copilot CLI の非ゼロ終了はすべて通常の失敗として扱う（特別なハンドリングは行わない）
      - `retries.count` が残っている場合: n 回目の再試行前に `delay_seconds × n` 秒待機してから再実行する (`backoff: linear` の計算式。例: delay_seconds=60 のとき 1回目60s、2回目120s)。`delay_seconds` が省略された場合は 0 秒（待機なし）で即時再試行する
      - 再試行をすべて使い切った場合、または `retries` 未設定の場合:
        - `on_failure.action: abort` → 後続プロンプトをすべてスキップして終了コード 1 で終了する
        - `on_failure` 未設定 → 後続プロンプトの実行を継続する

5. **終了する**
   - すべてのプロンプトが正常終了した場合は終了コード 0 で終了する
   - 1 つでも失敗したプロンプトがある場合（`on_failure` 未設定で後続継続した場合を含む）は終了コード 1 (EXIT_ERROR) で終了する
   - SIGINT を受信した場合は終了コード 2 (EXIT_CANCEL) で終了する
   - SIGPIPE を受信した場合（下流のパイプが閉じた場合）は正常終了 (0) として扱う。SIGPIPE が発生しうる出力箇所は `|| true` または局所的な `set +e` でハンドリングし、`set -e` によるスクリプト中断を防ぐ

## エラーと終了コード

共通仕様の終了コードに準拠する。

コード | 発生条件
--- | ---
0 | すべてのプロンプトが正常終了した / SIGPIPE を受信した（下流のパイプ閉鎖）
1 | copilot CLI が見つからない / YAML パース失敗 / ファイルが存在しない / copilot CLI の実行エラー / タイムアウト後に on_failure: abort / on_failure 未設定で継続したが 1 つ以上のプロンプトが失敗した / `retries.backoff` に未サポートの値が指定された
2 | SIGINT (Ctrl-C) を受信した
3 | 引数・パイプ・`--prompt` がすべてない（stdin が TTY またはクローズ済み）/ 不明なフラグを指定した

### エラーメッセージ形式

共通仕様のルートコマンドのエラー形式に準拠する:

```
Error: <エラーメッセージ>

Usage: corun run [flags] [string ...]

Run 'corun run --help' for more information.
```

## テストケース

主要な単体テスト/結合テストの一覧と期待結果。

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
| UT-15 | `--model` 未指定時は copilot CLI に `--model` フラグを渡さない | (フラグなし) | `--model` フラグが付与されない（copilot CLI のデフォルトモデルに委ねる） |

#### プロンプト定義ファイルのパース

| ID | テストケース | 入力 | 期待結果 |
| --- | --- | --- | --- |
| UT-16 | 有効な YAML を正常にパースできる | `prompts.yml` (正常な YAML) | プロンプトリストが読み込まれる |
| UT-17 | 不正な YAML はエラーになる | `prompts.yml` (インデント不正) | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| UT-18 | `prompts` キーが空のとき警告してスキップする | `prompts: []` | 終了コード 0、「プロンプトが存在しない」を stderr に出力 |
| UT-19 | トップレベルの `continue` がグローバルデフォルトになる | `continue: true` | 各プロンプトで `--continue` が付与される |
| UT-20 | プロンプト個別の `continue` がグローバル設定を上書きする | グローバル `continue: false`、個別 `continue: true` | そのプロンプトのみ `--continue` が付与される |
| UT-21 | プロンプト個別の `no-ask-user` がグローバル設定を上書きする | グローバル `no-ask-user: false`、個別 `no-ask-user: true` | そのプロンプトのみ `--no-ask-user` が付与される |
| UT-22 | stdin がクローズ済みで引数・`--prompt` なし → 引数エラー | `run`（stdin がクローズ済み＝TTY でもパイプでもない） | 終了コード 3 (EXIT_USAGE)、ハングせずエラーメッセージを stderr に出力 |
| UT-23 | `resume` と `--continue` 両方指定時、1回目は `--resume` のみ付与 | `resume: sid`・グローバル `continue: true` | 1回目プロンプト: `--resume sid` のみ付与（`--continue` なし）、2回目以降: `--continue` のみ付与 |
| UT-24 | タイムアウト超過は失敗扱いとして `retries` を消費する | `timeout_seconds: 1`・`retries.count: 2`・応答が 2 秒以上かかる場合 | タイムアウト後に再試行し最大 2 回まで繰り返す（失敗扱い） |
| UT-25 | `text` フィールドが空のエントリはスキップして後続を継続する | `text: ""`（空文字）を持つエントリが存在する YAML | 当該エントリをスキップし警告を stderr に出力、後続プロンプトは実行され終了コード 0 |
| UT-26 | `retries.backoff` に未サポートの値を指定するとエラーになる | `backoff: "exponential"` | 終了コード 1 (EXIT_ERROR)、未サポート値のエラーメッセージを stderr に出力 |
| UT-27 | `retries.count: 0` は `retries` 未設定と同等に扱われる | `retries.count: 0` | 再試行なしで失敗扱いとして `on_failure` の設定に従う |

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
| IT-09 | `--verbose` 付きで実行するとデバッグログが stderr に出る | `corun --verbose run "hello"` | stderr に `timestamp=... level=DEBUG msg=running prompt id=...` 形式のログが出力される（開始・完了・失敗の3イベント） |

#### 異常系

| ID | テストケース | コマンド | 期待結果 |
| --- | --- | --- | --- |
| IT-10 | 引数・パイプ・`--prompt` がすべてない場合は使用方法エラー | `corun run` (stdin は TTY) | 終了コード 3 (EXIT_USAGE)、使用方法ヒントを stderr に出力 |
| IT-11 | copilot CLI が PATH 上に存在しない場合は即時エラー | `corun run "hello"` (copilot なし) | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| IT-12 | 存在しない `--prompt` ファイルはエラーになる | `corun run --prompt not-exist.yml` | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| IT-12 | 不正な YAML ファイルはエラーになる | `corun run --prompt invalid.yml` | 終了コード 1 (EXIT_ERROR)、エラーメッセージを stderr に出力 |
| IT-13 | copilot CLI が失敗したとき `on_failure: abort` で中断する | プロンプト1失敗、`on_failure: abort` | 終了コード 1、プロンプト2以降は実行されない |
| IT-14 | retries 設定に従って線形バックオフで再試行する | copilot CLI が1回失敗、`retries.count: 2`, `delay_seconds: 60` | 1回目は60s、2回目は120s 待機後に再試行し、最大2回まで繰り返す |
| IT-15 | SIGINT を送信すると終了コード 2 で終了する | `corun run "hello"` 実行中に Ctrl-C | 終了コード 2 (EXIT_CANCEL) |
| IT-16 | パイプ下流が先に終了しても正常終了する（SIGPIPE） | `corun run "hello" \| head -1` | 終了コード 0（SIGPIPE を正常終了として扱う）|
| IT-17 | stdin クローズ済み・引数・`--prompt` なし → 使用方法エラー | `corun run < /dev/null` | 終了コード 3 (EXIT_USAGE)、ハングしない |



## スコープ外

- **並列実行**: 複数プロンプトを同時に AI エンジンへ送信する並列実行はサポートしない。プロンプトは常に `prompts[]` の定義順に順次実行される（YAGNI 原則に基づき初期バージョンでは除外。copilot CLI のレートリミット・セッション競合などの複雑な問題を回避するため）。

## 参考情報

- copilot-cli-help.txt

## 更新履歴
- 2026-02-21: specs/002-prompt-runner/spec.md Clarifications (Session 2026-02-21) を反映（`--continue` の全プロンプト適用を明記、スキップ時の構造化ログなしを明記、`timeout_seconds` 未設定時の無制限待ちを明記、`delay_seconds` 省略時の即時再試行を明記、タイムスタンプ形式を UTC 固定・秒精度に明記）- 2026-02-21: specs/001-prompt-runner/spec.md Clarifications (Session 2026-02-21) を反映（`env` フィールドのユーザー責任を明記、レートリミットエラーを通常失敗と同一扱いする旨を動作フローに追記）
- 2026-02-21: specs/002-prompt-runner/spec.md Clarifications (Session 2026-02-21) を反映（`text` 未設定エントリのスキップ挙動、並列実行スコープ外宣言、`retries.backoff` 無効値エラー、`retries.count: 0` 同等扱い、テストケース UT-25〜UT-27 を追記）
- 2026-02-21: specs/001-prompt-runner/spec.md Clarifications (Session 2026-02-21) を反映（`on_failure` 未設定継続時の最終終了コードを終了フローと終了コードテーブルに追記、`--verbose` ログの `id` 未設定時の連番フォールバックを入出力セクションに追記）
- 2026-02-21: specs/002-prompt-runner/spec.md Clarifications (Session 2026-02-21) を反映（`env` フィールドの透過渡し・サニタイズなし明記、stdin 複数行→1プロンプト明記、`--verbose` 時の3イベント構造化ログ形式を入出力セクションと IT-09 に追記、`--log-level` バリデーションの copilot CLI 委任を明記）
- 2026-02-21: spec.md Clarifications (2026-02-21 セッション) を反映（YAML プロンプト本文フィールド名を `prompt` → `text` に変更、複数入力同時指定時の警告動作追加、stdout 区切りなし・実行状態は --verbose 時のみ stderr に明記、プロンプト数上限なし追記）
- 2026-02-21: spec.md Clarifications を反映（stdin クローズ済み EXIT_USAGE・timeout 失敗扱い・SIGPIPE 正常終了・--model デフォルト委任・resume×continue 優先順位）
- 2026-02-21: common.md 準拠に仕様を整備（フラグ説明・優先順位・エラー形式・stdin挙動・YAMLコメント追加）
- 2026-02-21: 作成
