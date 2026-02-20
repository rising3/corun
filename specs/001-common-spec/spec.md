# Feature Specification: corun 共通仕様

**Feature Branch**: `001-common-spec`  
**Created**: 2026-02-20  
**Status**: Draft  
**Input**: User description: "以下の仕様書を参照し、共通機能(docs/specs/features/common.md)の仕様を作成する。"

**References**:
- [docs/specs/features/README.md](../../docs/specs/features/README.md)
- [docs/specs/features/common.md](../../docs/specs/features/common.md)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - グローバルフラグでコマンドを制御できる (Priority: P1)

ユーザー（人・スクリプト・AI エージェント）が `corun` を実行する際、`--help` / `--verbose` / `--version` の各フラグを使ってコマンドの動作を制御できる。

**Why this priority**: すべてのサブコマンドはこれらのフラグを基盤として動作する。フラグが正しく機能しないと CLI としての最低限の利用が成立しない。

**Independent Test**: `corun --help` / `corun --version` / `corun run --help` を実行し、それぞれ期待通りの出力が stdout に表示されることを確認する。`--verbose` 付きで実行し、詳細ログが stderr に出力されることを確認する。

**Acceptance Scenarios**:

1. **Given** 任意のコマンドを実行するとき、**When** `--help` または `-h` を付けると、**Then** ヘルプテキストが stdout に出力され、終了コード 0 で終了する。
2. **Given** ルートコマンドを実行するとき、**When** `--version` または `-v` を付けると、**Then** `corun version <バージョン番号>` が stdout に出力され、終了コード 0 で終了する。
3. **Given** 任意のコマンドを実行するとき、**When** `--verbose` を付けると、**Then** 詳細なログが stderr に出力され、正常処理は stdout に出力される。
4. **Given** 不明なフラグを指定したとき、**When** コマンドを実行すると、**Then** エラーメッセージが stderr に出力され、終了コード 3 で終了する。

---

### User Story 2 - 終了コードでコマンド結果をスクリプトから判別できる (Priority: P1)

シェルスクリプトや CI パイプラインが `corun` の終了コードを参照して、処理の成否・中断・不正呼び出しを判別できる。

**Why this priority**: 終了コードは CLI の契約の根幹であり、自動化・パイプライン連携の可否を左右する。

**Independent Test**: 正常実行・存在しないサブコマンド・Ctrl-C キャンセル・不正フラグの各シナリオを実行し、それぞれ終了コード 0 / 1 / 2 / 3 が返ることを確認する。

**Acceptance Scenarios**:

1. **Given** コマンドが正常に完了したとき、**When** 終了コードを確認すると、**Then** 0 が返る。
2. **Given** 処理中にエラーが発生したとき、**When** 終了コードを確認すると、**Then** 1 が返る。
3. **Given** ユーザーが処理を中断（シグナル送信）したとき、**When** 終了コードを確認すると、**Then** 2 が返る。
4. **Given** 引数・フラグの指定が不正なとき、**When** 終了コードを確認すると、**Then** 3 が返る。

---

### User Story 3 - stdin/stdout/stderr を通じてパイプ連携できる (Priority: P2)

ユーザーが `corun` をパイプラインの一部として使用し、結果を stdout から受け取り、エラーを stderr で区別して処理できる。

**Why this priority**: CLI ツールとしての重要な品質属性だが、基本動作自体はフラグ・終了コードに依存するため P2。

**Independent Test**: `corun run ... | grep <keyword>` のようなパイプを実行し、正常出力だけが stdout に流れることを確認する。また、エラー発生時に stderr にのみエラーが出力されることを確認する。

**Acceptance Scenarios**:

1. **Given** コマンドが正常に完了したとき、**When** stdout をパイプで受け取ると、**Then** 正常な結果のみが含まれる（エラーメッセージは含まれない）。
2. **Given** エラーが発生したとき、**When** stderr を確認すると、**Then** エラーメッセージのみが stderr に出力される。
3. **Given** stdin からデータを渡したとき、**When** コマンドがそれを読み取る場合、**Then** パイプ入力として正しく処理される。

---

### User Story 4 - ヘルプ出力から使い方を把握できる (Priority: P3)

初めて `corun` を使うユーザーが `--help` を実行するだけで、コマンドの説明・使い方・サブコマンド一覧・例を確認し、次の操作を判断できる。

**Why this priority**: ユーザビリティとして重要だが、機能自体は `--help` フラグ（User Story 1）の一部。出力形式の詳細定義として P3。

**Independent Test**: `corun --help` を実行し、DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE セクションがすべて含まれることを確認する。

**Acceptance Scenarios**:

1. **Given** `corun --help` を実行すると、**When** 出力を確認すると、**Then** コマンド名・説明 (DESCRIPTION)・使用方法 (USAGE)・利用可能コマンド一覧 (AVAILABLE COMMANDS)・使用例 (EXAMPLES) が表示される。
2. **Given** サブコマンドに `--help` を付けると、**When** 出力を確認すると、**Then** そのサブコマンドのヘルプが表示される。

