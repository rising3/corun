#!/usr/bin/env bats
# integration_tests/verbose_integration_test.bats
#
# --verbose フラグの結合テスト
# bin/corun コマンドを実際に実行してログ出力を検証する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
CORUN="${REPO_ROOT}/bin/corun"

# ─── --verbose あり テスト ────────────────────────────────────────────────────

@test "corun --verbose 付き実行時に stderr に timestamp= が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --verbose 2>"$stderr_file" || true
  grep -q 'timestamp=' "$stderr_file"
  rm -f "$stderr_file"
}

@test "corun --verbose 付き実行時に stderr に level=DEBUG が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --verbose 2>"$stderr_file" || true
  grep -q 'level=DEBUG' "$stderr_file"
  rm -f "$stderr_file"
}

@test "corun --verbose 付き実行時に stderr に msg= が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --verbose 2>"$stderr_file" || true
  grep -q 'msg=' "$stderr_file"
  rm -f "$stderr_file"
}

# ─── --verbose なし テスト ────────────────────────────────────────────────────

@test "corun --version 実行時 (--verbose なし) に stderr は空" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --version 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

@test "corun --help 実行時 (--verbose なし) に DEBUG ログが stderr に出力されない" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --help 2>"$stderr_file" || true
  ! grep -q 'level=DEBUG' "$stderr_file"
  rm -f "$stderr_file"
}
