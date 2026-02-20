#!/usr/bin/env bash
# src/lib/flags.sh
#
# グローバルフラグ解析関数
# --help / --verbose / --version を解析し、対応する環境変数をセットする

# parse_flags() — コマンドライン引数を解析してグローバルフラグ変数をセットする
#
# 解析後にフラグ以外の引数は CORUN_ARGS 配列に格納される。
#
# セット対象変数:
#   CORUN_HELP    - --help または -h が指定されたとき 1
#   CORUN_VERBOSE - --verbose が指定されたとき 1 (last-wins: 複数指定でも 1)
#   CORUN_VERSION - --version または -v が指定されたとき 1
#   CORUN_ARGS    - フラグ以外の残余引数の配列
#
# エラー:
#   不明フラグが指定された場合、使用方法ヒントを stderr に出力して終了コード 3 で終了する
#
# 使用方法:
#   parse_flags "$@"
#   [[ "${CORUN_HELP:-0}" == "1" ]] && print_help && exit 0
#
# 例:
#   parse_flags --verbose run myfile.yaml
#   # → CORUN_VERBOSE=1, CORUN_ARGS=(run myfile.yaml)
parse_flags() {
  CORUN_HELP="${CORUN_HELP:-0}"
  CORUN_VERBOSE="${CORUN_VERBOSE:-0}"
  CORUN_VERSION="${CORUN_VERSION:-0}"
  CORUN_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help | -h)
        CORUN_HELP=1
        shift
        ;;
      --verbose)
        CORUN_VERBOSE=1
        shift
        ;;
      --version | -v)
        CORUN_VERSION=1
        shift
        ;;
      --*)
        # 未知のロングオプション
        printf 'ERROR: Unknown flag: %s\nUsage: corun [--help|-h] [--verbose] [--version|-v] [<args>]\n' "$1" >&2
        exit "${EXIT_USAGE:-3}"
        ;;
      *)
        # フラグ以外の引数
        CORUN_ARGS+=("$1")
        shift
        ;;
    esac
  done

  # --help が --version より優先される（両方指定時は CORUN_HELP=1 が有効のまま）
  # 変数は呼び出し元スコープで参照されることを前提とするため export はしない
  return 0
}
