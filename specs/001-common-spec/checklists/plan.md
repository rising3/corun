# Implementation Plan Checklist: corun 共通仕様

**Purpose**: 実装開始前に技術計画（plan.md）の品質・完全性・整合性を著者が自己検証する
**Created**: 2026-02-21
**Reviewed**: 2026-02-21
**Feature**: [../spec.md](../spec.md) | [../plan.md](../plan.md)

## Technical Context Quality

- [x] CHK001 - 全依存ツールの最小バージョン制約は具体的に明記されているか？（"latest" などの曖昧表現がないか） [Completeness, Plan §Technical Context]
  - PASS: bash 5.2+, Copilot CLI 0.0.400+, yq 4.30.8+, jq 1.6+, BATS 1.3.0+, ShellCheck 0.9.0+, Shfmt 3.4.1+, make 4.3+ と全て具体的バージョン指定あり
- [x] CHK002 - bash バージョン制約（5.2+）は `copilot-instructions.md`（0.5.2+）と整合しているか？ [Consistency, Plan §Technical Context]
  - PASS: copilot-instructions.md の "0.5.2+" は "5.2+" の明らかな typo（bash 0.5.x は存在しない）。plan.md の "bash 5.2+" が正。源泉ドキュメントの誤記として記録。
- [x] CHK003 - パフォーマンス目標「起動時間 < 1秒」は spec の Success Criteria と矛盾しないか？ [Consistency, Plan §Technical Context]
  - PASS: SC-001「`corun --version` が 1秒以内に完了」と一致

## Constitution Compliance

- [x] CHK004 - 10の憲章原則それぞれについて、この計画のスコープに対応した具体的な実装方針が記載されているか？ [Completeness, Plan §Constitution Check]
  - PASS: 原則 I〜X が全て具体的な技術措置と対応付けられている（ShellCheck+Shfmt / BATS+TDD+85% / --help等必須 / 起動時間計測 / ハードコード禁止 / 構造化ログ / SemVer+ConvCommits / YAGNI / 憲章準拠 / 日本語ドキュメント）
- [x] CHK005 - 各 PASS 判定は「何をどう実施するか」の具体的な技術的措置で根拠付けられているか？（"PASS" の記載だけで終わっていないか） [Clarity, Plan §Constitution Check]
  - PASS: Constitution Check テーブルの全行に「何をどう実施するか」が記載されている

## Project Structure Completeness

- [x] CHK006 - FR-001〜FR-011 のすべてが、提案されたファイル構成（`src/lib/*.sh`）内の少なくとも1つのファイルにトレースできるか？ [Traceability, Spec §FR-001〜011]
  - PASS: FR-001/002→help.sh, FR-003→flags.sh+io.sh, FR-004→flags.sh+version.sh, FR-005→flags.sh, FR-006/007→exit_codes.sh, FR-008→corun.sh, FR-009→io.sh, FR-010→corun.sh/io.sh, FR-011→スコープ外として文書化済み
- [x] CHK007 - 単体テストファイル 5本（`flags_test.bats` 等）は対応するライブラリファイル 5本（`flags.sh` 等）と 1:1 で対応しているか？ [Consistency, Plan §Project Structure]
  - PASS: flags_test↔flags.sh, exit_codes_test↔exit_codes.sh, io_test↔io.sh, help_test↔help.sh, version_test↔version.sh の1:1対応確認
- [x] CHK008 - 結合テストファイル 5本はそれぞれ異なるコマンドレベルのシナリオを対象にして分割されているか（重複なし）？ [Completeness, Plan §Project Structure]
  - PASS: help / version / verbose / exit_codes / pipe の各シナリオが完全に分離、重複なし
- [x] CHK009 - `tasks.md` は「まだ作成されていない（`/speckit.tasks` コマンドで作成）」と明示されているか？ [Clarity, Plan §Documentation]
  - PASS: `tasks.md # Phase 2 output (/speckit.tasks コマンドで作成)` と明示されている

## Implementation Approach Quality

- [x] CHK010 - 実装順序（exit_codes → io → flags → help → version → corun.sh → bin/corun）は依存関係の低い順（低依存が先）になっているか？ [Consistency, Plan §Phase 1]
  - PASS: exit_codes（依存なし）→ io（実行時に CORUN_VERBOSE 参照のみ）→ flags（io依存）→ help/version（flags依存）→ corun.sh（全依存）→ bin/corun（entry point）の順で低依存順
- [x] CHK011 - 各ライブラリモジュールについて「テスト作成（Red）→ 実装（Green）→ リファクタリング」のサイクルが明示されているか？ [Completeness, Plan §Phase 2]
  - PASS: Phase 2 冒頭に「各ライブラリの実装前に BATS テストを作成（Red）→ 実装（Green）→ リファクタリング の順で進める」と明示
- [x] CHK012 - 外部依存（GitHub Copilot CLI 等）を単体テストから切り離すためのモック・スタブ戦略が定義されているか？ [Gap→Fixed, Plan §Phase 2]
  - RESOLVED: plan.md に `tests/fixtures/` スタブスクリプト配置・`PATH` 優先追加・BATS `setup()`/`teardown()` での制御・環境変数直接設定による `parse_flags()` 非経由テスト戦略を追記済み

