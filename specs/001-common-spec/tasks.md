# Tasks: corun 共通仕様

**Input**: Design documents from `/specs/001-common-spec/`
**Prerequisites**: [plan.md](./plan.md) (required), [spec.md](./spec.md) (required)

**Notes**:
- TDD は憲章 II 条（NON-NEGOTIABLE）により必須。テストを先に作成し失敗（Red）を確認してから実装（Green）し、その後リファクタリングする。
- `[P]` = 並行実行可（別ファイル、依存なし）
- `[USn]` = 対応するユーザーストーリー

## Phase 1: Setup（プロジェクト初期化）

**Purpose**: ディレクトリ構成・Makefile・CI スケルトンの整備。すべてのフェーズの前提。

- [x] T001 `bin/` / `src/lib/` / `tests/unit/` / `tests/fixtures/` / `integration_tests/` のディレクトリ構造を作成する
- [x] T002 Makefile に `lint` / `format` / `test` / `integration_test` / `build` / `clean` / `help` / `all` / `ci` の全ターゲットを定義する in `Makefile`
- [x] T003 [P] CI パイプラインのスケルトンを作成する in `.github/workflows/ci.yml`（トリガー: push/PR to `main`, `next`, `feature/**`; ステップ: checkout → install prerequisites → lint → test → integration_test → build → upload）

---

## Phase 2: Foundational（基盤ライブラリ）

**Purpose**: 全モジュールが依存する終了コードと入出力ヘルパーを先行実装する。このフェーズが完了するまでユーザーストーリー実装を開始しない。

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 終了コードの単体テストを作成する in `tests/unit/exit_codes_test.bats`（`EXIT_OK=0` / `EXIT_ERROR=1` / `EXIT_CANCEL=2` / `EXIT_USAGE=3` の値確認、`die()` / `exit_with()` の動作確認）— **Red を確認してから T005 へ**
- [x] T005 終了コード定数とヘルパー関数を実装する in `src/lib/exit_codes.sh`（`EXIT_OK` / `EXIT_ERROR` / `EXIT_CANCEL` / `EXIT_USAGE`、`die()` / `exit_with()` 関数）
- [x] T006 [P] 入出力ユーティリティの単体テストを作成する in `tests/unit/io_test.bats`（`out()` が stdout のみ出力、`err()` が stderr のみ出力、`log_debug()` が `--verbose` OFF で何も出力しない、`--verbose` ON で `timestamp=<ISO8601> level=DEBUG msg=` 形式を stderr へ出力）— **Red を確認してから T007 へ**
- [x] T007 入出力ユーティリティ関数を実装する in `src/lib/io.sh`（`out()` → stdout、`err()` → stderr、`log_debug()` → `timestamp=<ISO8601> level=DEBUG msg=<message>` 形式で stderr）

**Checkpoint**: `make test` が T004〜T007 の全テストで green になること

---

## Phase 3: User Story 1 — グローバルフラグで制御できる (Priority: P1) 🎯 MVP

**Goal**: `--help` / `-h` / `--verbose` / `--version` / `-v` が全コマンドで正しく動作する

**Independent Test**: `corun --help` が終了コード 0 かつ 5 セクション含む / `corun --version` が終了コード 0 かつ `corun version X.Y.Z` 形式 / `corun --verbose` 付き実行時に stderr へ構造化ログが出力される

### Tests for User Story 1 ⚠️ Write FIRST, confirm FAIL before implementing

- [x] T008 [US1] フラグ解析の単体テストを作成する in `tests/unit/flags_test.bats`（`--help` / `-h` の認識、`--verbose` の認識、`--version` / `-v` の認識、不明フラグで終了コード 3、重複フラグ last-wins（`--verbose --verbose` で verbose ON）、`--version` と `--help` の同時指定で `--help` 優先）
- [x] T009 [P] [US1] バージョン表示の単体テストを作成する in `tests/unit/version_test.bats`（`print_version()` が `corun version X.Y.Z` 形式、SemVer パターンマッチ `^[0-9]+\.[0-9]+\.[0-9]+`）

### Implementation for User Story 1

