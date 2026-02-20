#!/usr/bin/env bats
# tests/unit/help_test.bats
#
# help.sh の単体テスト
# TDD Red フェーズ: src/lib/help.sh が存在しない状態で実行すると全テスト失敗する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
LIB="${REPO_ROOT}/src/lib/help.sh"

# ─── 5 セクション存在確認 ─────────────────────────────────────────────────────

@test "print_help() の出力に DESCRIPTION セクションが含まれる" {
  run bash -c "source '${LIB}'; print_help"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi 'DESCRIPTION'
}

@test "print_help() の出力に USAGE セクションが含まれる" {
  run bash -c "source '${LIB}'; print_help"
  echo "$output" | grep -qi 'USAGE'
}

@test "print_help() の出力に AVAILABLE COMMANDS セクションが含まれる" {
  run bash -c "source '${LIB}'; print_help"
  echo "$output" | grep -qi 'AVAILABLE COMMANDS'
}

@test "print_help() の出力に EXAMPLES セクションが含まれる" {
  run bash -c "source '${LIB}'; print_help"
  echo "$output" | grep -qi 'EXAMPLES'
}

@test "print_help() の出力に LEARN MORE セクションが含まれる" {
  run bash -c "source '${LIB}'; print_help"
  echo "$output" | grep -qi 'LEARN MORE'
}

# ─── 出力先テスト ─────────────────────────────────────────────────────────────

@test "print_help() は stdout に出力する" {
  run bash -c "source '${LIB}'; print_help"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "print_help() は終了コード 0 で終了する" {
  run bash -c "source '${LIB}'; print_help"
  [ "$status" -eq 0 ]
}

@test "print_help() は stderr に何も出力しない" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "source '${LIB}'; print_help" 2>"$stderr_file"
  [ ! -s "$stderr_file" ]
  rm -f "$stderr_file"
}

# ─── セクション順序テスト ─────────────────────────────────────────────────────

@test "print_help() は DESCRIPTION が最初のセクションである" {
  run bash -c "source '${LIB}'; print_help"
  # DESCRIPTION が USAGE より前の行に出現するか
  local desc_line usage_line
  desc_line=$(echo "$output" | grep -ni 'DESCRIPTION' | head -1 | cut -d: -f1)
  usage_line=$(echo "$output" | grep -ni 'USAGE' | head -1 | cut -d: -f1)
  [ "${desc_line:-0}" -lt "${usage_line:-999}" ]
}

@test "print_help() の出力は 5 行以上ある" {
  output=$(bash -c "source '${LIB}'; print_help")
  line_count=$(echo "$output" | wc -l)
  [ "$line_count" -ge 5 ]
}
