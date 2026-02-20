# Implementation Plan: corun 共通仕様

**Branch**: `001-common-spec` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-common-spec/spec.md`

## Summary

`corun` CLI の全コマンドに共通する基盤動作（グローバルフラグ、終了コード、入出力ストリーム分離、ヘルプ形式、バージョン表示、verbose 構造化ログ）を bash スクリプトとして実装する。実装は `src/` にライブラリ関数として集約し、`bin/corun` エントリポイントから呼び出す構成とする。BATS による単体テスト・結合テストでカバレッジ 85% 以上を確保する。

## Technical Context

**Language/Version**: bash 5.2+  
**Primary Dependencies**:
- GitHub Copilot CLI 0.0.400+ (外部連携、共通基盤では直接依存しない)
- yq 4.30.8+ (YAML 処理用ユーティリティ)
- jq 1.6+ (JSON 処理用ユーティリティ)
- BATS 1.3.0+ (単体テスト)
- ShellCheck 0.9.0+ (静的解析)
- Shfmt 3.4.1+ (コードフォーマット)
- make 4.3+ (ビルド自動化)

**Storage**: N/A（共通基盤に永続ストレージなし）  
**Testing**: BATS (`make test` / `make integration_test`)  
**Target Platform**: Linux (bash 5.2+)  
**Project Type**: シングルプロジェクト（単一スクリプト群）  
**Performance Goals**: 各コマンドの起動時間 < 1秒 を基準とし、機能実装ごとにパフォーマンス監視を実施する  
**Constraints**:
- 機密情報をコードにハードコードしない (OWASP)
- SemVer × Conventional Commits によるバージョン管理
- コードカバレッジ 85% 以上（コアモジュール）
- ShellCheck エラーゼロ、Shfmt フォーマット遵守

**Scale/Scope**: 共通基盤（フラグ処理・終了コード・ログ出力）の実装。サブコマンド実装は後続フィーチャーで行う。

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | チェック | 判定 |
|------|----------|------|
| I. コード品質 | ShellCheck + Shfmt を CI に組込み、PR は CI green が必須 | PASS |
| II. テスト標準 | BATS で TDD、カバレッジ 85% 以上、Red-Green-Refactor サイクル遵守 | PASS |
| III. インターフェイス | `--help` / `--verbose` / `--version` 必須実装、stdin→stdout/stderr 分離 | PASS |
| IV. パフォーマンス | 各機能単位で起動時間を計測し監視する | PASS |
| V. セキュリティ | API キー等のハードコードなし、OWASP 準拠 | PASS |
| VI. 可観測性 | `--verbose` 時に `timestamp=... level=DEBUG msg=...` を stderr へ出力 | PASS |
| VII. バージョン管理 | SemVer + Conventional Commits、CI でバージョン自動決定 | PASS |
| VIII. シンプルさ | シングルプロジェクト、YAGNI 原則を遵守 | PASS |
| IX. ガバナンス | 本計画は憲章に準拠して作成 | PASS |
| X. ドキュメント | 日本語でドキュメント更新、ADR を源泉として参照 | PASS |

**Constitution Violations**: なし

## Project Structure

### Documentation (this feature)

```text
specs/001-common-spec/
├── plan.md              # This file (/speckit.plan コマンド出力)
├── spec.md              # Feature specification
├── checklists/
│   └── requirements.md  # 仕様品質チェックリスト
└── tasks.md             # Phase 2 output (/speckit.tasks コマンドで作成)
```

### Source Code (repository root)

```text
bin/
└── corun                # エントリポイント（実行権限付きシェルスクリプト）

src/
├── lib/
│   ├── flags.sh         # グローバルフラグ解析（--help / --verbose / --version）
│   ├── exit_codes.sh    # 終了コード定数定義と exit ヘルパー関数
│   ├── io.sh            # stdout/stderr 出力ヘルパー（log_debug / log_error / out）
│   ├── help.sh          # ヘルプ出力テンプレート（DESCRIPTION/USAGE/AVAILABLE COMMANDS/EXAMPLES/LEARN MORE）
│   └── version.sh       # バージョン情報の読み取りと出力
└── corun.sh             # ルートコマンドディスパッチャ

tests/
├── unit/
│   ├── flags_test.bats       # flags.sh の単体テスト
│   ├── exit_codes_test.bats  # exit_codes.sh の単体テスト
│   ├── io_test.bats          # io.sh の単体テスト
│   ├── help_test.bats        # help.sh の単体テスト
│   └── version_test.bats     # version.sh の単体テスト
└── fixtures/                 # テスト用スタブ・フィクスチャ

integration_tests/
├── help_integration_test.bats     # --help 出力の結合テスト
├── version_integration_test.bats  # --version 出力の結合テスト
├── verbose_integration_test.bats  # --verbose ログ出力の結合テスト
├── exit_codes_integration_test.bats # 終了コードの結合テスト
└── pipe_integration_test.bats     # パイプ連携の結合テスト

