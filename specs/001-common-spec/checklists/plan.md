# Implementation Plan Checklist: corun 共通仕様

**Purpose**: 実装開始前に技術計画（plan.md）の品質・完全性・整合性を著者が自己検証する
**Created**: 2026-02-21
**Feature**: [../spec.md](../spec.md) | [../plan.md](../plan.md)

## Technical Context Quality

- [ ] CHK001 - 全依存ツールの最小バージョン制約は具体的に明記されているか？（"latest" などの曖昧表現がないか） [Completeness, Plan §Technical Context]
- [ ] CHK002 - bash バージョン制約（5.2+）は `copilot-instructions.md`（0.5.2+）と整合しているか？ [Consistency, Plan §Technical Context]
- [ ] CHK003 - パフォーマンス目標「起動時間 < 1秒」は spec の Success Criteria と矛盾しないか？ [Consistency, Plan §Technical Context]

## Constitution Compliance

- [ ] CHK004 - 10の憲章原則それぞれについて、この計画のスコープに対応した具体的な実装方針が記載されているか？ [Completeness, Plan §Constitution Check]
- [ ] CHK005 - 各 PASS 判定は「何をどう実施するか」の具体的な技術的措置で根拠付けられているか？（"PASS" の記載だけで終わっていないか） [Clarity, Plan §Constitution Check]

## Project Structure Completeness

- [ ] CHK006 - FR-001〜FR-011 のすべてが、提案されたファイル構成（`src/lib/*.sh`）内の少なくとも1つのファイルにトレースできるか？ [Traceability, Spec §FR-001〜011]
- [ ] CHK007 - 単体テストファイル 5本（`flags_test.bats` 等）は対応するライブラリファイル 5本（`flags.sh` 等）と 1:1 で対応しているか？ [Consistency, Plan §Project Structure]
- [ ] CHK008 - 結合テストファイル 5本はそれぞれ異なるコマンドレベルのシナリオを対象にして分割されているか（重複なし）？ [Completeness, Plan §Project Structure]
- [ ] CHK009 - `tasks.md` は「まだ作成されていない（`/speckit.tasks` コマンドで作成）」と明示されているか？ [Clarity, Plan §Documentation]

## Implementation Approach Quality

- [ ] CHK010 - 実装順序（exit_codes → io → flags → help → version → corun.sh → bin/corun）は依存関係の低い順（低依存が先）になっているか？ [Consistency, Plan §Phase 1]
- [ ] CHK011 - 各ライブラリモジュールについて「テスト作成（Red）→ 実装（Green）→ リファクタリング」のサイクルが明示されているか？ [Completeness, Plan §Phase 2]
- [ ] CHK012 - 外部依存（GitHub Copilot CLI 等）を単体テストから切り離すためのモック・スタブ戦略が定義されているか？ [Gap, Plan §Phase 2]

## Test Design Coverage

- [ ] CHK013 - `flags_test.bats` のテストケースは spec の User Story 1 の Acceptance Scenarios 4件（--help / --version / --verbose / 不明フラグ）をすべてカバーしているか？ [Coverage, Spec §US1]
- [ ] CHK014 - 終了コードのテストケースは FR-007 で定義した 4コード（0/1/2/3）をすべてカバーしているか？ [Coverage, Spec §FR-007]
- [ ] CHK015 - `io_test.bats` は「`--verbose` OFF 時に stderr が空」という SC-005 の期待値を明示的にカバーしているか？ [Coverage, Spec §SC-005]
- [ ] CHK016 - `--verbose` ログの期待パターン文字列（`timestamp=... level=DEBUG msg=...`）が BATS のマッチ文字列として具体的に特定されているか？ [Clarity, Plan §Phase 2]
- [ ] CHK017 - `pipe_integration_test.bats` は「stdin クローズ済みで正常終了（0）」のエッジケースをカバーしているか？ [Coverage, Spec §Edge Cases]
- [ ] CHK018 - `--version` と `--help` を同時指定した場合（`--help` 優先）のシナリオがいずれかのテストファイルでカバーされているか？ [Coverage, Spec §Edge Cases]

## CI & Build Requirements

- [ ] CHK019 - Makefile の全ターゲット（`lint`, `format`, `test`, `integration_test`, `build`, `clean`, `help`）が計画に定義されているか？ [Completeness, Plan §Phase 3]
- [ ] CHK020 - CI パイプラインに `make format`（Shfmt によるフォーマットチェック）が含まれているか？ [Gap, Plan §Phase 3]
- [ ] CHK021 - CI のトリガー条件（push/PR を `main`, `next`, `feature/**` に対して）は `copilot-instructions.md` の CI パイプライン定義と一致しているか？ [Consistency, Plan §Phase 3]

## Risk Coverage

- [ ] CHK022 - 特定されたリスク 4件はすべて具体的な緩和策とペアになっているか？ [Completeness, Plan §Risks]
- [ ] CHK023 - `set -euo pipefail` がパイプチェーン（SIGPIPE 等）を意図せず中断するリスクが計画に記載または考慮されているか？ [Gap, Plan §Risks]