- [x] T010 [US1] フラグ解析関数を実装する in `src/lib/flags.sh`（`parse_flags()`: `--help`/`-h` → `CORUN_HELP=1`、`--verbose` → `CORUN_VERBOSE=1` (last-wins)、`--version`/`-v` → `CORUN_VERSION=1`、不明フラグ → `exit 3` + stderr へ使用方法ヒント）
- [x] T011 [P] [US1] バージョン表示関数を実装する in `src/lib/version.sh`（`print_version()`: `corun version X.Y.Z` を stdout へ出力）
- [x] T012 [US1] `--version` 結合テストを作成・検証する in `integration_tests/version_integration_test.bats`（`corun --version` → 終了コード 0、`corun version X.Y.Z` 形式）
- [x] T013 [US1] `--verbose` 結合テストを作成・検証する in `integration_tests/verbose_integration_test.bats`（`--verbose` あり → stderr に `timestamp=` `level=DEBUG` を含む、`--verbose` なし → stderr 空）

**Checkpoint**: `corun --version` と `corun --verbose` が独立して動作することを確認

---

## Phase 4: User Story 2 — 終了コードで結果を判別できる (Priority: P1)

**Goal**: 正常実行・エラー・キャンセル・不正フラグの各シナリオで終了コード 0/1/2/3 が正確に返る

**Independent Test**: 4 パターン全シナリオの終了コードを `make integration_test` で検証できる

### Tests for User Story 2 ⚠️ Write FIRST, confirm FAIL before implementing

- [x] T014 [US2] 終了コード結合テストを作成する in `integration_tests/exit_codes_integration_test.bats`（正常完了 → 0、一般エラー発生 → 1、SIGINT 送信 → 2、不正フラグ → 3）

### Implementation for User Story 2

- [x] T015 [US2] ルートコマンドディスパッチャを実装する in `src/corun.sh`（`parse_flags()` 呼び出し → `CORUN_HELP=1` なら `print_help()` → `CORUN_VERSION=1` なら `print_version()` → サブコマンドへ振り分け; `trap 'exit 2' INT` で SIGINT をキャンセルコードにマップ; エラー時は `exit 1`）
- [x] T016 [US2] エントリポイントスクリプトを作成する in `bin/corun`（`#!/usr/bin/env bash`、`set -euo pipefail`、`src/corun.sh` を source して実行、`chmod +x` で実行権限付与）

**Checkpoint**: `make integration_test` で 4 パターンの終了コードが全て green になること

---

## Phase 5: User Story 3 — パイプ連携できる (Priority: P2)

**Goal**: stdout と stderr が分離し、パイプチェーンで正常出力のみ流れる。stdin クローズ済みでもハングしない

**Independent Test**: `corun ... | grep <keyword>` がエラーメッセージを含まない stdout のみ返す。`corun ... <&-` が終了コード 0 で正常終了する

### Tests for User Story 3 ⚠️ Write FIRST, confirm FAIL before implementing

- [x] T017 [US3] パイプ結合テストを作成する in `integration_tests/pipe_integration_test.bats`（stdout をパイプで受け取ったときエラーメッセージが含まれない、`2>/dev/null` で stderr を捨てたときエラーが stdout に漏れない、`corun ... <&-` が終了コード 0 で正常終了する）

### Implementation for User Story 3

- [x] T018 [US3] `src/corun.sh` に stdin クローズ済み対応を追加する（stdin が閉じられている場合でもハングしないよう stdin の状態を必要に応じてチェックし、使用しない場合は無視して続行する）
- [x] T019 [US3] `src/lib/io.sh` の stdout/stderr 分離をパイプテストで検証・修正する（パイプ経由で stderr が stdout に混在しないことを確認し、必要に応じて修正する）

**Checkpoint**: `make integration_test` でパイプ・stdin クローズのテストが全て green になること

---

## Phase 6: User Story 4 — ヘルプ出力から使い方を把握できる (Priority: P3)

**Goal**: `corun --help` / `<subcommand> --help` 実行時に DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE の 5 セクションが表示される

**Independent Test**: `corun --help` が終了コード 0 かつ 5 セクションをすべて含む

### Tests for User Story 4 ⚠️ Write FIRST, confirm FAIL before implementing

