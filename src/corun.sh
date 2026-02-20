#!/usr/bin/env bash
# src/corun.sh
#
# ルートコマンドディスパッチャ
# parse_flags() でグローバルフラグを解析し、各サブコマンドへ振り分ける

set -euo pipefail

# ─── 依存ライブラリのロード ───────────────────────────────────────────────────

_CORUN_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=src/lib/exit_codes.sh
source "${_CORUN_SRC_DIR}/lib/exit_codes.sh"
# shellcheck source=src/lib/io.sh
source "${_CORUN_SRC_DIR}/lib/io.sh"
# shellcheck source=src/lib/flags.sh
source "${_CORUN_SRC_DIR}/lib/flags.sh"
# shellcheck source=src/lib/version.sh
source "${_CORUN_SRC_DIR}/lib/version.sh"

# ─── シグナルハンドラー ───────────────────────────────────────────────────────

# SIGINT（Ctrl-C）をユーザーキャンセルとして扱う（EXIT_CANCEL=2）
trap 'exit "$EXIT_CANCEL"' INT

# ─── メイン処理 ───────────────────────────────────────────────────────────────

# フラグ解析
parse_flags "$@"

# detailed ロギング（--verbose 有効時に起動ログを出力）
log_debug "starting corun (args: ${CORUN_ARGS[*]:-<none>})"

# --version / -v
if [[ "${CORUN_VERSION:-0}" -eq 1 ]]; then
  print_version
  exit "$EXIT_OK"
fi

# --help / -h
if [[ "${CORUN_HELP:-0}" -eq 1 ]]; then
  # help.sh は Phase 6 (T022) で実装する
  # 現時点では基本的な使用方法を出力してエラーにしない
  printf 'Usage: corun [--help|-h] [--verbose] [--version|-v] [<subcommand>] [<args>]\n'
  exit "$EXIT_OK"
fi

# サブコマンドなし
if [[ ${#CORUN_ARGS[@]} -eq 0 ]]; then
  printf 'Usage: corun [--help|-h] [--verbose] [--version|-v] [<subcommand>] [<args>]\n'
  exit "$EXIT_OK"
fi

# サブコマンドへの振り分け（後続フェーズで実装）
die "Unknown subcommand: ${CORUN_ARGS[0]}" "$EXIT_ERROR"
