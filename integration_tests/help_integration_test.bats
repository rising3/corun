#!/usr/bin/env bats
# integration_tests/help_integration_test.bats
#
# --help フラグの結合テスト
# bin/corun コマンドを実際に実行してヘルプ出力を検証する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
CORUN="${REPO_ROOT}/bin/corun"

# ─── corun --help テスト ──────────────────────────────────────────────────────

@test "corun --help は終了コード 0 で終了する" {
  run "$CORUN" --help
  [ "$status" -eq 0 ]
}

@test "corun --help の出力に DESCRIPTION セクションが含まれる" {
  run "$CORUN" --help
  echo "$output" | grep -qi 'DESCRIPTION'
}

@test "corun --help の出力に USAGE セクションが含まれる" {
  run "$CORUN" --help
  echo "$output" | grep -qi 'USAGE'
}

@test "corun --help の出力に AVAILABLE COMMANDS セクションが含まれる" {
  run "$CORUN" --help
  echo "$output" | grep -qi 'AVAILABLE COMMANDS'
}

@test "corun --help の出力に EXAMPLES セクションが含まれる" {
  run "$CORUN" --help
  echo "$output" | grep -qi 'EXAMPLES'
}

@test "corun --help の出力に LEARN MORE セクションが含まれる" {
  run "$CORUN" --help
  echo "$output" | grep -qi 'LEARN MORE'
}

@test "corun -h は終了コード 0 で終了する" {
  run "$CORUN" -h
  [ "$status" -eq 0 ]
}

@test "corun -h の出力に 5 セクション全てが含まれる" {
  run "$CORUN" -h
  echo "$output" | grep -qi 'DESCRIPTION'
  echo "$output" | grep -qi 'USAGE'
  echo "$output" | grep -qi 'AVAILABLE COMMANDS'
  echo "$output" | grep -qi 'EXAMPLES'
  echo "$output" | grep -qi 'LEARN MORE'
}

@test "corun --help は stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --help 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}
