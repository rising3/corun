#!/usr/bin/env bats
# tests/unit/io_test.bats
#
# io.sh の単体テスト
# TDD Red フェーズ: src/lib/io.sh が存在しない状態で実行すると全テスト失敗する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
LIB="${REPO_ROOT}/src/lib/io.sh"

# ─── out() テスト ──────────────────────────────────────────────────────────────

@test "out() は引数を stdout に出力する" {
  run bash -c "source '${LIB}'; out 'hello world'"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}

@test "out() は stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; out 'hello'" 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

@test "out() は空文字列を出力できる" {
  run bash -c "source '${LIB}'; out ''"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "out() は複数の単語を含む文字列をそのまま出力する" {
  run bash -c "source '${LIB}'; out 'foo bar baz'"
  [ "$output" = "foo bar baz" ]
}

# ─── err() テスト ──────────────────────────────────────────────────────────────

@test "err() はメッセージを stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; err 'error message'" 2>"$stderr_file"
  grep -q 'error message' "$stderr_file"
  rm -f "$stderr_file"
}

@test "err() は stdout に何も出力しない" {
  # run では stderr も $output に混入するため $() で stdout のみキャプチャする
  local stdout_content
  stdout_content=$(bash -c "source '${LIB}'; err 'error message'" 2>/dev/null)
  [ "$stdout_content" = "" ]
}

@test "err() は空文字列を stderr に出力できる" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; err ''" 2>"$stderr_file"
  [ -f "$stderr_file" ]
  rm -f "$stderr_file"
}

# ─── log_debug() テスト ────────────────────────────────────────────────────────

@test "log_debug() は CORUN_VERBOSE 未設定のとき stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "unset CORUN_VERBOSE; source '${LIB}'; log_debug 'debug msg'" 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

@test "log_debug() は CORUN_VERBOSE=0 のとき stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=0; source '${LIB}'; log_debug 'debug msg'" 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

@test "log_debug() は CORUN_VERBOSE=1 のとき stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'debug msg'" 2>"$stderr_file"
  grep -q 'debug msg' "$stderr_file"
  rm -f "$stderr_file"
}

@test "log_debug() の出力に timestamp= が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'check ts'" 2>"$stderr_file"
  grep -q 'timestamp=' "$stderr_file"
  rm -f "$stderr_file"
}

@test "log_debug() の出力に level=DEBUG が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'check level'" 2>"$stderr_file"
  grep -q 'level=DEBUG' "$stderr_file"
  rm -f "$stderr_file"
}

@test "log_debug() の出力に msg=<message> が含まれる" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'my message'" 2>"$stderr_file"
  grep -q 'msg=my message' "$stderr_file"
  rm -f "$stderr_file"
}

@test "log_debug() の出力が ISO8601 形式の timestamp を含む" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'format test'" 2>"$stderr_file"
  # ISO8601: YYYY-MM-DDTHH:MM:SS
  grep -qE 'timestamp=[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}' "$stderr_file"
  rm -f "$stderr_file"
}

@test "log_debug() は CORUN_VERBOSE=1 のとき stdout に何も出力しない" {
  # run では stderr も $output に混入するため $() で stdout のみキャプチャする
  local stdout_content
  stdout_content=$(bash -c "CORUN_VERBOSE=1; source '${LIB}'; log_debug 'stdout check'" 2>/dev/null)
  [ "$stdout_content" = "" ]
}