- [x] T020 [US4] ヘルプ出力の単体テストを作成する in `tests/unit/help_test.bats`（`print_help()` の出力が DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE を含む）
- [x] T021 [P] [US4] ヘルプ結合テストを作成する in `integration_tests/help_integration_test.bats`（`corun --help` → 終了コード 0、5 セクション全含む; サブコマンド `--help` → そのサブコマンドのヘルプが出力される）

### Implementation for User Story 4

- [x] T022 [US4] ヘルプ出力関数を実装する in `src/lib/help.sh`（`print_help()`: DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE の各セクションを stdout へ出力; ルートコマンドとサブコマンドで出力を切り替えられる設計）

**Checkpoint**: `corun --help` が終了コード 0 かつ 5 セクションを表示することを独立して確認

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: 品質ゲート通過・ドキュメント整備・CI 最終検証

- [x] T023 [P] ShellCheck 静的解析を全ファイルに実行し違反をゼロにする (`make lint`): `bin/corun`, `src/**/*.sh`
- [x] T024 [P] Shfmt フォーマッタを全ファイルに実行する (`make format`): `bin/corun`, `src/**/*.sh`, `tests/**/*.bats`, `integration_tests/**/*.bats`
- [x] T025 CI パイプラインをエンドツーエンドで通過させる（`make lint` → `make test` → `make integration_test` → `make build` がすべて green）
- [x] T026 コアモジュールのテストカバレッジが 85% 以上であることを確認する（`exit_codes.sh` / `io.sh` / `flags.sh` / `help.sh` / `version.sh` を重点確認）
- [x] T027 [P] `README.md` を更新する（インストール手順・使用方法・フラグ一覧・終了コード表）
- [x] T028 [P] `CHANGELOG.md` に `feat: add common CLI base (flags, exit codes, io, help, version)` を追記する

---

## Dependencies

```
Phase 1 (Setup)
  └── Phase 2 (Foundational: exit_codes, io)
        ├── Phase 3 (US1: flags, version — P1)     ← MVP
        │     └── Phase 4 (US2: dispatcher, bin/corun — P1)
        │           └── Phase 5 (US3: pipe, stdin — P2)
        │                 └── Phase 6 (US4: help — P3)
        │                       └── Phase 7 (Polish)
        └── (Phase 3 と Phase 4 は Phase 2 完了後に並行着手可)
```

**US1 と US2 は Phase 2 完了後に並行着手可能**（US1 は flags/version、US2 は dispatcher/bin/corun）

---

## Parallel Execution Examples

### Phase 3 + Phase 4 を並行実施する場合

```bash
# 担当A: US1 (flags + version)
# T008 → T010 → T012 → T013

# 担当B: US4 (help) を先行して実装開始可
# T020 → T022 → T021
```

### Phase 7 内の並行タスク

```bash
# T023 (lint) と T024 (format) は独立して並行実行可
# T027 (README) と T028 (CHANGELOG) は独立して並行実行可
```

---

## Implementation Strategy

**MVP scope**: Phase 1 + Phase 2 + Phase 3 (US1) + Phase 4 (US2) で `corun --help` / `--version` / `--verbose` / 終了コードの基本動作が完成。これだけで独立してデモ可能。

**Incremental delivery**:
1. Phase 1〜2: 基盤整備（外部公開なし）
2. Phase 3〜4: `corun` コマンドの基本 CLI として利用可能（MVP）
3. Phase 5〜6: パイプ連携・ヘルプ整備で UX 向上
4. Phase 7: 品質ゲート通過して PR マージ可能な状態

**Task Summary**:

| フェーズ | タスク数 | ユーザーストーリー |
|---|---|---|
| Phase 1: Setup | 3 | — |
| Phase 2: Foundational | 4 | — |
| Phase 3: US1 (P1) | 6 | グローバルフラグ制御 |
| Phase 4: US2 (P1) | 3 | 終了コード判別 |
| Phase 5: US3 (P2) | 3 | パイプ連携 |
| Phase 6: US4 (P3) | 3 | ヘルプ出力形式 |
| Phase 7: Polish | 6 | — |
| **合計** | **28** | |

**並行実行機会**: T003, T006, T009, T011, T021, T023, T024, T027, T028（9タスク）
