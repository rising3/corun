#!/usr/bin/env bats
# integration_tests/version_integration_test.bats
#
# --version フラグの結合テスト
# bin/corun コマンドを実際に実行してバージョン出力を検証する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
CORUN="${REPO_ROOT}/bin/corun"

# ─── --version テスト ─────────────────────────────────────────────────────────

@test "corun --version は終了コード 0 で終了する" {
  run "$CORUN" --version
  [ "$status" -eq 0 ]
}

@test "corun --version は 'corun version X.Y.Z' 形式を stdout に出力する" {
  run "$CORUN" --version
  [[ "$output" =~ ^corun\ version\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "corun -v は終了コード 0 で終了する" {
  run "$CORUN" -v
  [ "$status" -eq 0 ]
}

@test "corun -v は 'corun version X.Y.Z' 形式を stdout に出力する" {
  run "$CORUN" -v
  [[ "$output" =~ ^corun\ version\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "corun --version は stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  "$CORUN" --version 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}
