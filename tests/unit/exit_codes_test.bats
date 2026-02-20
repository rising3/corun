#!/usr/bin/env bats
# tests/unit/exit_codes_test.bats
#
# exit_codes.sh の単体テスト
# TDD Red フェーズ: src/lib/exit_codes.sh が存在しない状態で実行すると全テスト失敗する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
LIB="${REPO_ROOT}/src/lib/exit_codes.sh"

# ─── 定数テスト ──────────────────────────────────────────────────────────────

@test "EXIT_OK は 0 である" {
  source "$LIB"
  [ "$EXIT_OK" -eq 0 ]
}

@test "EXIT_ERROR は 1 である" {
  source "$LIB"
  [ "$EXIT_ERROR" -eq 1 ]
}

@test "EXIT_CANCEL は 2 である" {
  source "$LIB"
  [ "$EXIT_CANCEL" -eq 2 ]
}

@test "EXIT_USAGE は 3 である" {
  source "$LIB"
  [ "$EXIT_USAGE" -eq 3 ]
}

# ─── die() テスト ──────────────────────────────────────────────────────────────

@test "die() はデフォルトで終了コード 1 (EXIT_ERROR) で終了する" {
  run bash -c "source '${LIB}'; die 'fatal error'"
  [ "$status" -eq 1 ]
}

@test "die() はメッセージを stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; die 'fatal error'" 2>"$stderr_file" || true
  grep -q 'fatal error' "$stderr_file"
  rm -f "$stderr_file"
}

@test "die() は第 2 引数で終了コードを指定できる" {
  run bash -c "source '${LIB}'; die 'usage error' 3"
  [ "$status" -eq 3 ]
}

@test "die() はデフォルトで stderr に ERROR プレフィックスを含む" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; die 'oops'" 2>"$stderr_file" || true
  grep -qi 'error\|ERROR' "$stderr_file"
  rm -f "$stderr_file"
}

# ─── exit_with() テスト ───────────────────────────────────────────────────────

@test "exit_with() は指定した終了コードで終了する (0)" {
  run bash -c "source '${LIB}'; exit_with 0"
  [ "$status" -eq 0 ]
}

@test "exit_with() は指定した終了コードで終了する (1)" {
  run bash -c "source '${LIB}'; exit_with 1"
  [ "$status" -eq 1 ]
}

@test "exit_with() は指定した終了コードで終了する (2)" {
  run bash -c "source '${LIB}'; exit_with 2"
  [ "$status" -eq 2 ]
}

@test "exit_with() は指定した終了コードで終了する (3)" {
  run bash -c "source '${LIB}'; exit_with 3"
  [ "$status" -eq 3 ]
}