---

### Edge Cases

- フラグが複数重複して指定された場合（例: `--verbose --verbose`）、エラーとせず最後の指定を有効にする（last-wins）。
- `--version` と `--help` を同時に指定した場合、`--help` を優先して表示する。
- stdin がパイプでもなく TTY でもない（クローズ済み）場合、コマンドはハングせず正常終了（終了コード 0）する。stdin を使用しないコマンドは stdin の状態を無視して続行する。
- 無効な引数が混在するとき（例: `corun --unknown-flag`）、終了コード 3 かつ使用方法のヒントを stderr に出力する。
- Ctrl-C をサブコマンド実行中に送信した場合、終了コード 2 で終了し、中途半端な状態を残さない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `corun` はルートコマンドとして `run` および `gen` サブコマンドを提供しなければならない (MUST)。
- **FR-002**: すべてのコマンドは `--help` / `-h` フラグをサポートし、stdout にヘルプを出力して終了コード 0 で終了しなければならない (MUST)。
- **FR-003**: ルートコマンドは `--version` / `-v` フラグをサポートし、`corun version <バージョン番号>` を stdout に出力して終了コード 0 で終了しなければならない (MUST)。バージョン番号は Semantic Versioning 形式 (`MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`) でなければならない (MUST)。
- **FR-004**: すべてのコマンドは `--verbose` フラグをサポートし、詳細なログを stderr に出力しなければならない (MUST)。ログは構造化形式 `timestamp=<ISO8601> level=DEBUG msg=<メッセージ>` に従わなければならない (MUST)。
- **FR-005**: フラグの優先順位はコマンドライン引数 > 環境変数 > デフォルト値の順でなければならない (MUST)。設定ファイルはサポートしないため優先順位チェーンには含まない（FR-011 参照）。
- **FR-006**: 正常な出力結果は stdout、エラーメッセージ・ログ・進捗表示は stderr に出力しなければならない (MUST)。
- **FR-007**: コマンドは以下の終了コードを使用しなければならない (MUST):
  - `0`: 正常終了
  - `1`: 一般エラー（処理中のエラー）
  - `2`: キャンセル（ユーザーによる中断）
  - `3`: 使用方法エラー（引数・フラグの不正）
- **FR-008**: ルートコマンドのエラーメッセージは以下の形式に従わなければならない (MUST):
  ```
  Error: <エラーメッセージ>

  Usage: <コマンド名> <command> [flags]

  Run '<コマンド名> <command> --help' for more information.
  ```
- **FR-009**: ファイル操作を行うサブコマンドのエラーメッセージは GNU coreutils 互換の形式 (`<コマンド名>: <filename>: <error description>`) に従わなければならない (MUST)。
- **FR-010**: ヘルプ出力は DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE の各セクションを含まなければならない (MUST)。
- **FR-011**: 設定ファイルおよびシェル補完はサポートしない (MUST NOT)。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `corun --help` を実行した場合、100% のケースで終了コード 0 かつ必須セクション（DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE）がすべて含まれる出力が得られる。
- **SC-002**: `corun --version` を実行した場合、100% のケースで `corun version X.Y.Z` 形式の出力が終了コード 0 で得られる。
- **SC-003**: 不正なフラグや引数を指定した場合、100% のケースで終了コード 3 かつ使用方法ヒントが stderr に出力される。
- **SC-004**: 正常実行・エラー・キャンセル・不正フラグの 4 パターンすべてで、定義された終了コード（0 / 1 / 2 / 3）が返ることを BATS テストで検証できる。
- **SC-005**: `--verbose` なし実行時に stderr が空であること（ログが stdout を汚染しないこと）を確認できる。

## Clarifications

### Session 2026-02-20

- Q: FR-005（フラグ優先順位）に設定ファイルが含まれているが FR-011 では設定ファイルをサポートしない。どちらを優先するか？ → A: コマンドライン引数 > 環境変数 > デフォルト値（設定ファイルを削除）
- Q: 同一フラグが複数回指定された場合（例: `--verbose --verbose`）の挙動は？ → A: 最後の指定を有効にする（last-wins）
- Q: ヘルプ出力の最終セクション `LEAN MORE` は typo か意図的か？ → A: typo のため `LEARN MORE` に修正する
- Q: stdin がクローズ済み（パイプでも TTY でもない）場合の終了コードは？ → A: 正常終了（終了コード 0）、stdin を使わないコマンドは無視して続行する
- Q: `--verbose` 時のログ出力フォーマットは？ → A: 構造化ログ形式 `timestamp=<ISO8601> level=DEBUG msg=<メッセージ>`（key=value 形式）

## Assumptions

- `corun` コマンドは単一のバイナリ（または実行可能シェルスクリプト）として提供される。
- 設定ファイルは現時点ではスコープ外とする（FR-011）。
- シェル補完は現時点ではスコープ外とする（FR-011）。
- バージョン番号は SemVer に準拠するが、ビルド番号（`+BUILD`）は省略可能とする。
