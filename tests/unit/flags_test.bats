#!/usr/bin/env bats
# tests/unit/flags_test.bats
#
# flags.sh の単体テスト
# TDD Red フェーズ: src/lib/flags.sh が存在しない状態で実行すると全テスト失敗する

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
LIB="${REPO_ROOT}/src/lib/flags.sh"

# ─── ヘルパー ─────────────────────────────────────────────────────────────────

# flags.sh と依存ライブラリを source してフラグ変数を初期化するサブシェルコマンド
_parse() {
  bash -c "
    source '${REPO_ROOT}/src/lib/exit_codes.sh'
    source '${LIB}'
    parse_flags \"\$@\"
    echo \"HELP=\${CORUN_HELP:-0}\"
    echo \"VERBOSE=\${CORUN_VERBOSE:-0}\"
    echo \"VERSION=\${CORUN_VERSION:-0}\"
    echo \"ARGS=\${CORUN_ARGS[*]:-}\"
  " -- "$@"
}

# ─── --help / -h テスト ───────────────────────────────────────────────────────

@test "parse_flags(): --help は CORUN_HELP=1 をセットする" {
  output=$(_parse --help)
  grep -q 'HELP=1' <<<"$output"
}

@test "parse_flags(): -h は CORUN_HELP=1 をセットする" {
  output=$(_parse -h)
  grep -q 'HELP=1' <<<"$output"
}

@test "parse_flags(): --help 時に CORUN_VERBOSE はデフォルト 0 のまま" {
  output=$(_parse --help)
  grep -q 'VERBOSE=0' <<<"$output"
}

# ─── --verbose テスト ─────────────────────────────────────────────────────────

@test "parse_flags(): --verbose は CORUN_VERBOSE=1 をセットする" {
  output=$(_parse --verbose)
  grep -q 'VERBOSE=1' <<<"$output"
}

@test "parse_flags(): --verbose --verbose は CORUN_VERBOSE=1 のまま (last-wins)" {
  output=$(_parse --verbose --verbose)
  grep -q 'VERBOSE=1' <<<"$output"
}

@test "parse_flags(): --verbose なしのとき CORUN_VERBOSE=0" {
  output=$(_parse --help)
  grep -q 'VERBOSE=0' <<<"$output"
}

# ─── --version / -v テスト ───────────────────────────────────────────────────

@test "parse_flags(): --version は CORUN_VERSION=1 をセットする" {
  output=$(_parse --version)
  grep -q 'VERSION=1' <<<"$output"
}

@test "parse_flags(): -v は CORUN_VERSION=1 をセットする" {
  output=$(_parse -v)
  grep -q 'VERSION=1' <<<"$output"
}

# ─── 不明フラグ テスト ────────────────────────────────────────────────────────

@test "parse_flags(): 不明フラグは終了コード 3 で終了する" {
  run bash -c "
    source '${REPO_ROOT}/src/lib/exit_codes.sh'
    source '${LIB}'
    parse_flags --unknown-flag
  "
  [ "$status" -eq 3 ]
}

@test "parse_flags(): 不明フラグ時に使用方法ヒントを stderr に出力する" {
  local stderr_file
  stderr_file=$(mktemp)
  bash -c "
    source '${REPO_ROOT}/src/lib/exit_codes.sh'
    source '${LIB}'
    parse_flags --unknown-flag
  " 2>"$stderr_file" || true
  grep -qi 'usage\|使用\|unknown\|invalid\|unrecognized' "$stderr_file"
  rm -f "$stderr_file"
}

# ─── 優先度テスト ─────────────────────────────────────────────────────────────

@test "parse_flags(): --version と --help を同時指定すると CORUN_HELP=1 が優先" {
  output=$(_parse --version --help)
  grep -q 'HELP=1' <<<"$output"
  grep -q 'VERSION=1' <<<"$output"
}

# ─── 残余引数テスト ───────────────────────────────────────────────────────────

@test "parse_flags(): フラグ以外の引数はそのまま残る" {
  output=$(_parse --verbose run myfile.yaml)
  grep -q 'VERBOSE=1' <<<"$output"
  grep -q 'ARGS=run myfile.yaml' <<<"$output"
}

@test "parse_flags(): 引数なしでもエラーにならない" {
  run bash -c "
    source '${REPO_ROOT}/src/lib/exit_codes.sh'
    source '${LIB}'
    parse_flags
  "
  [ "$status" -eq 0 ]
}