Makefile                 # ビルド・テスト・lint 自動化
.github/
└── workflows/
    └── ci.yml           # CI パイプライン定義
```

**Structure Decision**: シングルプロジェクト構成（Option 1）を採用。共通基盤は `src/lib/` にライブラリとして集約し、`bin/corun` から `source` して利用する。サブコマンドは後続フィーチャーで `src/commands/` に追加する予定。

## Implementation Approach

### Phase 1: コアライブラリ実装（TDD）

実装順序（依存関係を考慮した最小依存順）:

1. `src/lib/exit_codes.sh` — 終了コード定数（0/1/2/3）と `die()` / `exit_with()` ヘルパー
2. `src/lib/io.sh` — `out()` (stdout), `err()` (stderr), `log_debug()` (verbose ログ形式 `timestamp=... level=DEBUG msg=...`)
3. `src/lib/flags.sh` — `parse_flags()`: `--help` / `-h` / `--verbose` / `--version` / `-v` のパース（last-wins、不明フラグは終了コード 3）
4. `src/lib/help.sh` — `print_help()`: DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE セクション出力
5. `src/lib/version.sh` — `print_version()`: `corun version X.Y.Z` 形式で stdout に出力
6. `src/corun.sh` — `bin/corun` から呼ばれるルートディスパッチャ（フラグ解析 → help / version / サブコマンド振り分け）
7. `bin/corun` — エントリポイント（`#!/usr/bin/env bash` + `set -euo pipefail` + `src/corun.sh` を source して実行）

### Phase 2: テスト実装

各ライブラリの実装前に BATS テストを作成（Red）→ 実装（Green）→ リファクタリング の順で進める。

**単体テスト対象**:

| ファイル | 主なテストケース |
|---|---|
| `flags_test.bats` | `--help` / `-h` / `--verbose` / `--version` / `-v` の認識、不明フラグで終了コード 3、重複フラグ last-wins |
| `exit_codes_test.bats` | 各定数の値確認（EXIT_OK=0, EXIT_ERROR=1, EXIT_CANCEL=2, EXIT_USAGE=3） |
| `io_test.bats` | `out()` が stdout のみ出力、`err()` が stderr のみ出力、`log_debug()` が verbose OFF 時に何も出力しない |
| `help_test.bats` | 出力に DESCRIPTION / USAGE / AVAILABLE COMMANDS / EXAMPLES / LEARN MORE が含まれる |
| `version_test.bats` | `corun version X.Y.Z` 形式、SemVer パターンマッチ |

**結合テスト対象** (コマンド単位でファイル分割):

| ファイル | 主なテストケース |
|---|---|
| `help_integration_test.bats` | `corun --help` → 終了コード 0、5セクション含む |
| `version_integration_test.bats` | `corun --version` → 終了コード 0、`corun version X.Y.Z` 形式 |
| `verbose_integration_test.bats` | `corun --verbose ...` → stderr に `timestamp=... level=DEBUG` を含む、verbose なしで stderr 空 |
| `exit_codes_integration_test.bats` | 正常: 0 / エラー: 1 / キャンセル: 2 / 不正フラグ: 3 |
| `pipe_integration_test.bats` | パイプで stdout のみ流れる、stdin クローズ済みで正常終了（0） |

### Phase 3: ビルドとCI

**Makefile ターゲット**:

```makefile
lint:   # shellcheck src/**/*.sh bin/corun
format: # shfmt -w src/**/*.sh bin/corun
test:   # bats tests/unit/
integration_test: # bats integration_tests/
build:  # chmod +x bin/corun, verify
clean:  # rm -rf dist/
```

**CI パイプライン** (`.github/workflows/ci.yml`):

```
push/PR → main, next, feature/**
  Step 1: actions/checkout@v3
  Step 2: install prerequisites (bash, shellcheck, shfmt, bats, make)
  Step 3: make lint
  Step 4: make test
  Step 5: make integration_test
  Step 6: make build
  Step 7: upload coverage report
```

## Complexity Tracking

Constitution Check で violations なし。複雑性の追加は不要。

## Risks & Mitigations

| リスク | 影響 | 緩和策 |
|---|---|---|
| bash バージョン差異 | 互換性問題 | シェバン `#!/usr/bin/env bash`、`bash 5.2+` を CI で強制 |
| stdin クローズ済み時のハング | テスト環境・CI でのハング | `read` にタイムアウトを設定、stdin 状態を事前チェック |
| 重複フラグ last-wins の誤実装 | テスト失敗 | BATS で `--verbose --verbose` / `-v --version` のシナリオを網羅 |
| ShellCheck 誤検知 | lint 失敗 | `# shellcheck disable=SC...` ディレクティブを最小限使用し理由をコメント記載 |