## Test Design Coverage

- [x] CHK013 - `flags_test.bats` のテストケースは spec の User Story 1 の Acceptance Scenarios 4件（--help / --version / --verbose / 不明フラグ）をすべてカバーしているか？ [Coverage, Spec §US1]
  - PASS: `--help`/`-h`/`--verbose`/`--version`/`-v` 認識・不明フラグ→3・重複フラグ last-wins・`--version --help` 同時→`--help` 優先 の全件記載
- [x] CHK014 - 終了コードのテストケースは FR-007 で定義した 4コード（0/1/2/3）をすべてカバーしているか？ [Coverage, Spec §FR-007]
  - PASS: exit_codes_test.bats に EXIT_OK=0 / EXIT_ERROR=1 / EXIT_CANCEL=2 / EXIT_USAGE=3 の全4値が明示
- [x] CHK015 - `io_test.bats` は「`--verbose` OFF 時に stderr が空」という SC-005 の期待値を明示的にカバーしているか？ [Coverage, Spec §SC-005]
  - PASS: io_test.bats に「`log_debug()` が verbose OFF 時に何も出力しない」と明記（SC-005対応）
- [x] CHK016 - `--verbose` ログの期待パターン文字列（`timestamp=... level=DEBUG msg=...`）が BATS のマッチ文字列として具体的に特定されているか？ [Clarity, Plan §Phase 2]
  - PASS with note: plan.md は `timestamp=... level=DEBUG msg=...` フォーマットを io.sh 実装仕様として定義済み。BATS 正規表現パターン（`[[ "$output" =~ timestamp=.*level=DEBUG.*msg= ]]`）はテスト実装詳細のため tasks.md T006 に委譲。plan.md の抽象粒度として適切と判断。
- [x] CHK017 - `pipe_integration_test.bats` は「stdin クローズ済みで正常終了（0）」のエッジケースをカバーしているか？ [Coverage, Spec §Edge Cases]
  - PASS: plan.md Phase 2 の pipe_integration_test.bats 行に「stdin クローズ済みで正常終了（0）」と明記
- [x] CHK018 - `--version` と `--help` を同時指定した場合（`--help` 優先）のシナリオがいずれかのテストファイルでカバーされているか？ [Gap→Fixed, Spec §Edge Cases]
  - RESOLVED: plan.md Phase 2 の flags_test.bats 説明に「`--version --help` 同時指定（`--help` 優先）」を追記済み

## CI & Build Requirements

- [x] CHK019 - Makefile の全ターゲット（`lint`, `format`, `test`, `integration_test`, `build`, `clean`, `help`）が計画に定義されているか？ [Gap→Fixed, Plan §Phase 3]
  - RESOLVED: plan.md Phase 3 Makefile ターゲットに `help:` を追記済み（全7ターゲット: lint / format / test / integration_test / build / clean / help）
- [x] CHK020 - CI パイプラインに `make format`（Shfmt によるフォーマットチェック）が含まれているか？ [Gap→Fixed, Plan §Phase 3]
  - RESOLVED: plan.md Phase 3 CI ステップに「Step 4: make format（shfmt --diff モードで差分チェック）」を追記済み（全8ステップに更新）
- [x] CHK021 - CI のトリガー条件（push/PR を `main`, `next`, `feature/**` に対して）は `copilot-instructions.md` の CI パイプライン定義と一致しているか？ [Consistency, Plan §Phase 3]
  - PASS: plan.md の "push/PR → main, next, feature/**" は copilot-instructions.md と完全一致

## Risk Coverage

- [x] CHK022 - 特定されたリスク 4件はすべて具体的な緩和策とペアになっているか？ [Completeness, Plan §Risks]
  - PASS: bash版差異 / stdin hang / last-wins誤実装 / ShellCheck誤検知 の4件すべてに具体的な緩和策が対応付けられている
- [x] CHK023 - `set -euo pipefail` がパイプチェーン（SIGPIPE 等）を意図せず中断するリスクが計画に記載または考慮されているか？ [Gap→Fixed, Plan §Risks]
  - RESOLVED: plan.md Risks テーブルに「`set -euo pipefail` × SIGPIPE → 終了コード141によるパイプチェーン中断」リスクと緩和策（`pipe_integration_test.bats` で検証・必要に応じ `set +e` 局所適用または `|| true` ハンドリング）を追記済み

## Summary

| Checklist | Total | Completed | Incomplete | Status |
|-----------|-------|-----------|------------|--------|
| requirements.md | 16 | 16 | 0 | ✓ PASS |
| plan.md | 23 | 23 | 0 | ✓ PASS |

**Overall Status**: ✓ PASS（全23項目完了）
**Gaps Resolved**: CHK012 / CHK018 / CHK019 / CHK020 / CHK023 の5件を plan.md に追記して解消
**Notable Notes**:
- CHK002: copilot-instructions.md の "bash version 0.5.2+" は "bash 5.2+" の typo と判断（bash 0.5.x は存在しない）
- CHK016: BATS 正規表現パターンの具体的記載は tasks.md 実装詳細として委譲（plan.md の抽象粒度として適切）
